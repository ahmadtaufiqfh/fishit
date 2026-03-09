local ReplicatedStorage = game:GetService("ReplicatedStorage")
local itemsFolder = ReplicatedStorage:FindFirstChild("Items")

-- 1. Kumpulkan Data Ikan (Sama seperti sebelumnya, efisien dan cepat)
local fishNames = {}
local tempDict = {}

if itemsFolder then
    for _, instance in ipairs(itemsFolder:GetDescendants()) do
        if instance:IsA("ModuleScript") then
            local success, itemData = pcall(function() return require(instance) end)
            if success and type(itemData) == "table" and itemData.Data and itemData.Data.Type == "Fish" then
                local fishName = itemData.Data.Name
                if fishName and not tempDict[fishName] then
                    tempDict[fishName] = true
                    table.insert(fishNames, fishName)
                end
            end
        end
    end
    table.sort(fishNames)
end

-- ==========================================
-- 2. Membuat Custom UI yang Sangat Ringan
-- ==========================================
local guiName = "LightweightFishUI"
-- Mencari tempat yang aman untuk menaruh GUI (mendukung Delta/eksekutor modern)
local parentGui = (gethui and gethui()) or game:GetService("CoreGui") or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

-- Hapus UI lama jika script di-execute ulang (mencegah duplikat layar)
if parentGui:FindFirstChild(guiName) then
    parentGui[guiName]:Destroy()
end

-- ScreenGui Utama
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = guiName
ScreenGui.Parent = parentGui

-- Frame Latar Belakang (Bisa digeser/Drag)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 350)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Active = true
MainFrame.Draggable = true 
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- Judul UI
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundTransparency = 1
Title.Text = "Target Ikan: Belum Dipilih"
Title.TextColor3 = Color3.fromRGB(200, 200, 200)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.Parent = MainFrame

-- Kolom Pencarian (Search Bar)
local SearchBox = Instance.new("TextBox")
SearchBox.Size = UDim2.new(1, -20, 0, 30)
SearchBox.Position = UDim2.new(0, 10, 0, 40)
SearchBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SearchBox.PlaceholderText = "🔍 Cari nama ikan..."
SearchBox.Font = Enum.Font.Gotham
SearchBox.TextSize = 13
SearchBox.ClearTextOnFocus = false
SearchBox.Parent = MainFrame

local SearchCorner = Instance.new("UICorner")
SearchCorner.CornerRadius = UDim.new(0, 5)
SearchCorner.Parent = SearchBox

-- Frame Daftar Ikan (Scrollable)
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -20, 1, -85)
ScrollFrame.Position = UDim2.new(0, 10, 0, 75)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.ScrollBarThickness = 4
ScrollFrame.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 4)
UIListLayout.Parent = ScrollFrame

-- 3. Mengisi Daftar dan Membuat Fitur Search Berfungsi
local buttons = {} -- Menyimpan referensi tombol untuk filter pencarian

for _, name in ipairs(fishNames) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 28)
    btn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = "  " .. name
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = ScrollFrame
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 4)
    BtnCorner.Parent = btn

    -- Ketika Ikan Dipilih
    btn.MouseButton1Click:Connect(function()
        Title.Text = "Target: " .. name
        print("Ikan diklik: " .. name)
        -- ANDA BISA MENAMBAHKAN LOGIKA AUTO CATCH DI SINI NANTINYA
    end)

    -- Simpan ke tabel untuk fitur search (jadikan huruf kecil semua agar mudah dicari)
    table.insert(buttons, {button = btn, nameLower = string.lower(name)})
end

-- Menyesuaikan ukuran scroll otomatis
UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
end)

-- LOGIKA PENCARIAN (Berjalan otomatis saat Anda mengetik)
SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    local searchText = string.lower(SearchBox.Text)
    for _, data in ipairs(buttons) do
        -- Jika kolom search kosong, atau nama ikan mengandung huruf yang diketik
        if searchText == "" or string.find(data.nameLower, searchText) then
            data.button.Visible = true
        else
            data.button.Visible = false
        end
    end
end)
