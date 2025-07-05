-- Younger Brother Shopkeeper NPC
-- Server-side initialization

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.Base = "base_ai"
ENT.Type = "ai"

-- NPC Data
ENT.NPCName = "Cletus 'Clete' McCoy"
ENT.NPCDescription = "Younger brother, specializes in weapons and tools"
ENT.ShopType = "weapons_tools" -- Specializes in weapons and tools

function ENT:Initialize()
    self:SetModel("models/player/group01/male_02.mdl")
    self:SetHullType(HULL_HUMAN)
    self:SetHullSizeNormal()
    self:SetNPCState(NPC_STATE_SCRIPT)
    self:SetSolid(SOLID_BBOX)
    self:CapabilitiesAdd(CAP_ANIMATEDFACE + CAP_TURN_HEAD)
    self:SetUseType(SIMPLE_USE)
    self:DropToFloor()
    
    -- Customize appearance for younger hillbilly look
    self:SetSkin(0) -- Lighter skin
    self:SetBodygroup(1, 0) -- Less facial hair
    
    -- Set health
    self:SetHealth(1000)
    self:SetMaxHealth(1000)
    
    -- Schedule thinking
    self:SetThink(self.Think)
    self:NextThink(CurTime() + 1)
    
    -- Initialize dialogue system
    self:InitializeDialogue()
    
    print("[Hive Store] Younger Brother NPC spawned: " .. self.NPCName)
end

function ENT:InitializeDialogue()
    self.Dialogue = {
        greetings = {
            "Hey there, mister! I'm Cletus, but folks call me Clete!",
            "Howdy! My big brother Jeb runs the main store, but I got the good stuff!",
            "Well hello! You look like someone who appreciates fine weaponry!",
            "Welcome to my corner! I got the best guns and tools this side of the mountain!"
        },
        shop_talk = {
            "I know everything there is to know about guns and tools!",
            "Been huntin' and fixin' things since I was knee-high to a grasshopper!",
            "Jeb handles the fancy stuff, but when you need real firepower, you come to me!",
            "Every weapon I sell, I've tested myself out in them hills!",
            "PeakeCoin's mighty fine currency - way better than them old paper bills!"
        },
        weapon_talk = {
            "This here pistol? Shot my first deer with one just like it!",
            "Tools are important too - can't fix nothin' without proper tools!",
            "I can tell you stories about every gun I got in stock!",
            "Quality over quantity, that's what Pa always said!"
        },
        farewells = {
            "Happy huntin', partner!",
            "Don't go shootin' your eye out now!",
            "Come back when you need more firepower!",
            "Tell Jeb I said hey!"
        }
    }
    
    self.lastDialogue = 0
    self.dialogueType = "greetings"
    self.excitement = 0
end

function ENT:Use(activator, caller)
    if not IsValid(activator) or not activator:IsPlayer() then return end
    
    -- Face the player with more enthusiasm
    local ang = (activator:GetPos() - self:GetPos()):Angle()
    ang.p = 0
    ang.r = 0
    self:SetAngles(ang)
    
    -- Show dialogue
    self:ShowDialogue(activator)
    
    -- Open specialized store after a delay
    timer.Simple(2.5, function()
        if IsValid(activator) then
            self:OpenSpecializedStore(activator)
        end
    end)
end

function ENT:ShowDialogue(player)
    if not IsValid(player) then return end
    
    local currentTime = CurTime()
    if currentTime - self.lastDialogue < 3 then return end -- Prevent spam
    
    -- Choose dialogue based on excitement level
    local dialogueOptions = {"shop_talk", "weapon_talk"}
    if self.dialogueType == "greetings" then
        dialogueOptions = {"greetings"}
    elseif self.dialogueType == "farewells" then
        dialogueOptions = {"farewells"}
    end
    
    local chosenType = dialogueOptions[math.random(1, #dialogueOptions)]
    local dialogue = self.Dialogue[chosenType]
    
    if dialogue and #dialogue > 0 then
        local message = dialogue[math.random(1, #dialogue)]
        
        -- Send dialogue to player
        player:ChatPrint("[" .. self.NPCName .. "] " .. message)
        
        -- Play sound (younger brother is more excited)
        self:EmitSound("vo/npc/male01/hi0" .. math.random(1, 2) .. ".wav", 75, math.random(110, 130))
    end
    
    self.lastDialogue = currentTime
    self.excitement = math.min(self.excitement + 1, 3)
    
    -- Cycle dialogue types
    if self.dialogueType == "greetings" then
        self.dialogueType = "shop_talk"
    elseif self.dialogueType == "shop_talk" then
        self.dialogueType = "weapon_talk"
    elseif self.dialogueType == "weapon_talk" then
        self.dialogueType = "farewells"
    else
        self.dialogueType = "greetings"
        self.excitement = 0
    end
end

function ENT:OpenSpecializedStore(player)
    if not IsValid(player) then return end
    
    -- Send specialized store data
    net.Start("HiveStore.OpenSpecializedStore")
    net.WriteString(self.ShopType)
    net.WriteString(self.NPCName)
    net.Send(player)
    
    -- Show store message
    player:ChatPrint("[" .. self.NPCName .. "] Here's my collection of fine weapons and tools!")
end

function ENT:Think()
    -- More animated than elder brother
    if math.random(1, 80) == 1 then
        -- Random excited gestures
        local activities = {ACT_IDLE, ACT_IDLE_RELAXED, ACT_IDLE_STIMULATED}
        local activity = activities[math.random(1, #activities)]
        self:StartActivity(activity)
    end
    
    -- Look around more frequently (younger brother is more alert)
    if math.random(1, 150) == 1 then
        local players = player.GetAll()
        if #players > 0 then
            local target = players[math.random(1, #players)]
            if IsValid(target) and target:GetPos():Distance(self:GetPos()) < 600 then
                local ang = (target:GetPos() - self:GetPos()):Angle()
                ang.p = 0
                ang.r = 0
                self:SetAngles(ang)
                
                -- Occasionally wave at distant players
                if target:GetPos():Distance(self:GetPos()) > 300 then
                    self:StartActivity(ACT_SIGNAL3)
                end
            end
        end
    end
    
    -- Random weapon maintenance animation
    if math.random(1, 400) == 1 then
        self:EmitSound("weapons/pistol/pistol_reload1.wav", 60)
    end
    
    self:NextThink(CurTime() + 0.8) -- Think more frequently
    return true
end

function ENT:OnTakeDamage(damage)
    -- React to damage with dialogue
    if math.random(1, 3) == 1 then
        local attacker = damage:GetAttacker()
        if IsValid(attacker) and attacker:IsPlayer() then
            attacker:ChatPrint("[" .. self.NPCName .. "] Hey now! I'm just tryin' to run a business here!")
        end
    end
    
    -- Shopkeepers are invulnerable
    return false
end

-- Custom skin application
function ENT:ApplyHillbillyAppearance()
    -- Younger brother appearance
    self:SetColor(Color(255, 235, 200)) -- Lighter skin tone
    
    -- Apply custom material if available
    timer.Simple(0.1, function()
        if IsValid(self) then
            self:SetMaterial("models/hivestore/younger_brother")
        end
    end)
end

-- Network string for specialized store
util.AddNetworkString("HiveStore.OpenSpecializedStore")
