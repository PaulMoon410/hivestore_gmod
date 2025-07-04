-- PeakeCoin Integration
-- Handles PeakeCoin transactions and Hive blockchain integration

HiveStore = HiveStore or {}
HiveStore.PeakeCoin = {}

-- Rate limiting for API requests
local RequestQueue = {}
local LastRequestTime = {}

-- Initialize PeakeCoin system
function HiveStore.PeakeCoin.Initialize()
    print("[Hive Store] Initializing PeakeCoin integration...")
    
    -- Test API connection
    HiveStore.PeakeCoin.TestConnection()
    
    -- Start balance refresh timer
    timer.Create("HiveStore.BalanceRefresh", HiveStore.Config.PeakeCoin.RefreshInterval, 0, function()
        HiveStore.PeakeCoin.RefreshAllBalances()
    end)
    
    print("[Hive Store] PeakeCoin integration initialized!")
end

-- Test connection to Hive Engine API
function HiveStore.PeakeCoin.TestConnection()
    http.Fetch(HiveStore.Config.PeakeCoin.APIEndpoint, 
        function(body, len, headers, code)
            if code == 200 then
                print("[Hive Store] PeakeCoin API connection successful!")
            else
                print("[Hive Store] WARNING: PeakeCoin API connection failed - Code: " .. code)
            end
        end,
        function(error)
            print("[Hive Store] ERROR: Failed to connect to PeakeCoin API - " .. error)
        end
    )
end

-- Check rate limiting
function HiveStore.PeakeCoin.CheckRateLimit(steamid)
    local currentTime = CurTime()
    local lastTime = LastRequestTime[steamid] or 0
    
    if currentTime - lastTime < 60 / HiveStore.Config.Network.MaxRequestsPerMinute then
        return false
    end
    
    LastRequestTime[steamid] = currentTime
    return true
end

-- Get PeakeCoin balance from Hive Engine
function HiveStore.PeakeCoin.GetBalance(hiveAccount, callback)
    if not hiveAccount or hiveAccount == "" then
        if callback then callback(0) end
        return
    end
    
    local postData = util.TableToJSON({
        jsonrpc = "2.0",
        id = 1,
        method = "find",
        params = {
            contract = "tokens",
            table = "balances",
            query = {
                account = hiveAccount,
                symbol = HiveStore.Config.PeakeCoin.TokenSymbol
            }
        }
    })
    
    http.Post(HiveStore.Config.PeakeCoin.APIEndpoint, postData, 
        function(body, len, headers, code)
            if code == 200 then
                local success, data = pcall(util.JSONToTable, body)
                if success and data and data.result and data.result[1] then
                    local balance = tonumber(data.result[1].balance) or 0
                    if callback then callback(balance) end
                else
                    if callback then callback(0) end
                end
            else
                print("[Hive Store] API Error: " .. code)
                if callback then callback(0) end
            end
        end,
        function(error)
            print("[Hive Store] Network Error: " .. error)
            if callback then callback(0) end
        end,
        {["Content-Type"] = "application/json"}
    )
end

-- Update player balance from Hive blockchain
function HiveStore.PeakeCoin.UpdatePlayerBalance(ply, callback)
    if not IsValid(ply) then return end
    
    local steamid = ply:SteamID()
    
    -- Check rate limiting
    if not HiveStore.PeakeCoin.CheckRateLimit(steamid) then
        if callback then callback(false, "Rate limited") end
        return
    end
    
    -- Get Hive account from player data or use SteamID as fallback
    local playerData = HiveStore.Database.GetPlayerData(ply)
    local hiveAccount = playerData and playerData.hive_account or nil
    
    if not hiveAccount then
        -- Try to use a simplified version of their Steam name
        hiveAccount = string.lower(string.gsub(ply:Name(), "[^%w]", ""))
        if string.len(hiveAccount) < 3 then
            hiveAccount = "player" .. string.sub(steamid, -6)
        end
    end
    
    HiveStore.PeakeCoin.GetBalance(hiveAccount, function(balance)
        if balance > 0 then
            HiveStore.Database.SetPlayerBalance(ply, balance)
            ply:ChatPrint("[Hive Store] Updated PeakeCoin balance: " .. balance .. " PEK")
        end
        
        if callback then callback(true, balance) end
    end)
end

-- Refresh all player balances
function HiveStore.PeakeCoin.RefreshAllBalances()
    for _, ply in pairs(player.GetAll()) do
        if IsValid(ply) then
            HiveStore.PeakeCoin.UpdatePlayerBalance(ply)
        end
    end
end

-- Send PeakeCoin transaction (simulated for now)
function HiveStore.PeakeCoin.SendTransaction(fromPlayer, toAccount, amount, memo, callback)
    if not IsValid(fromPlayer) then 
        if callback then callback(false, "Invalid player") end
        return 
    end
    
    local playerBalance = HiveStore.Database.GetPlayerBalance(fromPlayer)
    
    if playerBalance < amount then
        if callback then callback(false, "Insufficient funds") end
        return
    end
    
    -- For now, we'll simulate the transaction by just updating the local balance
    -- In a real implementation, you would integrate with Hive keychain or similar
    HiveStore.Database.RemovePlayerBalance(fromPlayer, amount)
    
    -- Generate a fake transaction ID for logging
    local txId = "HIVE_TX_" .. os.time() .. "_" .. math.random(1000, 9999)
    
    fromPlayer:ChatPrint("[Hive Store] Transaction sent: " .. amount .. " PEK to " .. toAccount)
    fromPlayer:ChatPrint("[Hive Store] Transaction ID: " .. txId)
    
    if callback then callback(true, txId) end
end

-- Process purchase transaction
function HiveStore.PeakeCoin.ProcessPurchase(ply, item, callback)
    if not IsValid(ply) then 
        if callback then callback(false, "Invalid player") end
        return 
    end
    
    local playerBalance = HiveStore.Database.GetPlayerBalance(ply)
    
    if playerBalance < item.price then
        if callback then callback(false, "Insufficient PeakeCoin balance") end
        return
    end
    
    -- Remove PeakeCoin from player balance
    if not HiveStore.Database.RemovePlayerBalance(ply, item.price) then
        if callback then callback(false, "Failed to process payment") end
        return
    end
    
    -- Record the purchase
    HiveStore.Database.RecordPurchase(ply, item.id, item.price)
    
    -- Log the transaction
    HiveStore.Server.LogTransaction(ply, "PURCHASE", item.name, item.price, HiveStore.Database.GetPlayerBalance(ply))
    
    if callback then callback(true, "Purchase successful") end
end

-- Process sell transaction
function HiveStore.PeakeCoin.ProcessSell(ply, item, callback)
    if not IsValid(ply) then 
        if callback then callback(false, "Invalid player") end
        return 
    end
    
    if not item.sellable then
        if callback then callback(false, "Item cannot be sold") end
        return
    end
    
    -- Add PeakeCoin to player balance
    HiveStore.Database.AddPlayerBalance(ply, item.sellPrice)
    
    -- Log the transaction
    HiveStore.Server.LogTransaction(ply, "SELL", item.name, item.sellPrice, HiveStore.Database.GetPlayerBalance(ply))
    
    if callback then callback(true, "Sale successful") end
end

-- Get current PEK to USD rate (simulated)
function HiveStore.PeakeCoin.GetUSDRate(callback)
    -- In a real implementation, you would fetch this from an API
    local mockRate = 0.05 -- $0.05 per PEK
    if callback then callback(mockRate) end
end

-- Format PeakeCoin amount for display
function HiveStore.PeakeCoin.FormatAmount(amount)
    return string.format("%.2f %s", amount, HiveStore.Config.Currency)
end
