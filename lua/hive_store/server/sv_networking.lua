-- Network Communication
-- Handles client-server communication for the Hive Store

HiveStore = HiveStore or {}
HiveStore.Networking = {}

-- Initialize networking
function HiveStore.Networking.Initialize()
    print("[Hive Store] Initializing networking...")
    
    -- Register network strings
    util.AddNetworkString("HiveStore.OpenGUI")
    util.AddNetworkString("HiveStore.OpenAdminGUI")
    util.AddNetworkString("HiveStore.CloseGUI")
    util.AddNetworkString("HiveStore.RequestItems")
    util.AddNetworkString("HiveStore.SendItems")
    util.AddNetworkString("HiveStore.RequestBalance")
    util.AddNetworkString("HiveStore.UpdateBalance")
    util.AddNetworkString("HiveStore.PurchaseItem")
    util.AddNetworkString("HiveStore.SellItem")
    util.AddNetworkString("HiveStore.PurchaseResult")
    util.AddNetworkString("HiveStore.SellResult")
    util.AddNetworkString("HiveStore.RefreshBalance")
    util.AddNetworkString("HiveStore.AdminAction")
    
    -- Register network receivers
    HiveStore.Networking.RegisterReceivers()
    
    print("[Hive Store] Networking initialized!")
end

-- Register network message receivers
function HiveStore.Networking.RegisterReceivers()
    -- Client requests store items
    net.Receive("HiveStore.RequestItems", function(len, ply)
        if not IsValid(ply) then return end
        
        local category = net.ReadString()
        local items = {}
        
        if category == "ALL" then
            items = HiveStore.Items
        else
            items = HiveStore.GetItemsByCategory(category)
        end
        
        -- Send items to client
        net.Start("HiveStore.SendItems")
        net.WriteTable(items)
        net.Send(ply)
    end)
    
    -- Client requests balance update
    net.Receive("HiveStore.RequestBalance", function(len, ply)
        if not IsValid(ply) then return end
        
        local balance = HiveStore.Database.GetPlayerBalance(ply)
        
        net.Start("HiveStore.UpdateBalance")
        net.WriteInt(balance, 32)
        net.Send(ply)
    end)
    
    -- Client wants to purchase item
    net.Receive("HiveStore.PurchaseItem", function(len, ply)
        if not IsValid(ply) then return end
        
        local itemId = net.ReadString()
        local item = HiveStore.GetItemById(itemId)
        
        if not item then
            net.Start("HiveStore.PurchaseResult")
            net.WriteBool(false)
            net.WriteString("Item not found")
            net.Send(ply)
            return
        end
        
        if item.adminOnly and not HiveStore.Server.IsPlayerAdmin(ply) then
            net.Start("HiveStore.PurchaseResult")
            net.WriteBool(false)
            net.WriteString("Admin only item")
            net.Send(ply)
            return
        end
        
        HiveStore.PeakeCoin.ProcessPurchase(ply, item, function(success, message)
            if success then
                HiveStore.Commands.GiveItemToPlayer(ply, item)
            end
            
            net.Start("HiveStore.PurchaseResult")
            net.WriteBool(success)
            net.WriteString(message)
            if success then
                net.WriteInt(HiveStore.Database.GetPlayerBalance(ply), 32)
            end
            net.Send(ply)
        end)
    end)
    
    -- Client wants to sell item
    net.Receive("HiveStore.SellItem", function(len, ply)
        if not IsValid(ply) then return end
        
        local itemId = net.ReadString()
        local item = HiveStore.GetItemById(itemId)
        
        if not item then
            net.Start("HiveStore.SellResult")
            net.WriteBool(false)
            net.WriteString("Item not found")
            net.Send(ply)
            return
        end
        
        if not item.sellable then
            net.Start("HiveStore.SellResult")
            net.WriteBool(false)
            net.WriteString("Item cannot be sold")
            net.Send(ply)
            return
        end
        
        -- Check if player has the item
        local hasItem = false
        if item.category == HiveStore.ItemCategories.WEAPON then
            hasItem = ply:HasWeapon(item.class)
        else
            -- For non-weapons, we'll assume they can sell it
            hasItem = true
        end
        
        if not hasItem then
            net.Start("HiveStore.SellResult")
            net.WriteBool(false)
            net.WriteString("You don't have this item")
            net.Send(ply)
            return
        end
        
        HiveStore.PeakeCoin.ProcessSell(ply, item, function(success, message)
            if success then
                -- Remove item from player
                if item.category == HiveStore.ItemCategories.WEAPON and ply:HasWeapon(item.class) then
                    ply:StripWeapon(item.class)
                end
            end
            
            net.Start("HiveStore.SellResult")
            net.WriteBool(success)
            net.WriteString(message)
            if success then
                net.WriteInt(HiveStore.Database.GetPlayerBalance(ply), 32)
            end
            net.Send(ply)
        end)
    end)
    
    -- Client requests balance refresh
    net.Receive("HiveStore.RefreshBalance", function(len, ply)
        if not IsValid(ply) then return end
        
        HiveStore.PeakeCoin.UpdatePlayerBalance(ply, function(success, result)
            local balance = HiveStore.Database.GetPlayerBalance(ply)
            
            net.Start("HiveStore.UpdateBalance")
            net.WriteInt(balance, 32)
            net.Send(ply)
        end)
    end)
    
    -- Admin actions
    net.Receive("HiveStore.AdminAction", function(len, ply)
        if not IsValid(ply) or not HiveStore.Server.IsPlayerAdmin(ply) then return end
        
        local action = net.ReadString()
        
        if action == "give_pek" then
            local targetId = net.ReadString()
            local amount = net.ReadInt(32)
            
            local target = player.GetBySteamID(targetId)
            if IsValid(target) then
                HiveStore.Commands.GivePeakeCoin(ply, target, amount)
            end
            
        elseif action == "set_price" then
            local itemId = net.ReadString()
            local price = net.ReadInt(32)
            
            HiveStore.Commands.SetItemPrice(ply, itemId, price)
            
        elseif action == "add_item" then
            -- Handle adding new items (future feature)
            
        elseif action == "remove_item" then
            -- Handle removing items (future feature)
        end
    end)
end

-- Send notification to player
function HiveStore.Networking.SendNotification(ply, message, type, duration)
    if not IsValid(ply) then return end
    
    ply:ChatPrint("[Hive Store] " .. message)
    
    -- Could also send to client for fancy notifications
    -- net.Start("HiveStore.Notification")
    -- net.WriteString(message)
    -- net.WriteString(type or "info")
    -- net.WriteInt(duration or 5, 8)
    -- net.Send(ply)
end

-- Broadcast store message to all players
function HiveStore.Networking.BroadcastMessage(message)
    for _, ply in pairs(player.GetAll()) do
        ply:ChatPrint("[Hive Store] " .. message)
    end
end
