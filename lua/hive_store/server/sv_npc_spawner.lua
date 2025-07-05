-- HiveStore NPC Spawn Configuration
-- Admin commands for spawning and managing the McCoy Brothers

HiveStore = HiveStore or {}
HiveStore.NPCSpawner = {}

-- NPC spawn locations (can be customized per map)
HiveStore.NPCSpawner.SpawnLocations = {
    elder_brother = {
        pos = Vector(0, 0, 0), -- Will be set by admin
        ang = Angle(0, 0, 0),
        spawned = false,
        entity = nil
    },
    younger_brother = {
        pos = Vector(100, 0, 0), -- Will be set by admin
        ang = Angle(0, 180, 0),
        spawned = false,
        entity = nil
    }
}

-- Initialize NPC spawner
function HiveStore.NPCSpawner.Initialize()
    print("[Hive Store] NPC Spawner initialized!")
    
    -- Register console commands
    concommand.Add("hivestore_spawn_elder", function(ply, cmd, args)
        if not HiveStore.Server.IsPlayerAdmin(ply) then
            ply:ChatPrint("You must be an admin to use this command!")
            return
        end
        
        HiveStore.NPCSpawner.SpawnElderBrother(ply)
    end)
    
    concommand.Add("hivestore_spawn_younger", function(ply, cmd, args)
        if not HiveStore.Server.IsPlayerAdmin(ply) then
            ply:ChatPrint("You must be an admin to use this command!")
            return
        end
        
        HiveStore.NPCSpawner.SpawnYoungerBrother(ply)
    end)
    
    concommand.Add("hivestore_spawn_both", function(ply, cmd, args)
        if not HiveStore.Server.IsPlayerAdmin(ply) then
            ply:ChatPrint("You must be an admin to use this command!")
            return
        end
        
        HiveStore.NPCSpawner.SpawnBothBrothers(ply)
    end)
    
    concommand.Add("hivestore_remove_npcs", function(ply, cmd, args)
        if not HiveStore.Server.IsPlayerAdmin(ply) then
            ply:ChatPrint("You must be an admin to use this command!")
            return
        end
        
        HiveStore.NPCSpawner.RemoveAllNPCs(ply)
    end)
end

-- Spawn Elder Brother NPC
function HiveStore.NPCSpawner.SpawnElderBrother(ply)
    if HiveStore.NPCSpawner.SpawnLocations.elder_brother.spawned then
        ply:ChatPrint("[Hive Store] Elder Brother is already spawned!")
        return
    end
    
    local pos = ply:GetPos() + ply:GetForward() * 100
    local ang = ply:GetAngles()
    ang.p = 0
    ang.r = 0
    ang.y = ang.y + 180
    
    local npc = ents.Create("npc_hivestore_elder_brother")
    if IsValid(npc) then
        npc:SetPos(pos)
        npc:SetAngles(ang)
        npc:Spawn()
        npc:Activate()
        
        -- Store reference
        HiveStore.NPCSpawner.SpawnLocations.elder_brother.entity = npc
        HiveStore.NPCSpawner.SpawnLocations.elder_brother.spawned = true
        HiveStore.NPCSpawner.SpawnLocations.elder_brother.pos = pos
        HiveStore.NPCSpawner.SpawnLocations.elder_brother.ang = ang
        
        ply:ChatPrint("[Hive Store] Elder Brother (Jeb McCoy) spawned successfully!")
        
        -- Apply custom appearance
        timer.Simple(0.5, function()
            if IsValid(npc) then
                npc:ApplyHillbillyAppearance()
            end
        end)
    else
        ply:ChatPrint("[Hive Store] Failed to spawn Elder Brother!")
    end
end

-- Spawn Younger Brother NPC
function HiveStore.NPCSpawner.SpawnYoungerBrother(ply)
    if HiveStore.NPCSpawner.SpawnLocations.younger_brother.spawned then
        ply:ChatPrint("[Hive Store] Younger Brother is already spawned!")
        return
    end
    
    local pos = ply:GetPos() + ply:GetForward() * 100 + ply:GetRight() * 50
    local ang = ply:GetAngles()
    ang.p = 0
    ang.r = 0
    ang.y = ang.y + 180
    
    local npc = ents.Create("npc_hivestore_younger_brother")
    if IsValid(npc) then
        npc:SetPos(pos)
        npc:SetAngles(ang)
        npc:Spawn()
        npc:Activate()
        
        -- Store reference
        HiveStore.NPCSpawner.SpawnLocations.younger_brother.entity = npc
        HiveStore.NPCSpawner.SpawnLocations.younger_brother.spawned = true
        HiveStore.NPCSpawner.SpawnLocations.younger_brother.pos = pos
        HiveStore.NPCSpawner.SpawnLocations.younger_brother.ang = ang
        
        ply:ChatPrint("[Hive Store] Younger Brother (Cletus McCoy) spawned successfully!")
        
        -- Apply custom appearance
        timer.Simple(0.5, function()
            if IsValid(npc) then
                npc:ApplyHillbillyAppearance()
            end
        end)
    else
        ply:ChatPrint("[Hive Store] Failed to spawn Younger Brother!")
    end
end

-- Spawn both brothers
function HiveStore.NPCSpawner.SpawnBothBrothers(ply)
    HiveStore.NPCSpawner.SpawnElderBrother(ply)
    
    timer.Simple(1, function()
        HiveStore.NPCSpawner.SpawnYoungerBrother(ply)
        ply:ChatPrint("[Hive Store] McCoy Brothers Trading Post is now open for business!")
    end)
end

-- Remove all NPCs
function HiveStore.NPCSpawner.RemoveAllNPCs(ply)
    local removed = 0
    
    if HiveStore.NPCSpawner.SpawnLocations.elder_brother.spawned then
        local npc = HiveStore.NPCSpawner.SpawnLocations.elder_brother.entity
        if IsValid(npc) then
            npc:Remove()
            removed = removed + 1
        end
        HiveStore.NPCSpawner.SpawnLocations.elder_brother.spawned = false
        HiveStore.NPCSpawner.SpawnLocations.elder_brother.entity = nil
    end
    
    if HiveStore.NPCSpawner.SpawnLocations.younger_brother.spawned then
        local npc = HiveStore.NPCSpawner.SpawnLocations.younger_brother.entity
        if IsValid(npc) then
            npc:Remove()
            removed = removed + 1
        end
        HiveStore.NPCSpawner.SpawnLocations.younger_brother.spawned = false
        HiveStore.NPCSpawner.SpawnLocations.younger_brother.entity = nil
    end
    
    ply:ChatPrint("[Hive Store] Removed " .. removed .. " NPCs")
end

-- Clean up on entity removal
hook.Add("EntityRemoved", "HiveStore.NPCCleanup", function(ent)
    if ent:GetClass() == "npc_hivestore_elder_brother" then
        HiveStore.NPCSpawner.SpawnLocations.elder_brother.spawned = false
        HiveStore.NPCSpawner.SpawnLocations.elder_brother.entity = nil
    elseif ent:GetClass() == "npc_hivestore_younger_brother" then
        HiveStore.NPCSpawner.SpawnLocations.younger_brother.spawned = false
        HiveStore.NPCSpawner.SpawnLocations.younger_brother.entity = nil
    end
end)

-- Auto-spawn on map load (optional)
hook.Add("InitPostEntity", "HiveStore.AutoSpawn", function()
    timer.Simple(5, function()
        -- Auto-spawn can be enabled in config
        if HiveStore.Config and HiveStore.Config.AutoSpawnNPCs then
            local spawnPos = Vector(0, 0, 0) -- Set appropriate spawn position
            
            -- This would need to be customized per map
            -- For now, we'll just notify admins
            PrintMessage(HUD_PRINTTALK, "[Hive Store] Use console commands to spawn NPCs:")
            PrintMessage(HUD_PRINTTALK, "  hivestore_spawn_elder - Spawn Elder Brother")
            PrintMessage(HUD_PRINTTALK, "  hivestore_spawn_younger - Spawn Younger Brother")
            PrintMessage(HUD_PRINTTALK, "  hivestore_spawn_both - Spawn Both Brothers")
            PrintMessage(HUD_PRINTTALK, "  hivestore_remove_npcs - Remove All NPCs")
        end
    end)
end)

-- Initialize the spawner
HiveStore.NPCSpawner.Initialize()
