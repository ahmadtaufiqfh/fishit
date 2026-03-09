-- ==============================================================
-- ARSY FREECAM 
-- ==============================================================

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- 1. CLEAN UP PREVIOUS UI
if CoreGui:FindFirstChild("ArsyFreecam") then
    CoreGui.ArsyFreecam:Destroy()
end

-- 2. CREATE MINIMALIST UI PANEL
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ArsyFreecam"
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 160, 0, 80)
MainFrame.Position = UDim2.new(0.5, -80, 0.05, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BackgroundTransparency = 0.2 -- Sedikit tembus pandang
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local ToggleFreecamBtn = Instance.new("TextButton")
ToggleFreecamBtn.Size = UDim2.new(1, -10, 0, 30)
ToggleFreecamBtn.Position = UDim2.new(0, 5, 0, 5)
ToggleFreecamBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
ToggleFreecamBtn.BorderSizePixel = 0
ToggleFreecamBtn.Text = "FREECAM : OFF"
ToggleFreecamBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
ToggleFreecamBtn.Font = Enum.Font.GothamSemibold
ToggleFreecamBtn.TextSize = 13
ToggleFreecamBtn.Parent = MainFrame

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(1, -10, 0, 15)
SpeedLabel.Position = UDim2.new(0, 5, 0, 42)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "SPEED: 50"
SpeedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
SpeedLabel.Font = Enum.Font.GothamSemibold
SpeedLabel.TextSize = 11
SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
SpeedLabel.Parent = MainFrame

local SliderBG = Instance.new("TextButton")
SliderBG.Size = UDim2.new(1, -10, 0, 8)
SliderBG.Position = UDim2.new(0, 5, 0, 62)
SliderBG.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
SliderBG.BorderSizePixel = 0
SliderBG.Text = ""
SliderBG.AutoButtonColor = false
SliderBG.Parent = MainFrame

local SliderFill = Instance.new("Frame")
SliderFill.Size = UDim2.new(0.25, 0, 1, 0)
SliderFill.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
SliderFill.BorderSizePixel = 0
SliderFill.Parent = SliderBG

-- 3. CREATE MOBILE Q/E BUTTONS
local BtnContainer = Instance.new("Frame")
BtnContainer.Size = UDim2.new(0, 50, 0, 110)
BtnContainer.Position = UDim2.new(1, -65, 0.5, -55)
BtnContainer.BackgroundTransparency = 1
BtnContainer.Visible = false
BtnContainer.Parent = ScreenGui

local UpBtn = Instance.new("TextButton")
UpBtn.Size = UDim2.new(1, 0, 0, 50)
UpBtn.Position = UDim2.new(0, 0, 0, 0)
UpBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
UpBtn.BackgroundTransparency = 0.5
UpBtn.BorderSizePixel = 0
UpBtn.Text = "^"
UpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
UpBtn.Font = Enum.Font.GothamBold
UpBtn.TextSize = 20
UpBtn.Parent = BtnContainer

local DownBtn = Instance.new("TextButton")
DownBtn.Size = UDim2.new(1, 0, 0, 50)
DownBtn.Position = UDim2.new(0, 0, 0, 60)
DownBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
DownBtn.BackgroundTransparency = 0.5
DownBtn.BorderSizePixel = 0
DownBtn.Text = "v"
DownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
DownBtn.Font = Enum.Font.GothamBold
DownBtn.TextSize = 20
DownBtn.Parent = BtnContainer

-- ==========================================
-- 4. INPUT LOGIC & FREECAM
-- ==========================================
local isDragging = false
local minSpeed = 10
local maxSpeed = 200
local currentSpeed = 50

-- Logika Slider
local function updateSlider(input)
    local relativeX = math.clamp(input.Position.X - SliderBG.AbsolutePosition.X, 0, SliderBG.AbsoluteSize.X)
    local percentage = relativeX / SliderBG.AbsoluteSize.X
    SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
    currentSpeed = math.floor(minSpeed + ((maxSpeed - minSpeed) * percentage))
    SpeedLabel.Text = "SPEED: " .. currentSpeed
end

SliderBG.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDragging = true
        updateSlider(input)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        updateSlider(input)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDragging = false
    end
end)

-- Logika Tombol Sentuh Mobile
local isUpPressed = false
local isDownPressed = false

local function handleTouchBegan(input, buttonType)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        if buttonType == "up" then 
            isUpPressed = true 
            UpBtn.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
        elseif buttonType == "down" then 
            isDownPressed = true 
            DownBtn.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
        end
    end
end

local function handleTouchEnded(input, buttonType)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        if buttonType == "up" then 
            isUpPressed = false 
            UpBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        elseif buttonType == "down" then 
            isDownPressed = false 
            DownBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        end
    end
end

UpBtn.InputBegan:Connect(function(input) handleTouchBegan(input, "up") end)
UpBtn.InputEnded:Connect(function(input) handleTouchEnded(input, "up") end)
DownBtn.InputBegan:Connect(function(input) handleTouchBegan(input, "down") end)
DownBtn.InputEnded:Connect(function(input) handleTouchEnded(input, "down") end)

-- Modul Pergerakan Bawaan Roblox
local PlayerModule = require(player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"))
local controls = PlayerModule:GetControls()

local freecamConnection = nil
local freecamOn = false
local camPart = nil

ToggleFreecamBtn.MouseButton1Click:Connect(function()
    freecamOn = not freecamOn
    local character = player.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    
    if freecamOn then
        ToggleFreecamBtn.Text = "FREECAM : ON"
        ToggleFreecamBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
        BtnContainer.Visible = true
        
        if hrp then hrp.Anchored = true end
        
        camPart = Instance.new("Part")
        camPart.Transparency = 1
        camPart.CanCollide = false
        camPart.Anchored = true
        camPart.Size = Vector3.new(1, 1, 1)
        camPart.CFrame = CFrame.new(camera.Focus.Position) 
        camPart.Parent = workspace
        
        camera.CameraSubject = camPart
        
        freecamConnection = RunService.RenderStepped:Connect(function(dt)
            local moveVec = controls:GetMoveVector()
            
            local verticalMovement = 0
            if UserInputService:IsKeyDown(Enum.KeyCode.E) or isUpPressed then verticalMovement = 1 end
            if UserInputService:IsKeyDown(Enum.KeyCode.Q) or isDownPressed then verticalMovement = -1 end
            
            if moveVec.Magnitude > 0 or verticalMovement ~= 0 then
                local camCF = camera.CFrame
                local movement = (camCF.LookVector * -moveVec.Z) + (camCF.RightVector * moveVec.X) + Vector3.new(0, verticalMovement, 0)
                
                if movement.Magnitude > 1 then
                    movement = movement.Unit
                end
                
                camPart.Position = camPart.Position + (movement * currentSpeed * dt)
            end
        end)
    else
        ToggleFreecamBtn.Text = "FREECAM : OFF"
        ToggleFreecamBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        BtnContainer.Visible = false
        
        if freecamConnection then 
            freecamConnection:Disconnect() 
            freecamConnection = nil 
        end
        if camPart then
            camPart:Destroy()
            camPart = nil
        end
        if hrp then hrp.Anchored = false end
        if character and character:FindFirstChild("Humanoid") then
            camera.CameraSubject = character.Humanoid
        end
        
        isUpPressed = false
        isDownPressed = false
        UpBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        DownBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    end
end)
