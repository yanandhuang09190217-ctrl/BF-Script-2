local baseUrl = "https://raw.githubusercontent.com/yanandhuang09190217-ctrl/BF-Script-2/main/"
local modules = {
    "AhKaiUtils",
    "AhKaiCore",
    "AhKaiFruit",
    "AhKaiUI"
}
for _, modName in ipairs(modules) do
    local url = baseUrl .. modName .. ".lua"
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    if not success then
        warn("❌ AhKai 模組載入失敗: " .. modName .. " - " .. tostring(result))
    else
        print("✅ 載入成功: " .. modName)
    end
end
print("🎉 AhKai 腳本已完全啟動！")
