-- Server Initialization
-- Sets up the server-side components of the Hive Store

HiveStore = HiveStore or {}
HiveStore.Server = {}

-- Initialize server components
function HiveStore.Server.Initialize()
    print("[Hive Store] Initializing server components...")
    
    -- Create data directories
    if not file.Exists("hive_store", "DATA") then
        file.CreateDir("hive_store")
    end
    
    if not file.Exists("hive_store/players", "DATA") then
        file.CreateDir("hive_store/players")
    end
    
    if not file.Exists("hive_store/transactions", "DATA") then
        file.CreateDir("hive_store/transactions")
    end
    
    -- Initialize database
    HiveStore.Database.Initialize()
    
    -- Initialize PeakeCoin integration
    HiveStore.PeakeCoin.Initialize()
    
    -- Set up networking
    HiveStore.Networking.Initialize()
    
    -- Register hooks
    HiveStore.Server.RegisterHooks()
    
    print("[Hive Store] Server initialization complete!")
end

-- Register server hooks
function HiveStore.Server.RegisterHooks()
    -- Player connection
    hook.Add("PlayerInitialSpawn", "HiveStore.PlayerJoin", function(ply)
        -- Initialize player data
        timer.Simple(5, function()
            if IsValid(ply) then
                HiveStore.Database.LoadPlayerData(ply)
                HiveStore.PeakeCoin.UpdatePlayerBalance(ply)
            end
        end)
    end)
    
    -- Player disconnection
    hook.Add("PlayerDisconnected", "HiveStore.PlayerLeave", function(ply)
        HiveStore.Database.SavePlayerData(ply)
    end)
    
    -- Server shutdown
    hook.Add("ShutDown", "HiveStore.Shutdown", function()
        HiveStore.Database.SaveAll()
        print("[Hive Store] Data saved on server shutdown")
    end)
    
    -- Periodic save
    timer.Create("HiveStore.AutoSave", HiveStore.Config.Database.SaveInterval, 0, function()
        if HiveStore.Config.Database.AutoSave then
            HiveStore.Database.SaveAll()
        end
    end)
end

-- Utility functions
function HiveStore.Server.IsPlayerAdmin(ply)
    if not IsValid(ply) then return false end
    
    for _, group in pairs(HiveStore.Config.Admin.Groups) do
        if ply:IsUserGroup(group) then
            return true
        end
    end
    
    return false
end

function HiveStore.Server.LogTransaction(ply, action, item, amount, balance)
    local logData = {
        timestamp = os.time(),
        player = ply:Name(),
        steamid = ply:SteamID(),
        action = action,
        item = item,
        amount = amount,
        balance = balance
    }
    
    -- Log to console
    if HiveStore.Config.Admin.LogTransactions then
        print(string.format("[Hive Store] %s (%s) %s %s for %d PEK (Balance: %d)", 
            logData.player, logData.steamid, logData.action, logData.item, logData.amount, logData.balance))
    end
    
    -- Save to file
    local logFile = "hive_store/transactions/" .. os.date("%Y-%m-%d") .. ".txt"
    local logLine = string.format("[%s] %s (%s) %s %s for %d PEK (Balance: %d)\n", 
        os.date("%H:%M:%S"), logData.player, logData.steamid, logData.action, logData.item, logData.amount, logData.balance)
    
    file.Append(logFile, logLine)
end

function HiveStore.Server.BroadcastMessage(message, color)
    color = color or Color(76, 175, 80)
    
    for _, ply in pairs(player.GetAll()) do
        ply:ChatPrint(message)
    end
end

-- Initialize when the file is loaded
HiveStore.Server.Initialize()
