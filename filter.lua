local ReplicatedStorage = game:GetService("ReplicatedStorage")
local itemsFolder = ReplicatedStorage:FindFirstChild("Items")

-- 1. Menyiapkan tabel data ikan
local fishNames = {}
local tempDict = {}

if itemsFolder then
    print("Mencari data ikan...")
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
    print("Berhasil menemukan " .. #fishNames .. " jenis ikan!")
else
    warn("Folder 'Items' tidak ditemukan!")
end

-- ==========================================
-- 3. Membuat UI dengan Rayfield Library
-- ==========================================

-- Memuat Rayfield Library (Link stabil)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Membuat Jendela UI
local Window = Rayfield:CreateWindow({
   Name = "Fish Hub",
   LoadingTitle = "Memuat Data Ikan...",
   LoadingSubtitle = "Tunggu sebentar",
   ConfigurationSaving = {
      Enabled = false,
   },
   KeySystem = false -- Tidak perlu pakai sistem key/password
})

-- Membuat Tab Utama
local MainTab = Window:CreateTab("Menu Ikan", 4483345998) -- Angka adalah ID Icon

-- Membuat Dropdown
local FishDropdown = MainTab:CreateDropdown({
   Name = "Pilih Ikan Target",
   Options = fishNames, -- Memasukkan 564 nama ikan ke sini
   CurrentOption = {""},
   MultipleOptions = false,
   Flag = "DropdownIkan", -- Identifier unik
   Callback = function(Option)
       -- Option akan berbentuk tabel karena Rayfield mendukung multiple choice
       -- Kita ambil indeks pertama [1]
       local selectedFish = Option[1]
       print("Anda memilih ikan: " .. selectedFish)
   end,
})
