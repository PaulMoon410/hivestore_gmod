-- Chat Commands and Console Commands
-- Handles all player and admin commands for the Hive Store

HiveStore = HiveStore or {}
HiveStore.Commands = {}

-- Initialize command system
function HiveStore.Commands.Initialize()
    print("[Hive Store] Initializing command system...")
    
    -- Register chat commands
    HiveStore.Commands.RegisterChatCommands()
    
    -- Register console commands
    HiveStore.Commands.RegisterConsoleCommands()
    
    print("[Hive Store] Command system initialized!")
end

-- Register chat commands
function HiveStore.Commands.RegisterChatCommands()
    hook.Add("PlayerSay", "HiveStore.ChatCommands", function(ply, text, team)
        local args = string.Explode(" ", string.lower(text))
        local command = args[1]
        
        -- Store commands
        if command == "!store" or command == "/store" then
            HiveStore.Commands.OpenStore(ply)
            return ""
        elseif command == "!wallet" or command == "/wallet" or command == "!balance" or command == "/balance" then
            HiveStore.Commands.ShowWallet(ply)
            return ""
        elseif command == "!buy" or command == "/buy" then
            if args[2] then
                HiveStore.Commands.QuickBuy(ply, args[2])
            else
                ply:ChatPrint("[Hive Store] Usage: !buy <item_id>")
            end
            return ""
        elseif command == "!sell" or command == "/sell" then
            if args[2] then
                HiveStore.Commands.QuickSell(ply, args[2])
            else
                ply:ChatPrint("[Hive Store] Usage: !sell <item_id>")
            end
            return ""
        elseif command == "!refresh" or command == "/refresh" then
            HiveStore.Commands.RefreshBalance(ply)
            return ""
        end
        
        -- Admin commands
        if HiveStore.Server.IsPlayerAdmin(ply) then
            if command == "!storeadmin" or command == "/storeadmin" then
                HiveStore.Commands.OpenAdminPanel(ply)
                return ""
            elseif command == "!givepek" or command == "/givepek" then
                if args[2] and args[3] then
                    local target = HiveStore.Commands.FindPlayer(args[2])
                    local amount = tonumber(args[3])
                    if target and amount then
                        HiveStore.Commands.GivePeakeCoin(ply, target, amount)
                    else
                        ply:ChatPrint("[Hive Store] Usage: !givepek <player> <amount>")
                    end
                else
                    ply:ChatPrint("[Hive Store] Usage: !givepek <player> <amount>")
                end
                return ""
            elseif command == "!setprice" or command == "/setprice" then
                if args[2] and args[3] then
                    HiveStore.Commands.SetItemPrice(ply, args[2], tonumber(args[3]))
                else
                    ply:ChatPrint("[Hive Store] Usage: !setprice <item_id> <price>")
                end
                return ""
            end
        end
    end)
end

-- Register console commands
function HiveStore.Commands.RegisterConsoleCommands()
    concommand.Add("hive_store_open", function(ply, cmd, args)
        if IsValid(ply) then
            HiveStore.Commands.OpenStore(ply)
        end
    end)
    
    concommand.Add("hive_store_wallet", function(ply, cmd, args)
        if IsValid(ply) then
            HiveStore.Commands.ShowWallet(ply)
        end
    end)
    
    concommand.Add("hive_store_refresh", function(ply, cmd, args)
        if IsValid(ply) then
            HiveStore.Commands.RefreshBalance(ply)
        end
    end)
end

-- Open store interface
function HiveStore.Commands.OpenStore(ply)
    if not IsValid(ply) then return end
    
    net.Start("HiveStore.OpenGUI")
    net.Send(ply)
    
    ply:ChatPrint("[Hive Store] Opening store interface...")
end

-- Show wallet information
function HiveStore.Commands.ShowWallet(ply)
    if not IsValid(ply) then return end
    
    local balance = HiveStore.Database.GetPlayerBalance(ply)
    local playerData = HiveStore.Database.GetPlayerData(ply)
    
    ply:ChatPrint("============= HIVE WALLET =============")
    ply:ChatPrint("Balance: " .. balance .. " " .. HiveStore.Config.Currency)
    
    if playerData then
        ply:ChatPrint("Total Spent: " .. playerData.total_spent .. " " .. HiveStore.Config.Currency)
        ply:ChatPrint("Total Earned: " .. playerData.total_earned .. " " .. HiveStore.Config.Currency)
        ply:ChatPrint("Purchases: " .. #playerData.purchases)
    end
    
    ply:ChatPrint("=====================================")
end

-- Quick buy item
function HiveStore.Commands.QuickBuy(ply, itemId)
    if not IsValid(ply) then return end
    
    local item = HiveStore.GetItemById(itemId)
    if not item then
        ply:ChatPrint("[Hive Store] Item not found: " .. itemId)
        return
    end
    
    if item.adminOnly and not HiveStore.Server.IsPlayerAdmin(ply) then
        ply:ChatPrint("[Hive Store] This item requires admin privileges!")
        return
    end
    
    HiveStore.Commands.PurchaseItem(ply, item)
end

-- Quick sell item
function HiveStore.Commands.QuickSell(ply, itemId)
    if not IsValid(ply) then return end
    
    local item = HiveStore.GetItemById(itemId)
    if not item then
        ply:ChatPrint("[Hive Store] Item not found: " .. itemId)
        return
    end
    
    if not item.sellable then
        ply:ChatPrint("[Hive Store] This item cannot be sold!")
        return
    end
    
    HiveStore.Commands.SellItem(ply, item)
end

-- Purchase item
function HiveStore.Commands.PurchaseItem(ply, item)
    if not IsValid(ply) then return end
    
    HiveStore.PeakeCoin.ProcessPurchase(ply, item, function(success, message)
        if success then
            -- Give item to player
            HiveStore.Commands.GiveItemToPlayer(ply, item)
            ply:ChatPrint("[Hive Store] Successfully purchased " .. item.name .. " for " .. item.price .. " " .. HiveStore.Config.Currency)
            ply:EmitSound(HiveStore.Config.Sounds.Purchase)
            
            -- Update client balance
            net.Start("HiveStore.UpdateBalance")
            net.WriteInt(HiveStore.Database.GetPlayerBalance(ply), 32)
            net.Send(ply)
        else
            ply:ChatPrint("[Hive Store] Purchase failed: " .. message)
            ply:EmitSound(HiveStore.Config.Sounds.Error)
        end
    end)
end

-- Sell item
function HiveStore.Commands.SellItem(ply, item)
    if not IsValid(ply) then return end
    
    -- Check if player has the item (simplified check)
    if not ply:HasWeapon(item.class) and item.category == HiveStore.ItemCategories.WEAPON then
        ply:ChatPrint("[Hive Store] You don't have this item to sell!")
        return
    end
    
    HiveStore.PeakeCoin.ProcessSell(ply, item, function(success, message)
        if success then
            -- Remove item from player
            if item.category == HiveStore.ItemCategories.WEAPON and ply:HasWeapon(item.class) then
                ply:StripWeapon(item.class)
            end
            
            ply:ChatPrint("[Hive Store] Successfully sold " .. item.name .. " for " .. item.sellPrice .. " " .. HiveStore.Config.Currency)
            ply:EmitSound(HiveStore.Config.Sounds.Sell)
            
            -- Update client balance
            net.Start("HiveStore.UpdateBalance")
            net.WriteInt(HiveStore.Database.GetPlayerBalance(ply), 32)
            net.Send(ply)
        else
            ply:ChatPrint("[Hive Store] Sale failed: " .. message)
            ply:EmitSound(HiveStore.Config.Sounds.Error)
        end
    end)
end

-- Give item to player
function HiveStore.Commands.GiveItemToPlayer(ply, item)
    if not IsValid(ply) then return end
    
    if item.spawnType == "vehicle" then
        -- Spawn vehicle near player
        local pos = ply:GetPos() + ply:GetForward() * 200
        local ent = ents.Create(item.class)
        ent:SetPos(pos)
        ent:Spawn()
        ent:SetOwner(ply)
    elseif item.spawnType == "entity" then
        -- Spawn entity near player
        local pos = ply:GetPos() + ply:GetForward() * 100
        local ent = ents.Create(item.class)
        ent:SetPos(pos)
        ent:Spawn()
    elseif item.spawnType == "prop" then
        -- Spawn prop near player
        local pos = ply:GetPos() + ply:GetForward() * 100
        local ent = ents.Create("prop_physics")
        ent:SetModel(item.model)
        ent:SetPos(pos)
        ent:Spawn()
    else
        -- Default: give as weapon
        ply:Give(item.class)
    end
end

-- Refresh player balance
function HiveStore.Commands.RefreshBalance(ply)
    if not IsValid(ply) then return end
    
    ply:ChatPrint("[Hive Store] Refreshing PeakeCoin balance...")
    
    HiveStore.PeakeCoin.UpdatePlayerBalance(ply, function(success, result)
        if success then
            local balance = HiveStore.Database.GetPlayerBalance(ply)
            ply:ChatPrint("[Hive Store] Balance updated: " .. balance .. " " .. HiveStore.Config.Currency)
            
            -- Update client
            net.Start("HiveStore.UpdateBalance")
            net.WriteInt(balance, 32)
            net.Send(ply)
        else
            ply:ChatPrint("[Hive Store] Failed to refresh balance: " .. result)
        end
    end)
end

-- Admin: Open admin panel
function HiveStore.Commands.OpenAdminPanel(ply)
    if not IsValid(ply) or not HiveStore.Server.IsPlayerAdmin(ply) then return end
    
    net.Start("HiveStore.OpenAdminGUI")
    net.Send(ply)
end

-- Admin: Give PeakeCoin to player
function HiveStore.Commands.GivePeakeCoin(admin, target, amount)
    if not IsValid(admin) or not IsValid(target) or not HiveStore.Server.IsPlayerAdmin(admin) then return end
    
    if not HiveStore.Config.Admin.AllowPlayerGivePEK then
        admin:ChatPrint("[Hive Store] Giving PEK to players is disabled!")
        return
    end
    
    HiveStore.Database.AddPlayerBalance(target, amount)
    
    admin:ChatPrint("[Hive Store] Gave " .. amount .. " " .. HiveStore.Config.Currency .. " to " .. target:Name())
    target:ChatPrint("[Hive Store] You received " .. amount .. " " .. HiveStore.Config.Currency .. " from " .. admin:Name())
    
    -- Update target's client
    net.Start("HiveStore.UpdateBalance")
    net.WriteInt(HiveStore.Database.GetPlayerBalance(target), 32)
    net.Send(target)
end

-- Admin: Set item price
function HiveStore.Commands.SetItemPrice(admin, itemId, price)
    if not IsValid(admin) or not HiveStore.Server.IsPlayerAdmin(admin) then return end
    
    local item = HiveStore.GetItemById(itemId)
    if not item then
        admin:ChatPrint("[Hive Store] Item not found: " .. itemId)
        return
    end
    
    item.price = price
    admin:ChatPrint("[Hive Store] Set price of " .. item.name .. " to " .. price .. " " .. HiveStore.Config.Currency)
end

-- Find player by partial name
function HiveStore.Commands.FindPlayer(name)
    name = string.lower(name)
    
    for _, ply in pairs(player.GetAll()) do
        if string.find(string.lower(ply:Name()), name, 1, true) then
            return ply
        end
    end
    
    return nil
end

-- Initialize commands
HiveStore.Commands.Initialize()
