local Utils = {}
_G.AhKaiUtils = Utils

Utils.Services = {
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    UserInputService = game:GetService("UserInputService"),
    TweenService = game:GetService("TweenService"),
    CoreGui = game:GetService("CoreGui"),
    Workspace = game:GetService("Workspace"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    HttpService = game:GetService("HttpService"),
    VirtualInputManager = game:GetService("VirtualInputManager"),
}
Utils.LocalPlayer = Utils.Services.Players.LocalPlayer
Utils.Mouse = Utils.LocalPlayer:GetMouse()
function Utils.Safe(fn, ...)
    return pcall(fn, ...)
end
function Utils.GetChar()
    return Utils.LocalPlayer.Character
end
function Utils.GetHum()
    local c = Utils.GetChar()
    return c and c:FindFirstChildWhichIsA("Humanoid")
end
function Utils.GetHRP()
    local c = Utils.GetChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end
_G.AhKaiDebug = {
    Messages = {},
    Max = 5
}

function Utils.Debug(msg, isError)
    local text = (isError and "❌ " or "✅ ") .. os.date("%X") .. " " .. msg
    table.insert(_G.AhKaiDebug.Messages, 1, text)
    if #_G.AhKaiDebug.Messages > _G.AhKaiDebug.Max then
        table.remove(_G.AhKaiDebug.Messages)
    end
    print(text)
end

Utils.AttackRemotes = {}

function Utils.ScanAttackRemotes()
    table.clear(Utils.AttackRemotes)
    local keywords = {"attack", "melee", "sword", "fruit", "combat", "hit", "damage", "main", "event"}
    for _, v in ipairs(Utils.Services.ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") then
            local name = v.Name:lower()
            for _, kw in ipairs(keywords) do
                if name:find(kw) then
                    table.insert(Utils.AttackRemotes, v)
                    break
                end
            end
        end
    end
    local extraNames = {"MainEvent", "CombatEvent", "AttackEvent", "RemoteEvent"}
    for _, exactName in ipairs(extraNames) do
        local ev = Utils.Services.ReplicatedStorage:FindFirstChild(exactName)
        if ev and ev:IsA("RemoteEvent") and not table.find(Utils.AttackRemotes, ev) then
            table.insert(Utils.AttackRemotes, ev)
        end
    end
    Utils.Debug("偵測到 "..#Utils.AttackRemotes.." 個攻擊遠端")
end

Utils.ScanAttackRemotes()

function Utils.TryAttack(target)
    if not target then return end
    local hum = target:FindFirstChildWhichIsA("Humanoid")
    if not hum or hum.Health <= 0 then return end
    for _, remote in ipairs(Utils.AttackRemotes) do
        Utils.Safe(function() remote:FireServer(target) end)
    end
end

return Utils
