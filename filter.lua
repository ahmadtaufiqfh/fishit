local ReplicatedStorage = game:GetService("ReplicatedStorage")
local itemsFolder = ReplicatedStorage:FindFirstChild("Items")
local variantsFolder = ReplicatedStorage:FindFirstChild("Variants")
local tiersModule = ReplicatedStorage:FindFirstChild("Tiers")

-- ==========================================
-- 1. Mengumpulkan Data
-- ==========================================
local fishNames = {}
local tempFishDict = {}

-- Ambil Data Ikan
if itemsFolder then
    for _, instance in ipairs(itemsFolder:GetDescendants()) do
        if instance:IsA("ModuleScript") then
            local success, itemData = pcall(function() return require(instance) end)
            if success and type(itemData) == "table" and itemData.Data and itemData.Data.Type == "Fish" then
                local fishName = itemData.Data.Name
                if fishName and not tempFishDict[fishName] then
                    tempFishDict[fishName] = true
                    table.insert(fishNames, fishName)
                end
            end
        end
    end
    table.sort(fishNames)
end

-- Ambil Data Variant
local variantNames = {}
if variantsFolder then
    for _, child in ipairs(variantsFolder:GetChildren()) do
        table.insert(variantNames, child.Name)
    end
    if variantsFolder:IsA("ModuleScript") and #variantNames == 0 then
        local success, varData = pcall(function() return require(variantsFolder) end)
        if success and type(varData) == "table" then
            for key, val in pairs(varData) do
                local nameToInsert = type(val) == "table" and val.Name or (type(key) == "string" and key or tostring(val))
                table.insert(variantNames, nameToInsert)
            end
        end
    end
    table.sort(variantNames)
end

-- Ambil Data Tiers (Diurutkan berdasarkan Level Tier, bukan Abjad)
local tierNames = {}
if tiersModule and tiersModule:IsA("ModuleScript") then
    local success, tierData = pcall(function() return require(tiersModule) end)
    if success and type(tierData) == "table" then
        local rawTiers = {}
        for _, data in pairs(tierData) do
            if type(data) == "table" and data.Name then
                -- Simpan nama dan angka Tier-nya (jika tidak ada angka tier, jadikan 999 agar di bawah)
                table.insert(rawTiers, {name = data.Name, tierLevel = data.Tier or 999})
            end
        end
        -- Mengurutkan dari Tier terkecil ke terbesar
        table.sort(rawTiers, function(a, b) return a.tierLevel < b.tierLevel end)
        
        -- Memasukkan nama yang sudah diurutkan ke daftar dropdown
        for _, v in ipairs(rawTiers) do
            table.insert(tierNames, v.name)
        end
    end
end

-- ==========================================
-- 2. Membuat Custom UI (3 Dropdown)
-- ==========================================
local guiName = "FishVariantTierDropdownUI"
local parentGui = (gethui and gethui()) or game:GetService("CoreGui") or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

if parentGui:FindFirstChild(guiName) then parentGui[guiName]:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = guiName
ScreenGui.Parent = parentGui

-- Frame Utama (Diperbesar untuk 3 Dropdown)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 260, 0, 200)
MainFrame.Position = UDim2.new(0.5, -130, 0.5, -100)
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MainFrame.Active = true
MainFrame.Draggable = true 
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Text = "🐟 Auto Fish Config"
Title.TextColor3 = Color3.fromRGB(220, 220, 220)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.Parent = MainFrame

-- ==========================================
-- Fungsi Pembuat Dropdown
-- ==========================================
local function CreateDropdown(titleText, yPosition, optionsList, zIndexLayer)
    local DropdownFrame = Instance.new("Frame")
    DropdownFrame.Size = UDim2.new(1, -20, 0, 35)
    DropdownFrame.Position = UDim2.new(0, 10, 0, yPosition)
    DropdownFrame.BackgroundTransparency = 1
    DropdownFrame.ZIndex = zIndexLayer
    DropdownFrame.Parent = MainFrame

    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(1, 0, 1, -5)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleBtn.Text = "  " .. titleText .. ": Belum Dipilih"
    ToggleBtn.Font = Enum.Font.Gotham
    ToggleBtn.TextSize = 13
    ToggleBtn.TextXAlignment = Enum.TextXAlignment.Left
    ToggleBtn.ZIndex = zIndexLayer
    ToggleBtn.Parent = DropdownFrame

    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 5)
    ToggleCorner.Parent = ToggleBtn

    local ListPanel = Instance.new("Frame")
    ListPanel.Size = UDim2.new(1, 0, 0, 140)
    ListPanel.Position = UDim2.new(0, 0, 1, 0)
    ListPanel.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    ListPanel.Visible = false
    ListPanel.ZIndex = zIndexLayer + 1
    ListPanel.Parent = DropdownFrame

    local PanelCorner = Instance.new("UICorner")
    PanelCorner.CornerRadius = UDim.new(0, 5)
    PanelCorner.Parent = ListPanel

    local SearchBox = Instance.new("TextBox")
    SearchBox.Size = UDim2.new(1, -10, 0, 25)
    SearchBox.Position = UDim2.new(0, 5, 0, 5)
    SearchBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    SearchBox.PlaceholderText = "🔍 Cari " .. string.lower(titleText) .. "..."
    SearchBox.Font = Enum.Font.Gotham
    SearchBox.TextSize = 12
    SearchBox.ClearTextOnFocus = false
    SearchBox.ZIndex = zIndexLayer + 1
    SearchBox.Parent = ListPanel

    local ScrollFrame = Instance.new("ScrollingFrame")
    ScrollFrame.Size = UDim2.new(1, -10, 1, -40)
    ScrollFrame.Position = UDim2.new(0, 5, 0, 35)
    ScrollFrame.BackgroundTransparency = 1
    ScrollFrame.ScrollBarThickness = 3
    ScrollFrame.ZIndex = zIndexLayer + 1
    ScrollFrame.Parent = ListPanel

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 2)
    UIListLayout.Parent = ScrollFrame

    local buttons = {}
    for _, optName in ipairs(optionsList) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 25)
        btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        btn.TextColor3 = Color3.fromRGB(220, 220, 220)
        btn.Text = "  " .. optName
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 12
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.ZIndex = zIndexLayer + 1
        btn.Parent = ScrollFrame

        btn.MouseButton1Click:Connect(function()
            ToggleBtn.Text = "  " .. titleText .. ": " .. optName
            ListPanel.Visible = false
            print(titleText .. " disetel ke: " .. optName)
        end)

        table.insert(buttons, {btn = btn, lowerName = string.lower(optName)})
    end

    UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
    end)

    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local query = string.lower(SearchBox.Text)
        for _, data in ipairs(buttons) do
            data.btn.Visible = (query == "" or string.find(data.lowerName, query) ~= nil)
        end
    end)

    ToggleBtn.MouseButton1Click:Connect(function()
        ListPanel.Visible = not ListPanel.Visible
    end)
end

-- ==========================================
-- 3. Memasang Ketiga Dropdown ke UI
-- ==========================================
-- Perhatikan Z-Index (15, 10, 5) agar panel tidak tertutup elemen di bawahnya
CreateDropdown("Target Ikan", 45, fishNames, 15)
CreateDropdown("Target Variant", 85, variantNames, 10)
CreateDropdown("Target Tier", 125, tierNames, 5)

-- Info Jumlah Data
local InfoText = Instance.new("TextLabel")
InfoText.Size = UDim2.new(1, 0, 0, 20)
InfoText.Position = UDim2.new(0, 0, 1, -25)
InfoText.Text = "Data: " .. #fishNames .. " Ikan | " .. #variantNames .. " Variant | " .. #tierNames .. " Tier"
InfoText.TextColor3 = Color3.fromRGB(150, 150, 150)
InfoText.BackgroundTransparency = 1
InfoText.Font = Enum.Font.Gotham
InfoText.TextSize = 11
InfoText.Parent = MainFrame
