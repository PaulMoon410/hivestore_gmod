-- Younger Brother Shopkeeper NPC
-- Client-side initialization

include("shared.lua")

ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:Initialize()
    -- Client-side initialization
    self.nextBlink = CurTime() + math.random(3, 8)
    self.isBlinking = false
    self.blinkDuration = 0.2
end

function ENT:Draw()
    self:DrawModel()
    
    -- Draw name tag above NPC with different style for younger brother
    local pos = self:GetPos() + Vector(0, 0, 85)
    local ang = (LocalPlayer():GetPos() - pos):Angle()
    ang:RotateAroundAxis(ang:Forward(), 90)
    ang:RotateAroundAxis(ang:Right(), 90)
    
    -- Slightly bouncing name tag for younger brother's personality
    local bounce = math.sin(CurTime() * 2) * 2
    pos = pos + Vector(0, 0, bounce)
    
    cam.Start3D2D(pos, ang, 0.1)
        draw.SimpleTextOutlined(self.NPCName or "Cletus McCoy", "DermaLarge", 0, 0, Color(255, 255, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color(0, 0, 0))
        draw.SimpleTextOutlined("Younger Brother - Weapons & Tools", "DermaDefault", 0, 30, Color(255, 200, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0))
        draw.SimpleTextOutlined("Press E for Quality Gear!", "DermaDefault", 0, 50, Color(255, 150, 50), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0))
    cam.End3D2D()
end

-- More animated effects for younger brother
function ENT:Think()
    local currentTime = CurTime()
    
    -- Blinking animation
    if currentTime >= self.nextBlink and not self.isBlinking then
        self.isBlinking = true
        self.blinkEnd = currentTime + self.blinkDuration
    end
    
    if self.isBlinking and currentTime >= self.blinkEnd then
        self.isBlinking = false
        self.nextBlink = currentTime + math.random(2, 6)
    end
    
    -- Occasional gun cleaning particle effect
    if math.random(1, 400) == 1 then
        local pos = self:GetPos() + self:GetUp() * 50 + self:GetForward() * 15 + self:GetRight() * 10
        
        local effectdata = EffectData()
        effectdata:SetOrigin(pos)
        effectdata:SetScale(0.5)
        util.Effect("dust_impact", effectdata)
    end
    
    -- Tool sparks occasionally
    if math.random(1, 600) == 1 then
        local pos = self:GetPos() + self:GetUp() * 45 + self:GetForward() * 20
        
        local effectdata = EffectData()
        effectdata:SetOrigin(pos)
        effectdata:SetMagnitude(1)
        effectdata:SetScale(1)
        util.Effect("ElectricSpark", effectdata)
    end
end

-- Handle specialized store opening
net.Receive("HiveStore.OpenSpecializedStore", function()
    local shopType = net.ReadString()
    local npcName = net.ReadString()
    
    -- This will be handled by the main store GUI system
    -- but with filtered items based on shopType
    HiveStore = HiveStore or {}
    HiveStore.Client = HiveStore.Client or {}
    
    if HiveStore.Client.OpenSpecializedStore then
        HiveStore.Client.OpenSpecializedStore(shopType, npcName)
    else
        -- Fallback to regular store
        if HiveStore.Client.OpenStore then
            HiveStore.Client.OpenStore()
        end
    end
end)
