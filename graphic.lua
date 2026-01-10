if getgenv().AUTO_POTATO ~= nil then return end
getgenv().AUTO_POTATO = true

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

-- ===== APPLY FUNCTION =====
local function ApplyPotato()
    if not getgenv().AUTO_POTATO then return end

    local Terrain = workspace:FindFirstChildOfClass("Terrain")

    Lighting.GlobalShadows = false
    Lighting.Brightness = 0
    Lighting.FogEnd = 1e9
    Lighting.EnvironmentDiffuseScale = 0
    Lighting.EnvironmentSpecularScale = 0

    for _,v in ipairs(Lighting:GetChildren()) do
        if v:IsA("PostEffect") then
            v:Destroy()
        end
    end

    if Terrain then
        Terrain.WaterWaveSize = 0
        Terrain.WaterWaveSpeed = 0
        Terrain.WaterReflectance = 0
        Terrain.WaterTransparency = 1
    end
		pcall(function()
        Terrain:SetMaterialColor(Enum.Material.Water, Color3.new(0,0,0))
		end)

    for _,v in ipairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            v.Material = Enum.Material.Plastic
            v.Reflectance = 0
            v.CastShadow = false
        elseif v:IsA("Decal") or v:IsA("Texture") then
            v:Destroy()
        elseif v:IsA("ParticleEmitter")
        or v:IsA("Trail")
        or v:IsA("Smoke")
        or v:IsA("Fire") then
            v.Enabled = false
        end
    end

    for _,p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            p.Character:Destroy()
        end
    end

    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    end)
end

-- ===== SIMPLE TOGGLE UI =====
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "PotatoToggle"

local btn = Instance.new("TextButton", gui)
btn.Size = UDim2.new(0, 90, 0, 28)
btn.Position = UDim2.new(0, 10, 0, 10)
btn.BackgroundColor3 = Color3.fromRGB(30,30,30)
btn.TextColor3 = Color3.new(1,1,1)
btn.TextSize = 12
btn.Font = Enum.Font.Code
btn.Text = "FPS BOOST : ON"
btn.BorderSizePixel = 0
btn.Active = true
btn.Draggable = true

btn.MouseButton1Click:Connect(function()
    getgenv().AUTO_POTATO = not getgenv().AUTO_POTATO
    btn.Text = "FPS BOOST : "..(getgenv().AUTO_POTATO and "ON" or "OFF")

    if getgenv().AUTO_POTATO then
        ApplyPotato()
    end
end)

-- ===== APPLY FIRST =====
ApplyPotato()

-- ===== RE-APPLY ON RESPAWN =====
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    ApplyPotato()
end)

-- ===== AUTO RE-APPLY ON TELEPORT =====
LocalPlayer.OnTeleport:Connect(function(state)
    if state == Enum.TeleportState.Started then
        queue_on_teleport([[
            getgenv().AUTO_POTATO = true
        ]])
    end
end)
