-- HiveStore NPC Spawn Configuration
-- Admin commands for spawning and managing the Loona Brothers

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
    
    concommand.Add("hivestore_spawn_trading_post", function(ply, cmd, args)
        if not HiveStore.Server.IsPlayerAdmin(ply) then
            ply:ChatPrint("You must be an admin to use this command!")
            return
        end
        
        HiveStore.NPCSpawner.SpawnTradingPost(ply)
    end)
    
    concommand.Add("hivestore_remove_npcs", function(ply, cmd, args)
        if not HiveStore.Server.IsPlayerAdmin(ply) then
            ply:ChatPrint("You must be an admin to use this command!")
            return
        end
        
        HiveStore.NPCSpawner.RemoveAllNPCs(ply)
    end)
    
    -- Protection system
    HiveStore.NPCSpawner.InitializeProtection()
end

-- Initialize protection system
function HiveStore.NPCSpawner.InitializeProtection()
    -- Protect NPCs from admin cleanup commands
    hook.Add("PlayerSay", "HiveStore.ProtectNPCs", function(ply, text)
        if not ply:IsAdmin() then return end
        
        local cmd = string.lower(text)
        if string.find(cmd, "cleanup") or string.find(cmd, "removeall") then
            timer.Simple(1, function()
                HiveStore.NPCSpawner.CheckAndRespawnNPCs()
            end)
        end
    end)
    
    -- Protect from physics gun removal
    hook.Add("PhysgunDrop", "HiveStore.ProtectNPCs", function(ply, ent)
        if IsValid(ent) and ent:GetNWBool("IsHiveStoreNPC") then
            ent:SetPos(ent:GetPos()) -- Reset position if moved
        end
    end)
    
    -- Protect from remover tool
    hook.Add("CanTool", "HiveStore.ProtectNPCs", function(ply, tr, tool)
        local ent = tr.Entity
        if IsValid(ent) and ent:GetNWBool("IsHiveStoreNPC") then
            if tool == "remover" then
                ply:ChatPrint("[Hive Store] Cannot remove protected shopkeeper!")
                return false
            end
        end
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
        
        ply:ChatPrint("[Hive Store] Elder Brother (E.R. Loona) spawned successfully!")
        ply:ChatPrint("[Hive Store] This NPC is now permanent and protected!")
        
        -- Apply custom appearance
        timer.Simple(0.5, function()
            if IsValid(npc) then
                npc:ApplyHillbillyAppearance()
            end
        end)
        
        -- Save positions for persistence
        HiveStore.NPCSpawner.SaveNPCPositions()
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
        
        ply:ChatPrint("[Hive Store] Younger Brother (Nater Loona) spawned successfully!")
        ply:ChatPrint("[Hive Store] This NPC is now permanent and protected!")
        
        -- Apply custom appearance
        timer.Simple(0.5, function()
            if IsValid(npc) then
                npc:ApplyHillbillyAppearance()
            end
        end)
        
        -- Save positions for persistence
        HiveStore.NPCSpawner.SaveNPCPositions()
    else
        ply:ChatPrint("[Hive Store] Failed to spawn Younger Brother!")
    end
end

-- Spawn both brothers
function HiveStore.NPCSpawner.SpawnBothBrothers(ply)
    HiveStore.NPCSpawner.SpawnElderBrother(ply)
    
    timer.Simple(1, function()
        HiveStore.NPCSpawner.SpawnYoungerBrother(ply)
        ply:ChatPrint("[Hive Store] Loona Brothers Trading Post is now open for business!")
    end)
end

-- Spawn Complete Trading Post with both brothers
function HiveStore.NPCSpawner.SpawnTradingPost(ply)
    if HiveStore.NPCSpawner.SpawnLocations.trading_post and HiveStore.NPCSpawner.SpawnLocations.trading_post.spawned then
        ply:ChatPrint("[Hive Store] Trading Post is already spawned!")
        return
    end
    
    local pos = ply:GetPos() + ply:GetForward() * 150
    local ang = ply:GetAngles()
    ang.p = 0
    ang.r = 0
    ang.y = ang.y + 180
    
    local tradingPost = ents.Create("npc_hivestore_trading_post")
    if IsValid(tradingPost) then
        tradingPost:SetPos(pos)
        tradingPost:SetAngles(ang)
        tradingPost:Spawn()
        tradingPost:Activate()
        
        -- Initialize tracking if not exists
        if not HiveStore.NPCSpawner.SpawnLocations.trading_post then
            HiveStore.NPCSpawner.SpawnLocations.trading_post = {
                pos = Vector(0, 0, 0),
                ang = Angle(0, 0, 0),
                spawned = false,
                entity = nil
            }
        end
        
        -- Store reference
        HiveStore.NPCSpawner.SpawnLocations.trading_post.entity = tradingPost
        HiveStore.NPCSpawner.SpawnLocations.trading_post.spawned = true
        HiveStore.NPCSpawner.SpawnLocations.trading_post.pos = pos
        HiveStore.NPCSpawner.SpawnLocations.trading_post.ang = ang
        
        ply:ChatPrint("[Hive Store] Loona Trading Post spawned successfully!")
        ply:ChatPrint("[Hive Store] Both brothers will spawn automatically!")
        ply:ChatPrint("[Hive Store] This trading post is permanent and protected!")
        
        -- Save positions for persistence
        HiveStore.NPCSpawner.SaveNPCPositions()
    else
        ply:ChatPrint("[Hive Store] Failed to spawn Trading Post!")
    end
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
    
    if HiveStore.NPCSpawner.SpawnLocations.trading_post and HiveStore.NPCSpawner.SpawnLocations.trading_post.spawned then
        local tradingPost = HiveStore.NPCSpawner.SpawnLocations.trading_post.entity
        if IsValid(tradingPost) then
            tradingPost:Remove()
            removed = removed + 1
        end
        HiveStore.NPCSpawner.SpawnLocations.trading_post.spawned = false
        HiveStore.NPCSpawner.SpawnLocations.trading_post.entity = nil
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
    elseif ent:GetClass() == "npc_hivestore_trading_post" then
        HiveStore.NPCSpawner.SpawnLocations.trading_post.spawned = false
        HiveStore.NPCSpawner.SpawnLocations.trading_post.entity = nil
    end
end)

-- Auto-spawn on map load (optional)
hook.Add("InitPostEntity", "HiveStore.AutoSpawn", function()
    timer.Simple(5, function()
        -- Start health check system
        HiveStore.NPCSpawner.StartHealthCheck()
        
        -- Try to auto-respawn NPCs if they were previously spawned
        HiveStore.NPCSpawner.AutoRespawnOnRestart()
        
        -- Notify admins about commands
        PrintMessage(HUD_PRINTTALK, "[Hive Store] Use console commands to spawn permanent NPCs:")
        PrintMessage(HUD_PRINTTALK, "  hivestore_spawn_elder - Spawn Elder Brother")
        PrintMessage(HUD_PRINTTALK, "  hivestore_spawn_younger - Spawn Younger Brother")
        PrintMessage(HUD_PRINTTALK, "  hivestore_spawn_both - Spawn Both Brothers")
        PrintMessage(HUD_PRINTTALK, "  hivestore_remove_npcs - Remove All NPCs")
        PrintMessage(HUD_PRINTTALK, "[Hive Store] NPCs are permanent and will auto-respawn if removed!")
    end)
end)

-- Save positions when server shuts down
hook.Add("ShutDown", "HiveStore.SaveNPCs", function()
    HiveStore.NPCSpawner.SaveNPCPositions()
end)

-- Respawn Elder Brother if removed
function HiveStore.NPCSpawner.RespawnElderBrother()
    local data = HiveStore.NPCSpawner.SpawnLocations.elder_brother
    if data.pos and data.ang then
        local npc = ents.Create("npc_hivestore_elder_brother")
        if IsValid(npc) then
            npc:SetPos(data.pos)
            npc:SetAngles(data.ang)
            npc:Spawn()
            npc:Activate()
            
            data.entity = npc
            data.spawned = true
            
            print("[Hive Store] Elder Brother respawned automatically")
            
            timer.Simple(0.5, function()
                if IsValid(npc) then
                    npc:ApplyHillbillyAppearance()
                end
            end)
        end
    end
end

-- Respawn Younger Brother if removed
function HiveStore.NPCSpawner.RespawnYoungerBrother()
    local data = HiveStore.NPCSpawner.SpawnLocations.younger_brother
    if data.pos and data.ang then
        local npc = ents.Create("npc_hivestore_younger_brother")
        if IsValid(npc) then
            npc:SetPos(data.pos)
            npc:SetAngles(data.ang)
            npc:Spawn()
            npc:Activate()
            
            data.entity = npc
            data.spawned = true
            
            print("[Hive Store] Younger Brother respawned automatically")
            
            timer.Simple(0.5, function()
                if IsValid(npc) then
                    npc:ApplyHillbillyAppearance()
                end
            end)
        end
    end
end

-- Respawn Trading Post if removed
function HiveStore.NPCSpawner.RespawnTradingPost()
    if not HiveStore.NPCSpawner.SpawnLocations.trading_post then return end
    
    local data = HiveStore.NPCSpawner.SpawnLocations.trading_post
    if data.pos and data.ang then
        local tradingPost = ents.Create("npc_hivestore_trading_post")
        if IsValid(tradingPost) then
            tradingPost:SetPos(data.pos)
            tradingPost:SetAngles(data.ang)
            tradingPost:Spawn()
            tradingPost:Activate()
            
            data.entity = tradingPost
            data.spawned = true
            
            print("[Hive Store] Trading Post respawned automatically")
        end
    end
end

-- Check and respawn NPCs if missing
function HiveStore.NPCSpawner.CheckAndRespawnNPCs()
    -- Check elder brother
    if HiveStore.NPCSpawner.SpawnLocations.elder_brother.spawned then
        local npc = HiveStore.NPCSpawner.SpawnLocations.elder_brother.entity
        if not IsValid(npc) then
            print("[Hive Store] Elder Brother missing - respawning...")
            HiveStore.NPCSpawner.RespawnElderBrother()
        end
    end
    
    -- Check younger brother
    if HiveStore.NPCSpawner.SpawnLocations.younger_brother.spawned then
        local npc = HiveStore.NPCSpawner.SpawnLocations.younger_brother.entity
        if not IsValid(npc) then
            print("[Hive Store] Younger Brother missing - respawning...")
            HiveStore.NPCSpawner.RespawnYoungerBrother()
        end
    end
    
    -- Check trading post
    if HiveStore.NPCSpawner.SpawnLocations.trading_post and HiveStore.NPCSpawner.SpawnLocations.trading_post.spawned then
        local tradingPost = HiveStore.NPCSpawner.SpawnLocations.trading_post.entity
        if not IsValid(tradingPost) then
            print("[Hive Store] Trading Post missing - respawning...")
            HiveStore.NPCSpawner.RespawnTradingPost()
        end
    end
end

-- Periodic health check
function HiveStore.NPCSpawner.StartHealthCheck()
    timer.Create("HiveStore.NPCHealthCheck", 30, 0, function()
        HiveStore.NPCSpawner.CheckAndRespawnNPCs()
        
        -- Also heal NPCs to full health
        for _, data in pairs(HiveStore.NPCSpawner.SpawnLocations) do
            if data.spawned and IsValid(data.entity) then
                data.entity:SetHealth(data.entity:GetMaxHealth())
            end
        end
    end)
end

-- Save NPC positions to file for persistence
function HiveStore.NPCSpawner.SaveNPCPositions()
    local data = {
        elder_brother = {
            pos = HiveStore.NPCSpawner.SpawnLocations.elder_brother.pos,
            ang = HiveStore.NPCSpawner.SpawnLocations.elder_brother.ang,
            spawned = HiveStore.NPCSpawner.SpawnLocations.elder_brother.spawned
        },
        younger_brother = {
            pos = HiveStore.NPCSpawner.SpawnLocations.younger_brother.pos,
            ang = HiveStore.NPCSpawner.SpawnLocations.younger_brother.ang,
            spawned = HiveStore.NPCSpawner.SpawnLocations.younger_brother.spawned
        }
    }
    
    file.Write("hive_store/npc_positions.txt", util.TableToJSON(data))
    print("[Hive Store] NPC positions saved")
end

-- Load NPC positions from file
function HiveStore.NPCSpawner.LoadNPCPositions()
    if file.Exists("hive_store/npc_positions.txt", "DATA") then
        local content = file.Read("hive_store/npc_positions.txt", "DATA")
        local success, data = pcall(util.JSONToTable, content)
        
        if success and data then
            HiveStore.NPCSpawner.SpawnLocations.elder_brother.pos = Vector(data.elder_brother.pos.x, data.elder_brother.pos.y, data.elder_brother.pos.z)
            HiveStore.NPCSpawner.SpawnLocations.elder_brother.ang = Angle(data.elder_brother.ang.p, data.elder_brother.ang.y, data.elder_brother.ang.r)
            
            HiveStore.NPCSpawner.SpawnLocations.younger_brother.pos = Vector(data.younger_brother.pos.x, data.younger_brother.pos.y, data.younger_brother.pos.z)
            HiveStore.NPCSpawner.SpawnLocations.younger_brother.ang = Angle(data.younger_brother.ang.p, data.younger_brother.ang.y, data.younger_brother.ang.r)
            
            print("[Hive Store] NPC positions loaded from file")
            return true
        end
    end
    return false
end

-- Auto-respawn on map restart
function HiveStore.NPCSpawner.AutoRespawnOnRestart()
    timer.Simple(5, function()
        if HiveStore.NPCSpawner.LoadNPCPositions() then
            -- Auto-respawn if positions were saved
            if HiveStore.NPCSpawner.SpawnLocations.elder_brother.pos then
                HiveStore.NPCSpawner.RespawnElderBrother()
            end
            if HiveStore.NPCSpawner.SpawnLocations.younger_brother.pos then
                HiveStore.NPCSpawner.RespawnYoungerBrother()
            end
        end
    end)
end

-- Initialize the spawner
HiveStore.NPCSpawner.Initialize()
