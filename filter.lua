local ReplicatedStorage = game:GetService("ReplicatedStorage")
local itemsFolder = ReplicatedStorage:FindFirstChild("Items")

-- 1. Siapkan tabel untuk UI dan tabel untuk Data
local fishNames = {}     -- Hanya berisi nama ikan untuk dropdown {"Blocky Octopus", "Shark", ...}
local fishDataMap = {}   -- Menyimpan data lengkap berdasarkan nama ikan

-- 2. Mengumpulkan Data Ikan
if itemsFolder then
    for _, instance in ipairs(itemsFolder:GetDescendants()) do
        if instance:IsA("ModuleScript") then
            local success, itemData = pcall(function() return require(instance) end)
            
            if success and type(itemData) == "table" and itemData.Data and itemData.Data.Type == "Fish" then
                local fishName = itemData.Data.Name
                
                -- Pastikan ikan punya nama dan belum dimasukkan ke daftar (mencegah duplikat)
                if fishName and not fishDataMap[fishName] then
                    table.insert(fishNames, fishName)
                    fishDataMap[fishName] = itemData -- Simpan data lengkapnya di sini
                end
            end
        end
    end
    
    -- Urutkan nama ikan sesuai abjad agar rapi di dropdown
    table.sort(fishNames)
else
    warn("Folder 'Items' tidak ditemukan!")
end

-- ==========================================
-- 3. Membuat GUI menggunakan Orion Library
-- ==========================================

-- Memuat Orion Library dari GitHub
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

-- Membuat Jendela Utama
local Window = OrionLib:MakeWindow({Name = "Fish Hub", HidePremium = true, SaveConfig = false})

-- Membuat Tab
local MainTab = Window:MakeTab({
	Name = "Auto Fish",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

-- Variabel untuk menyimpan ikan yang sedang dipilih saat ini
local selectedFishName = ""

-- Membuat Dropdown
MainTab:AddDropdown({
	Name = "Pilih Ikan Target",
	Default = "",
	Options = fishNames, -- Memasukkan daftar nama ikan yang sudah difilter
	Callback = function(Value)
        -- Fungsi ini berjalan setiap kali Anda memilih ikan dari dropdown
		selectedFishName = Value
		print("Anda memilih: " .. selectedFishName)
        
        -- CONTOH PENGEMBANGAN: Mengambil data lengkap dari ikan yang dipilih
        local selectedData = fishDataMap[selectedFishName]
        if selectedData then
            print("ID Ikan Target: " .. tostring(selectedData.Data.Id))
            print("Harga Jual: " .. tostring(selectedData.SellPrice))
            -- Di sini Anda bisa menambahkan logika auto-farm/teleport ke depannya
        end
	end    
})

-- Inisialisasi UI agar muncul di layar
OrionLib:Init()
