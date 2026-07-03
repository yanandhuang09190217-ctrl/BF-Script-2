-- AhKaiCore.lua (修正版 - 功能可用)
local Utils = _G.AhKaiUtils
local Core = {}
_G.AhKaiCore = Core

Core.State = {
    AutoFarm = false,
    AutoQuest = false,
    AutoRun = false,
    AutoBoss = false,
    AutoChest = false,
    AttackStyle = "果", -- 果/刀/拳
    Speed = 50,
    Jump = 50,
}

-- 查詢玩家等級 (優先從 Leaderstats 讀取)
local function GetPlayerLevel()
    local leaderstats = Utils.LocalPlayer:FindFirstChild("leaderstats")
    if leaderstats then
        local lvl = leaderstats:FindFirstChild("Level") or leaderstats:FindFirstChild("等級")
        if lvl and lvl:IsA("IntValue") then
            return lvl.Value
        end
    end
    return 1 -- 讀取失敗預設為1
end

-- 根據等級推薦任務與怪物 (Blox Fruits 常用資料)
local function GetRecommendedQuestAndMob(level)
    if level <= 10 then
        return "Bandit", "Bandit"
    elseif level <= 30 then
        return "Monkey", "Monkey"
    elseif level <= 50 then
        return "Pirate", "Pirate"
    elseif level <= 75 then
        return "Brute", "Brute"
    elseif level <= 100 then
        return "Desert Bandit", "Desert Bandit"
    else
        return "Galley Pirate", "Galley Pirate"
    end
end

-- 尋找最近的 NPC (用於任務)
local function FindNearestNPC(name)
    local nearest = nil
    local minDist = 500
    local hrp = Utils.GetHRP()
    if not hrp then return nil end
    for _, obj in ipairs(Utils.Services.Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:lower():find(name:lower()) then
            local head = obj:FindFirstChild("Head") or obj:FindFirstChild("HumanoidRootPart")
            if head then
                local dist = (hrp.Position - head.Position).Magnitude
                if dist < minDist then
                    minDist = dist
                    nearest = obj
                end
            end
        end
    end
    return nearest
end

-- 自動接任務
function Core.AutoQuestLoop()
    if not Core.State.AutoQuest then return end
    local level = GetPlayerLevel()
    local questName, mobName = GetRecommendedQuestAndMob(level)
    local npc = FindNearestNPC(questName)
    if npc then
        local hum = Utils.GetHum()
        local hrp = Utils.GetHRP()
        local targetPos = npc:FindFirstChild("Head") and npc.Head.Position or npc:GetPivot().p
        if hum and hrp then
            hum:MoveTo(targetPos)
            if (hrp.Position - targetPos).Magnitude < 10 then
                -- 模擬點擊 NPC (透過 ProximityPrompt 或點擊)
                local prompt = npc:FindFirstChildWhichIsA("ProximityPrompt")
                if prompt then
                    Utils.Safe(function() prompt:InputHoldBegin() task.wait(0.5) prompt:InputHoldEnd() end)
                    Utils.Debug("已與 "..npc.Name.." 對話")
                end
            end
        end
    else
        Utils.Debug("找不到任務NPC: "..questName, true)
    end
end

-- 自動跑圖 (移動到怪物區域)
function Core.AutoRunLoop()
    if not Core.State.AutoRun then return end
    local level = GetPlayerLevel()
    local _, mobName = GetRecommendedQuestAndMob(level)
    -- 尋找該怪物可能出現的區域 (以一個該怪物為參考)
    local mob = FindNearestNPC(mobName)
    if mob then
        local hum = Utils.GetHum()
        local hrp = Utils.GetHRP()
        if hum and hrp then
            local targetPos = mob:GetPivot().p
            hum:MoveTo(targetPos)
            Utils.Debug("跑圖至 "..mobName.." 區域")
        end
    else
        Utils.Debug("找不到目標怪物: "..mobName, true)
    end
end

-- 自動刷怪 (依等級與攻擊風格)
function Core.AutoFarmLoop()
    if not Core.State.AutoFarm then return end
    local char = Utils.GetChar()
    local hrp = Utils.GetHRP()
    local hum = Utils.GetHum()
    if not hrp or not hum then return end

    -- 根據玩家等級找最適合的怪
    local level = GetPlayerLevel()
    local _, targetMobName = GetRecommendedQuestAndMob(level)
    local targetMob = FindNearestNPC(targetMobName)

    -- 如果找不到對應怪物，就找任意有血量的敵人
    if not targetMob then
        for _, obj in ipairs(Utils.Services.Workspace:GetDescendants()) do
            if obj:IsA("Model") and obj ~= char then
                local tHum = obj:FindFirstChildWhichIsA("Humanoid")
                local tHRP = obj:FindFirstChild("HumanoidRootPart")
                if tHum and tHum.Health > 0 and tHRP then
                    targetMob = obj
                    break
                end
            end
        end
    end

    if targetMob then
        local tHRP = targetMob:FindFirstChild("HumanoidRootPart")
        if tHRP then
            hum:MoveTo(tHRP.Position)
            if (hrp.Position - tHRP.Position).Magnitude < 15 then
                Utils.TryAttack(targetMob)
                Utils.Debug("攻擊怪物: "..targetMob.Name)
            end
        end
    end
end

-- 自動拿寶箱 (TP 並觸發觸碰)
function Core.AutoChestLoop()
    if not Core.State.AutoChest then return end
    local hrp = Utils.GetHRP()
    if not hrp then return end
    local chestFound = false
    for _, v in ipairs(Utils.Services.Workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            local name = v.Name:lower()
            if name:find("chest") or name:find("treasure") or name:find("箱") or name:find("寶箱") then
                local dist = (hrp.Position - v.Position).Magnitude
                if dist < 1000 then
                    hrp.CFrame = v.CFrame + Vector3.new(0, 5, 0)
                    Utils.Debug("傳送至寶箱: "..v.Name)
                    task.wait(0.3)
                    Utils.Safe(function() firetouchinterest(hrp, v, 0) end)
                    Utils.Debug("觸碰寶箱")
                    chestFound = true
                    break
                end
            end
        end
    end
    if not chestFound then
        Utils.Debug("附近沒有寶箱")
    end
end

-- 啟動所有迴圈
function Core.StartLoops()
    Utils.Services.RunService.Heartbeat:Connect(function()
        Core.AutoFarmLoop()
        Core.AutoQuestLoop()
        Core.AutoRunLoop()
        Core.AutoChestLoop()
    end)
end

-- 重置功能
function Core.ResetAll()
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
    local hum = Utils.GetHum()
    if hum then
        hum.WalkSpeed = 16
        hum.JumpPower = 50
    end
end

return Core
