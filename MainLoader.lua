local baseUrl = "https://raw.githubusercontent.com/你的GitHub帳號/你的Repo/main/"
local modules = {
    "AhKaiUtils",
    "AhKaiCore",
    "AhKaiFruit",
    "AhKaiUI"
}

for _, modName in ipairs(modules) do
    local success, result = pcall(function()
        return loadstring(game:HttpGet(baseUrl .. modName .. ".lua"))()
    end)
    if not success then
        warn("❌ AhKai 載入失敗: " .. modName .. " - " .. tostring(result))
    end
end
