-- Hive Store Initialization
-- This file loads the Hive Store addon and sets up the necessary components

print("[Hive Store] Loading Hive Store addon...")

-- Load configuration
include("hive_store/config.lua")

-- Load core modules
if SERVER then
    include("hive_store/server/sv_init.lua")
    include("hive_store/server/sv_database.lua")
    include("hive_store/server/sv_peakecoin.lua")
    include("hive_store/server/sv_commands.lua")
    include("hive_store/server/sv_networking.lua")
    include("hive_store/server/sv_npc_spawner.lua")
    
    -- Add client files for download
    AddCSLuaFile("hive_store/client/cl_init.lua")
    AddCSLuaFile("hive_store/client/cl_gui.lua")
    AddCSLuaFile("hive_store/client/cl_networking.lua")
    AddCSLuaFile("hive_store/client/cl_skin_generator.lua")
    AddCSLuaFile("hive_store/shared/sh_items.lua")
    AddCSLuaFile("hive_store/config.lua")
    
    -- Initialize NPCs
    timer.Simple(1, function()
        print("[Hive Store] NPCs available for spawning:")
        print("  - npc_hivestore_elder_brother (Jeb McCoy)")
        print("  - npc_hivestore_younger_brother (Cletus McCoy)")
        print("Console Commands:")
        print("  - hivestore_spawn_elder")
        print("  - hivestore_spawn_younger") 
        print("  - hivestore_spawn_both")
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

print("[Hive Store] Addon loaded successfully!")
