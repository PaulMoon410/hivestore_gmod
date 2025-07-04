-- Example Configuration for Hive Store
-- Copy and modify this file to customize your store

HiveStore = HiveStore or {}
HiveStore.Config = {}

-- =========================
-- GENERAL STORE SETTINGS
-- =========================

HiveStore.Config.StoreName = "PeakeCoin Marketplace"
HiveStore.Config.Currency = "PEK"
HiveStore.Config.CurrencySymbol = "⚡"
HiveStore.Config.StoreDescription = "Buy and sell items with PeakeCoin!"

-- =========================
-- PEAKECOIN INTEGRATION
-- =========================

HiveStore.Config.PeakeCoin = {
    -- Hive Engine API endpoint
    APIEndpoint = "https://api.hive-engine.com/rpc",
    
    -- Hive blockchain API
    HiveAPIEndpoint = "https://api.hive.blog",
    
    -- Token settings
    TokenSymbol = "PEK",
    SwapSymbol = "SWAP.HIVE",
    
    -- New player starting balance
    DefaultBalance = 500,
    
    -- How often to refresh balances (seconds)
    RefreshInterval = 60,
    
    -- Enable real blockchain transactions (requires setup)
    UseRealTransactions = false,
    
    -- Transaction fee (percentage of transaction)
    TransactionFee = 0.01, -- 1%
    
    -- Minimum transaction amount
    MinTransactionAmount = 1
}

-- =========================
-- STORE CONFIGURATION
-- =========================

HiveStore.Config.Store = {
    -- Items per page in store
    MaxItemsPerPage = 15,
    
    -- Available categories
    Categories = {
        "Weapons",
        "Tools", 
        "Vehicles",
        "Props",
        "Cosmetics",
        "Utilities",
        "Special Items"
    },
    
    -- Default category when opening store
    DefaultCategory = "Weapons",
    
    -- Enable item selling
    AllowSelling = true,
    
    -- Sell price multiplier (percentage of buy price)
    SellPriceMultiplier = 0.5, -- 50% of purchase price
    
    -- Enable item previews
    EnablePreviews = true,
    
    -- Maximum items a player can own
    MaxOwnedItems = 100
}

-- =========================
-- USER INTERFACE SETTINGS
-- =========================

HiveStore.Config.UI = {
    -- Key to open store (see KEY_* constants)
    OpenKey = KEY_F4,
    
    -- Alternative key binding
    AlternateKey = KEY_B,
    
    -- Color scheme
    PrimaryColor = Color(46, 125, 50),      -- Green
    SecondaryColor = Color(76, 175, 80),    -- Light Green
    BackgroundColor = Color(33, 33, 33, 240), -- Dark Gray
    TextColor = Color(255, 255, 255),       -- White
    AccentColor = Color(255, 235, 59),      -- Yellow
    ErrorColor = Color(244, 67, 54),        -- Red
    SuccessColor = Color(76, 175, 80),      -- Green
    
    -- Animation settings
    AnimationSpeed = 0.3,
    EnableAnimations = true,
    
    -- Font sizes
    HeaderFont = "DermaLarge",
    BodyFont = "DermaDefault",
    SmallFont = "DermaDefaultBold",
    
    -- Window settings
    WindowWidth = 0.8,  -- Percentage of screen width
    WindowHeight = 0.8, -- Percentage of screen height
    
    -- Enable item icons
    ShowItemIcons = true,
    
    -- Show item descriptions
    ShowDescriptions = true
}

-- =========================
-- ADMIN SETTINGS
-- =========================

HiveStore.Config.Admin = {
    -- User groups that have admin access
    Groups = {"superadmin", "admin", "moderator"},
    
    -- Allow admins to give PEK to players
    AllowPlayerGivePEK = true,
    
    -- Allow admins to modify item prices in real-time
    AllowPriceModification = true,
    
    -- Allow admins to add/remove items
    AllowItemManagement = true,
    
    -- Log all transactions to console
    LogTransactions = true,
    
    -- Log all admin actions
    LogAdminActions = true,
    
    -- Maximum PEK an admin can give at once
    MaxGiveAmount = 10000,
    
    -- Enable admin notifications for purchases
    NotifyAdminPurchases = false
}

-- =========================
-- DATABASE SETTINGS
-- =========================

HiveStore.Config.Database = {
    -- Database type: "sqlite" or "mysql"
    Type = "sqlite",
    
    -- Table prefix for database tables
    TablePrefix = "hivestore_",
    
    -- Auto-save player data
    AutoSave = true,
    
    -- Save interval in seconds
    SaveInterval = 300, -- 5 minutes
    
    -- Backup settings
    CreateBackups = true,
    BackupInterval = 3600, -- 1 hour
    MaxBackups = 24, -- Keep 24 backups
    
    -- MySQL settings (if using MySQL)
    MySQL = {
        Host = "localhost",
        Port = 3306,
        Database = "hivestore",
        Username = "hivestore_user",
        Password = "your_password_here"
    }
}

-- =========================
-- SOUND SETTINGS
-- =========================

HiveStore.Config.Sounds = {
    -- Sound when purchasing items
    Purchase = "buttons/button14.wav",
    
    -- Sound when selling items
    Sell = "buttons/button15.wav",
    
    -- Sound for errors
    Error = "buttons/button10.wav",
    
    -- Sound for successful actions
    Success = "buttons/combine_button7.wav",
    
    -- Sound when opening store
    OpenStore = "buttons/button9.wav",
    
    -- Sound when closing store
    CloseStore = "buttons/button8.wav",
    
    -- Enable sounds
    EnableSounds = true,
    
    -- Volume multiplier
    Volume = 1.0
}

-- =========================
-- NETWORK SETTINGS
-- =========================

HiveStore.Config.Network = {
    -- Rate limiting: max requests per minute per player
    MaxRequestsPerMinute = 20,
    
    -- Request timeout in seconds
    RequestTimeout = 30,
    
    -- Enable compression for large data transfers
    EnableCompression = true,
    
    -- Maximum packet size
    MaxPacketSize = 65536
}

-- =========================
-- ECONOMY SETTINGS
-- =========================

HiveStore.Config.Economy = {
    -- Enable dynamic pricing based on demand
    DynamicPricing = false,
    
    -- Price change percentage per purchase
    PriceIncreaseRate = 0.05, -- 5% increase per purchase
    
    -- Maximum price multiplier
    MaxPriceMultiplier = 2.0, -- 200% of base price
    
    -- Price decay rate (return to normal over time)
    PriceDecayRate = 0.01, -- 1% per hour
    
    -- Enable sales/discounts
    EnableSales = true,
    
    -- Random discount chance (0-1)
    RandomDiscountChance = 0.1, -- 10% chance
    
    -- Random discount amount (0-1)
    RandomDiscountAmount = 0.2 -- 20% discount
}

-- =========================
-- SPECIAL FEATURES
-- =========================

HiveStore.Config.Features = {
    -- Enable player-to-player trading
    EnableTrading = false,
    
    -- Enable gift system
    EnableGifts = false,
    
    -- Enable wish list
    EnableWishList = false,
    
    -- Enable purchase history
    EnableHistory = true,
    
    -- Enable item reviews/ratings
    EnableRatings = false,
    
    -- Enable daily login bonuses
    EnableDailyBonus = true,
    DailyBonusAmount = 10,
    
    -- Enable referral system
    EnableReferrals = false,
    ReferralBonus = 50
}

-- =========================
-- SECURITY SETTINGS
-- =========================

HiveStore.Config.Security = {
    -- Enable anti-spam protection
    AntiSpam = true,
    
    -- Minimum time between purchases (seconds)
    PurchaseCooldown = 1,
    
    -- Maximum concurrent transactions per player
    MaxConcurrentTransactions = 3,
    
    -- Enable transaction verification
    VerifyTransactions = true,
    
    -- Log suspicious activity
    LogSuspiciousActivity = true
}

-- =========================
-- CUSTOM MESSAGES
-- =========================

HiveStore.Config.Messages = {
    WelcomeMessage = "Welcome to the Hive Store! Press F4 to browse items.",
    InsufficientFunds = "You don't have enough PeakeCoin for this purchase!",
    PurchaseSuccess = "Purchase successful! Enjoy your new item.",
    SellSuccess = "Item sold successfully!",
    ItemNotFound = "The requested item could not be found.",
    StoreDisabled = "The store is currently disabled.",
    AdminOnly = "This item is only available to administrators.",
    PurchaseFailed = "Purchase failed. Please try again.",
    BalanceUpdated = "Your PeakeCoin balance has been updated!"
}

-- Apply some validation
if HiveStore.Config.Store.SellPriceMultiplier > 1.0 then
    HiveStore.Config.Store.SellPriceMultiplier = 1.0
    print("[Hive Store] Warning: Sell price multiplier cannot exceed 100%")
end

if HiveStore.Config.PeakeCoin.DefaultBalance < 0 then
    HiveStore.Config.PeakeCoin.DefaultBalance = 0
    print("[Hive Store] Warning: Default balance cannot be negative")
end
