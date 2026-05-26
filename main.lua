-- main.lua
-- The Master Controller & State Machine Loop

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

if not LocalPlayer:GetAttribute("isLoaded") then
    LocalPlayer:GetAttributeChangedSignal("isLoaded"):Wait()
end

print("[Master] Player successfully loaded. Initializing modules...")

local parser = _G.Parser or require(script.Parent.modules.parser)
local solver = _G.Solver or require(script.Parent.modules.solver)
local combat = _G.Combat or require(script.Parent.modules.combat)
local sanitizer = _G.Sanitizer or require(script.Parent.modules.sanitizer)

local engine_data = sanitizer.Run()
if not engine_data then
    warn("[Master] Ingestion failed. Halting controller.")
    return
end

local spent_stats_this_camp = false
local gameover_detected_time = nil
local loop_interval = 0.5 -- Scans state every 500ms

local function check_summon_turn()
    local player_gui = LocalPlayer:FindFirstChild("PlayerGui")
    if player_gui and player_gui:FindFirstChild("PlayerGUI") then
        local summon_info = player_gui.PlayerGUI:FindFirstChild("SummonInfo")
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
        combat.ExecuteDecision(decision, is_summon_turn)
    else
        combat.EndTurn(is_summon_turn)
    end
end

-- ==========================================
-- STATE CONTROLLER 2: ENCOUNTER DECISION VOTE
-- ==========================================
local function handle_encounter_state(ui_instance)
    if combat.IsBusy() then return end
    
    local player_state = parser.GetPlayerState()
    local options = {}
    local option_frame = ui_instance:FindFirstChild("Background")
    
    if option_frame then
        for _, child in ipairs(option_frame:GetChildren()) do
            if child:IsA("ImageButton") and child.Visible and child:FindFirstChild("Title") then
                table.insert(options, child.Title.Text)
            end
        end
    end
    
    if table.find(options, "ShortRest") then
        local hp_ratio = player_state.HP / player_state.MaxHP
        local has_exhaustion = player_state.Statuses["Exhaustion"] ~= nil
        
        if hp_ratio <= 0.40 or has_exhaustion then
            combat.ChooseEncounterOption("ShortRest", false)
            return
        end
    end
    
    if table.find(options, "Scavenge") then
        combat.ChooseEncounterOption("Scavenge", false)
        return
    end
    
    if #options > 0 then
        combat.ChooseEncounterOption(options[1], false)
    end
end

-- ==========================================
-- STATE CONTROLLER 3: CAMPSITE RESTING & INVESTMENT
-- ==========================================
local function handle_rest_state()
    if combat.IsBusy() then return end
    
    local player_state = parser.GetPlayerState()
    
    if player_state.StatPoints > 0 and not spent_stats_this_camp then
        local target_investment = {}
        
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
            target_investment.DEX = player_state.StatPoints
        end
        
        combat.AllocateStats(target_investment)
        spent_stats_this_camp = true
        return
    end
    
    combat.ChooseEncounterOption("Rest", false)
end

-- ==========================================
-- STATE CONTROLLER 4: INFINITE REPLAY LOOP
-- ==========================================
local function handle_gameover_state()
    if combat.IsBusy() then return end
    
    if not gameover_detected_time then
        gameover_detected_time = tick()
        print("[Master] Game Over detected. Enforcing 2-second buffer...")
        return
    end

    if tick() - gameover_detected_time < 2.0 then
        return
    end

    local replay_remote = game.ReplicatedStorage.Remotes:FindFirstChild("ReplayEvent")
    if replay_remote then
        print("[Master] Firing Replay Event remote.")
        replay_remote:FireServer()
        task.wait(3.0) -- Prevents packet drops during stage transition
    end
end

-- ==========================================
-- MASTER EXECUTION THREAD
-- ==========================================
task.spawn(function()
    print("[Master] Core loop successfully started.")
    
    while true do
        local success, err = pcall(function()
            local ui_state = parser.GetActiveUIState()
            
            if ui_state.mode ~= "GameOver" then
                gameover_detected_time = nil -- Reset game-over timer outside state
            end
            
            if ui_state.mode == "Combat" then
                spent_stats_this_camp = false
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
            warn("[Master] Loop execution failure: " .. tostring(err))
        end
        
        task.wait(loop_interval)
    end
end)
