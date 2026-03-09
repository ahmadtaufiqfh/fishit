local ReplicatedStorage = game:GetService("ReplicatedStorage")
local itemsFolder = ReplicatedStorage:FindFirstChild("Items")

-- 1. Menyiapkan tabel untuk menyimpan nama-nama ikan
local fishNames = {}
local tempDict = {} -- Untuk mencegah nama ikan ganda/duplikat masuk ke dalam list

-- 2. Mengumpulkan dan Memfilter Data Ikan
if itemsFolder then
    print("Mencari data ikan...")
    for _, instance in ipairs(itemsFolder:GetDescendants()) do
        if instance:IsA("ModuleScript") then
            -- Gunakan pcall agar script tidak error jika ada module yang rusak
            local success, itemData = pcall(function() return require(instance) end)
            
            -- Cek apakah module berisi tabel, memiliki 'Data', dan Type-nya 'Fish'
            if success and type(itemData) == "table" and itemData.Data and itemData.Data.Type == "Fish" then
                local fishName = itemData.Data.Name
                
                -- Jika ada namanya dan belum terdaftar, masukkan ke list
                if fishName and not tempDict[fishName] then
                    tempDict[fishName] = true
                    table.insert(fishNames, fishName)
                end
            end
        end
    end
    
    -- Mengurutkan nama ikan sesuai abjad (A-Z)
    table.sort(fishNames)
    print("Berhasil menemukan " .. #fishNames .. " jenis ikan!")
else
    warn("Folder 'Items' tidak ditemukan di ReplicatedStorage!")
end

-- ==========================================
-- 3. Membuat UI (User Interface)
-- ==========================================

-- Memuat Orion Library (Library UI yang ringan dan populer)
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

-- Membuat Jendela Utama
local Window = OrionLib:MakeWindow({
    Name = "Fish Dropdown Menu", 
    HidePremium = true, 
    SaveConfig = false, 
    IntroText = "Memuat Data Ikan..."
})

-- Membuat Tab Utama
local MainTab = Window:MakeTab({
	Name = "Menu Ikan",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

-- Membuat Dropdown yang berisi daftar ikan
MainTab:AddDropdown({
	Name = "Pilih Ikan Target",
	Default = "",
	Options = fishNames, -- Memasukkan array fishNames yang sudah kita kumpulkan di atas
	Callback = function(Value)
        -- Fungsi ini akan berjalan saat Anda memilih ikan di dropdown
		print("Ikan yang dipilih di Dropdown: " .. Value)
	end    
})

-- Menjalankan UI
OrionLib:Init()
