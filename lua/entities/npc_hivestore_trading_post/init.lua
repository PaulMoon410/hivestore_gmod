-- Loona Trading Post - Combined NPC and Shop Entity
-- Server-side initialization

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.Base = "base_ai"
ENT.Type = "ai"

-- Trading Post Data
ENT.TradingPostName = "Loona Trading Post"
ENT.TradingPostDescription = "Complete hillbilly trading post with both Loona brothers"

function ENT:Initialize()
    self:SetModel("models/props_c17/FurnitureTable001a.mdl") -- Table as base
    self:SetSolid(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
    self:DropToFloor()
    
    -- Make permanent and unkillable
    self:SetHealth(999999)
    self:SetMaxHealth(999999)
    self:SetName("loona_trading_post")
    
    -- Prevent removal
    self.IsPermanent = true
    self.IsTradingPost = true
    self:SetNWBool("IsHiveStoreNPC", true)
    
    -- Spawn both brothers
    timer.Simple(0.5, function()
        if IsValid(self) then
            self:SpawnBrothers()
        end
    end)
    
    -- Spawn the Sniper's Cabin dupe
    timer.Simple(0.2, function()
        if IsValid(self) then
            self:SpawnSniperCabin()
        end
    end)
    
    print("[Hive Store] Loona Trading Post spawned - loading Sniper's Cabin...")
end

function ENT:SpawnBrothers()
    local pos = self:GetPos()
    local ang = self:GetAngles()
    local forward = ang:Forward()
    local right = ang:Right()
    
    -- Delay NPC spawning to let the cabin load first
    timer.Simple(2, function()
        if not IsValid(self) then return end
        
        -- Spawn Elder Brother (E.R.) - Sitting on the porch in a chair
        local elderBro = ents.Create("npc_hivestore_elder_brother")
        if IsValid(elderBro) then
            -- Position E.R. exactly where the chair will be, slightly elevated to "sit" on it
            local elderPos = pos + forward * 50 + right * -20 + Vector(0, 0, 25)  -- 10 units higher to sit on chair
            elderBro:SetPos(elderPos)
            elderBro:SetAngles(ang + Angle(0, 45, 0)) -- Face toward approach at angle
            elderBro:Spawn()
            elderBro:Activate()
            elderBro:SetParent(self)
            elderBro.TradingPost = self
            
            -- Store reference to chair position for animation
            elderBro.ChairPosition = elderPos
            elderBro.IsSitting = true
            
            self.ElderBrother = elderBro
            
            print("[Hive Store] Elder Brother (E.R.) spawned sitting on porch chair")
        end
        
        -- Spawn Younger Brother (Nater) - Inside the cabin working
        local youngerBro = ents.Create("npc_hivestore_younger_brother")
        if IsValid(youngerBro) then
            local youngerPos = pos + forward * -40 + right * 10 + Vector(0, 0, 15)  -- Inside cabin
            youngerBro:SetPos(youngerPos)
            youngerBro:SetAngles(ang + Angle(0, 135, 0)) -- Face toward entrance
            youngerBro:Spawn()
            youngerBro:Activate()
            youngerBro:DropToFloor()
            youngerBro:SetParent(self)
            youngerBro.TradingPost = self
            
            self.YoungerBrother = youngerBro
            
            print("[Hive Store] Younger Brother (Nater) spawned inside custom cabin")
        end
        
        -- Announce the trading post is open
        timer.Simple(1, function()
            if IsValid(self) then
                PrintMessage(HUD_PRINTTALK, "[Hive Store] Loona Trading Post is now open for business!")
                PrintMessage(HUD_PRINTTALK, "[Hive Store] E.R. is relaxing on the porch - he handles general items")
                PrintMessage(HUD_PRINTTALK, "[Hive Store] Nater is inside working - he specializes in weapons & tools!")
            end
        end)
    end)
end

function ENT:SpawnTradingPostProps()
    local pos = self:GetPos()
    local ang = self:GetAngles()
    local forward = ang:Forward()
    local right = ang:Right()
    
    self.TradingPostProps = {}
    
    -- MAIN SHACK STRUCTURE
    self:SpawnMainShack(pos, ang, forward, right)
    
    -- LEAN-TO ADDITION
    self:SpawnLeanTo(pos, ang, forward, right)
    
    -- TRADING POST PROPS
    self:SpawnTradingProps(pos, ang, forward, right)
    
    -- SIGNAGE
    self:SpawnSigns(pos, ang, forward, right)
end

function ENT:SpawnMainShack(pos, ang, forward, right)
    -- Main shack walls (4 walls)
    local shackProps = {
        -- Back wall
        {model = "models/props_building_details/Storefront_Template001a_Bars.mdl", 
         offset = Vector(-120, 0, 40), angles = Angle(0, 0, 0)},
        
        -- Left wall  
        {model = "models/props_building_details/Storefront_Template001a_Bars.mdl", 
         offset = Vector(-60, -80, 40), angles = Angle(0, 90, 0)},
         
        -- Right wall
        {model = "models/props_building_details/Storefront_Template001a_Bars.mdl", 
         offset = Vector(-60, 80, 40), angles = Angle(0, 90, 0)},
         
        -- Front wall (with opening for door)
        {model = "models/props_building_details/Storefront_Template001a_Bars.mdl", 
         offset = Vector(0, 0, 40), angles = Angle(0, 0, 0)},
    }
    
    -- Roof supports
    local roofProps = {
        {model = "models/props_c17/concrete_barrier001a.mdl", 
         offset = Vector(-60, 0, 80), angles = Angle(0, 0, 0)},
    }
    
    -- Floor
    local floorProps = {
        {model = "models/props_c17/concrete_barrier001a.mdl", 
         offset = Vector(-60, 0, -5), angles = Angle(0, 0, 0)},
        {model = "models/props_c17/concrete_barrier001a.mdl", 
         offset = Vector(-60, -40, -5), angles = Angle(0, 0, 0)},
        {model = "models/props_c17/concrete_barrier001a.mdl", 
         offset = Vector(-60, 40, -5), angles = Angle(0, 0, 0)},
    }
    
    -- Spawn all shack components
    for _, propList in pairs({shackProps, roofProps, floorProps}) do
        for _, propData in pairs(propList) do
            self:SpawnBuildingProp(pos, ang, propData)
        end
    end
end

function ENT:SpawnLeanTo(pos, ang, forward, right)
    -- Lean-to structure on the side
    local leanToProps = {
        -- Lean-to roof support
        {model = "models/props_c17/concrete_barrier001a.mdl", 
         offset = Vector(-60, 120, 60), angles = Angle(0, 0, -15)},
         
        -- Lean-to side wall
        {model = "models/props_building_details/Storefront_Template001a_Bars.mdl", 
         offset = Vector(-60, 140, 40), angles = Angle(0, 90, 0)},
         
        -- Lean-to back support
        {model = "models/props_building_details/Storefront_Template001a_Bars.mdl", 
         offset = Vector(-120, 120, 40), angles = Angle(0, 0, 0)},
         
        -- Lean-to floor
        {model = "models/props_c17/concrete_barrier001a.mdl", 
         offset = Vector(-60, 120, -5), angles = Angle(0, 0, 0)},
         
        -- Support posts
        {model = "models/props_c17/column02a.mdl", 
         offset = Vector(-20, 120, 20), angles = Angle(0, 0, 0)},
        {model = "models/props_c17/column02a.mdl", 
         offset = Vector(-100, 120, 20), angles = Angle(0, 0, 0)},
    }
    
    for _, propData in pairs(leanToProps) do
        self:SpawnBuildingProp(pos, ang, propData)
    end
end

function ENT:SpawnTradingProps(pos, ang, forward, right)
    -- Trading and storage props
    local tradingProps = {
        -- Inside main shack
        {model = "models/props_c17/FurnitureDresser001a.mdl", 
         offset = Vector(-100, -60, 0), angles = Angle(0, 45, 0)},
        {model = "models/props_junk/wood_crate001a.mdl", 
         offset = Vector(-80, 60, 0), angles = Angle(0, 25, 0)},
         
        -- Under lean-to (Nater's area)
        {model = "models/props_c17/oildrum001.mdl", 
         offset = Vector(-80, 120, 0), angles = Angle(0, 0, 0)},
        {model = "models/props_junk/wood_crate002a.mdl", 
         offset = Vector(-40, 140, 0), angles = Angle(0, -30, 0)},
        {model = "models/props_wasteland/laundry_basket002.mdl", 
         offset = Vector(-100, 140, 0), angles = Angle(0, 60, 0)},
         
        -- Outside decorations
        {model = "models/props_c17/oildrum001.mdl", 
         offset = Vector(20, -60, 0), angles = Angle(0, 0, 0)},
        {model = "models/props_junk/wood_crate001a.mdl", 
         offset = Vector(20, 60, 0), angles = Angle(0, 45, 0)},
    }
    
    for _, propData in pairs(tradingProps) do
        self:SpawnBuildingProp(pos, ang, propData)
    end
end

function ENT:SpawnSigns(pos, ang, forward, right)
    -- Main store sign - "The PeakeCoin Store"
    local mainSign = {
        model = "models/props_c17/FurnitureShelf001a.mdl", 
        offset = Vector(50, 0, 90), angles = Angle(0, 0, 0)
    }
    local signProp = self:SpawnBuildingProp(pos, ang, mainSign)
    
    -- Additional trading post signs
    local signProps = {
        -- Sign above main entrance
        {model = "models/props_c17/FurnitureShelf001a.mdl", 
         offset = Vector(10, 0, 70), angles = Angle(0, 0, 0)},
         
        -- Side sign for lean-to (Nater's workshop)
        {model = "models/props_c17/FurnitureShelf001a.mdl", 
         offset = Vector(-20, 120, 70), angles = Angle(0, 90, 0)},
         
        -- Support post for main sign
        {model = "models/props_c17/column02a.mdl", 
         offset = Vector(50, -30, 45), angles = Angle(0, 0, 0)},
        {model = "models/props_c17/column02a.mdl", 
         offset = Vector(50, 30, 45), angles = Angle(0, 0, 0)},
    }
    
    for _, propData in pairs(signProps) do
        self:SpawnBuildingProp(pos, ang, propData)
    end
end

function ENT:SpawnBuildingProp(basePos, baseAng, propData)
    local prop = ents.Create("prop_physics")
    if IsValid(prop) then
        prop:SetModel(propData.model)
        
        -- Calculate position and angles relative to trading post
        local offset = propData.offset
        local worldPos = basePos + baseAng:Forward() * offset.x + baseAng:Right() * offset.y + baseAng:Up() * offset.z
        
        prop:SetPos(worldPos)
        prop:SetAngles(baseAng + (propData.angles or Angle(0,0,0)))
        prop:Spawn()
        prop:PhysicsInit(SOLID_VPHYSICS)
        
        -- Make it permanent and attach to trading post
        prop:SetParent(self)
        prop:SetHealth(999999)
        prop:SetMaxHealth(999999)
        prop.IsPermanent = true
        prop:SetNWBool("IsHiveStoreProp", true)
        
        -- Prevent movement
        local physObj = prop:GetPhysicsObject()
        if IsValid(physObj) then
            physObj:EnableMotion(false)
        end
        
        table.insert(self.TradingPostProps, prop)
    end
end

function ENT:Use(activator, caller)
    if not IsValid(activator) or not activator:IsPlayer() then return end
    
    -- Direct player to the brothers
    activator:ChatPrint("[Loona Trading Post] Welcome to our mountain trading post!")
    activator:ChatPrint("[Loona Trading Post] E.R. is inside the main shack (left) - he handles general items")
    activator:ChatPrint("[Loona Trading Post] Nater is under the lean-to (right) - he specializes in weapons & tools!")
    activator:ChatPrint("[Loona Trading Post] Both brothers are permanent residents here - they're always open for business!")
    
    -- Open general store as fallback
    timer.Simple(1, function()
        if IsValid(activator) then
            net.Start("HiveStore.OpenGUI")
            net.Send(activator)
        end
    end)
end

function ENT:Think()
    -- Check if brothers are still alive
    if not IsValid(self.ElderBrother) or not IsValid(self.YoungerBrother) then
        -- Respawn missing brothers
        timer.Simple(2, function()
            if IsValid(self) then
                if not IsValid(self.ElderBrother) then
                    print("[Hive Store] Respawning missing Elder Brother...")
                    self:RespawnElderBrother()
                end
                if not IsValid(self.YoungerBrother) then
                    print("[Hive Store] Respawning missing Younger Brother...")
                    self:RespawnYoungerBrother()
                end
            end
        end)
    end
    
    self:NextThink(CurTime() + 5)
    return true
end

function ENT:RespawnElderBrother()
    local pos = self:GetPos()
    local ang = self:GetAngles()
    
    local elderBro = ents.Create("npc_hivestore_elder_brother")
    if IsValid(elderBro) then
        elderBro:SetPos(pos + self:GetForward() * 50 + self:GetRight() * -30)
        elderBro:SetAngles(ang + Angle(0, 180, 0))
        elderBro:Spawn()
        elderBro:Activate()
        elderBro:SetParent(self)
        
        self.ElderBrother = elderBro
        elderBro.TradingPost = self
    end
end

function ENT:RespawnYoungerBrother()
    local pos = self:GetPos()
    local ang = self:GetAngles()
    
    local youngerBro = ents.Create("npc_hivestore_younger_brother")
    if IsValid(youngerBro) then
        youngerBro:SetPos(pos + self:GetForward() * 50 + self:GetRight() * 30)
        youngerBro:SetAngles(ang + Angle(0, 180, 0))
        youngerBro:Spawn()
        youngerBro:Activate()
        youngerBro:SetParent(self)
        
        self.YoungerBrother = youngerBro
        youngerBro.TradingPost = self
    end
end

function ENT:OnTakeDamage(damage)
    -- Trading post is indestructible
    return false
end

function ENT:OnRemove()
    if not self.IsPermanent then return end
    
    print("[Hive Store] WARNING: Attempt to remove permanent trading post!")
    
    -- Respawn after short delay if removed
    timer.Simple(2, function()
        if not IsValid(self) then
            print("[Hive Store] Respawning removed trading post...")
            HiveStore.NPCSpawner.RespawnTradingPost()
        end
    end)
end

function ENT:Remove()
    if self.IsPermanent then
        print("[Hive Store] Attempted to remove permanent trading post - ignoring")
        return
    end
    BaseClass.Remove(self)
end

function ENT:SpawnSniperCabin()
    -- Check if custom cabin building is enabled
    if not HiveStore.Config.NPCs.UseCustomCabin then
        print("[Hive Store] Custom cabin disabled in config, using basic props...")
        self:SpawnTradingPostProps()
        return
    end
    
    local pos = self:GetPos()
    local ang = self:GetAngles()
    
    print("[Hive Store] Building custom hillbilly cabin...")
    
    -- Build a custom rustic cabin using props
    self:BuildCustomHillbillyCabin(pos, ang)
    
    print("[Hive Store] Custom hillbilly cabin construction complete!")
end

function ENT:BuildCustomHillbillyCabin(pos, ang)
    self.TradingPostProps = {}
    local forward = ang:Forward()
    local right = ang:Right()
    local up = ang:Up()
    
    -- MAIN CABIN STRUCTURE
    self:BuildCabinWalls(pos, ang, forward, right, up)
    self:BuildCabinRoof(pos, ang, forward, right, up)
    self:BuildCabinFloor(pos, ang, forward, right, up)
    
    -- PORCH/LEAN-TO
    self:BuildPorch(pos, ang, forward, right, up)
    
    -- RUSTIC DETAILS
    self:BuildRusticDetails(pos, ang, forward, right, up)
    
    -- SIGNAGE
    self:BuildCustomSigns(pos, ang, forward, right, up)
    
    print("[Hive Store] Spawned " .. #self.TradingPostProps .. " cabin props")
end

function ENT:BuildCabinWalls(pos, ang, forward, right, up)
    local wallProps = {
        -- Back wall (solid)
        {model = "models/props_phx/construct/wood/wood_boardx4.mdl", 
         offset = forward * -80 + up * 40, angles = Angle(0, 0, 0)},
        {model = "models/props_phx/construct/wood/wood_boardx4.mdl", 
         offset = forward * -80 + up * 80, angles = Angle(0, 0, 0)},
        {model = "models/props_phx/construct/wood/wood_boardx4.mdl", 
         offset = forward * -80 + up * 120, angles = Angle(0, 0, 0)},
         
        -- Left wall
        {model = "models/props_phx/construct/wood/wood_boardx4.mdl", 
         offset = right * -60 + forward * -40 + up * 40, angles = Angle(0, 90, 0)},
        {model = "models/props_phx/construct/wood/wood_boardx4.mdl", 
         offset = right * -60 + forward * -40 + up * 80, angles = Angle(0, 90, 0)},
        {model = "models/props_phx/construct/wood/wood_boardx4.mdl", 
         offset = right * -60 + forward * -40 + up * 120, angles = Angle(0, 90, 0)},
         
        -- Right wall (partial - has opening)
        {model = "models/props_phx/construct/wood/wood_boardx4.mdl", 
         offset = right * 60 + forward * -40 + up * 40, angles = Angle(0, 90, 0)},
        {model = "models/props_phx/construct/wood/wood_boardx4.mdl", 
         offset = right * 60 + forward * -40 + up * 120, angles = Angle(0, 90, 0)},
         
        -- Front wall (has door opening)
        {model = "models/props_phx/construct/wood/wood_boardx4.mdl", 
         offset = right * -30 + up * 40, angles = Angle(0, 0, 0)},
        {model = "models/props_phx/construct/wood/wood_boardx4.mdl", 
         offset = right * 30 + up * 40, angles = Angle(0, 0, 0)},
        {model = "models/props_phx/construct/wood/wood_boardx4.mdl", 
         offset = up * 120, angles = Angle(0, 0, 0)},
    }
    
    for _, propData in pairs(wallProps) do
        self:SpawnCabinProp(pos + propData.offset, ang + propData.angles, propData.model)
    end
end

function ENT:BuildCabinRoof(pos, ang, forward, right, up)
    local roofProps = {
        -- Roof beams
        {model = "models/props_phx/construct/wood/wood_boardx4.mdl", 
         offset = forward * -40 + up * 160, angles = Angle(0, 0, 15)},
        {model = "models/props_phx/construct/wood/wood_boardx4.mdl", 
         offset = forward * -40 + up * 160, angles = Angle(0, 0, -15)},
         
        -- Roof planks
        {model = "models/props_phx/construct/wood/wood_boardx4.mdl", 
         offset = forward * -20 + right * -20 + up * 150, angles = Angle(15, 90, 0)},
        {model = "models/props_phx/construct/wood/wood_boardx4.mdl", 
         offset = forward * -60 + right * -20 + up * 150, angles = Angle(15, 90, 0)},
        {model = "models/props_phx/construct/wood/wood_boardx4.mdl", 
         offset = forward * -20 + right * 20 + up * 150, angles = Angle(-15, 90, 0)},
        {model = "models/props_phx/construct/wood/wood_boardx4.mdl", 
         offset = forward * -60 + right * 20 + up * 150, angles = Angle(-15, 90, 0)},
    }
    
    for _, propData in pairs(roofProps) do
        self:SpawnCabinProp(pos + propData.offset, ang + propData.angles, propData.model)
    end
end

function ENT:BuildCabinFloor(pos, ang, forward, right, up)
    local floorProps = {
        -- Floor planks
        {model = "models/props_phx/construct/wood/wood_boardx4.mdl", 
         offset = forward * -60 + right * -30, angles = Angle(0, 90, 90)},
        {model = "models/props_phx/construct/wood/wood_boardx4.mdl", 
         offset = forward * -60 + right * 0, angles = Angle(0, 90, 90)},
        {model = "models/props_phx/construct/wood/wood_boardx4.mdl", 
         offset = forward * -60 + right * 30, angles = Angle(0, 90, 90)},
        {model = "models/props_phx/construct/wood/wood_boardx4.mdl", 
         offset = forward * -20 + right * -30, angles = Angle(0, 90, 90)},
        {model = "models/props_phx/construct/wood/wood_boardx4.mdl", 
         offset = forward * -20 + right * 0, angles = Angle(0, 90, 90)},
        {model = "models/props_phx/construct/wood/wood_boardx4.mdl", 
         offset = forward * -20 + right * 30, angles = Angle(0, 90, 90)},
    }
    
    for _, propData in pairs(floorProps) do
        self:SpawnCabinProp(pos + propData.offset, ang + propData.angles, propData.model)
    end
end

function ENT:BuildPorch(pos, ang, forward, right, up)
    local porchProps = {
        -- Porch posts
        {model = "models/props_phx/construct/wood/wood_boardx4.mdl", 
         offset = forward * 40 + right * -40 + up * 40, angles = Angle(0, 0, 90)},
        {model = "models/props_phx/construct/wood/wood_boardx4.mdl", 
         offset = forward * 40 + right * 40 + up * 40, angles = Angle(0, 0, 90)},
         
        -- Porch roof
        {model = "models/props_phx/construct/wood/wood_boardx4.mdl", 
         offset = forward * 40 + up * 100, angles = Angle(0, 0, 0)},
        {model = "models/props_phx/construct/wood/wood_boardx4.mdl", 
         offset = forward * 60 + up * 95, angles = Angle(10, 0, 0)},
         
        -- Porch floor
        {model = "models/props_phx/construct/wood/wood_boardx4.mdl", 
         offset = forward * 40 + right * -20 + up * 5, angles = Angle(0, 90, 90)},
        {model = "models/props_phx/construct/wood/wood_boardx4.mdl", 
         offset = forward * 40 + right * 20 + up * 5, angles = Angle(0, 90, 90)},
        {model = "models/props_phx/construct/wood/wood_boardx4.mdl", 
         offset = forward * 60 + right * -20 + up * 5, angles = Angle(0, 90, 90)},
        {model = "models/props_phx/construct/wood/wood_boardx4.mdl", 
         offset = forward * 60 + right * 20 + up * 5, angles = Angle(0, 90, 90)},
    }
    
    for _, propData in pairs(porchProps) do
        self:SpawnCabinProp(pos + propData.offset, ang + propData.angles, propData.model)
    end
end

function ENT:BuildRusticDetails(pos, ang, forward, right, up)
    local detailProps = {
        -- Interior furniture (Nater's workshop area)
        {model = "models/props_c17/FurnitureDresser001a.mdl", 
         offset = forward * -60 + right * -30 + up * 10, angles = Angle(0, 45, 0)},
        {model = "models/props_junk/wood_crate001a.mdl", 
         offset = forward * -50 + right * 30 + up * 10, angles = Angle(0, -30, 0)},
        {model = "models/props_c17/FurnitureTable001a.mdl", 
         offset = forward * -30 + right * -10 + up * 10, angles = Angle(0, 60, 0)},
         
        -- E.R.'s porch chair and area
        {model = "models/props_c17/FurnitureChair001a.mdl", 
         offset = forward * 50 + right * -20 + up * 10, angles = Angle(0, 45, 0)},
        {model = "models/props_junk/wood_crate002a.mdl", 
         offset = forward * 60 + right * -35 + up * 10, angles = Angle(0, 60, 0)},
        {model = "models/props_c17/oildrum001.mdl", 
         offset = forward * 40 + right * 40 + up * 10, angles = Angle(0, 0, 0)},
         
        -- Exterior storage and atmosphere
        {model = "models/props_c17/oildrum001.mdl", 
         offset = forward * -90 + right * 50 + up * 10, angles = Angle(0, 0, 0)},
        {model = "models/props_wasteland/laundry_basket002.mdl", 
         offset = forward * -30 + right * -70 + up * 10, angles = Angle(0, 120, 0)},
        {model = "models/props_junk/wood_crate001a.mdl", 
         offset = forward * -80 + right * -40 + up * 10, angles = Angle(0, 45, 0)},
         
        -- Rustic fence posts around property
        {model = "models/props_phx/construct/wood/wood_boardx4.mdl", 
         offset = forward * 100 + right * -60 + up * 30, angles = Angle(0, 0, 90)},
        {model = "models/props_phx/construct/wood/wood_boardx4.mdl", 
         offset = forward * 100 + right * 60 + up * 30, angles = Angle(0, 0, 90)},
        {model = "models/props_phx/construct/wood/wood_boardx4.mdl", 
         offset = forward * -100 + right * -60 + up * 30, angles = Angle(0, 0, 90)},
        {model = "models/props_phx/construct/wood/wood_boardx4.mdl", 
         offset = forward * -100 + right * 60 + up * 30, angles = Angle(0, 0, 90)},
         
        -- Horizontal fence rails
        {model = "models/props_phx/construct/wood/wood_boardx4.mdl", 
         offset = forward * 100 + up * 20, angles = Angle(0, 0, 0)},
        {model = "models/props_phx/construct/wood/wood_boardx4.mdl", 
         offset = forward * 100 + up * 40, angles = Angle(0, 0, 0)},
    }
    
    for _, propData in pairs(detailProps) do
        self:SpawnCabinProp(pos + propData.offset, ang + propData.angles, propData.model)
    end
end

function ENT:BuildCustomSigns(pos, ang, forward, right, up)
    -- Main "The PeakeCoin Store" sign
    local mainSign = self:SpawnCabinProp(pos + forward * 80 + up * 120, ang, "models/props_c17/FurnitureShelf001a.mdl")
    self.MainSign = mainSign
    
    -- Sign support posts
    self:SpawnCabinProp(pos + forward * 80 + right * -25 + up * 60, ang, "models/props_phx/construct/wood/wood_boardx4.mdl", Angle(0, 0, 90))
    self:SpawnCabinProp(pos + forward * 80 + right * 25 + up * 60, ang, "models/props_phx/construct/wood/wood_boardx4.mdl", Angle(0, 0, 90))
    
    -- Additional rustic signs
    self:SpawnCabinProp(pos + forward * 10 + right * -80 + up * 60, ang + Angle(0, 45, 0), "models/props_c17/FurnitureShelf001a.mdl")
    self:SpawnCabinProp(pos + forward * 50 + right * 80 + up * 80, ang + Angle(0, -45, 0), "models/props_c17/FurnitureShelf001a.mdl")
end

function ENT:SpawnCabinProp(propPos, propAng, model, angleOffset)
    local prop = ents.Create("prop_physics")
    if IsValid(prop) then
        prop:SetModel(model)
        prop:SetPos(propPos)
        prop:SetAngles(propAng + (angleOffset or Angle(0, 0, 0)))
        prop:Spawn()
        prop:PhysicsInit(SOLID_VPHYSICS)
        
        -- Make it permanent and attach to trading post
        prop:SetParent(self)
        prop:SetHealth(999999)
        prop:SetMaxHealth(999999)
        prop.IsPermanent = true
        prop:SetNWBool("IsHiveStoreProp", true)
        
        -- Prevent movement
        local physObj = prop:GetPhysicsObject()
        if IsValid(physObj) then
            physObj:EnableMotion(false)
        end
        
        table.insert(self.TradingPostProps, prop)
        return prop
    end
end

function ENT:SpawnDupeFromTable(dupeTable, basePos, baseAng)
    self.TradingPostProps = {}
    local spawnedCount = 0
    
    print("[Hive Store] Parsing dupe data structure...")
    
    -- Handle different dupe data structures
    local entities = dupeTable.Entities or dupeTable.entities or dupeTable
    if not entities then
        print("[Hive Store] No entities found in dupe data")
        self:SpawnTradingPostProps()
        return
    end
    
    -- Spawn entities from dupe
    for i, entData in pairs(entities) do
        if entData and (entData.Class or entData.class) then
            local className = entData.Class or entData.class
            local ent = ents.Create(className)
            if IsValid(ent) then
                -- Get position and angle data
                local pos = entData.Pos or entData.pos or entData.Position or {x=0, y=0, z=0}
                local angle = entData.Angle or entData.angle or entData.angles or {p=0, y=0, r=0}
                
                -- Convert to vectors/angles if needed
                if type(pos) == "table" then
                    pos = Vector(pos.x or pos[1] or 0, pos.y or pos[2] or 0, pos.z or pos[3] or 0)
                end
                if type(angle) == "table" then
                    angle = Angle(angle.p or angle.pitch or angle[1] or 0, 
                                 angle.y or angle.yaw or angle[2] or 0, 
                                 angle.r or angle.roll or angle[3] or 0)
                end
                
                -- Position relative to trading post
                local worldPos = basePos + pos
                local worldAng = baseAng + angle
                
                ent:SetPos(worldPos)
                ent:SetAngles(worldAng)
                
                -- Set model if specified
                local model = entData.Model or entData.model
                if model and model ~= "" then
                    ent:SetModel(model)
                end
                
                -- Set material if specified
                local material = entData.Material or entData.material
                if material and material ~= "" then
                    ent:SetMaterial(material)
                end
                
                -- Set color if specified
                local color = entData.Color or entData.color
                if color then
                    if type(color) == "table" then
                        ent:SetColor(Color(color.r or color[1] or 255, 
                                          color.g or color[2] or 255, 
                                          color.b or color[3] or 255, 
                                          color.a or color[4] or 255))
                    end
                end
                
                ent:Spawn()
                ent:Activate()
                
                -- Make permanent and parent to trading post
                ent:SetParent(self)
                ent:SetHealth(999999)
                ent:SetMaxHealth(999999)
                ent.IsPermanent = true
                ent:SetNWBool("IsHiveStoreProp", true)
                
                -- Prevent movement
                local physObj = ent:GetPhysicsObject()
                if IsValid(physObj) then
                    physObj:EnableMotion(false)
                end
                
                table.insert(self.TradingPostProps, ent)
                spawnedCount = spawnedCount + 1
                
                -- Debug info for cabin props
                if string.find(string.lower(model or ""), "cabin") or 
                   string.find(string.lower(model or ""), "wood") or 
                   string.find(string.lower(model or ""), "house") then
                    print("[Hive Store] Spawned cabin part: " .. (model or className))
                end
            end
        end
    end
    
    if spawnedCount > 0 then
        print("[Hive Store] Successfully spawned " .. spawnedCount .. " entities from dupe")
        -- Add "The PeakeCoin Store" sign
        self:SpawnMainSign(basePos, baseAng)
    else
        print("[Hive Store] No entities were spawned from dupe, falling back to basic props")
        self:SpawnTradingPostProps()
    end
end

function ENT:SpawnMainSign(pos, ang)
    -- Create main store sign
    local sign = ents.Create("prop_physics")
    if IsValid(sign) then
        sign:SetModel("models/props_c17/FurnitureShelf001a.mdl")
        sign:SetPos(pos + ang:Forward() * 100 + Vector(0, 0, 120)) -- High and visible
        sign:SetAngles(ang)
        sign:Spawn()
        sign:PhysicsInit(SOLID_VPHYSICS)
        sign:SetParent(self)
        sign:SetHealth(999999)
        sign:SetMaxHealth(999999)
        sign.IsPermanent = true
        sign:SetNWBool("IsHiveStoreProp", true)
        
        -- Prevent movement
        local physObj = sign:GetPhysicsObject()
        if IsValid(physObj) then
            physObj:EnableMotion(false)
        end
        
        self.MainSign = sign
        table.insert(self.TradingPostProps, sign)
        
        print("[Hive Store] Main sign created")
    end
end

-- Debug function to inspect dupe contents
function ENT:DebugDupeContents(dupeFile)
    print("[Hive Store] DEBUG: Inspecting dupe file contents...")
    local dupeData = file.Read("dupes/" .. dupeFile, "DATA")
    if dupeData then
        print("[Hive Store] DEBUG: Dupe file size: " .. string.len(dupeData) .. " bytes")
        
        -- Show first few lines of the file
        local lines = string.Explode("\n", dupeData)
        print("[Hive Store] DEBUG: First 5 lines of dupe file:")
        for i = 1, math.min(5, #lines) do
            print("[Hive Store] DEBUG: Line " .. i .. ": " .. (lines[i] or ""))
        end
        
        -- Check if it's a typical GMod dupe format
        if string.find(dupeData, "info") and string.find(dupeData, "entities") then
            print("[Hive Store] DEBUG: Detected standard GMod dupe format")
        elseif string.find(dupeData, "{") and string.find(dupeData, "}") then
            print("[Hive Store] DEBUG: Detected JSON-like format")
        else
            print("[Hive Store] DEBUG: Unknown dupe format")
        end
    end
end
