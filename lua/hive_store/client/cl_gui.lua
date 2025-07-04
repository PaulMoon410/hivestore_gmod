-- GUI System
-- Creates and manages all user interface elements for the Hive Store

HiveStore = HiveStore or {}
HiveStore.GUI = {}

-- GUI Elements
HiveStore.GUI.StoreFrame = nil
HiveStore.GUI.AdminFrame = nil
HiveStore.GUI.CurrentItems = {}
HiveStore.GUI.CurrentCategory = "ALL"

-- UI Colors and Styling
local function GetColors()
    return {
        primary = HiveStore.Config.UI.PrimaryColor,
        secondary = HiveStore.Config.UI.SecondaryColor,
        background = HiveStore.Config.UI.BackgroundColor,
        text = HiveStore.Config.UI.TextColor,
        accent = HiveStore.Config.UI.AccentColor,
        white = Color(255, 255, 255),
        black = Color(0, 0, 0),
        success = Color(76, 175, 80),
        error = Color(244, 67, 54),
        warning = Color(255, 152, 0)
    }
end

-- Create main store frame
function HiveStore.GUI.CreateStoreFrame()
    if IsValid(HiveStore.GUI.StoreFrame) then
        HiveStore.GUI.StoreFrame:Close()
    end
    
    local colors = GetColors()
    local scrW, scrH = ScrW(), ScrH()
    
    -- Main frame
    local frame = vgui.Create("DFrame")
    frame:SetSize(scrW * 0.8, scrH * 0.8)
    frame:Center()
    frame:SetTitle("")
    frame:SetVisible(true)
    frame:SetDraggable(true)
    frame:ShowCloseButton(true)
    frame:MakePopup()
    
    HiveStore.GUI.StoreFrame = frame
    
    frame.Paint = function(self, w, h)
        -- Background
        draw.RoundedBox(8, 0, 0, w, h, colors.background)
        
        -- Header
        draw.RoundedBoxEx(8, 0, 0, w, 60, colors.primary, true, true, false, false)
        
        -- Title
        draw.SimpleText("HIVE STORE", "DermaLarge", w/2, 30, colors.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    frame.OnClose = function()
        HiveStore.Client.StoreOpen = false
    end
    
    -- Create header panel
    local header = vgui.Create("DPanel", frame)
    header:SetPos(0, 0)
    header:SetSize(frame:GetWide(), 60)
    header.Paint = function() end
    
    -- Balance display
    local balanceLabel = vgui.Create("DLabel", header)
    balanceLabel:SetPos(20, 15)
    balanceLabel:SetSize(200, 30)
    balanceLabel:SetText("Balance: " .. HiveStore.Client.Balance .. " " .. HiveStore.Config.Currency)
    balanceLabel:SetFont("DermaDefault")
    balanceLabel:SetTextColor(colors.white)
    
    HiveStore.GUI.BalanceLabel = balanceLabel
    
    -- Refresh button
    local refreshBtn = vgui.Create("DButton", header)
    refreshBtn:SetPos(frame:GetWide() - 120, 15)
    refreshBtn:SetSize(100, 30)
    refreshBtn:SetText("Refresh")
    refreshBtn:SetTextColor(colors.white)
    refreshBtn.Paint = function(self, w, h)
        local col = self:IsHovered() and colors.secondary or colors.accent
        draw.RoundedBox(4, 0, 0, w, h, col)
    end
    refreshBtn.DoClick = function()
        HiveStore.Client.RefreshBalance()
    end
    
    -- Create content area
    local content = vgui.Create("DPanel", frame)
    content:SetPos(10, 70)
    content:SetSize(frame:GetWide() - 20, frame:GetTall() - 80)
    content.Paint = function() end
    
    -- Create category sidebar
    local sidebar = vgui.Create("DPanel", content)
    sidebar:SetPos(0, 0)
    sidebar:SetSize(150, content:GetTall())
    sidebar.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(50, 50, 50, 200))
    end
    
    -- Category list
    local categoryList = vgui.Create("DScrollPanel", sidebar)
    categoryList:SetPos(5, 5)
    categoryList:SetSize(140, sidebar:GetTall() - 10)
    
    -- Add "All Items" category
    local allBtn = vgui.Create("DButton", categoryList)
    allBtn:SetSize(130, 30)
    allBtn:SetText("All Items")
    allBtn:SetTextColor(colors.white)
    allBtn.Paint = function(self, w, h)
        local col = (HiveStore.GUI.CurrentCategory == "ALL" and colors.primary) or (self:IsHovered() and colors.secondary) or Color(70, 70, 70)
        draw.RoundedBox(4, 0, 0, w, h, col)
    end
    allBtn.DoClick = function()
        HiveStore.GUI.SetCategory("ALL")
    end
    
    -- Add category buttons
    local categories = HiveStore.GetAllCategories()
    for i, category in ipairs(categories) do
        local btn = vgui.Create("DButton", categoryList)
        btn:SetPos(0, i * 35)
        btn:SetSize(130, 30)
        btn:SetText(category)
        btn:SetTextColor(colors.white)
        btn.Paint = function(self, w, h)
            local col = (HiveStore.GUI.CurrentCategory == category and colors.primary) or (self:IsHovered() and colors.secondary) or Color(70, 70, 70)
            draw.RoundedBox(4, 0, 0, w, h, col)
        end
        btn.DoClick = function()
            HiveStore.GUI.SetCategory(category)
        end
    end
    
    -- Create items area
    local itemsArea = vgui.Create("DPanel", content)
    itemsArea:SetPos(160, 0)
    itemsArea:SetSize(content:GetWide() - 160, content:GetTall())
    itemsArea.Paint = function() end
    
    -- Items scroll panel
    local itemsScroll = vgui.Create("DScrollPanel", itemsArea)
    itemsScroll:SetPos(0, 0)
    itemsScroll:SetSize(itemsArea:GetWide(), itemsArea:GetTall())
    
    HiveStore.GUI.ItemsPanel = itemsScroll
    
    -- Load initial items
    HiveStore.Client.RequestItems("ALL")
end

-- Create admin panel
function HiveStore.GUI.CreateAdminFrame()
    if IsValid(HiveStore.GUI.AdminFrame) then
        HiveStore.GUI.AdminFrame:Close()
    end
    
    local colors = GetColors()
    local scrW, scrH = ScrW(), ScrH()
    
    local frame = vgui.Create("DFrame")
    frame:SetSize(600, 500)
    frame:Center()
    frame:SetTitle("Hive Store - Admin Panel")
    frame:SetVisible(true)
    frame:SetDraggable(true)
    frame:ShowCloseButton(true)
    frame:MakePopup()
    
    HiveStore.GUI.AdminFrame = frame
    
    frame.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, colors.background)
    end
    
    frame.OnClose = function()
        HiveStore.Client.AdminPanelOpen = false
    end
    
    -- Create tabs
    local sheet = vgui.Create("DPropertySheet", frame)
    sheet:SetPos(10, 30)
    sheet:SetSize(frame:GetWide() - 20, frame:GetTall() - 40)
    
    -- Player Management Tab
    local playerTab = vgui.Create("DPanel")
    playerTab.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(40, 40, 40))
    end
    
    HiveStore.GUI.CreatePlayerManagementTab(playerTab)
    sheet:AddSheet("Players", playerTab, "icon16/user.png")
    
    -- Item Management Tab
    local itemTab = vgui.Create("DPanel")
    itemTab.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(40, 40, 40))
    end
    
    HiveStore.GUI.CreateItemManagementTab(itemTab)
    sheet:AddSheet("Items", itemTab, "icon16/package.png")
    
    -- Statistics Tab
    local statsTab = vgui.Create("DPanel")
    statsTab.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(40, 40, 40))
    end
    
    HiveStore.GUI.CreateStatsTab(statsTab)
    sheet:AddSheet("Statistics", statsTab, "icon16/chart_bar.png")
end

-- Create player management tab
function HiveStore.GUI.CreatePlayerManagementTab(parent)
    local colors = GetColors()
    
    -- Player list
    local playerList = vgui.Create("DListView", parent)
    playerList:SetPos(10, 10)
    playerList:SetSize(parent:GetWide() - 20, 200)
    playerList:SetMultiSelect(false)
    playerList:AddColumn("Player")
    playerList:AddColumn("Balance")
    playerList:AddColumn("Total Spent")
    
    -- Populate player list
    for _, ply in pairs(player.GetAll()) do
        local balance = HiveStore.Database and HiveStore.Database.GetPlayerBalance(ply) or 0
        playerList:AddLine(ply:Name(), balance .. " PEK", "0 PEK")
    end
    
    -- Give PEK section
    local givePekLabel = vgui.Create("DLabel", parent)
    givePekLabel:SetPos(10, 220)
    givePekLabel:SetSize(200, 20)
    givePekLabel:SetText("Give PeakeCoin to Player:")
    givePekLabel:SetTextColor(colors.white)
    
    local amountEntry = vgui.Create("DNumberWang", parent)
    amountEntry:SetPos(10, 245)
    amountEntry:SetSize(100, 25)
    amountEntry:SetValue(100)
    
    local giveBtn = vgui.Create("DButton", parent)
    giveBtn:SetPos(120, 245)
    giveBtn:SetSize(100, 25)
    giveBtn:SetText("Give PEK")
    giveBtn.DoClick = function()
        local selectedLine = playerList:GetSelectedLine()
        if selectedLine then
            local playerName = playerList:GetLine(selectedLine):GetValue(1)
            local amount = amountEntry:GetValue()
            
            for _, ply in pairs(player.GetAll()) do
                if ply:Name() == playerName then
                    HiveStore.Client.SendAdminAction("give_pek", {
                        steamid = ply:SteamID(),
                        amount = amount
                    })
                    break
                end
            end
        end
    end
end

-- Create item management tab
function HiveStore.GUI.CreateItemManagementTab(parent)
    local colors = GetColors()
    
    -- Item list
    local itemList = vgui.Create("DListView", parent)
    itemList:SetPos(10, 10)
    itemList:SetSize(parent:GetWide() - 20, 300)
    itemList:SetMultiSelect(false)
    itemList:AddColumn("Item Name")
    itemList:AddColumn("Price")
    itemList:AddColumn("Category")
    itemList:AddColumn("Sellable")
    
    -- Populate item list
    for _, item in pairs(HiveStore.Items) do
        itemList:AddLine(item.name, item.price .. " PEK", item.category, item.sellable and "Yes" or "No")
    end
    
    -- Price modification section
    local priceLabel = vgui.Create("DLabel", parent)
    priceLabel:SetPos(10, 320)
    priceLabel:SetSize(200, 20)
    priceLabel:SetText("Set Item Price:")
    priceLabel:SetTextColor(colors.white)
    
    local priceEntry = vgui.Create("DNumberWang", parent)
    priceEntry:SetPos(10, 345)
    priceEntry:SetSize(100, 25)
    priceEntry:SetValue(100)
    
    local setPriceBtn = vgui.Create("DButton", parent)
    setPriceBtn:SetPos(120, 345)
    setPriceBtn:SetSize(100, 25)
    setPriceBtn:SetText("Set Price")
    setPriceBtn.DoClick = function()
        local selectedLine = itemList:GetSelectedLine()
        if selectedLine then
            local itemName = itemList:GetLine(selectedLine):GetValue(1)
            local newPrice = priceEntry:GetValue()
            
            -- Find item by name
            for _, item in pairs(HiveStore.Items) do
                if item.name == itemName then
                    HiveStore.Client.SendAdminAction("set_price", {
                        itemId = item.id,
                        price = newPrice
                    })
                    break
                end
            end
        end
    end
end

-- Create statistics tab
function HiveStore.GUI.CreateStatsTab(parent)
    local colors = GetColors()
    
    local statsLabel = vgui.Create("DLabel", parent)
    statsLabel:SetPos(10, 10)
    statsLabel:SetSize(parent:GetWide() - 20, 30)
    statsLabel:SetText("Store Statistics")
    statsLabel:SetFont("DermaLarge")
    statsLabel:SetTextColor(colors.white)
    
    -- Add some basic stats
    local totalItems = vgui.Create("DLabel", parent)
    totalItems:SetPos(10, 50)
    totalItems:SetSize(300, 20)
    totalItems:SetText("Total Items: " .. #HiveStore.Items)
    totalItems:SetTextColor(colors.white)
    
    local totalPlayers = vgui.Create("DLabel", parent)
    totalPlayers:SetPos(10, 75)
    totalPlayers:SetSize(300, 20)
    totalPlayers:SetText("Online Players: " .. #player.GetAll())
    totalPlayers:SetTextColor(colors.white)
end

-- Set category filter
function HiveStore.GUI.SetCategory(category)
    HiveStore.GUI.CurrentCategory = category
    HiveStore.Client.RequestItems(category)
end

-- Update item list
function HiveStore.GUI.UpdateItemList(items)
    if not IsValid(HiveStore.GUI.ItemsPanel) then return end
    
    HiveStore.GUI.ItemsPanel:Clear()
    HiveStore.GUI.CurrentItems = items
    
    local colors = GetColors()
    local itemsPerRow = 3
    local itemWidth = (HiveStore.GUI.ItemsPanel:GetWide() - 40) / itemsPerRow
    local itemHeight = 120
    
    for i, item in ipairs(items) do
        local row = math.floor((i - 1) / itemsPerRow)
        local col = (i - 1) % itemsPerRow
        
        local itemPanel = vgui.Create("DPanel", HiveStore.GUI.ItemsPanel)
        itemPanel:SetPos(col * (itemWidth + 10) + 10, row * (itemHeight + 10) + 10)
        itemPanel:SetSize(itemWidth - 10, itemHeight)
        
        itemPanel.Paint = function(self, w, h)
            local col = self:IsHovered() and colors.secondary or Color(60, 60, 60, 200)
            draw.RoundedBox(8, 0, 0, w, h, col)
            
            -- Draw item info
            draw.SimpleText(item.name, "DermaDefault", w/2, 10, colors.white, TEXT_ALIGN_CENTER)
            draw.SimpleText(item.price .. " " .. HiveStore.Config.Currency, "DermaDefault", w/2, 30, colors.accent, TEXT_ALIGN_CENTER)
            draw.SimpleText(item.category, "DermaDefault", w/2, 50, Color(200, 200, 200), TEXT_ALIGN_CENTER)
            
            if item.description then
                draw.SimpleText(item.description, "DermaDefault", w/2, 70, Color(180, 180, 180), TEXT_ALIGN_CENTER)
            end
        end
        
        -- Buy button
        local buyBtn = vgui.Create("DButton", itemPanel)
        buyBtn:SetPos(5, itemHeight - 30)
        buyBtn:SetSize(itemWidth/2 - 10, 25)
        buyBtn:SetText("Buy")
        buyBtn:SetTextColor(colors.white)
        buyBtn.Paint = function(self, w, h)
            local col = self:IsHovered() and Color(67, 160, 71) or colors.success
            draw.RoundedBox(4, 0, 0, w, h, col)
        end
        buyBtn.DoClick = function()
            HiveStore.Client.PurchaseItem(item.id)
        end
        
        -- Sell button (if sellable)
        if item.sellable then
            local sellBtn = vgui.Create("DButton", itemPanel)
            sellBtn:SetPos(itemWidth/2 + 5, itemHeight - 30)
            sellBtn:SetSize(itemWidth/2 - 15, 25)
            sellBtn:SetText("Sell (" .. (item.sellPrice or 0) .. ")")
            sellBtn:SetTextColor(colors.white)
            sellBtn.Paint = function(self, w, h)
                local col = self:IsHovered() and Color(255, 171, 64) or colors.warning
                draw.RoundedBox(4, 0, 0, w, h, col)
            end
            sellBtn.DoClick = function()
                HiveStore.Client.SellItem(item.id)
            end
        end
    end
end

-- Update balance display
function HiveStore.GUI.UpdateBalance(balance)
    if IsValid(HiveStore.GUI.BalanceLabel) then
        HiveStore.GUI.BalanceLabel:SetText("Balance: " .. balance .. " " .. HiveStore.Config.Currency)
    end
end

-- Update admin balance display
function HiveStore.GUI.UpdateAdminBalance(balance)
    -- Admin panel balance update if needed
end
