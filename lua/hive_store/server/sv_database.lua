-- Database Management
-- Handles all database operations for player data and transactions

HiveStore = HiveStore or {}
HiveStore.Database = {}

-- Player data structure
HiveStore.PlayerData = {}

-- Initialize database system
function HiveStore.Database.Initialize()
    print("[Hive Store] Initializing database system...")
    
    -- Load existing player data
    HiveStore.Database.LoadAllPlayerData()
    
    print("[Hive Store] Database system initialized!")
end

-- Load player data from file
function HiveStore.Database.LoadPlayerData(ply)
    if not IsValid(ply) then return end
    
    local steamid = ply:SteamID()
    local filename = "hive_store/players/" .. string.gsub(steamid, ":", "_") .. ".json"
    
    if file.Exists(filename, "DATA") then
        local data = file.Read(filename, "DATA")
        local success, playerData = pcall(util.JSONToTable, data)
        
        if success and playerData then
            HiveStore.PlayerData[steamid] = playerData
        else
            print("[Hive Store] Failed to load player data for " .. ply:Name())
            HiveStore.Database.CreatePlayerData(ply)
        end
    else
        HiveStore.Database.CreatePlayerData(ply)
    end
    
    -- Ensure all required fields exist
    HiveStore.Database.ValidatePlayerData(ply)
end

-- Create new player data
function HiveStore.Database.CreatePlayerData(ply)
    if not IsValid(ply) then return end
    
    local steamid = ply:SteamID()
    
    HiveStore.PlayerData[steamid] = {
        name = ply:Name(),
        steamid = steamid,
        peakecoin_balance = HiveStore.Config.PeakeCoin.DefaultBalance,
        total_spent = 0,
        total_earned = 0,
        purchases = {},
        last_login = os.time(),
        created = os.time()
    }
    
    print("[Hive Store] Created new player data for " .. ply:Name())
    HiveStore.Database.SavePlayerData(ply)
end

-- Validate and fix player data
function HiveStore.Database.ValidatePlayerData(ply)
    if not IsValid(ply) then return end
    
    local steamid = ply:SteamID()
    local data = HiveStore.PlayerData[steamid]
    
    if not data then
        HiveStore.Database.CreatePlayerData(ply)
        return
    end
    
    -- Ensure all required fields exist
    data.name = data.name or ply:Name()
    data.steamid = data.steamid or steamid
    data.peakecoin_balance = data.peakecoin_balance or HiveStore.Config.PeakeCoin.DefaultBalance
    data.total_spent = data.total_spent or 0
    data.total_earned = data.total_earned or 0
    data.purchases = data.purchases or {}
    data.last_login = os.time()
    data.created = data.created or os.time()
end

-- Save player data to file
function HiveStore.Database.SavePlayerData(ply)
    if not IsValid(ply) then return end
    
    local steamid = ply:SteamID()
    local data = HiveStore.PlayerData[steamid]
    
    if not data then return end
    
    local filename = "hive_store/players/" .. string.gsub(steamid, ":", "_") .. ".json"
    local jsonData = util.TableToJSON(data, true)
    
    file.Write(filename, jsonData)
end

-- Load all player data on server start
function HiveStore.Database.LoadAllPlayerData()
    local files, _ = file.Find("hive_store/players/*.json", "DATA")
    
    for _, filename in pairs(files) do
        local data = file.Read("hive_store/players/" .. filename, "DATA")
        local success, playerData = pcall(util.JSONToTable, data)
        
        if success and playerData and playerData.steamid then
            HiveStore.PlayerData[playerData.steamid] = playerData
        end
    end
    
    print("[Hive Store] Loaded " .. table.Count(HiveStore.PlayerData) .. " player records")
end

-- Save all player data
function HiveStore.Database.SaveAll()
    local count = 0
    for steamid, data in pairs(HiveStore.PlayerData) do
        local filename = "hive_store/players/" .. string.gsub(steamid, ":", "_") .. ".json"
        local jsonData = util.TableToJSON(data, true)
        file.Write(filename, jsonData)
        count = count + 1
    end
    
    print("[Hive Store] Saved " .. count .. " player records")
end

-- Get player data
function HiveStore.Database.GetPlayerData(ply)
    if not IsValid(ply) then return nil end
    return HiveStore.PlayerData[ply:SteamID()]
end

-- Update player balance
function HiveStore.Database.SetPlayerBalance(ply, amount)
    if not IsValid(ply) then return false end
    
    local data = HiveStore.Database.GetPlayerData(ply)
    if not data then return false end
    
    data.peakecoin_balance = math.max(0, amount)
    HiveStore.Database.SavePlayerData(ply)
    
    return true
end

-- Add to player balance
function HiveStore.Database.AddPlayerBalance(ply, amount)
    if not IsValid(ply) then return false end
    
    local data = HiveStore.Database.GetPlayerData(ply)
    if not data then return false end
    
    data.peakecoin_balance = data.peakecoin_balance + amount
    
    if amount > 0 then
        data.total_earned = data.total_earned + amount
    end
    
    HiveStore.Database.SavePlayerData(ply)
    return true
end

-- Remove from player balance
function HiveStore.Database.RemovePlayerBalance(ply, amount)
    if not IsValid(ply) then return false end
    
    local data = HiveStore.Database.GetPlayerData(ply)
    if not data then return false end
    
    if data.peakecoin_balance < amount then
        return false -- Insufficient funds
    end
    
    data.peakecoin_balance = data.peakecoin_balance - amount
    data.total_spent = data.total_spent + amount
    
    HiveStore.Database.SavePlayerData(ply)
    return true
end

-- Get player balance
function HiveStore.Database.GetPlayerBalance(ply)
    if not IsValid(ply) then return 0 end
    
    local data = HiveStore.Database.GetPlayerData(ply)
    if not data then return 0 end
    
    return data.peakecoin_balance or 0
end

-- Record purchase
function HiveStore.Database.RecordPurchase(ply, itemId, price)
    if not IsValid(ply) then return end
    
    local data = HiveStore.Database.GetPlayerData(ply)
    if not data then return end
    
    table.insert(data.purchases, {
        item = itemId,
        price = price,
        timestamp = os.time()
    })
    
    HiveStore.Database.SavePlayerData(ply)
end
