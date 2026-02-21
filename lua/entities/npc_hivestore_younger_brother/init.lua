-- Younger Brother Shopkeeper NPC
-- Server-side initialization

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.Base = "base_ai"
ENT.Type = "ai"

-- NPC Data
ENT.NPCName = "Nater Loona"
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
    
    -- Make permanent and unkillable
    self:SetHealth(999999)
    self:SetMaxHealth(999999)
    self:SetKeyValue("target", "hivestore_younger_brother")
    self:SetName("hivestore_younger_brother")
    
    -- Prevent removal
    self.IsPermanent = true
    self.IsShopkeeper = true
    self:SetNWBool("IsHiveStoreNPC", true)
    
    -- Customize appearance for younger hillbilly look (overalls)
    self:SetSkin(0) -- Lighter skin
    self:SetBodygroup(1, 0) -- Less facial hair
    
    -- Apply hillbilly overalls appearance
    timer.Simple(0.1, function()
        if IsValid(self) then
            self:ApplyOverallsAppearance()
        end
    end)
    
    -- Schedule thinking using timer for base_ai entities
    timer.Create("HiveStore_YoungerBro_" .. self:EntIndex(), 0.8, 0, function()
        if IsValid(self) then
            self:Think()
        end
    end)
    
    -- Initialize dialogue system
    self:InitializeDialogue()
    
    -- Check if spawned as part of trading post
    if self.TradingPost then
        print("[Hive Store] Younger Brother linked to trading post")
    end
    
    -- Mark as protected entity
    self:SetNWString("ShopkeeperName", self.NPCName)
    self:SetNWString("ShopType", self.ShopType)
    
    print("[Hive Store] Younger Brother NPC spawned: " .. self.NPCName)
    print("[Hive Store] NPC is now permanent and unkillable")
end

function ENT:InitializeDialogue()
    self.Dialogue = {
        greetings = {
            "Hey there, mister! I'm Nater, Nater Loona!",
            "Howdy! My big brother E.R. runs the main store, but I got the good stuff!",
            "Well hello! You look like someone who appreciates fine weaponry!",
            "Welcome to my workshop! I got the best guns and tools this side of the mountain!",
            "*adjusts overalls* Don't mind the work clothes - I been fixin' things all mornin'!"
        },
        shop_talk = {
            "I know everything there is to know about guns and tools!",
            "Been huntin' and fixin' things since I was knee-high to a grasshopper!",
            "E.R. handles the fancy stuff, but when you need real firepower, you come to me!",
            "Every weapon I sell, I've tested myself out in them hills!",
            "PeakeCoin's mighty fine currency - way better than them old paper bills!",
            "*pats overalls pockets* Got my tools right here if anything needs fixin'!"
        },
        weapon_talk = {
            "This here pistol? Shot my first deer with one just like it!",
            "Tools are important too - can't fix nothin' without proper tools!",
            "I can tell you stories about every gun I got in stock!",
            "Quality over quantity, that's what Pa always said!",
            "*wipes hands on overalls* Been cleanin' weapons since dawn!"
        },
        farewells = {
            "Happy huntin', partner!",
            "Don't go shootin' your eye out now!",
            "Come back when you need more firepower!",
            "Tell E.R. I said hey!",
            "*tips cap* Y'all come back now, ya hear?"
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
        -- Random excited gestures using sequences instead of activities
        local sequences = {"idle_all_01", "idle_all_02", "idle_angry"}
        local seq = sequences[math.random(1, #sequences)]
        local seqId = self:LookupSequence(seq)
        if seqId > 0 then
            self:ResetSequence(seqId)
        end
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
                    -- Use gesture sequence instead of activity
                    local waveSeq = self:LookupSequence("gesture_wave")
                    if waveSeq > 0 then
                        self:ResetSequence(waveSeq)
                    end
                end
            end
        end
    end
    
    -- Random weapon maintenance animation
    if math.random(1, 400) == 1 then
        self:EmitSound("weapons/pistol/pistol_reload1.wav", 60)
    end
    
    -- Think function is called by timer, no need for NextThink
    return true
end

function ENT:OnTakeDamage(damage)
    -- React to damage with dialogue
    local attacker = damage:GetAttacker()
    if IsValid(attacker) and attacker:IsPlayer() then
        local responses = {
            "Whoa there, partner! I'm just tryin' to help folks out!",
            "Hey now! My guns are for sellin', not for fightin'!",
            "Violence ain't necessary - we can talk business instead!",
            "You can't hurt me none - I got the mountain's protection!",
            "Easy there, friend! Save that energy for huntin'!"
        }
        attacker:ChatPrint("[" .. self.NPCName .. "] " .. responses[math.random(1, #responses)])
        attacker:ChatPrint("[System] This shopkeeper is protected and cannot be harmed.")
    end
    
    -- Always stay at full health
    self:SetHealth(self:GetMaxHealth())
    return false -- Block all damage
end

-- Prevent removal by any means
function ENT:OnRemove()
    -- Clean up timer
    timer.Remove("HiveStore_YoungerBro_" .. self:EntIndex())
    
    if not self.IsPermanent then return end
    
    -- Log removal attempt
    print("[Hive Store] WARNING: Attempt to remove permanent shopkeeper!")
    
    -- Respawn after short delay if removed
    timer.Simple(2, function()
        if not IsValid(self) then
            print("[Hive Store] Respawning removed permanent shopkeeper...")
            HiveStore.NPCSpawner.RespawnYoungerBrother()
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

-- Custom appearance application
function ENT:ApplyOverallsAppearance()
    -- Nater wears overalls - give him a working man's look
    self:SetColor(Color(255, 235, 200)) -- Lighter skin tone
    
    -- Try to set bodygroups for overalls look if model supports it
    self:SetBodygroup(0, 1) -- Different torso if available
    self:SetBodygroup(2, 1) -- Different legs if available
    
    -- Apply custom material for overalls if available
    self:SetMaterial("models/hivestore/nater_overalls")
    
    -- Set additional properties for younger brother
    self:SetSubMaterial(0, "models/player/shared/eyeball_l")
    self:SetSubMaterial(1, "models/player/shared/eyeball_r")
end

function ENT:ApplyHillbillyAppearance()
    -- Legacy function - redirect to new overalls appearance
    self:ApplyOverallsAppearance()
end

-- Network string for specialized store
util.AddNetworkString("HiveStore.OpenSpecializedStore")
