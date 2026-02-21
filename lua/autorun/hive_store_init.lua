-- Hive Store Initialization
-- This file loads the Hive Store addon and sets up the necessary components

print("[Hive Store] Loading Hive Store addon...")

-- Load configuration
include("hive_store/config.lua")

-- Load core modules
if SERVER then
    include("hive_store/server/sv_database.lua")
    include("hive_store/server/sv_peakecoin.lua")
    include("hive_store/server/sv_commands.lua")
    include("hive_store/server/sv_networking.lua")
    include("hive_store/server/sv_npc_spawner.lua")
    include("hive_store/server/sv_init.lua")
    
    -- Add client files for download
    AddCSLuaFile("hive_store/client/cl_init.lua")
    AddCSLuaFile("hive_store/client/cl_gui.lua")
    AddCSLuaFile("hive_store/client/cl_networking.lua")
    AddCSLuaFile("hive_store/client/cl_skin_generator.lua")
    AddCSLuaFile("hive_store/shared/sh_items.lua")
    AddCSLuaFile("hive_store/shared/sh_hive_keychain.lua")
    AddCSLuaFile("hive_store/config.lua")
    
    -- Initialize NPCs
    timer.Simple(1, function()
        print("[Hive Store] NPCs available for spawning:")
        print("  - npc_hivestore_elder_brother (E.R. Loona)")
        print("  - npc_hivestore_younger_brother (Nater Loona)")
        print("  - npc_hivestore_trading_post (Complete Trading Post)")
        print("Console Commands:")
        print("  - hivestore_spawn_elder")
        print("  - hivestore_spawn_younger") 
        print("  - hivestore_spawn_both")
        print("  - hivestore_spawn_trading_post (RECOMMENDED)")
        print("  - hivestore_remove_npcs")
    end)
end

if CLIENT then
    include("hive_store/client/cl_init.lua")
    include("hive_store/client/cl_gui.lua")
    include("hive_store/client/cl_networking.lua")
    include("hive_store/client/cl_skin_generator.lua")
end

-- Load shared files
include("hive_store/shared/sh_items.lua")
include("hive_store/shared/sh_hive_keychain.lua")

-- Initialize components
if SERVER then
    HiveStore.Server.Initialize()
end

if CLIENT then
    HiveStore.Client.Initialize()
end

print("[Hive Store] Addon loaded successfully!")
