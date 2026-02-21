-- Loona Trading Post - Combined NPC and Shop Entity
-- Client-side initialization

include("shared.lua")

ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:Initialize()
    -- Client-side initialization
end

function ENT:Draw()
    self:DrawModel()
    
    -- Draw main "PeakeCoin Store" sign high above
    local mainSignPos = self:GetPos() + Vector(50, 0, 120)
    local mainSignAng = (LocalPlayer():GetPos() - mainSignPos):Angle()
    mainSignAng:RotateAroundAxis(mainSignAng:Forward(), 90)
    mainSignAng:RotateAroundAxis(mainSignAng:Right(), 90)
    
    cam.Start3D2D(mainSignPos, mainSignAng, 0.3)
        -- Main store sign
        draw.SimpleTextOutlined("The PeakeCoin Store", "DermaLarge", 0, -20, Color(255, 215, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 4, Color(0, 0, 0))
        draw.SimpleTextOutlined("Cryptocurrency Trading Post", "DermaDefault", 0, 10, Color(200, 200, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color(0, 0, 0))
    cam.End3D2D()
    
    -- Draw trading post information sign
    local infoSignPos = self:GetPos() + Vector(0, 0, 100)
    local infoSignAng = (LocalPlayer():GetPos() - infoSignPos):Angle()
    infoSignAng:RotateAroundAxis(infoSignAng:Forward(), 90)
    infoSignAng:RotateAroundAxis(infoSignAng:Right(), 90)
    
    cam.Start3D2D(infoSignPos, infoSignAng, 0.2)
        -- Trading post info
        draw.SimpleTextOutlined("Loona Trading Post", "DermaLarge", 0, -40, Color(255, 255, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 3, Color(0, 0, 0))
        draw.SimpleTextOutlined("Mountain Trading Since 1995", "DermaDefault", 0, -10, Color(200, 200, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color(0, 0, 0))
        
        -- Brother instructions with updated names
        draw.SimpleTextOutlined("E.R. (Main Shack) - General Store", "DermaDefault", -80, 20, Color(150, 255, 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0))
        draw.SimpleTextOutlined("Nater (Lean-to) - Weapons & Tools", "DermaDefault", 80, 20, Color(255, 150, 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0))
        
        draw.SimpleTextOutlined("Press E to Trade", "DermaDefault", 0, 50, Color(100, 255, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color(0, 0, 0))
    cam.End3D2D()
end

-- Add some ambient effects
function ENT:Think()
    -- Occasional campfire smoke effect
    if math.random(1, 200) == 1 then
        local pos = self:GetPos() + Vector(0, 80, 10)
        
        local effectdata = EffectData()
        effectdata:SetOrigin(pos)
        effectdata:SetScale(2)
        util.Effect("smoke_gib01", effectdata)
    end
    
    -- Dust particles occasionally
    if math.random(1, 300) == 1 then
        local pos = self:GetPos() + Vector(math.random(-50, 50), math.random(-50, 50), 5)
        
        local effectdata = EffectData()
        effectdata:SetOrigin(pos)
        effectdata:SetScale(0.5)
        util.Effect("dust_impact", effectdata)
    end
end
