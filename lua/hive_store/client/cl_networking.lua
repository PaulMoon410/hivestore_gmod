-- Client Networking
-- Handles client-side network communication

HiveStore = HiveStore or {}
HiveStore.ClientNet = {}

-- Network message handlers
HiveStore.ClientNet.Handlers = {}

-- Initialize client networking
function HiveStore.ClientNet.Initialize()
    print("[Hive Store] Initializing client networking...")
    
    -- Register network handlers
    HiveStore.ClientNet.RegisterHandlers()
    
    print("[Hive Store] Client networking initialized!")
end

-- Register network message handlers
function HiveStore.ClientNet.RegisterHandlers()
    -- Handle store opening
    net.Receive("HiveStore.OpenGUI", function()
        HiveStore.Client.OpenStore()
    end)
    
    -- Handle admin panel opening
    net.Receive("HiveStore.OpenAdminGUI", function()
        HiveStore.Client.OpenAdminPanel()
    end)
    
    -- Handle balance updates
    net.Receive("HiveStore.UpdateBalance", function()
        local balance = net.ReadInt(32)
        HiveStore.Client.Balance = balance
        HiveStore.Client.UpdateBalanceDisplay()
    end)
    
    -- Handle item list updates
    net.Receive("HiveStore.SendItems", function()
        local items = net.ReadTable()
        HiveStore.Client.UpdateItemList(items)
    end)
    
    -- Handle purchase results
    net.Receive("HiveStore.PurchaseResult", function()
        local success = net.ReadBool()
        local message = net.ReadString()
        
        if success then
            local newBalance = net.ReadInt(32)
            HiveStore.Client.Balance = newBalance
            HiveStore.Client.ShowNotification("Purchase successful!", "success")
            surface.PlaySound(HiveStore.Config.Sounds.Success)
        else
            HiveStore.Client.ShowNotification("Purchase failed: " .. message, "error")
            surface.PlaySound(HiveStore.Config.Sounds.Error)
        end
        
        HiveStore.Client.UpdateBalanceDisplay()
    end)
    
    -- Handle sell results
    net.Receive("HiveStore.SellResult", function()
        local success = net.ReadBool()
        local message = net.ReadString()
        
        if success then
            local newBalance = net.ReadInt(32)
            HiveStore.Client.Balance = newBalance
            HiveStore.Client.ShowNotification("Item sold successfully!", "success")
            surface.PlaySound(HiveStore.Config.Sounds.Success)
        else
            HiveStore.Client.ShowNotification("Sale failed: " .. message, "error")
            surface.PlaySound(HiveStore.Config.Sounds.Error)
        end
        
        HiveStore.Client.UpdateBalanceDisplay()
    end)
end

-- Send purchase request
function HiveStore.ClientNet.PurchaseItem(itemId)
    net.Start("HiveStore.PurchaseItem")
    net.WriteString(itemId)
    net.SendToServer()
end

-- Send sell request
function HiveStore.ClientNet.SellItem(itemId)
    net.Start("HiveStore.SellItem")
    net.WriteString(itemId)
    net.SendToServer()
end

-- Request items by category
function HiveStore.ClientNet.RequestItems(category)
    net.Start("HiveStore.RequestItems")
    net.WriteString(category or "ALL")
    net.SendToServer()
end

-- Request balance update
function HiveStore.ClientNet.RequestBalance()
    net.Start("HiveStore.RequestBalance")
    net.SendToServer()
end

-- Request balance refresh from blockchain
function HiveStore.ClientNet.RefreshBalance()
    net.Start("HiveStore.RefreshBalance")
    net.SendToServer()
end

-- Send admin action
function HiveStore.ClientNet.SendAdminAction(action, data)
    net.Start("HiveStore.AdminAction")
    net.WriteString(action)
    
    if action == "give_pek" then
        net.WriteString(data.steamid)
        net.WriteInt(data.amount, 32)
    elseif action == "set_price" then
        net.WriteString(data.itemId)
        net.WriteInt(data.price, 32)
    elseif action == "add_item" then
        -- Future implementation
    elseif action == "remove_item" then
        -- Future implementation
    end
    
    net.SendToServer()
end

-- Initialize
HiveStore.ClientNet.Initialize()
