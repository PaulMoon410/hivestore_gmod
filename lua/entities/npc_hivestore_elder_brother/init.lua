-- Elder Brother Shopkeeper NPC
-- Server-side initialization

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.Base = "base_ai"
ENT.Type = "ai"

-- NPC Data
ENT.NPCName = "E.R. Loona"
ENT.NPCDescription = "Elder brother and main shopkeeper of the Loona Trading Post"
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
    
    -- Make permanent and unkillable
    self:SetHealth(999999)
    self:SetMaxHealth(999999)
    self:SetKeyValue("target", "hivestore_elder_brother")
    self:SetName("hivestore_elder_brother")
    
    -- Prevent removal
    self.IsPermanent = true
    self.IsShopkeeper = true
    self:SetNWBool("IsHiveStoreNPC", true)
    
    -- Customize appearance for cowboy hillbilly look
    self:SetSkin(1) -- Darker skin tone
    self:SetBodygroup(1, 1) -- Add beard/facial hair if available
    
    -- Apply cowboy appearance
    timer.Simple(0.1, function()
        if IsValid(self) then
            self:ApplyCowboyAppearance()
        end
    end)
    
    -- Schedule thinking using timer for base_ai entities
    timer.Create("HiveStore_ElderBro_" .. self:EntIndex(), 3, 0, function()
        if IsValid(self) then
            self:Think()
        end
    end)
    
    -- Initialize dialogue system
    self:InitializeDialogue()
    
    -- Set up sitting animation
    timer.Simple(1, function()
        if IsValid(self) then
            self:SetupSittingAnimation()
        end
    end)
    
    -- Check if spawned as part of trading post
    if self.TradingPost then
        print("[Hive Store] Elder Brother linked to trading post")
    end
    
    -- Mark as protected entity
    self:SetNWString("ShopkeeperName", self.NPCName)
    self:SetNWString("ShopType", self.ShopType)
    
    print("[Hive Store] Elder Brother NPC spawned: " .. self.NPCName)
    print("[Hive Store] NPC is now permanent and unkillable")
end

function ENT:SetupSittingAnimation()
    -- Try to find a sitting sequence
    local sittingSequences = {
        "sit_ground",
        "sitting",
        "sit",
        "sitchair",
        "sit_chair"
    }
    
    local foundSeq = false
    for _, seqName in ipairs(sittingSequences) do
        local seqId = self:LookupSequence(seqName)
        if seqId and seqId > 0 then
            self:ResetSequence(seqId)
            self:SetCycle(0)
            self:SetPlaybackRate(0.1) -- Very slow playback to maintain sitting pose
            foundSeq = true
            print("[Hive Store] E.R. sitting animation applied: " .. seqName)
            break
        end
    end
    
    if not foundSeq then
        -- Fallback to crouch animation which looks like sitting
        local crouchSeq = self:LookupSequence("crouch_idle")
        if crouchSeq and crouchSeq > 0 then
            self:ResetSequence(crouchSeq)
            self:SetCycle(0)
            self:SetPlaybackRate(0.1)
            print("[Hive Store] E.R. using crouch animation as sitting fallback")
        else
            -- Last resort - position based sitting
            print("[Hive Store] No sitting animation found, using position-based sitting")
        end
    end
    
    -- Force sitting position if we have a chair position
    if self.ChairPosition and self.IsSitting then
        self:SetPos(self.ChairPosition)
        -- Prevent the NPC from moving around
        self:SetMoveType(MOVETYPE_NONE)
        print("[Hive Store] E.R. locked to chair position")
    end
end

function ENT:InitializeDialogue()
    self.Dialogue = {
        greetings = {
            "Well howdy there, stranger! *rocks in chair* Welcome to Loona Trading Post!",
            "Afternoon! Name's E.R., and this here's my store. *gestures from porch chair*",
            "Howdy partner! *tips hat from chair* Got some fine goods for ya today!",
            "Welcome, welcome! *relaxes in chair* Don't mind me, just enjoyin' the mountain air!",
            "*tips cowboy hat while sitting* Fine day for tradin', ain't it?"
        },
        shop_talk = {
            "Got everything from weapons to tools, all for fair PeakeCoin prices!",
            "My little brother Nater's inside workin' hard. He handles the detailed stuff.",
            "Been trading in these parts for nigh on 20 years from this very porch!",
            "PeakeCoin's the only currency we take. *rocks in chair* Keep up with the times!",
            "*adjusts hat brim while sitting* This old hat's seen more deals than a cattle auction!",
            "*stretches in chair* These boots have walked every trading trail in the county!"
        },
        business_talk = {
            "Family business runs deep in these mountains.",
            "Nater's got the mechanical know-how, I got the... supervision! *chuckles*",
            "*fans self with hat* Hot days like this, glad I got this shady porch!",
            "*rocks slowly* Mountain breeze sure beats bein' cooped up inside!"
        },
        farewells = {
            "Y'all come back now, ya hear? *waves from chair*",
            "Safe travels, partner! *tips hat*",
            "Much obliged for your business! *rocks in chair*",
            "Tell your friends about Loona Trading Post!",
            "*tips hat while staying seated* Pleasure doin' business with ya!"
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
    -- Maintain sitting position
    if self.IsSitting and self.ChairPosition then
        -- Force E.R. to stay in chair position
        local currentPos = self:GetPos()
        local chairPos = self.ChairPosition
        if currentPos:Distance(chairPos) > 5 then
            self:SetPos(chairPos)
            print("[Hive Store] E.R. repositioned to chair")
        end
    end
    
    if not self.sittingSequenceSet then
        -- Reapply sitting animation if it got reset
        timer.Simple(0.1, function()
            if IsValid(self) then
                self:SetupSittingAnimation()
                self.sittingSequenceSet = true
            end
        end)
    end
    
    -- Subtle idle animations while sitting
    if math.random(1, 300) == 1 then
        -- Very subtle movements while maintaining sitting pose
        if self:GetSequence() and self:GetCycle() > 0.9 then
            self:SetCycle(0) -- Reset cycle to maintain pose
        end
    end
    
    -- Look around occasionally while sitting (head turning only)
    if math.random(1, 200) == 1 then
        local players = player.GetAll()
        if #players > 0 then
            local target = players[math.random(1, #players)]
            if IsValid(target) and target:GetPos():Distance(self:GetPos()) < 500 then
                -- Only very subtle head turning while sitting
                local ang = (target:GetPos() - self:GetPos()):Angle()
                ang.p = 0
                ang.r = 0
                local currentAng = self:GetAngles()
                -- Limit head turning range while sitting
                local angleDiff = math.abs(math.AngleDifference(ang.y, currentAng.y))
                if angleDiff < 45 then -- Only turn head within 45 degrees
                    local newAng = LerpAngle(0.05, currentAng, ang)
                    self:SetAngles(newAng)
                end
            end
        end
    end
    
    -- Think function is called by timer, no need for NextThink
    return true
end

function ENT:OnTakeDamage(damage)
    -- Shopkeepers are completely invulnerable
    local attacker = damage:GetAttacker()
    if IsValid(attacker) and attacker:IsPlayer() then
        attacker:ChatPrint("[" .. self.NPCName .. "] Now hold on there, partner. I'm just tryin' to run a business!")
        attacker:ChatPrint("[System] This shopkeeper is protected and cannot be harmed.")
    end
    
    -- Heal any damage instantly
    self:SetHealth(self:GetMaxHealth())
    
    return false -- Block all damage
end

-- Prevent removal by any means
function ENT:OnRemove()
    -- Clean up timer
    timer.Remove("HiveStore_ElderBro_" .. self:EntIndex())
    
    if not self.IsPermanent then return end
    
    -- Log removal attempt
    print("[Hive Store] WARNING: Attempt to remove permanent shopkeeper!")
    
    -- Respawn after short delay if removed
    timer.Simple(2, function()
        if not IsValid(self) then
            print("[Hive Store] Respawning removed permanent shopkeeper...")
            HiveStore.NPCSpawner.RespawnElderBrother()
        end
    end)
end

-- Override removal functions
function ENT:Remove()
    if self.IsPermanent then
        print("[Hive Store] Attempted to remove permanent shopkeeper - ignoring")
        return
    end
    BaseClass.Remove(self)
end

-- Prevent physics damage
function ENT:PhysicsCollide(data, physobj)
    -- Shopkeepers don't take physics damage
    return
end

-- Block all damage types
function ENT:OnTakeDamage(damage)
    local attacker = damage:GetAttacker()
    if IsValid(attacker) and attacker:IsPlayer() then
        -- Respond to damage attempts
        local responses = {
            "Hey now! No need for violence in a place of business!",
            "I'm just tryin' to make an honest living here!",
            "Violence ain't the answer, partner!",
            "You can't hurt me - I'm protected by the mountain spirits!"
        }
        attacker:ChatPrint("[" .. self.NPCName .. "] " .. responses[math.random(1, #responses)])
    end
    
    -- Always stay at full health
    self:SetHealth(self:GetMaxHealth())
    return false
end

-- Custom appearance application
function ENT:ApplyCowboyAppearance()
    -- E.R. wears cowboy hat, shorts, and boots - classic southern look
    self:SetColor(Color(245, 220, 180)) -- Slightly tanned skin from outdoor work
    
    -- Try to set bodygroups for cowboy look if model supports it
    self:SetBodygroup(0, 2) -- Different torso (shirtless/vest) if available
    self:SetBodygroup(2, 2) -- Shorts instead of pants if available  
    self:SetBodygroup(3, 1) -- Boots if available
    
    -- Apply custom material for cowboy look if available
    self:SetMaterial("models/hivestore/er_cowboy")
    
    -- Set additional properties for elder brother
    self:SetSubMaterial(0, "models/player/shared/eyeball_l")
    self:SetSubMaterial(1, "models/player/shared/eyeball_r")
end

function ENT:ApplyHillbillyAppearance()
    -- Legacy function - redirect to new cowboy appearance
    self:ApplyCowboyAppearance()
end

hook.Add("PlayerInitialSpawn", "HiveStore.ElderBrotherGreeting", function(ply)
    timer.Simple(5, function()
        if IsValid(ply) then
            ply:ChatPrint("[Server] Welcome! Visit E.R. Loona at the trading post to buy items with PeakeCoin!")
        end
    end)
end)
