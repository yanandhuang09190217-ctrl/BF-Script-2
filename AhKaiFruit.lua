-- AhKaiFruit.lua
local Utils = _G.AhKaiUtils
local Fruit = {}
_G.AhKaiFruit = Fruit

Fruit.State = {
    RainActive = false,
    FruitList = {}
}

-- 創建一顆可互動的果實 (可吃/放)
function Fruit.CreateFruit(position, fruitType)
    local part = Instance.new("Part")
    part.Name = "AhKaiFruit_"..fruitType
    part.Size = Vector3.new(2,2,2)
    part.Position = position
    part.Anchored = false
    part.CanCollide = true
    part.Parent = Utils.Services.Workspace
    -- 外觀 (隨機顏色代表不同果實)
    part.BrickColor = BrickColor.random()
    local mesh = Instance.new("SpecialMesh", part)
    mesh.MeshId = "rbxassetid://1234567" -- 可更換成果實模型
    mesh.ScaleType = Enum.ScaleType.Fit
    -- 點擊事件 (透過 ProximityPrompt)
    local prompt = Instance.new("ProximityPrompt", part)
    prompt.ActionText = "撿起 "..fruitType
    prompt.Triggered:Connect(function(player)
        if player == Utils.LocalPlayer then
            -- 顯示選項：吃、存放背包、放下
            -- 簡化：直接加入背包
            table.insert(Fruit.State.FruitList, fruitType)
            Utils.Debug("獲得果實: "..fruitType)
            part:Destroy()
        end
    end)
    return part
end

-- 果實雨
function Fruit.StartRain()
    Fruit.State.RainActive = true
    Utils.Debug("🌧 果實雨開始!")
    local function spawnFruit()
        if not Fruit.State.RainActive then return end
        local playerPos = Utils.GetHRP() and Utils.GetHRP().Position or Vector3.zero
        local randPos = playerPos + Vector3.new(math.random(-50,50), 50, math.random(-50,50))
        local types = {"火焰", "冰凍", "轟雷", "黑暗", "橡膠"}
        local type = types[math.random(#types)]
        Fruit.CreateFruit(randPos, type)
        task.wait(2)
        spawnFruit()
    end
    task.spawn(spawnFruit)
end

function Fruit.StopRain()
    Fruit.State.RainActive = false
    Utils.Debug("果實雨停止")
    -- 清除殘留果實
    for _, v in ipairs(Utils.Services.Workspace:GetChildren()) do
        if v.Name:find("AhKaiFruit_") then v:Destroy() end
    end
end

-- 吃果實 (從背包)
function Fruit.EatFruit(fruitType)
    Utils.Debug("吃下 "..fruitType.." 果實")
    -- 模擬吃果實的行為，通常需觸發RemoteEvent
    for _, remote in ipairs(Utils.Services.ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") and remote.Name:lower():find("eat") then
            Utils.Safe(function() remote:FireServer(fruitType) end)
        end
    end
end

-- 放下果實
function Fruit.DropFruit(fruitType)
    Utils.Debug("放下 "..fruitType)
    -- 在玩家前方生成
    local hrp = Utils.GetHRP()
    if hrp then
        Fruit.CreateFruit(hrp.Position + hrp.CFrame.LookVector * 10, fruitType)
    end
end

return Fruit
