-- modules/combat.lua
-- The Action Executor (The "Hands" of the Bot)
-- Interface that safely fires server remotes with network throttling

local combat = {}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes", 5)
if not Remotes then
    warn("[Combat] Critical Error: Remotes folder not found in ReplicatedStorage.")
    return nil
end

-- Network Throttling Variables (Mutex Lock)
local is_busy = false
local last_action_time = 0
local ACTION_TIMEOUT = 1.5 -- Safety timeout (seconds) to prevent getting permanently stuck

-- Dynamic self-healing unlocker: listens to server replication states
LocalPlayer.AttributeChanged:Connect(function(attribute)
    if attribute == "Turn" and not LocalPlayer:GetAttribute("Turn") then
        is_busy = false -- Server confirmed our turn has ended, release lock
    elseif attribute == "Energy" or attribute == "HP" or attribute == "Gold" then
        is_busy = false -- Server processed our action and updated our stats, release lock
    end
end)

-- Safe remote check helper
local function get_remote(name, class)
    local remote = Remotes:FindFirstChild(name)
    if not remote or not remote:IsA(class) then
        warn("[Combat] Critical Error: Remote '" .. name .. "' of class '" .. class .. "' not found.")
        return nil
    end
    return remote
end

-- ==========================================
-- ENGINE MUTEX MUTATOR (THROTTLE SENSOR)
-- ==========================================

function combat.IsBusy()
    if is_busy then
        -- Safety check: If we've been locked longer than the timeout limit, force unlock
        if tick() - last_action_time > ACTION_TIMEOUT then
            print("[Combat] Action timeout expired. Forcing mutex release.")
            is_busy = false
        end
    end
    return is_busy
end

local function acquire_lock()
    is_busy = true
    last_action_time = tick()
end

-- ==========================================
-- COMBAT ACTION EXECUTORS
-- ==========================================

-- Executes an ability or item casting decision on a target
function combat.ExecuteDecision(decision, is_summon)
    if combat.IsBusy() then return false end
    if not decision or not decision.Target then return false end
    
    local turn_remote = get_remote("TurnDecision", "RemoteEvent")
    if not turn_remote then return false end
    
    acquire_lock()
    
    local success, err = pcall(function()
        if decision.Type == "Ability" then
            print("[Combat] Executing Ability: " .. tostring(decision.Name) .. " on target " .. tostring(decision.Target.Name))
            turn_remote:FireServer("Ability", decision.Target, decision.Name, is_summon)
        elseif decision.Type == "Item" and decision.ItemKey then
            print("[Combat] Executing Item: " .. tostring(decision.Name) .. " on target " .. tostring(decision.Target.Name))
            turn_remote:FireServer("Item", decision.Target, decision.ItemKey, is_summon)
        elseif decision.Type == "Focus" then
            print("[Combat] Executing Focus Action.")
            turn_remote:FireServer("Focus")
        end
    end)
    
    if not success then
        warn("[Combat] Failed to execute turn decision: " .. tostring(err))
        is_busy = false -- Release lock immediately on local execution errors
        return false
    end
    
    return true
end

-- Signals the server to end your active turn
function combat.EndTurn(is_summon)
    if combat.IsBusy() then return false end
    
    local end_turn_remote = get_remote("EndTurn", "RemoteEvent")
    if not end_turn_remote then return false end
    
    acquire_lock()
    print("[Combat] Ending Turn. Summon Turn: " .. tostring(is_summon))
    
    local success, err = pcall(function()
        end_turn_remote:FireServer(is_summon)
    end)
    
    if not success then
        warn("[Combat] Failed to end turn: " .. tostring(err))
        is_busy = false
        return false
    end
    
    return true
end

-- ==========================================
-- ENVIRONMENTAL & ENCOUNTER EXECUTORS
-- ==========================================

-- Casts a vote or choice in room encounters or dialogue trees
function combat.ChooseEncounterOption(option_name, is_client_dialogue)
    if combat.IsBusy() then return false end
    
    local voting_remote = get_remote("VotingEvent", "RemoteEvent")
    if not voting_remote then return false end
    
    acquire_lock()
    print("[Combat] Selecting Option: " .. tostring(option_name) .. " | Client dialogue: " .. tostring(is_client_dialogue))
    
    local success, err = pcall(function()
        if is_client_dialogue then
            -- Client-only dialogue choices (e.g. choices inside conversations)
            voting_remote:FireServer("SceneClient", option_name)
        else
            -- Group-voted dialogue or room paths (e.g., voting on "ShortRest")
            voting_remote:FireServer("Encounter", option_name)
        end
    end)
    
    if not success then
        warn("[Combat] Failed to select encounter option: " .. tostring(err))
        is_busy = false
        return false
    end
    
    return true
end

-- ==========================================
-- PROGRESSION & INVENTORY EXECUTORS
-- ==========================================

-- Directs stat investments
function combat.AllocateStats(stats_table)
    if combat.IsBusy() then return false end
    if type(stats_table) ~= "table" then return false end
    
    local invest_remote = get_remote("InvestStats", "RemoteEvent")
    if not invest_remote then return false end
    
    acquire_lock()
    print("[Combat] Registering stat investments...")
    
    local success, err = pcall(function()
        invest_remote:FireServer(stats_table)
    end)
    
    if not success then
        warn("[Combat] Failed to register stat investments: " .. tostring(err))
        is_busy = false
        return false
    end
    
    return true
end

-- Purchases skill-tree upgrades
function combat.BuyUpgrade(class_name, upgrade_name)
    if combat.IsBusy() then return false end
    
    local upgrade_remote = get_remote("Upgrade", "RemoteEvent")
    if not upgrade_remote then return false end
    
    acquire_lock()
    print("[Combat] Purchasing skill upgrade: " .. tostring(upgrade_name) .. " under Class " .. tostring(class_name))
    
    local success, err = pcall(function()
        upgrade_remote:FireServer(class_name, upgrade_name)
    end)
    
    if not success then
        warn("[Combat] Failed to purchase upgrade: " .. tostring(err))
        is_busy = false
        return false
    end
    
    return true
end

return combat
