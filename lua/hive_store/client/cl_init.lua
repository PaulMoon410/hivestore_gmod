-- Client Initialization
-- Sets up the client-side components of the Hive Store

HiveStore = HiveStore or {}
HiveStore.Client = {}

-- Client data
HiveStore.Client.Balance = 0
HiveStore.Client.StoreOpen = false
HiveStore.Client.AdminPanelOpen = false
HiveStore.Client.SpecializedStoreOpen = false
HiveStore.Client.CurrentShopkeeper = nil

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

-- Open specialized store for specific NPCs
function HiveStore.Client.OpenSpecializedStore(shopType, npcName)
    if HiveStore.Client.SpecializedStoreOpen then
        HiveStore.Client.CloseSpecializedStore()
    end
    
    HiveStore.Client.SpecializedStoreOpen = true
    HiveStore.Client.CurrentShopkeeper = npcName
    
    -- Filter items based on shop type
    local filteredItems = {}
    if shopType == "weapons_tools" then
        for _, item in pairs(HiveStore.Items or {}) do
            if item.category == "Weapons" or item.category == "Tools" then
                table.insert(filteredItems, item)
            end
        end
    else
        filteredItems = HiveStore.Items or {}
    end
    
    -- Create specialized store GUI
    HiveStore.Client.CreateSpecializedGUI(filteredItems, npcName)
    
    -- Play opening sound
    surface.PlaySound("ui/buttonclick.wav")
end

-- Close specialized store
function HiveStore.Client.CloseSpecializedStore()
    if IsValid(HiveStore.GUI.SpecializedFrame) then
        HiveStore.GUI.SpecializedFrame:Remove()
    end
    
    HiveStore.Client.SpecializedStoreOpen = false
    HiveStore.Client.CurrentShopkeeper = nil
    
    surface.PlaySound("ui/buttonclickrelease.wav")
end

-- Create specialized store GUI
function HiveStore.Client.CreateSpecializedGUI(items, npcName)
    HiveStore.GUI = HiveStore.GUI or {}
    
    -- Create main frame
    local frame = vgui.Create("DFrame")
    frame:SetSize(800, 600)
    frame:Center()
    frame:SetTitle(npcName .. "'s Shop - " .. #items .. " items")
    frame:SetVisible(true)
    frame:SetDraggable(true)
    frame:ShowCloseButton(true)
    frame:MakePopup()
    
    -- Store frame reference
    HiveStore.GUI.SpecializedFrame = frame
    
    -- Close function
    frame.OnClose = function()
        HiveStore.Client.CloseSpecializedStore()
    end
    
    -- Background color
    frame.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(40, 40, 40, 240))
        draw.RoundedBox(0, 0, 0, w, 25, Color(60, 60, 60, 255))
    end
    
    -- Balance display
    local balanceLabel = vgui.Create("DLabel", frame)
    balanceLabel:SetPos(10, 30)
    balanceLabel:SetSize(200, 25)
    balanceLabel:SetText("Balance: " .. (HiveStore.Client.Balance or 0) .. " PEK")
    balanceLabel:SetTextColor(Color(100, 255, 100))
    
    -- Shopkeeper info
    local shopkeeperInfo = vgui.Create("DLabel", frame)
    shopkeeperInfo:SetPos(10, 55)
    shopkeeperInfo:SetSize(400, 25)
    shopkeeperInfo:SetText("Talking to: " .. npcName)
    shopkeeperInfo:SetTextColor(Color(255, 255, 100))
    
    -- Items scroll panel
    local scroll = vgui.Create("DScrollPanel", frame)
    scroll:SetPos(10, 85)
    scroll:SetSize(780, 470)
    
    -- Items layout
    local layout = vgui.Create("DIconLayout", scroll)
    layout:SetSize(780, 470)
    layout:SetSpaceY(5)
    layout:SetSpaceX(5)
    
    -- Add items to the layout
    for _, item in pairs(items) do
        local itemPanel = vgui.Create("DPanel")
        itemPanel:SetSize(760, 80)
        
        itemPanel.Paint = function(self, w, h)
            local bgColor = Color(50, 50, 50, 200)
            if self:IsHovered() then
                bgColor = Color(70, 70, 70, 220)
            end
            draw.RoundedBox(4, 0, 0, w, h, bgColor)
            
            -- Item border
            draw.RoundedBox(4, 1, 1, w-2, h-2, Color(80, 80, 80, 100))
        end
        
        -- Item name
        local nameLabel = vgui.Create("DLabel", itemPanel)
        nameLabel:SetPos(10, 5)
        nameLabel:SetSize(300, 25)
        nameLabel:SetText(item.name)
        nameLabel:SetFont("DermaDefaultBold")
        nameLabel:SetTextColor(Color(255, 255, 255))
        
        -- Item description
        local descLabel = vgui.Create("DLabel", itemPanel)
        descLabel:SetPos(10, 25)
        descLabel:SetSize(400, 20)
        descLabel:SetText(item.description or "No description")
        descLabel:SetTextColor(Color(200, 200, 200))
        
        -- Item price
        local priceLabel = vgui.Create("DLabel", itemPanel)
        priceLabel:SetPos(10, 45)
        priceLabel:SetSize(200, 20)
        priceLabel:SetText("Price: " .. (item.price or 0) .. " PEK")
        priceLabel:SetTextColor(Color(100, 255, 100))
        
        -- Buy button
        local buyButton = vgui.Create("DButton", itemPanel)
        buyButton:SetPos(650, 25)
        buyButton:SetSize(100, 30)
        buyButton:SetText("Buy")
        buyButton.DoClick = function()
            HiveStore.Client.PurchaseItem(item.id)
            surface.PlaySound("ui/buttonclick.wav")
        end
        
        layout:Add(itemPanel)
    end
    
    -- Refresh button
    local refreshButton = vgui.Create("DButton", frame)
    refreshButton:SetPos(650, 30)
    refreshButton:SetSize(140, 25)
    refreshButton:SetText("Refresh Balance")
    refreshButton.DoClick = function()
        HiveStore.Client.RefreshBalance()
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
