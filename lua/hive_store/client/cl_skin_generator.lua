-- Custom Skin Generator for HiveStore NPCs
-- Generates procedural textures for the hillbilly brothers

HiveStore = HiveStore or {}
HiveStore.SkinGenerator = {}

-- Initialize skin generator
function HiveStore.SkinGenerator.Initialize()
    print("[Hive Store] Initializing skin generator...")
    
    -- Generate elder brother skin
    HiveStore.SkinGenerator.GenerateElderBrotherSkin()
    
    -- Generate younger brother skin
    HiveStore.SkinGenerator.GenerateYoungerBrotherSkin()
    
    print("[Hive Store] Custom skins generated!")
end

-- Generate elder brother's weathered appearance
function HiveStore.SkinGenerator.GenerateElderBrotherSkin()
    local rt = GetRenderTarget("elder_brother_skin", 512, 512)
    
    render.PushRenderTarget(rt)
    render.Clear(139, 105, 69, 255) -- Dark tan base color
    
    cam.Start2D()
        -- Base skin tone with weathered look
        surface.SetDrawColor(160, 120, 80, 255)
        surface.DrawRect(0, 0, 512, 512)
        
        -- Add some texture variations for weathered skin
        for i = 1, 50 do
            local x = math.random(0, 512)
            local y = math.random(0, 512)
            local size = math.random(2, 8)
            
            surface.SetDrawColor(145, 110, 75, 180)
            surface.DrawRect(x, y, size, size)
        end
        
        -- Beard area (darker)
        surface.SetDrawColor(80, 60, 40, 200)
        surface.DrawRect(200, 350, 120, 80)
        
        -- Add some gray streaks in beard
        surface.SetDrawColor(120, 120, 120, 150)
        for i = 1, 10 do
            local x = 210 + math.random(0, 100)
            local y = 360 + math.random(0, 60)
            surface.DrawRect(x, y, 2, 15)
        end
        
        -- Wrinkles around eyes
        surface.SetDrawColor(120, 90, 60, 100)
        surface.DrawRect(150, 200, 60, 2)
        surface.DrawRect(300, 200, 60, 2)
        surface.DrawRect(140, 220, 80, 1)
        surface.DrawRect(290, 220, 80, 1)
        
    cam.End2D()
    render.PopRenderTarget()
    
    -- Save the render target as material
    local mat = CreateMaterial("elder_brother_skin", "UnlitGeneric", {
        ["$basetexture"] = rt:GetName(),
        ["$vertexcolor"] = 1,
        ["$vertexalpha"] = 1
    })
end

-- Generate younger brother's cleaner appearance
function HiveStore.SkinGenerator.GenerateYoungerBrotherSkin()
    local rt = GetRenderTarget("younger_brother_skin", 512, 512)
    
    render.PushRenderTarget(rt)
    render.Clear(200, 160, 120, 255) -- Lighter tan base color
    
    cam.Start2D()
        -- Base skin tone (cleaner, younger)
        surface.SetDrawColor(210, 170, 130, 255)
        surface.DrawRect(0, 0, 512, 512)
        
        -- Less weathering, smoother skin
        for i = 1, 20 do
            local x = math.random(0, 512)
            local y = math.random(0, 512)
            local size = math.random(1, 4)
            
            surface.SetDrawColor(205, 165, 125, 120)
            surface.DrawRect(x, y, size, size)
        end
        
        -- Light stubble instead of full beard
        surface.SetDrawColor(100, 80, 60, 120)
        for i = 1, 30 do
            local x = 200 + math.random(0, 120)
            local y = 340 + math.random(0, 60)
            surface.DrawRect(x, y, 1, 1)
        end
        
        -- Fewer wrinkles (younger)
        surface.SetDrawColor(190, 150, 110, 80)
        surface.DrawRect(160, 210, 40, 1)
        surface.DrawRect(310, 210, 40, 1)
        
        -- Bright eyes (more energetic)
        surface.SetDrawColor(100, 150, 200, 200)
        surface.DrawRect(170, 200, 8, 8)
        surface.DrawRect(330, 200, 8, 8)
        
    cam.End2D()
    render.PopRenderTarget()
    
    -- Save the render target as material
    local mat = CreateMaterial("younger_brother_skin", "UnlitGeneric", {
        ["$basetexture"] = rt:GetName(),
        ["$vertexcolor"] = 1,
        ["$vertexalpha"] = 1
    })
end

-- Hook to initialize when needed
hook.Add("InitPostEntity", "HiveStore.GenerateSkins", function()
    timer.Simple(2, function()
        HiveStore.SkinGenerator.Initialize()
    end)
end)
