-- modules/solver.lua
-- The Cognitive Decision Engine (Utility-Based HEURISTIC Solver)
-- Fully dynamic: Ingests all metrics from ReplicatedStorage module scripts via Sanitizer

local solver = {}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local parser = _G.Parser or require(script.Parent.parser)
local boon_db = _G.BoonDatabase
local skill_db = _G.SkillDatabase

-- Virtual Health Tracking table to prevent overkill / coordinated target splitting
local virtual_hp_cache = {}

local function safe_get(tbl, key, fallback)
    if type(tbl) ~= "table" then return fallback end
    return tbl[key] ~= nil and tbl[key] or fallback
end

-- ==========================================
-- MATH ENGINE 1: DYNAMIC STATUS RESOLVER
-- ==========================================

-- Dynamically resolves active multipliers on a player or enemy using EngineData
local function get_status_multipliers(statuses)
    local multipliers = {
        damage_dealt = 1.0,
        damage_taken = 1.0,
        healing_dealt = 1.0,
        healing_received = 1.0,
        dodge_chance = 0.0,
        block_chance = 0.0,
        block_dr = 0.0
    }
    
    if not _G.EngineData or not _G.EngineData.Effects then return multipliers end
    
    for status_name, duration in pairs(statuses) do
        local effect_data = _G.EngineData.Effects[status_name]
        if effect_data then
            local raw_val = effect_data.damage_received_mult or 1.0
            local effect_type = effect_data.type or "Buff"
            
            -- Normalization: Convert raw values into true mathematical multipliers
            local normalized_val = raw_val
            if raw_val > 0 and raw_val < 1 then
                -- If a status has a value like 0.25 (Vulnerable) or 0.35 (Psyched), it means +25% or +35%
                normalized_val = 1 + raw_val
            end
            
            -- Dynamically apply to the correct calculation stream
            if effect_type == "Debuff" then
                -- Debuffs typically increase damage taken (e.g., Vulnerable, Fractured)
                multipliers.damage_taken = multipliers.damage_taken * normalized_val
            elseif effect_type == "Buff" then
                -- Check if the status is a defensive reduction buff (e.g. Way of Earth, Imbued)
                if status_name == "Way_of_Earth" or status_name == "Imbued" or status_name == "Rallied" then
                    -- These use direct raw decimals (like 0.85 for taking 85% damage)
                    multipliers.damage_taken = multipliers.damage_taken * raw_val
                else
                    -- Standard offensive buff (increases damage dealt)
                    multipliers.damage_dealt = multipliers.damage_dealt * normalized_val
                end
            end
            
            -- Dynamically apply stat-specific modifications if present in effect data
            if effect_data.dodge_modifier and effect_data.dodge_modifier ~= 0 then
                multipliers.dodge_chance = multipliers.dodge_chance + effect_data.dodge_modifier
            end
            if effect_data.block_modifier and effect_data.block_modifier ~= 0 then
                multipliers.block_chance = multipliers.block_chance + effect_data.block_modifier
            end
        end
    end
    
    return multipliers
end

-- ==========================================
-- MATH ENGINE 2: DAMAGE & HEAL CALCULATORS (INSTANT + DoT)
-- ==========================================

-- Calculates the damage-over-time (DoT) payload of an applied status effect
local function calculate_dot_expected_value(status_name, duration, target_max_hp, target_current_hp)
    local total_dot_damage = 0
    if not status_name or duration <= 0 then return 0 end
    
    for turn = 1, duration do
        if status_name == "Poison" then
            -- Poison formula: 1 + target_current_hp * 0.025 + active_poison_duration * 0.5
            total_dot_damage = total_dot_damage + (1 + (target_current_hp * 0.025) + (turn * 0.5))
        elseif status_name == "Voidblaze" then
            -- Voidblaze formula: target_max_hp * 0.025 + active_voidblaze_duration * 2.5
            total_dot_damage = total_dot_damage + ((target_max_hp * 0.025) + (turn * 2.5))
        elseif status_name == "Bleed" then
            -- Bleed base formula is 1.5 + active_bleed_duration
            total_dot_damage = total_dot_damage + (1.5 + turn)
        elseif status_name == "Burn" then
            -- Burn formula: 2.8 + 0.2 * active_burn_duration
            total_dot_damage = total_dot_damage + (2.8 + (0.2 * turn))
        elseif status_name == "Holy_Fire" then
            -- Holy Fire formula: 3.6 + 0.4 * active_holy_fire_duration
            total_dot_damage = total_dot_damage + (3.6 + (0.4 * turn))
        end
    end
    return total_dot_damage
end

-- Calculates the mathematical projected output of an ability
local function calculate_ability_potency(ability_name, player_state, target_data)
    local ability_data = safe_get(_G.EngineData.Abilities, ability_name)
    if not ability_data then return 0 end
    
    local base_damage = safe_get(ability_data, "base_damage", 0)
    local scaling = safe_get(ability_data, "scaling", {})
    local multihit = safe_get(ability_data, "multihit", 1)
    
    -- 1. Calculate Raw Base Damage + Stat Scaling
    local raw_output = base_damage
    local stats = {
        STR = player_state.Instance:GetAttribute("STR") or 10,
        DEX = player_state.Instance:GetAttribute("DEX") or 10,
        CON = player_state.Instance:GetAttribute("CON") or 10,
        INT = player_state.Instance:GetAttribute("INT") or 10,
        FTH = player_state.Instance:GetAttribute("FTH") or 10,
        CHA = player_state.Instance:GetAttribute("CHA") or 10,
        LCK = player_state.Instance:GetAttribute("LCK") or 10
    }
    
    for stat, multiplier in pairs(scaling) do
        raw_output = raw_output + ((stats[stat] or 0) * multiplier)
    end
    
    -- 2. Apply Multi-hit Scaling
    raw_output = raw_output * multihit
    
    -- 3. Ingest Status Multipliers (Player & Target)
    local player_mods = get_status_multipliers(player_state.Statuses)
    local target_mods = get_status_multipliers(target_data.Statuses)
    
    local final_potency = raw_output
    if ability_data.attack_type == "Healing" then
        final_potency = final_potency * player_mods.healing_dealt * target_mods.healing_received
    else
        final_potency = final_potency * player_mods.damage_dealt * target_mods.damage_taken
    end
    
    -- 4. Calculate Expected Value (EV) of Applied Status Effects (DoTs)
    local applied_effects = safe_get(ability_data, "effects_applied", {})
    for status, duration in pairs(applied_effects) do
        if status == "Poison" or status == "Voidblaze" or status == "Bleed" or status == "Burn" or status == "Holy_Fire" then
            local expected_dot = calculate_dot_expected_value(status, duration, target_data.MaxHP, target_data.HP)
            final_potency = final_potency + expected_dot
        end
    end
    
    -- 5. Calculate Setup Value (Future EV Projection for Buffs)
    if ability_data.attack_type == "Status" and applied_effects["Psyched"] then
        local avg_damage_per_turn = player_state.Level * 10
        local expected_increase = (avg_damage_per_turn * 1.35) - avg_damage_per_turn
        local setup_value = applied_effects["Psyched"] * expected_increase
        final_potency = final_potency + setup_value
    end
    
    return final_potency
end

-- ==========================================
-- MATH ENGINE 3: THREAT ANALYSIS & TARGET VALUE
-- ==========================================

-- Evaluates the "Kill Urgency" and threat priority of an enemy target
local function evaluate_target_priority(target_data)
    local base_threat = 100
    
    local name = target_data.Name
    if string.match(name, "Mage") or string.match(name, "Scientist") or string.match(name, "Warder") then
        base_threat = 175
    elseif string.match(name, "Knight") or string.match(name, "Hulk") then
        base_threat = 130
    end
    
    -- Calculate target's real-time physical HP (factoring in our virtual actions)
    local active_hp = virtual_hp_cache[target_data.Instance] or target_data.HP
    
    if active_hp <= 0 then return 0 end
    
    return base_threat / active_hp
end

-- ==========================================
-- THE SOLVER MASTER CONTROLLER
-- ==========================================

function solver.GetBestAction(is_summon)
    if not _G.EngineData then
        warn("[Solver] Error: EngineData is empty. Sanitizer must be executed first.")
        return nil
    end

    local player_state = parser.GetPlayerState()
    local enemies = parser.GetEnemies()
    local ui_state = parser.GetActiveUIState()
    
    if not parser.IsMyTurn() or ui_state.mode ~= "Combat" then
        return nil
    end
    
    table.clear(virtual_hp_cache)
    
    local best_action = nil
    local best_target = nil
    local highest_utility = -math.huge
    
    local my_cooldowns = parser.GetCooldowns(is_summon)
    local my_energy = is_summon and 4 or player_state.Energy
    
    local active_class_configs = _G.SkillDatabase
    local available_abilities = {}
    
    if is_summon then
        local summons = parser.GetSummons()
        if #summons > 0 then
            available_abilities = safe_get(_G.EngineData.Enemies[summons[1].Name], "abilities", {})
        end
    else
        local base_class = player_state.Class
        local config = active_class_configs and active_class_configs[base_class]
        if config then
            for _, skill in pairs(config.skills) do
                table.insert(available_abilities, skill.name)
            end
        else
            available_abilities = { "Strike", "Guard", "Focus" }
        end
    end
    
    for _, ability_name in ipairs(available_abilities) do
        local ability_data = safe_get(_G.EngineData.Abilities, ability_name)
        
        if ability_data then
            local cost = safe_get(ability_data, "energy_cost", 0)
            if cost == "X" then cost = my_energy end
            
            local cooldown_active = my_cooldowns[ability_name] and my_cooldowns[ability_name] > 0
            local has_enough_energy = cost <= my_energy
            
            if not cooldown_active and has_enough_energy then
                for _, enemy in ipairs(enemies) do
                    local utility = 0
                    local expected_output = calculate_ability_potency(ability_name, player_state, enemy)
                    local target_priority = evaluate_target_priority(enemy)
                    
                    if ability_data.attack_type == "Healing" then
                        local hp_deficit = 1 - (player_state.HP / player_state.MaxHP)
                        local healing_urgency = math.exp(3 * hp_deficit) - 1
                        utility = expected_output * healing_urgency
                    else
                        utility = expected_output * target_priority
                    end
                    
                    local energy_efficiency_factor = 1 - (cost / 6)
                    utility = utility + (energy_efficiency_factor * 10)
                    
                    if is_summon and _G.PlayerFocusTarget == enemy.Instance then
                        utility = utility * 1.5
                    end
                    
                    if utility > highest_utility then
                        highest_utility = utility
                        best_action = {
                            Type = "Ability",
                            Name = ability_name,
                            Target = enemy.Instance,
                            PredictedOutput = expected_output
                        }
                    end
                end
            end
        end
    end
    
    if not is_summon then
        local inventory = parser.GetInventory()
        for _, item_data in pairs(inventory) do
            local item_config = safe_get(_G.EngineData.Items, item_data.Name)
            
            if item_config and item_config.slot == "Consumable" then
                local utility = 0
                local expected_heal = safe_get(safe_get(item_config, "abilities", {}), "Heal", 0)
                
                local hp_deficit = 1 - (player_state.HP / player_state.MaxHP)
                local healing_urgency = math.exp(3 * hp_deficit) - 1
                utility = expected_heal * healing_urgency
                
                local area_name = parser.GetCurrentArea()
                local is_boss_room = string.match(area_name, "Boss") or string.match(area_name, "Gate")
                
                if not is_boss_room then
                    local scarcity_penalty = (10 / item_data.Amount) * 20
                    utility = utility - scarcity_penalty
                end
                
                if utility > highest_utility then
                    highest_utility = utility
                    best_action = {
                        Type = "Item",
                        Name = item_data.Name,
                        Target = LocalPlayer.Character,
                        ItemKey = item_data.Name
                    }
                end
            end
        end
    end
    
    if not is_summon and best_action then
        _G.PlayerFocusTarget = best_action.Target
        virtual_hp_cache[best_action.Target] = (virtual_hp_cache[best_action.Target] or best_action.Target:GetAttribute("HP") or 0) - (best_action.PredictedOutput or 0)
    end
    
    return best_action
end

return solver
