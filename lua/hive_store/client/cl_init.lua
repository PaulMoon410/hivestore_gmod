-- Client Initialization
-- Sets up the client-side components of the Hive Store

HiveStore = HiveStore or {}
HiveStore.Client = {}

-- Client data
HiveStore.Client.Balance = 0
HiveStore.Client.StoreOpen = false
HiveStore.Client.AdminPanelOpen = false

-- Initialize client components
function HiveStore.Client.Initialize()
    print("[Hive Store] Initializing client components...")
    
    -- Set up key bindings
    HiveStore.Client.SetupKeyBinds()
    
    -- Set up networking
    HiveStore.Client.SetupNetworking()
    
    -- Request initial balance
    HiveStore.Client.RequestBalance()
    
    print("[Hive Store] Client initialization complete!")
end

-- Set up key bindings
function HiveStore.Client.SetupKeyBinds()
    hook.Add("PlayerButtonDown", "HiveStore.KeyPress", function(ply, button)
        if not IsValid(ply) or ply ~= LocalPlayer() then return end
        
        if button == HiveStore.Config.UI.OpenKey then
            if not HiveStore.Client.StoreOpen then
                HiveStore.Client.OpenStore()
            else
                HiveStore.Client.CloseStore()
            end
        end
    end)
end

-- Set up networking
function HiveStore.Client.SetupNetworking()
    -- Server opens store GUI
    net.Receive("HiveStore.OpenGUI", function()
        HiveStore.Client.OpenStore()
    end)
    
    -- Server opens admin GUI
    net.Receive("HiveStore.OpenAdminGUI", function()
        HiveStore.Client.OpenAdminPanel()
    end)
    
    -- Server sends balance update
    net.Receive("HiveStore.UpdateBalance", function()
        HiveStore.Client.Balance = net.ReadInt(32)
        HiveStore.Client.UpdateBalanceDisplay()
    end)
    
    -- Server sends store items
    net.Receive("HiveStore.SendItems", function()
        local items = net.ReadTable()
        HiveStore.Client.UpdateItemList(items)
    end)
    
    -- Server sends purchase result
    net.Receive("HiveStore.PurchaseResult", function()
        local success = net.ReadBool()
        local message = net.ReadString()
        
        if success then
            HiveStore.Client.Balance = net.ReadInt(32)
            HiveStore.Client.ShowNotification("Purchase successful!", "success")
            surface.PlaySound(HiveStore.Config.Sounds.Success)
        else
            HiveStore.Client.ShowNotification("Purchase failed: " .. message, "error")
            surface.PlaySound(HiveStore.Config.Sounds.Error)
        end
        
        HiveStore.Client.UpdateBalanceDisplay()
    end)
    
    -- Server sends sell result
    net.Receive("HiveStore.SellResult", function()
        local success = net.ReadBool()
        local message = net.ReadString()
        
        if success then
            HiveStore.Client.Balance = net.ReadInt(32)
            HiveStore.Client.ShowNotification("Sale successful!", "success")
            surface.PlaySound(HiveStore.Config.Sounds.Success)
        else
            HiveStore.Client.ShowNotification("Sale failed: " .. message, "error")
            surface.PlaySound(HiveStore.Config.Sounds.Error)
        end
        
        HiveStore.Client.UpdateBalanceDisplay()
    end)
end

-- Open store interface
function HiveStore.Client.OpenStore()
    if HiveStore.Client.StoreOpen then return end
    
    HiveStore.Client.StoreOpen = true
    HiveStore.GUI.CreateStoreFrame()
    
    -- Request latest items and balance
    HiveStore.Client.RequestItems("ALL")
    HiveStore.Client.RequestBalance()
end

-- Close store interface
function HiveStore.Client.CloseStore()
    if not HiveStore.Client.StoreOpen then return end
    
    HiveStore.Client.StoreOpen = false
    
    if IsValid(HiveStore.GUI.StoreFrame) then
        HiveStore.GUI.StoreFrame:Close()
    end
end

-- Open admin panel
function HiveStore.Client.OpenAdminPanel()
    if HiveStore.Client.AdminPanelOpen then return end
    
    HiveStore.Client.AdminPanelOpen = true
    HiveStore.GUI.CreateAdminFrame()
end

-- Close admin panel
function HiveStore.Client.CloseAdminPanel()
    if not HiveStore.Client.AdminPanelOpen then return end
    
    HiveStore.Client.AdminPanelOpen = false
    
    if IsValid(HiveStore.GUI.AdminFrame) then
        HiveStore.GUI.AdminFrame:Close()
    end
end

-- Request store items from server
function HiveStore.Client.RequestItems(category)
    net.Start("HiveStore.RequestItems")
    net.WriteString(category or "ALL")
    net.SendToServer()
end

-- Request balance update from server
function HiveStore.Client.RequestBalance()
    net.Start("HiveStore.RequestBalance")
    net.SendToServer()
end

-- Request balance refresh from Hive blockchain
function HiveStore.Client.RefreshBalance()
    net.Start("HiveStore.RefreshBalance")
    net.SendToServer()
    
    HiveStore.Client.ShowNotification("Refreshing balance from Hive blockchain...", "info")
end

-- Purchase item
function HiveStore.Client.PurchaseItem(itemId)
    net.Start("HiveStore.PurchaseItem")
    net.WriteString(itemId)
    net.SendToServer()
end

-- Sell item
function HiveStore.Client.SellItem(itemId)
    net.Start("HiveStore.SellItem")
    net.WriteString(itemId)
    net.SendToServer()
end

-- Update item list in GUI
function HiveStore.Client.UpdateItemList(items)
    if IsValid(HiveStore.GUI.StoreFrame) then
        HiveStore.GUI.UpdateItemList(items)
    end
end

-- Update balance display
function HiveStore.Client.UpdateBalanceDisplay()
    if IsValid(HiveStore.GUI.StoreFrame) then
        HiveStore.GUI.UpdateBalance(HiveStore.Client.Balance)
    end
    
    if IsValid(HiveStore.GUI.AdminFrame) then
        HiveStore.GUI.UpdateAdminBalance(HiveStore.Client.Balance)
    end
end

-- Show notification
function HiveStore.Client.ShowNotification(message, type)
    -- Simple chat notification for now
    chat.AddText(HiveStore.Config.UI.PrimaryColor, "[Hive Store] ", color_white, message)
    
    -- Could create fancy notification popup here
end

-- Admin action
function HiveStore.Client.SendAdminAction(action, data)
    net.Start("HiveStore.AdminAction")
    net.WriteString(action)
    
    if action == "give_pek" then
        net.WriteString(data.steamid)
        net.WriteInt(data.amount, 32)
    elseif action == "set_price" then
        net.WriteString(data.itemId)
        net.WriteInt(data.price, 32)
    end
    
    net.SendToServer()
end

-- Initialize when the file loads
HiveStore.Client.Initialize()
