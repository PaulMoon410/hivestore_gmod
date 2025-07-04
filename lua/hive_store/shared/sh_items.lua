-- Shared Items Database
-- Defines all items available in the Hive Store

HiveStore = HiveStore or {}
HiveStore.Items = {}

-- Item Categories
HiveStore.ItemCategories = {
    WEAPON = "Weapons",
    TOOL = "Tools",
    VEHICLE = "Vehicles",
    PROP = "Props",
    COSMETIC = "Cosmetics",
    UTILITY = "Utilities"
}

-- Define store items
HiveStore.Items = {
    -- Weapons
    {
        id = "weapon_pistol",
        name = "Pistol",
        description = "A basic pistol for self-defense",
        price = 50,
        category = HiveStore.ItemCategories.WEAPON,
        class = "weapon_pistol",
        model = "models/weapons/w_pistol.mdl",
        icon = "icon16/gun.png",
        sellable = true,
        sellPrice = 25,
        adminOnly = false
    },
    {
        id = "weapon_smg1",
        name = "SMG",
        description = "Submachine gun with high rate of fire",
        price = 150,
        category = HiveStore.ItemCategories.WEAPON,
        class = "weapon_smg1",
        model = "models/weapons/w_smg1.mdl",
        icon = "icon16/gun.png",
        sellable = true,
        sellPrice = 75,
        adminOnly = false
    },
    {
        id = "weapon_shotgun",
        name = "Shotgun",
        description = "Powerful close-range weapon",
        price = 200,
        category = HiveStore.ItemCategories.WEAPON,
        class = "weapon_shotgun",
        model = "models/weapons/w_shotgun.mdl",
        icon = "icon16/gun.png",
        sellable = true,
        sellPrice = 100,
        adminOnly = false
    },
    {
        id = "weapon_ar2",
        name = "AR2 Rifle",
        description = "Advanced assault rifle",
        price = 300,
        category = HiveStore.ItemCategories.WEAPON,
        class = "weapon_ar2",
        model = "models/weapons/w_irifle.mdl",
        icon = "icon16/gun.png",
        sellable = true,
        sellPrice = 150,
        adminOnly = true
    },
    
    -- Tools
    {
        id = "weapon_crowbar",
        name = "Crowbar",
        description = "Useful for breaking things",
        price = 25,
        category = HiveStore.ItemCategories.TOOL,
        class = "weapon_crowbar",
        model = "models/weapons/w_crowbar.mdl",
        icon = "icon16/wrench.png",
        sellable = true,
        sellPrice = 12,
        adminOnly = false
    },
    {
        id = "weapon_physgun",
        name = "Physics Gun",
        description = "Manipulate physics objects",
        price = 500,
        category = HiveStore.ItemCategories.TOOL,
        class = "weapon_physgun",
        model = "models/weapons/w_physics.mdl",
        icon = "icon16/wand.png",
        sellable = true,
        sellPrice = 250,
        adminOnly = true
    },
    {
        id = "gmod_tool",
        name = "Tool Gun",
        description = "Swiss army knife of tools",
        price = 400,
        category = HiveStore.ItemCategories.TOOL,
        class = "gmod_tool",
        model = "models/weapons/w_toolgun.mdl",
        icon = "icon16/wrench_orange.png",
        sellable = true,
        sellPrice = 200,
        adminOnly = true
    },
    
    -- Vehicles
    {
        id = "gmod_sent_vehicle_fphysics_car",
        name = "Car",
        description = "A basic vehicle for transportation",
        price = 800,
        category = HiveStore.ItemCategories.VEHICLE,
        class = "gmod_sent_vehicle_fphysics_car",
        model = "models/buggy.mdl",
        icon = "icon16/car.png",
        sellable = true,
        sellPrice = 400,
        adminOnly = false,
        spawnType = "vehicle"
    },
    {
        id = "gmod_sent_vehicle_fphysics_helicopter",
        name = "Helicopter",
        description = "Aerial vehicle for quick travel",
        price = 1500,
        category = HiveStore.ItemCategories.VEHICLE,
        class = "gmod_sent_vehicle_fphysics_helicopter",
        model = "models/combine_helicopter.mdl",
        icon = "icon16/car.png",
        sellable = true,
        sellPrice = 750,
        adminOnly = true,
        spawnType = "vehicle"
    },
    
    -- Props/Entities
    {
        id = "prop_health_kit",
        name = "Health Kit",
        description = "Restores health when used",
        price = 75,
        category = HiveStore.ItemCategories.UTILITY,
        class = "item_healthkit",
        model = "models/items/healthkit.mdl",
        icon = "icon16/heart.png",
        sellable = true,
        sellPrice = 35,
        adminOnly = false,
        spawnType = "entity"
    },
    {
        id = "prop_suit_battery",
        name = "Suit Battery",
        description = "Recharges suit power",
        price = 50,
        category = HiveStore.ItemCategories.UTILITY,
        class = "item_battery",
        model = "models/items/battery.mdl",
        icon = "icon16/lightning.png",
        sellable = true,
        sellPrice = 25,
        adminOnly = false,
        spawnType = "entity"
    },
    
    -- Cosmetics
    {
        id = "cosmetic_hat",
        name = "Hat",
        description = "Stylish headwear",
        price = 100,
        category = HiveStore.ItemCategories.COSMETIC,
        class = "cosmetic_hat",
        model = "models/props_junk/cardboard_box004a.mdl",
        icon = "icon16/user.png",
        sellable = true,
        sellPrice = 50,
        adminOnly = false,
        spawnType = "prop"
    }
}

-- Helper functions for item management
function HiveStore.GetItemById(id)
    for _, item in pairs(HiveStore.Items) do
        if item.id == id then
            return item
        end
    end
    return nil
end

function HiveStore.GetItemsByCategory(category)
    local items = {}
    for _, item in pairs(HiveStore.Items) do
        if item.category == category then
            table.insert(items, item)
        end
    end
    return items
end

function HiveStore.GetAllCategories()
    local categories = {}
    for _, item in pairs(HiveStore.Items) do
        if not table.HasValue(categories, item.category) then
            table.insert(categories, item.category)
        end
    end
    return categories
end

-- Validate item data
function HiveStore.ValidateItems()
    for i, item in pairs(HiveStore.Items) do
        if not item.id or not item.name or not item.price then
            print("[Hive Store] ERROR: Invalid item at index " .. i)
            return false
        end
    end
    return true
end

-- Initialize validation
if HiveStore.ValidateItems() then
    print("[Hive Store] Items database loaded successfully - " .. #HiveStore.Items .. " items")
else
    print("[Hive Store] ERROR: Items database validation failed!")
end
