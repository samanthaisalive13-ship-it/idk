-- modules/parser.lua
-- Reads and standardizes the active game state in real-time

local parser = {}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Local Caches to maintain state regardless of place transitions
local inventory_cache = {}
local equipment_cache = {}
local cooldowns_cache = {}
local summon_cooldowns_cache = {}

-- Safe attribute reader
local function get_safe_attribute(instance, attribute, fallback)
    if not instance then return fallback end
    local success, val = pcall(function() return instance:GetAttribute(attribute) end)
    return success and val ~= nil and val or fallback
end

-- Hook into Network Remotes to dynamically build inventory and cooldown caches
local Remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes", 5)
if Remotes then
    -- Intercept Inventory Updates
    local inv_remote = Remotes:FindFirstChild("PlayerInventory")
    if inv_remote then
        inv_remote.OnClientEvent:Connect(function(action, data)
            if action == "Inventory" and data and data.Player then
                inventory_cache = data.Player.Inventory or {}
                equipment_cache = data.Player.Equipment or {}
            end
        end)
    end

    -- Intercept Cooldown Updates on Turn Starts
    local turn_remote = Remotes:FindFirstChild("FireTurn")
    if turn_remote then
        turn_remote.OnClientEvent:Connect(function(_, cooldowns, summon_cooldowns)
            cooldowns_cache = cooldowns or {}
            summon_cooldowns_cache = summon_cooldowns or {}
        end)
    end
end

-- Private helper to scan an instance's active status effects based on our sanitizer data
local function get_active_statuses(instance)
    local active = {}
    if not instance or not _G.EngineData or not _G.EngineData.Effects then 
        return active 
    end
    
    local success, attrs = pcall(function() return instance:GetAttributes() end)
    if success then
        for k, v in pairs(attrs) do
            if _G.EngineData.Effects[k] then
                active[k] = v -- Stores the duration/potency of the status effect
            end
        end
    end
    return active
end

-- 1. TURN STATE CHECK
function parser.IsMyTurn()
    return get_safe_attribute(LocalPlayer, "Turn", false)
end

-- 2. ACTIVE ENEMY SCANNER
function parser.GetEnemies()
    local enemy_folder = workspace:FindFirstChild("Enemies")
    local active_enemies = {}
    
    if enemy_folder then
        for _, model in ipairs(enemy_folder:GetChildren()) do
            if model:IsA("Model") and get_safe_attribute(model, "isAlive", false) then
                table.insert(active_enemies, {
                    Name = model.Name,
                    Instance = model,
                    HP = get_safe_attribute(model, "HP", 0),
                    MaxHP = get_safe_attribute(model, "MaxHP", 1),
                    Energy = get_safe_attribute(model, "Energy", 0),
                    MaxEnergy = get_safe_attribute(model, "MaxEnergy", 4),
                    Statuses = get_active_statuses(model)
                })
            end
        end
    end
    return active_enemies
end

-- 3. PLAYER COMBAT STATE SCANNER
function parser.GetPlayerState()
    local char = LocalPlayer.Character
    return {
        HP = get_safe_attribute(LocalPlayer, "HP", 0),
        MaxHP = get_safe_attribute(LocalPlayer, "MaxHP", 1),
        Energy = get_safe_attribute(LocalPlayer, "Energy", 0),
        MaxEnergy = get_safe_attribute(LocalPlayer, "MaxEnergy", 6),
        Level = get_safe_attribute(LocalPlayer, "Level", 1),
        Gold = get_safe_attribute(LocalPlayer, "Gold", 0),
        StatPoints = get_safe_attribute(LocalPlayer, "StatPoints", 0),
        Class = get_safe_attribute(LocalPlayer, "Class", "Warrior"),
        isAlive = get_safe_attribute(LocalPlayer, "isAlive", false),
        Statuses = get_active_statuses(LocalPlayer),
        CharStatuses = char and get_active_statuses(char) or {}
    }
end

-- 4. ACTIVE COMPANION SCANNER
function parser.GetSummons()
    local summon_folder = workspace:FindFirstChild("Summons")
    local active_summons = {}
    
    if summon_folder then
        for _, model in ipairs(summon_folder:GetChildren()) do
            if model:IsA("Model") and get_safe_attribute(model, "isAlive", false) then
                table.insert(active_summons, {
                    Name = model.Name,
                    Instance = model,
                    HP = get_safe_attribute(model, "HP", 0),
                    MaxHP = get_safe_attribute(model, "MaxHP", 1),
                    Energy = get_safe_attribute(model, "Energy", 0),
                    MaxEnergy = get_safe_attribute(model, "MaxEnergy", 4),
                    Statuses = get_active_statuses(model)
                })
            end
        end
    end
    return active_summons
end

-- 5. CACHED INVENTORY & EQUIPMENT ACCESSORS
function parser.GetInventory()
    return inventory_cache
end

function parser.GetEquipment()
    return equipment_cache
end

function parser.GetCooldowns(is_summon)
    return is_summon and summon_cooldowns_cache or cooldowns_cache
end

-- 6. ACTIVE AREA PATHFINDER
function parser.GetCurrentArea()
    local battlemap = workspace:FindFirstChild("Battlemap")
    if battlemap then
        local current_map = battlemap:FindFirstChildOfClass("Folder")
        if current_map then
            return current_map.Name -- Returns "Forest", "Dungeon", etc.
        end
    end
    return "Unknown"
end

-- 7. INTERFACE & WINDOW STATE READER
function parser.GetActiveUIState()
    local player_gui = LocalPlayer:FindFirstChild("PlayerGui")
    if not player_gui then 
        return { mode = "Hallway" } 
    end
    
    -- Check if combat interface is active
    local player_gui_folder = player_gui:FindFirstChild("PlayerGUI")
    if player_gui_folder and player_gui_folder.Enabled then
        if player_gui_folder:FindFirstChild("PlayerInfo") and player_gui_folder.PlayerInfo.Visible then
            return { mode = "Combat" }
        end
    end
    
    -- Check if encounter decision window is open
    local encounter_gui = player_gui:FindFirstChild("EncounterGUI")
    if encounter_gui and encounter_gui.Enabled then
        local frame = encounter_gui:FindFirstChild("EncounterFrame")
        if frame and frame.Visible and frame.Position.Y.Scale > 0 then
            return { mode = "Encounter", instance = frame }
        end
    end
    
    -- Check if resting/stash interface is open
    local rest_gui = player_gui:FindFirstChild("RestGUI")
    if rest_gui and rest_gui.Enabled then
        local frame = rest_gui:FindFirstChild("RestFrame")
        if frame and frame.Visible then
            return { mode = "Rest", instance = frame }
        end
    end
    
    -- Check if game over or win screen is open
    local game_over_gui = player_gui:FindFirstChild("GameOver")
    if game_over_gui and game_over_gui.Enabled then
        local frame = game_over_gui:FindFirstChild("Frame")
        if frame and frame.Visible then
            return { mode = "GameOver", result = frame.Title.Border.Title.Text }
        end
    end
    
    return { mode = "Hallway" } -- Walking or transitioning between rooms
end

return parser
