-- AhKaiCore.lua (全海域通用版 - 自動適配)
local Utils = _G.AhKaiUtils
local Core = {}
_G.AhKaiCore = Core

Core.State = {
    AutoFarm = false,
    AutoQuest = false,
    AutoRun = false,
    AutoBoss = false,
    AutoChest = false,
    AttackStyle = "果",
    Speed = 50,
    Jump = 50,
}

-- 海域/等級對照表（可自行擴充）
local SeaMonsters = {
    -- 第一海域
    { minLv = 0,  maxLv = 10,   keywords = {"Bandit", "Trainee"} },
    { minLv = 11, maxLv = 30,   keywords = {"Monkey", "Gorilla"} },
    { minLv = 31, maxLv = 50,   keywords = {"Pirate", "Brute"} },
    { minLv = 51, maxLv = 75,   keywords = {"Desert Bandit", "Desert Officer"} },
    { minLv = 76, maxLv = 100,  keywords = {"Soldier", "Marine"} },
    { minLv = 101,maxLv = 150,  keywords = {"Galley Pirate", "Galley Captain"} },
    { minLv = 151,maxLv = 200,  keywords = {"Fishman", "Fishman Warrior"} },
    { minLv = 201,maxLv = 300,  keywords = {"Sky Bandit", "Sky Soldier"} },
    { minLv = 301,maxLv = 400,  keywords = {"Shandian", "Priest"} },
    { minLv = 401,maxLv = 500,  keywords = {"Upper Yard", "God's Guard"} },
    { minLv = 501,maxLv = 625,  keywords = {"Royal Guard", "Royal Soldier"} },
    { minLv = 626,maxLv = 700,  keywords = {"Pirate", "Marine", "Mercenary"} },
    -- 第二海域
    { minLv = 700, maxLv = 850,  keywords = {"Galley Pirate", "Galley Captain", "Soldier", "Officer"} },
    { minLv = 851, maxLv = 1000, keywords = {"Marine", "Captain", "Vice Admiral", "Pirate"} },
    { minLv = 1001,maxLv = 1200, keywords = {"Bounty Hunter", "Swordman", "Shandian"} },
    { minLv = 1201,maxLv = 1500, keywords = {"Dragon Crew", "Dragon Captain"} },
    -- 第三海域 (預留，可依實際新增)
    { minLv = 1501,maxLv = 2000, keywords = {"Trainee", "Sea Soldier", "Water Fighter"} },
    { minLv = 2001,maxLv = 9999, keywords = {"Pirate", "Marine", "Elite", "Boss"} },
}

-- 動態讀取玩家等級
local function GetPlayerLevel()
    local leaderstats = Utils.LocalPlayer:FindFirstChild("leaderstats")
    if leaderstats then
        local lvl = leaderstats:FindFirstChild("Level") or leaderstats:FindFirstChild("等級")
        if lvl and lvl:IsA("IntValue") then
            return lvl.Value
        end
    end
    return 1
end

-- 取得目前等級對應的怪物關鍵字
local function GetCurrentKeywords()
    local level = GetPlayerLevel()
    for _, zone in ipairs(SeaMonsters) do
        if level >= zone.minLv and level <= zone.maxLv then
            return zone.keywords
        end
    end
    -- 若完全找不到，使用通用關鍵字
    return {"Pirate", "Marine", "Soldier", "Bandit", "Monkey", "Guard"}
end

-- 尋找最近的敵方角色（依據關鍵字）
local function FindNearestEnemy()
    local char = Utils.GetChar()
    local hrp = Utils.GetHRP()
    if not hrp then return nil end
    local keywords = GetCurrentKeywords()
    local nearest, minDist = nil, 800
    for _, obj in ipairs(Utils.Services.Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj ~= char then
            local tHum = obj:FindFirstChildWhichIsA("Humanoid")
            local tHRP = obj:FindFirstChild("HumanoidRootPart")
            if tHum and tHum.Health > 0 and tHRP then
                -- 檢查名稱是否包含任一關鍵字
                local match = false
                local lowerName = obj.Name:lower()
                for _, kw in ipairs(keywords) do
                    if lowerName:find(kw:lower()) then
                        match = true
                        break
                    end
                end
                if match then
                    local dist = (hrp.Position - tHRP.Position).Magnitude
                    if dist < minDist then
                        minDist = dist
                        nearest = obj
                    end
                end
            end
        end
    end
    return nearest
end

-- 自動刷怪
function Core.AutoFarmLoop()
    if not Core.State.AutoFarm then return end
    local hrp = Utils.GetHRP()
    local hum = Utils.GetHum()
    if not hrp or not hum then return end
    local target = FindNearestEnemy()
    if target then
        local tHRP = target:FindFirstChild("HumanoidRootPart")
        if tHRP then
            hum:MoveTo(tHRP.Position)
            if (hrp.Position - tHRP.Position).Magnitude < 15 then
                Utils.TryAttack(target)
                Utils.Debug("⚔️ 攻擊: "..target.Name)
            end
        end
    else
        local kw = table.concat(GetCurrentKeywords(), ", ")
        Utils.Debug("🔍 沒找到敵人 (關鍵字: "..kw..")")
    end
end

-- 自動寶箱（通用名稱 + 距離限制）
function Core.AutoChestLoop()
    if not Core.State.AutoChest then return end
    local hrp = Utils.GetHRP()
    if not hrp then return end
    local found = false
    for _, v in ipairs(Utils.Services.Workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            local n = v.Name:lower()
            if n:find("chest") or n:find("treasure") or n:find("箱") or n:find("寶") then
                local dist = (hrp.Position - v.Position).Magnitude
                if dist < 1500 then
                    hrp.CFrame = v.CFrame + Vector3.new(0,5,0)
                    Utils.Debug("📦 傳送至寶箱: "..v.Name)
                    task.wait(0.3)
                    pcall(function() firetouchinterest(hrp, v, 0) end)
                    found = true
                    break
                end
            end
        end
    end
    if not found then Utils.Debug("📦 附近無寶箱") end
end

-- 自動接任務（通用型 - 目前留底，可擴充 NPC 關鍵字）
function Core.AutoQuestLoop()
    if not Core.State.AutoQuest then return end
    Utils.Debug("📋 自動任務暫未開放 (通用NPC辨識開發中)")
end

-- 自動跑圖
function Core.AutoRunLoop()
    if not Core.State.AutoRun then return end
    Utils.Debug("🏃 自動跑圖暫未開放")
end

-- 啟動主迴圈
function Core.StartLoops()
    Utils.Services.RunService.Heartbeat:Connect(function()
        Core.AutoFarmLoop()
        Core.AutoChestLoop()
        Core.AutoQuestLoop()
        Core.AutoRunLoop()
    end)
    Utils.Debug("🚀 全域迴圈已啟動 (Lv."..GetPlayerLevel()..")")
end

function Core.ResetAll()
    for k in pairs(Core.State) do
        if type(Core.State[k]) == "boolean" then Core.State[k] = false end
    end
    local hum = Utils.GetHum()
    if hum then hum.WalkSpeed = 16; hum.JumpPower = 50 end
end

return Core
