-- Hive Store Configuration
-- Configure all settings for the Hive Store addon

HiveStore = HiveStore or {}
HiveStore.Config = {}

-- General Settings
HiveStore.Config.StoreName = "Hive Store"
HiveStore.Config.Currency = "PEK"
HiveStore.Config.CurrencySymbol = "⚡"

-- PeakeCoin Integration
HiveStore.Config.PeakeCoin = {
    APIEndpoint = "https://api.hive-engine.com/rpc",
    HiveAPIEndpoint = "https://api.hive.blog",
    TokenSymbol = "PEK",
    SwapSymbol = "SWAP.HIVE",
    DefaultBalance = 100, -- Starting PeakeCoin for new players
    RefreshInterval = 30 -- Seconds between balance updates
}

-- Store Settings
HiveStore.Config.Store = {
    MaxItemsPerPage = 12,
    Categories = {
        "Weapons",
        "Tools", 
        "Vehicles",
        "Props",
        "Cosmetics",
        "Utilities"
    },
    DefaultCategory = "Weapons"
}

-- UI Settings
HiveStore.Config.UI = {
    OpenKey = KEY_F4,
    PrimaryColor = Color(46, 125, 50),
    SecondaryColor = Color(76, 175, 80),
    BackgroundColor = Color(33, 33, 33, 240),
    TextColor = Color(255, 255, 255),
    AccentColor = Color(255, 235, 59)
}

-- Admin Settings
HiveStore.Config.Admin = {
    Groups = {"superadmin", "admin"}, -- Groups that can access admin panel
    AllowPlayerGivePEK = false, -- Allow admins to give PEK to players
    LogTransactions = true -- Log all transactions to console
}

-- Database Settings
HiveStore.Config.Database = {
    Type = "sqlite", -- sqlite or mysql
    TablePrefix = "hivestore_",
    AutoSave = true,
    SaveInterval = 60 -- Seconds between auto-saves
}

-- Sound Settings
HiveStore.Config.Sounds = {
    Purchase = "buttons/button14.wav",
    Sell = "buttons/button15.wav",
    Error = "buttons/button10.wav",
    Success = "buttons/combine_button7.wav"
}

-- Network Settings
HiveStore.Config.Network = {
    MaxRequestsPerMinute = 10, -- Rate limiting per player
    RequestTimeout = 30 -- Seconds before timing out requests
}
