-- Elder Brother Shopkeeper NPC
-- Client-side initialization

include("shared.lua")

ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:Initialize()
    -- Client-side initialization
end

function ENT:Draw()
    self:DrawModel()
    
    -- Draw name tag above NPC
    local pos = self:GetPos() + Vector(0, 0, 85)
    local ang = (LocalPlayer():GetPos() - pos):Angle()
    ang:RotateAroundAxis(ang:Forward(), 90)
    ang:RotateAroundAxis(ang:Right(), 90)
    
    cam.Start3D2D(pos, ang, 0.1)
        draw.SimpleTextOutlined(self.NPCName or "Jeb McCoy", "DermaLarge", 0, 0, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color(0, 0, 0))
        draw.SimpleTextOutlined("Elder Brother - General Store", "DermaDefault", 0, 30, Color(200, 200, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0))
        draw.SimpleTextOutlined("Press E to Trade", "DermaDefault", 0, 50, Color(100, 255, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0))
    cam.End3D2D()
end

-- Add particle effects for atmosphere
function ENT:Think()
    -- Occasional smoke puff from pipe (if we add one)
    if math.random(1, 300) == 1 then
        local pos = self:GetPos() + self:GetUp() * 65 + self:GetForward() * 10
        
        local effectdata = EffectData()
        effectdata:SetOrigin(pos)
        util.Effect("smoke_gib01", effectdata)
    end
end
