-- Elder Brother Shopkeeper NPC
-- Server-side initialization

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.Base = "base_ai"
ENT.Type = "ai"

-- NPC Data
ENT.NPCName = "Jebediah 'Jeb' McCoy"
ENT.NPCDescription = "Elder brother and main shopkeeper of the McCoy Trading Post"
ENT.ShopType = "general" -- Can sell all categories

function ENT:Initialize()
    self:SetModel("models/player/group01/male_04.mdl")
    self:SetHullType(HULL_HUMAN)
    self:SetHullSizeNormal()
    self:SetNPCState(NPC_STATE_SCRIPT)
    self:SetSolid(SOLID_BBOX)
    self:CapabilitiesAdd(CAP_ANIMATEDFACE + CAP_TURN_HEAD)
    self:SetUseType(SIMPLE_USE)
    self:DropToFloor()
    
    -- Customize appearance for hillbilly look
    self:SetSkin(1) -- Darker skin tone
    self:SetBodygroup(1, 1) -- Add beard/facial hair if available
    
    -- Set health
    self:SetHealth(1000)
    self:SetMaxHealth(1000)
    
    -- Schedule thinking
    self:SetThink(self.Think)
    self:NextThink(CurTime() + 1)
    
    -- Initialize dialogue system
    self:InitializeDialogue()
    
    print("[Hive Store] Elder Brother NPC spawned: " .. self.NPCName)
end

function ENT:InitializeDialogue()
    self.Dialogue = {
        greetings = {
            "Well howdy there, stranger! Welcome to McCoy Trading Post!",
            "Afternoon! Name's Jeb, and this here's my store.",
            "Howdy partner! Got some fine goods for ya today!",
            "Welcome, welcome! Don't mind the mess, we got quality items!"
        },
        shop_talk = {
            "Got everything from weapons to tools, all for fair PeakeCoin prices!",
            "My little brother Cletus helps me run this place. He's... special.",
            "Been trading in these parts for nigh on 20 years now.",
            "PeakeCoin's the only currency we take. Keep up with the times, ya know!"
        },
        farewells = {
            "Y'all come back now, ya hear?",
            "Safe travels, partner!",
            "Much obliged for your business!",
            "Tell your friends about McCoy Trading Post!"
        }
    }
    
    self.lastDialogue = 0
    self.dialogueType = "greetings"
end

function ENT:Use(activator, caller)
    if not IsValid(activator) or not activator:IsPlayer() then return end
    
    -- Face the player
    local ang = (activator:GetPos() - self:GetPos()):Angle()
    ang.p = 0
    ang.r = 0
    self:SetAngles(ang)
    
    -- Show dialogue
    self:ShowDialogue(activator)
    
    -- Open store after a delay
    timer.Simple(2, function()
        if IsValid(activator) then
            self:OpenStore(activator)
        end
    end)
end

function ENT:ShowDialogue(player)
    if not IsValid(player) then return end
    
    local currentTime = CurTime()
    if currentTime - self.lastDialogue < 3 then return end -- Prevent spam
    
    local dialogue = self.Dialogue[self.dialogueType]
    if dialogue and #dialogue > 0 then
        local message = dialogue[math.random(1, #dialogue)]
        
        -- Send dialogue to player
        player:ChatPrint("[" .. self.NPCName .. "] " .. message)
        
        -- Play sound
        self:EmitSound("vo/npc/male01/hi0" .. math.random(1, 2) .. ".wav")
    end
    
    self.lastDialogue = currentTime
    
    -- Cycle dialogue types
    if self.dialogueType == "greetings" then
        self.dialogueType = "shop_talk"
    elseif self.dialogueType == "shop_talk" then
        self.dialogueType = "farewells"
    else
        self.dialogueType = "greetings"
    end
end

function ENT:OpenStore(player)
    if not IsValid(player) then return end
    
    -- Send message to open store GUI
    net.Start("HiveStore.OpenGUI")
    net.Send(player)
    
    -- Show store message
    player:ChatPrint("[" .. self.NPCName .. "] Here's what I got in stock!")
end

function ENT:Think()
    -- Idle animations and behaviors
    if math.random(1, 100) == 1 then
        -- Random idle animations
        local animations = {"idle_all_01", "idle_all_02", "idle_subtle"}
        local anim = animations[math.random(1, #animations)]
        self:StartActivity(ACT_IDLE)
    end
    
    -- Look around occasionally
    if math.random(1, 200) == 1 then
        local players = player.GetAll()
        if #players > 0 then
            local target = players[math.random(1, #players)]
            if IsValid(target) and target:GetPos():Distance(self:GetPos()) < 500 then
                local ang = (target:GetPos() - self:GetPos()):Angle()
                ang.p = 0
                ang.r = 0
                self:SetAngles(ang)
            end
        end
    end
    
    self:NextThink(CurTime() + 1)
    return true
end

function ENT:OnTakeDamage(damage)
    -- Shopkeepers are invulnerable
    return false
end

-- Custom skin application
function ENT:ApplyHillbillyAppearance()
    -- This will be enhanced with custom materials
    self:SetColor(Color(245, 220, 180)) -- Slightly tanned skin
    
    -- Apply custom material if available
    timer.Simple(0.1, function()
        if IsValid(self) then
            self:SetMaterial("models/hivestore/elder_brother")
        end
    end)
end

hook.Add("PlayerInitialSpawn", "HiveStore.ElderBrotherGreeting", function(ply)
    timer.Simple(5, function()
        if IsValid(ply) then
            ply:ChatPrint("[Server] Welcome! Visit Jeb McCoy at the trading post to buy items with PeakeCoin!")
        end
    end)
end)
