-- AhKaiCore.lua
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

-- 查詢玩家等級（此處簡化，實際應讀取玩家數據）
local function GetPlayerLevel()
    -- 嘗試從 Leaderstats 或其他 UI 獲取，這裡返回模擬值
    return 100 -- 可自行擴充
end

-- 根據等級推薦任務與怪物 (僅供參考)
local function GetRecommendedQuestAndMob(level)
    if level < 50 then
        return "起始島任務", "海盜"
    elseif level < 100 then
        return "中級島任務", "海軍"
    else
        return "高級島任務", "革命軍"
    end
end

-- 自動接任務 (需根據遊戲實際 NPC 調整)
function Core.AutoQuestLoop()
    if not Core.State.AutoQuest then return end
    local level = GetPlayerLevel()
    local questName, mobName = GetRecommendedQuestAndMob(level)
    -- 尋找任務NPC並點擊 (此處僅印出 Debug)
    Utils.Debug("嘗試接取任務: "..questName.." (推薦怪物: "..mobName..")")
    -- 實際實作需移動到 NPC 並觸發對話
end

-- 自動跑圖 (移動到下一個任務區域)
function Core.AutoRunLoop()
    if not Core.State.AutoRun then return end
    local level = GetPlayerLevel()
    local _, mobName = GetRecommendedQuestAndMob(level)
    Utils.Debug("自動跑圖至 "..mobName.." 區域")
    -- 實際需計算路徑或使用航點
end

-- 自動刷怪 (依等級與攻擊風格)
function Core.AutoFarmLoop()
    if not Core.State.AutoFarm then return end
    local char = Utils.GetChar()
    local hrp = Utils.GetHRP()
    local hum = Utils.GetHum()
    if not hrp or not hum then return end

    -- 找尋符合等級的怪物
    local level = GetPlayerLevel()
    local targetMob = nil
    for _, obj in ipairs(Utils.Services.Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj ~= char then
            local tHum = obj:FindFirstChildWhichIsA("Humanoid")
            local tHRP = obj:FindFirstChild("HumanoidRootPart")
            if tHum and tHum.Health > 0 and tHRP and obj.Name:lower():find("海盜") then -- 簡化示例
                targetMob = obj
                break
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
    for _, v in ipairs(Utils.Services.Workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Name:lower():find("chest") then
            local dist = (hrp.Position - v.Position).Magnitude
            if dist < 1000 then -- 可調整範圍
                hrp.CFrame = v.CFrame + Vector3.new(0,5,0)
                Utils.Debug("傳送至寶箱")
                task.wait(0.3)
                Utils.Safe(function() firetouchinterest(hrp, v, 0) end)
                Utils.Debug("觸碰寶箱")
                break
            end
        end
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
