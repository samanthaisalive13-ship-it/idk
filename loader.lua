-- loader.lua
-- The Master Bootstrapper (Delta Executor Entry Point)
-- Dynamically downloads, standardizes, and executes the framework from GitHub

local repo_url = "https://raw.githubusercontent.com/samanthaisalive13-ship-it/idk/main/"

-- List of files to load in their exact logical execution order
local file_manifest = {
    -- 1. Static Databases First
    { path = "data/lobby_data.lua", global_key = "LobbyRaw", is_data = true },
    { path = "data/boons.lua", global_key = "BoonsRaw", is_data = true },
    
    -- 2. Sensory and Interpretive Layers
    { path = "modules/sanitizer.lua", global_key = "Sanitizer" },
    { path = "modules/parser.lua", global_key = "Parser" },
    
    -- 3. Decision and Execution Layers
    { path = "modules/solver.lua", global_key = "Solver" },
    { path = "modules/combat.lua", global_key = "Combat" },
    
    -- 4. Master State Controller Last
    { path = "main.lua", is_entry = true }
}

-- Safe downloader helper
local function download_script(filepath)
    local success, response = pcall(function()
        return game:HttpGet(repo_url .. filepath)
    end)
    
    if success and response then
        return response
    else
        warn("[Loader] Failed to download: " .. tostring(filepath))
        return nil
    end
end

-- Core compiler and initialization loop
local function execute_framework()
    print("[Loader] Initializing system boot sequence...")
    
    for _, file in ipairs(file_manifest) do
        local raw_code = download_script(file.path)
        if not raw_code then
            warn("[Loader] Boot aborted due to a download failure on " .. file.path)
            return
        end
        
        -- Compile raw code into an executable Luau chunk
        local chunk, err = loadstring(raw_code)
        if not chunk then
            warn("[Loader] Compilation error in " .. file.path .. ": " .. tostring(err))
            return
        end
        
        -- Run the chunk and safely capture returned modules
        local success, returned_module = pcall(chunk)
        if not success then
            warn("[Loader] Execution failure in " .. file.path .. ": " .. tostring(returned_module))
            return
        end
        
        -- Map modules into global scope to resolve dependencies across the sandbox
        if file.global_key then
            _G[file.global_key] = returned_module
            print("[Loader] Registered module: " .. file.global_key)
        end
        
        -- Standardize Global Databases to match solver/parser logic
        if file.global_key == "LobbyRaw" and returned_module then
            _G.SkillDatabase = returned_module.ClassConfigs
            _G.RaceDatabase = returned_module.Races
            print("[Loader] Standardized Skill & Race Databases successfully.")
        elseif file.global_key == "BoonsRaw" and returned_module then
            _G.BoonDatabase = returned_module.Data
            print("[Loader] Standardized Boon Database successfully.")
        end
        
        if file.is_entry then
            print("[Loader] Master loop engaged.")
        end
    end
    
    print("[Loader] Boot sequence completed. All modules are green.")
end

execute_framework()
