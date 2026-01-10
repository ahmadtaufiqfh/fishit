-- FPS BOOST FINAL (ANDROID SAFE)
-- SELF LOWPOLY | OTHER PLAYER INVISIBLE
-- NO WATER | NO ANIMATION | NO EFFECT
-- DELTA EXECUTOR

if getgenv().FPS_BOOST ~= nil then return end
getgenv().FPS_BOOST = true

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Terrain = workspace:FindFirstChildOfClass("Terrain")

-- ================== OBJECT OPTIMIZER ==================
local function OptimizeObject(v)
    if v:IsA("BasePart") then
        v.Material = Enum.Material.Plastic
        v.Reflectance = 0
        v.CastShadow = false

    elseif v:IsA("Decal") or v:IsA("Texture") then
        v.Transparency = 1

    elseif v:IsA("ParticleEmitter")
        or v:IsA("Trail")
        or v:IsA("Beam")
        or v:IsA("Smoke")
        or v:IsA("Fire") then
        v.Enabled = false
    end
end

-- ================== DISABLE ANIMATIONS ==================
local function DisableAnimations(char)
    for _,v in ipairs(char:GetDescendants()) do
        if v:IsA("Animator") or v:IsA("AnimationController") then
            for _,track in ipairs(v:GetPlayingAnimationTracks()) do
                track:Stop()
            end
        end
    end
end

-- ================== SELF LOW POLY ==================
local function LowPolySelf(char)
    for _,v in ipairs(char:GetDescendants()) do
        if v:IsA("BasePart") then
            v.Material = Enum.Material.Plastic
            v.Reflectance = 0
            v.CastShadow = false

        elseif v:IsA("Accessory") then
            local h = v:FindFirstChild("Handle")
            if h then
                h.Transparency = 1
            end
        end
    end
    DisableAnimations(char)
end

-- ================== OTHER PLAYER INVISIBLE ==================
local function HideOtherPlayer(char)
    for _,v in ipairs(char:GetDescendants()) do
        if v:IsA("BasePart") then
            v.Transparency = 1
            v.CanCollide = false
            v.CastShadow = false

        elseif v:IsA("ParticleEmitter")
            or v:IsA("Trail")
            or v:IsA("Beam")
            or v:IsA("Smoke")
            or v:IsA("Fire") then
            v.Enabled = false
        end
    end
    DisableAnimations(char)
end

-- ================== APPLY FPS BOOST ==================
local function ApplyFPSBoost()
    if not getgenv().FPS_BOOST then return end

    -- Lighting
    Lighting.GlobalShadows = false
    Lighting.Brightness = 0
    Lighting.FogEnd = 1e9
    Lighting.EnvironmentDiffuseScale = 0
    Lighting.EnvironmentSpecularScale = 0

    for _,v in ipairs(Lighting:GetChildren()) do
        if v:IsA("Sky") then
            v:Destroy()
        elseif v:IsA("PostEffect")
            or v:IsA("Atmosphere")
            or v:IsA("SunRaysEffect")
            or v:IsA("BloomEffect")
            or v:IsA("DepthOfFieldEffect")
            or v:IsA("ColorCorrectionEffect") then
            v.Enabled = false
        end
    end

    -- Cloud OFF
    local cloud = workspace:FindFirstChildOfClass("Clouds")
    if cloud then cloud.Enabled = false end

    -- Water OFF
    if Terrain then
        Terrain.WaterWaveSize = 0
        Terrain.WaterWaveSpeed = 0
        Terrain.WaterReflectance = 0
        Terrain.WaterTransparency = 1
    end

    -- Map optimize
    for _,v in ipairs(workspace:GetDescendants()) do
        OptimizeObject(v)
    end

    -- Players
    for _,p in ipairs(Players:GetPlayers()) do
        if p.Character then
            if p == LocalPlayer then
                LowPolySelf(p.Character)
            else
                HideOtherPlayer(p.Character)
            end
        end
    end

    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    end)
end

-- ================== AUTO APPLY NEW OBJECT ==================
workspace.DescendantAdded:Connect(function(v)
    if getgenv().FPS_BOOST then
        task.wait()
        OptimizeObject(v)
    end
end)

-- ================== PLAYER JOIN / RESPAWN ==================
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function(char)
        task.wait(1)
        if getgenv().FPS_BOOST then
            if p == LocalPlayer then
                LowPolySelf(char)
            else
                HideOtherPlayer(char)
            end
        end
    end)
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1)
    if getgenv().FPS_BOOST then
        LowPolySelf(char)
    end
end)

-- ================== UI ==================
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "FPSBoostUI"

local btn = Instance.new("TextButton", gui)
btn.Size = UDim2.new(0, 110, 0, 28)
btn.Position = UDim2.new(0, 10, 0, 10)
btn.BackgroundColor3 = Color3.fromRGB(20,20,20)
btn.TextColor3 = Color3.new(1,1,1)
btn.TextSize = 12
btn.Font = Enum.Font.Code
btn.BorderSizePixel = 0
btn.Active = true
btn.Draggable = true
btn.Text = "FPS BOOST : ON"

btn.MouseButton1Click:Connect(function()
    getgenv().FPS_BOOST = not getgenv().FPS_BOOST
    btn.Text = "FPS BOOST : "..(getgenv().FPS_BOOST and "ON" or "OFF")

    if getgenv().FPS_BOOST then
        ApplyFPSBoost()
    end
end)

-- ================== TELEPORT SAFE ==================
LocalPlayer.OnTeleport:Connect(function(state)
    if state == Enum.TeleportState.Started then
        queue_on_teleport([[
            getgenv().FPS_BOOST = true
        ]])
    end
end)

-- ================== START ==================
ApplyFPSBoost()
