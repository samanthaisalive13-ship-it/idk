-- modules/sanitizer.lua
-- Sanitizes and standardizes active in-game ModuleScripts at runtime

local sanitizer = {}

-- Global table where sanitized data will be stored for solver access
_G.EngineData = _G.EngineData or {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Dictionaries = ReplicatedStorage:WaitForChild("Dictionaries", 5)

if not Dictionaries then
    warn("[Sanitizer] Critical Error: 'Dictionaries' folder not found in ReplicatedStorage.")
    return nil
end

-- Helper to safely index a table
local function safe_index(tbl, key)
    if type(tbl) ~= "table" then return nil end
    local success, result = pcall(function() return tbl[key] end)
    return success and result or nil
end

-- Deep copy helper that strips functions and visual assets
local function clean_copy_table(original)
    if type(original) ~= "table" then return original end
    local copy = {}
    for k, v in pairs(original) do
        local val_type = type(v)
        -- Strip out asset IDs (images, meshes, sounds) and animations
        local is_asset_string = val_type == "string" and (string.match(v, "rbxassetid://") or string.match(v, "Anim"))
        
        if val_type ~= "function" and not is_asset_string then
            if val_type == "table" then
                copy[k] = clean_copy_table(v)
            else
                copy[k] = v
            end
        end
    end
    return copy
end

-- 1. SANITIZE ENEMIES
local function sanitize_enemies()
    local raw_module = Dictionaries:FindFirstChild("Enemies")
    if not raw_module then return end
    
    local success, raw_data = pcall(require, raw_module)
    if not success or type(raw_data) ~= "table" then return end
    
    local clean_enemies = {}
    for enemy_name, data in pairs(raw_data) do
        clean_enemies[enemy_name] = {
            hp_min = safe_index(data, "MinHealth") or 0,
            hp_max = safe_index(data, "MaxHealth") or 0,
            energy_max = safe_index(data, "MaxEnergy") or 4,
            block_chance = safe_index(data, "BlockChance") or 0,
            dodge_chance = safe_index(data, "DodgeChance") or 0,
            crit_chance = safe_index(data, "CritChance") or 0,
            crit_damage = safe_index(data, "CritDamage") or 1.0,
            initiative = safe_index(data, "Initiative") or 0,
            abilities = clean_copy_table(safe_index(data, "Abilities")) or {},
            drops = clean_copy_table(safe_index(data, "Drops")) or {},
            modifiers = clean_copy_table(safe_index(data, "Modifiers")) or {}
        }
    end
    _G.EngineData.Enemies = clean_enemies
end

-- 2. SANITIZE ITEMS (Weapons, Armor, Consumables)
local function sanitize_items()
    local raw_module = Dictionaries:FindFirstChild("Items")
    if not raw_module then return end
    
    local success, raw_data = pcall(require, raw_module)
    if not success or type(raw_data) ~= "table" then return end
    
    local clean_items = {}
    for item_name, data in pairs(raw_data) do
        clean_items[item_name] = {
            slot = safe_index(data, "Slot") or "Material",
            cost = safe_index(data, "Cost") or 0,
            stats = clean_copy_table(safe_index(data, "Stats")) or {},
            recipe = clean_copy_table(safe_index(data, "Recipe")) or {},
            weapon_type = safe_index(data, "WeaponType"),
            abilities = clean_copy_table(safe_index(data, "Abilities")) or {}
        }
    end
    _G.EngineData.Items = clean_items
end

-- 3. SANITIZE EFFECTS (Statuses, Buffs, Debuffs)
local function sanitize_effects()
    local raw_module = Dictionaries:FindFirstChild("Effects")
    if not raw_module then return end
    
    local success, raw_data = pcall(require, raw_module)
    if not success or type(raw_data) ~= "table" then return end
    
    local clean_effects = {}
    for effect_name, data in pairs(raw_data) do
        clean_effects[effect_name] = {
            type = safe_index(data, "Type") or "Buff",
            trigger = safe_index(data, "Trigger") or "Start",
            dodge_modifier = safe_index(data, "DodgeChance") or safe_index(data, "Dodge") or 0,
            block_modifier = safe_index(data, "BlockChance") or safe_index(data, "BlockValue") or 0,
            damage_received_mult = safe_index(data, "Value") or safe_index(data, "DefenseValue") or safe_index(data, "DamageValue") or 1.0,
            damage_type = safe_index(data, "DamageType")
        }
        
        -- Safely extract formula behavior without saving active closures
        local formula = safe_index(data, "Formula")
        if type(formula) == "function" then
            clean_effects[effect_name].has_dynamic_formula = true
        end
    end
    _G.EngineData.Effects = clean_effects
end

-- 4. SANITIZE ABILITIES
local function sanitize_abilities()
    local raw_module = Dictionaries:FindFirstChild("Abilities")
    if not raw_module then return end
    
    local success, raw_data = pcall(require, raw_module)
    if not success or type(raw_data) ~= "table" then return end
    
    local clean_abilities = {}
    for ability_name, data in pairs(raw_data) do
        clean_abilities[ability_name] = {
            attack_type = safe_index(data, "AttackType") or "Physical",
            damage_type = safe_index(data, "DamageType") or "Physical",
            target_type = safe_index(data, "TargetType") or "SingleEnemy",
            base_damage = safe_index(data, "Damage") or 0,
            energy_cost = safe_index(data, "Cost") or 0,
            cooldown = safe_index(data, "Cooldown") or 0,
            multihit = safe_index(data, "Multihit") or 1,
            unblockable = safe_index(data, "Unblockable") or false,
            undodgeable = safe_index(data, "Undodgeable") or false,
            effects_applied = clean_copy_table(safe_index(data, "Effects")) or {},
            scaling = clean_copy_table(safe_index(data, "Scaling")) or {}
        }
    end
    _G.EngineData.Abilities = clean_abilities
end

-- 5. SANITIZE ENCOUNTERS
local function sanitize_encounters()
    local raw_module = Dictionaries:FindFirstChild("Encounters")
    if not raw_module then return end
    
    local success, raw_data = pcall(require, raw_module)
    if not success or type(raw_data) ~= "table" then return end
    
    local clean_encounters = {}
    for encounter_name, data in pairs(raw_data) do
        local options = safe_index(data, "Options") or {}
        local clean_options = {}
        
        for option_name, option_data in pairs(options) do
            clean_options[option_name] = {
                requirements = clean_copy_table(safe_index(option_data, "Conditions")) or {}
            }
        end
        
        clean_encounters[encounter_name] = {
            options = clean_options
        }
    end
    _G.EngineData.Encounters = clean_encounters
end

-- 6. SANITIZE MAP MODIFIERS
local function sanitize_modifiers()
    local raw_module = Dictionaries:FindFirstChild("GameModifiers")
    if not raw_module then return end
    
    local success, raw_data = pcall(require, raw_module)
    if not success or type(raw_data) ~= "table" then return end
    
    _G.EngineData.GameModifiers = clean_copy_table(raw_data)
end

-- Main execution sequence
function sanitizer.Run()
    local success, err = pcall(function()
        sanitize_enemies()
        sanitize_items()
        sanitize_effects()
        sanitize_abilities()
        sanitize_encounters()
        sanitize_modifiers()
    end)
    
    if success then
        print("[Sanitizer] In-game database compiled and standardized successfully.")
        return _G.EngineData
    else
        warn("[Sanitizer] Critical failure during dynamic ingestion: " .. tostring(err))
        return nil
    end
end

return sanitizer
