-- main.lua
-- The Master Controller & State Machine Loop
-- Orchestrates all layers (Sensors, Decisions, and Network Executions)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Ensure the player character has loaded before starting
if not LocalPlayer:GetAttribute("isLoaded") then
    LocalPlayer:GetAttributeChangedSignal("isLoaded"):Wait()
end

print("[Master] Player successfully loaded. Initializing modules...")

-- 1. LOAD DEPENDENCIES (Assumes loader.lua has imported these into global scope)
local parser = _G.Parser or require(script.Parent.modules.parser)
local solver = _G.Solver or require(script.Parent.modules.solver)
local combat = _G.Combat or require(script.Parent.modules.combat)
local sanitizer = _G.Sanitizer or require(script.Parent.modules.sanitizer)

-- 2. RUN SANITIZER (Compile active place database once on entry)
local engine_data = sanitizer.Run()
if not engine_data then
    warn("[Master] Ingestion failed. Halting controller.")
    return
end

-- State variables to manage campsite investments and loop logic
local spent_stats_this_camp = false
local loop_interval = 0.5 -- Scans state every 500ms

-- Helper to determine if it is currently the companion's turn
local function check_summon_turn()
    local player_gui = LocalPlayer:FindFirstChild("PlayerGui")
    if player_gui and player_gui:FindFirstChild("PlayerGUI") then
        local summon_info = player_gui.PlayerGUI:FindFirstChild("SummonInfo")
        -- If SummonInfo is visible and positioned on screen, it is the summon's active turn
        if summon_info and summon_info.Visible and summon_info.Position.Y.Scale < 1 then
            return true
        end
    end
    return false
end

-- ==========================================
-- STATE CONTROLLER 1: COMBAT MACHINE
-- ==========================================
local function handle_combat_state()
    if not parser.IsMyTurn() or combat.IsBusy() then return end
    
    local is_summon_turn = check_summon_turn()
    local decision = solver.GetBestAction(is_summon_turn)
    
    if decision then
        -- Execute the optimal physical action
        combat.ExecuteDecision(decision, is_summon_turn)
    else
        -- If no legal moves are available or energy is depleted, pass turn
        combat.EndTurn(is_summon_turn)
    end
end

-- ==========================================
-- STATE CONTROLLER 2: ENCOUNTER DECISION VOTE
-- ==========================================
local function handle_encounter_state(ui_instance)
    if combat.IsBusy() then return end
    
    local player_state = parser.GetPlayerState()
    
    -- Ingest option labels directly from the active GUI frame
    local options = {}
    local option_frame = ui_instance:FindFirstChild("Background")
    if option_frame then
        for _, child in ipairs(option_frame:GetChildren()) do
            if child:IsA("ImageButton") and child.Visible and child:FindFirstChild("Title") then
                table.insert(options, child.Title.Text)
            end
        end
    end
    
    -- Priority 1: Survival Healing Node
    if table.find(options, "ShortRest") then
        local hp_ratio = player_state.HP / player_state.MaxHP
        local has_exhaustion = player_state.Statuses["Exhaustion"] ~= nil
        
        -- If critical health deficit or exhausted, vote to rest
        if hp_ratio <= 0.40 or has_exhaustion then
            combat.ChooseEncounterOption("ShortRest", false)
            return
        end
    end
    
    -- Priority 2: Ingest Resource Scavenging
    if table.find(options, "Scavenge") then
        combat.ChooseEncounterOption("Scavenge", false)
        return
    end
    
    -- Priority 3: Fallback to the first available valid progress path
    if #options > 0 then
        -- Avoid locked choice recursion by selecting the first safe valid index
        combat.ChooseEncounterOption(options[1], false)
    end
end

-- ==========================================
-- STATE CONTROLLER 3: CAMPSITE RESTING & INVESTMENT
-- ==========================================
local function handle_rest_state()
    if combat.IsBusy() then return end
    
    local player_state = parser.GetPlayerState()
    
    -- 1. Spend accumulated Stat Points using the Investment Planner
    if player_state.StatPoints > 0 and not spent_stats_this_camp then
        local target_investment = {}
        
        -- Default: invest evenly in main build stats depending on Class
        if player_state.Class == "Warrior" then
            local half = math.floor(player_state.StatPoints / 2)
            target_investment.STR = half
            target_investment.CON = player_state.StatPoints - half
        elseif player_state.Class == "Mage" then
            target_investment.INT = player_state.StatPoints
        elseif player_state.Class == "Rogue" then
            local half = math.floor(player_state.StatPoints / 2)
            target_investment.DEX = half
            target_investment.LCK = player_state.StatPoints - half
        else
            -- General fallback: equal spread across main offensive stat
            target_investment.DEX = player_state.StatPoints
        end
        
        combat.AllocateStats(target_investment)
        spent_stats_this_camp = true
        return
    end
    
    -- 2. Signal "Ready" to the server to continue map progression
    combat.ChooseEncounterOption("Rest", false)
end

-- ==========================================
-- STATE CONTROLLER 4: INFINITE REPLAY LOOP
-- ==========================================
local function handle_gameover_state()
    if combat.IsBusy() then return end
    
    -- Instantly signal the server to restart/replay the run
    local replay_remote = game.ReplicatedStorage.Remotes:FindFirstChild("ReplayEvent")
    if replay_remote then
        print("[Master] Dungeon Complete. Firing Replay Event.")
        replay_remote:FireServer()
        task.wait(1.5) -- Cool down to prevent teleport-packet drop
    end
end

-- ==========================================
-- MASTER EXECUTION THREAD
-- ==========================================
task.spawn(function()
    print("[Master] Core loop started successfully.")
    
    while true do
        local success, err = pcall(function()
            local ui_state = parser.GetActiveUIState()
            
            if ui_state.mode == "Combat" then
                spent_stats_this_camp = false -- Reset campsite status on battle start
                handle_combat_state()
            elseif ui_state.mode == "Encounter" then
                handle_encounter_state(ui_state.instance)
            elseif ui_state.mode == "Rest" then
                handle_rest_state()
            elseif ui_state.mode == "GameOver" then
                handle_gameover_state()
            end
        end)
        
        if not success then
            warn("[Master] Error encountered in active loop: " .. tostring(err))
        end
        
        task.wait(loop_interval) -- Safe yield to preserve CPU/Executor threads
    end
end)
