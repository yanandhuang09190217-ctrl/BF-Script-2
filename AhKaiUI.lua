local Utils = _G.AhKaiUtils
local Core = _G.AhKaiCore
local Fruit = _G.AhKaiFruit
local UI = {}
_G.AhKaiUI = UI
local function ShowIntro()
    local screen = Instance.new("ScreenGui")
    screen.Name = "AhKaiIntro"
    screen.Parent = Utils.Services.CoreGui
    screen.ResetOnSpawn = false
    local bg = Instance.new("Frame")
    bg.Size = UDim2.fromScale(1,1)
    bg.BackgroundColor3 = Color3.fromRGB(0,0,0)
    bg.BackgroundTransparency = 0.9
    bg.Parent = screen
    local text = "AhKai"
    local letters = {}
    local startX = 0.3
    for i=1, #text do
        local letter = Instance.new("TextLabel")
        letter.Size = UDim2.fromOffset(40,60)
        letter.Position = UDim2.fromScale(startX + i*0.06, 0.4)
        letter.BackgroundTransparency = 1
        letter.Text = text:sub(i,i)
        letter.TextSize = 40
        letter.Font = Enum.Font.Code
        letter.TextColor3 = Color3.fromRGB(math.random(255),math.random(255),math.random(255))
        letter.Parent = bg
        table.insert(letters, letter)
        task.spawn(function()
            while bg.Parent do
                letter.TextColor3 = Color3.fromRGB(math.random(255),math.random(255),math.random(255))
                task.wait(0.2)
            end
        end)
    end
    local line = Instance.new("Frame")
    line.Size = UDim2.new(1,0,0,2)
    line.BackgroundColor3 = Color3.fromRGB(0,255,0)
    line.BorderSizePixel = 0
    line.Parent = bg
    task.spawn(function()
        while bg.Parent do
            line.Position = UDim2.fromScale(0, math.random()*0.9)
            task.wait(0.05)
        end
    end)
    task.delay(3, function()
        screen:Destroy()
        UI:CreateMainPanel()
    end)
end
function UI:CreateMainPanel()
    local screen = Instance.new("ScreenGui")
    screen.Name = "AhKaiMain"
    screen.Parent = Utils.Services.CoreGui
    screen.ResetOnSpawn = false
    local main = Instance.new("Frame")
    main.Size = UDim2.fromOffset(330, 520)
    main.Position = UDim2.new(-0.35, 0, 0.5, -260)
    main.BackgroundColor3 = Color3.fromRGB(10,10,15)
    main.BorderSizePixel = 0
    main.Active = true
    main.Draggable = true
    Instance.new("UICorner", main).CornerRadius = UDim.new(0,12)
    main.Parent = screen
    local glow = Instance.new("ImageLabel")
    glow.Image = "rbxassetid://5028857084"
    glow.Size = UDim2.new(1, 30, 1, 30)
    glow.Position = UDim2.new(0, -15, 0, -15)
    glow.BackgroundTransparency = 1
    glow.ImageColor3 = Color3.fromRGB(0,255,255)
    glow.ImageTransparency = 0.85
    glow.ScaleType = Enum.ScaleType.Slice
    glow.SliceCenter = Rect.new(10,10,118,118)
    glow.Parent = main
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1,-10,0,30)
    title.Position = UDim2.new(0,5,0,5)
    title.BackgroundTransparency = 1
    title.Text = "⚡ AhKai Terminal v2.0"
    title.TextColor3 = Color3.fromRGB(0,255,255)
    title.Font = Enum.Font.Code
    title.TextSize = 16
    title.Parent = main
    local close = Instance.new("TextButton")
    close.Size = UDim2.fromOffset(24,24)
    close.Position = UDim2.new(1,-30,0,4)
    close.BackgroundColor3 = Color3.fromRGB(255,80,80)
    close.Text = "✕"
    close.TextColor3 = Color3.fromRGB(255,255,255)
    close.Font = Enum.Font.GothamBold
    close.TextSize = 14
    Instance.new("UICorner", close).CornerRadius = UDim.new(0,6)
    close.Parent = main
    close.MouseButton1Click:Connect(function()
        Core.ResetAll()
        Fruit.StopRain()
        screen:Destroy()
    end)
    local minimized = false
    local catLogo
    local function MinimizeToggle()
        minimized = not minimized
        main.Visible = not minimized
        if minimized then
            if not catLogo then
                catLogo = Instance.new("ImageButton")
                catLogo.Size = UDim2.fromOffset(50,50)
                catLogo.Position = UDim2.new(0, 10, 0, 10)
                catLogo.BackgroundTransparency = 1
                if minimized then
                    if not catLogo then
                        catLogo = Instance.new("TextButton")
                        catLogo.Size = UDim2.fromOffset(50, 50)
                        catLogo.Position = UDim2.new(0, 10, 0, 10)
                        catLogo.BackgroundTransparency = 1
                        catLogo.Text = "🐱"
                        catLogo.TextSize = 40
                        catLogo.Font = Enum.Font.GothamBold
                        catLogo.Active = true
                        catLogo.Draggable = true
                        catLogo.Parent = screen
                        catLogo.MouseButton1Click:Connect(MinimizeToggle)
                    else
                        catLogo.Visible = true
                    end
                catLogo.Active = true
                catLogo.Draggable = true
                catLogo.Parent = screen
                catLogo.MouseButton1Click:Connect(MinimizeToggle)
            else
                catLogo.Visible = true
            end
        else
            if catLogo then catLogo.Visible = false end
        end
    end
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1,-10,1,-45)
    scroll.Position = UDim2.new(0,5,0,40)
    scroll.BackgroundTransparency = 1
    scroll.CanvasSize = UDim2.new(0,0,0,700)
    scroll.ScrollBarThickness = 3
    scroll.Parent = main
    local list = Instance.new("UIListLayout", scroll)
    list.Padding = UDim.new(0,6)
    local function MakeToggle(name, default, callback)
        local f = Instance.new("Frame")
        f.Size = UDim2.new(1,0,0,38)
        f.BackgroundColor3 = Color3.fromRGB(20,20,30)
        f.BorderSizePixel = 0
        Instance.new("UICorner", f).CornerRadius = UDim.new(0,6)
        local l = Instance.new("TextLabel")
        l.Size = UDim2.fromScale(0.6,1)
        l.Position = UDim2.fromScale(0.05,0)
        l.BackgroundTransparency = 1
        l.Text = name
        l.TextColor3 = Color3.fromRGB(0,255,200)
        l.Font = Enum.Font.Code
        l.TextSize = 12
        l.Parent = f
        local b = Instance.new("TextButton")
        b.Size = UDim2.fromOffset(42,22)
        b.Position = UDim2.new(1,-50,0.5,-11)
        b.BackgroundColor3 = default and Color3.fromRGB(0,200,100) or Color3.fromRGB(80,80,90)
        b.Text = default and "ON" or "OFF"
        b.TextColor3 = Color3.fromRGB(255,255,255)
        b.Font = Enum.Font.Code
        b.TextSize = 10
        b.AutoButtonColor = false
        Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
        local on = default
        local function upd() b.BackgroundColor3 = on and Color3.fromRGB(0,200,100) or Color3.fromRGB(80,80,90); b.Text = on and "ON" or "OFF" end
        b.MouseButton1Click:Connect(function()
            on = not on
            upd()
            Utils.Safe(callback, on)
            Utils.Debug(name..(on and " 啟用" or " 停用"))
        end)
        f.Parent = scroll
        return {Set = function(v) on = v; upd() end}
    end
    MakeToggle("自動接取任務", false, function(on) Core.State.AutoQuest = on end)
    MakeToggle("自動跑圖", false, function(on) Core.State.AutoRun = on end)
    MakeToggle("自動刷怪", false, function(on) Core.State.AutoFarm = on end)
    MakeToggle("自動拿寶箱", false, function(on) Core.State.AutoChest = on end)
    MakeToggle("果實雨", false, function(on)
        if on then Fruit.StartRain() else Fruit.StopRain() end
    end)
    local styleFrame = Instance.new("Frame")
    styleFrame.Size = UDim2.new(1,0,0,40)
    styleFrame.BackgroundColor3 = Color3.fromRGB(20,20,30)
    Instance.new("UICorner", styleFrame).CornerRadius = UDim.new(0,6)
    local styleLabel = Instance.new("TextLabel")
    styleLabel.Size = UDim2.fromScale(0.3,1)
    styleLabel.Position = UDim2.fromScale(0.05,0)
    styleLabel.BackgroundTransparency = 1
    styleLabel.Text = "風格:"
    styleLabel.TextColor3 = Color3.fromRGB(0,255,200)
    styleLabel.Font = Enum.Font.Code
    styleLabel.TextSize = 12
    styleLabel.Parent = styleFrame
    local dropdown = Instance.new("TextButton")
    dropdown.Size = UDim2.fromOffset(80,24)
    dropdown.Position = UDim2.new(0.4,0,0.5,-12)
    dropdown.Text = "果"
    dropdown.TextColor3 = Color3.fromRGB(255,255,255)
    dropdown.Font = Enum.Font.Code
    dropdown.BackgroundColor3 = Color3.fromRGB(30,30,40)
    Instance.new("UICorner", dropdown).CornerRadius = UDim.new(0,6)
    dropdown.Parent = styleFrame
    local styles = {"果", "刀", "拳"}
    local styleIndex = 1
    dropdown.MouseButton1Click:Connect(function()
        styleIndex = styleIndex % 3 + 1
        Core.State.AttackStyle = styles[styleIndex]
        dropdown.Text = styles[styleIndex]
        Utils.Debug("切換攻擊風格: "..styles[styleIndex])
    end)
    styleFrame.Parent = scroll
    local debugFrame = Instance.new("Frame")
    debugFrame.Size = UDim2.new(1,0,0,100)
    debugFrame.BackgroundColor3 = Color3.fromRGB(5,5,10)
    debugFrame.BorderSizePixel = 0
    Instance.new("UICorner", debugFrame).CornerRadius = UDim.new(0,6)
    local debugLabel = Instance.new("TextLabel")
    debugLabel.Size = UDim2.new(1,-10,1,-10)
    debugLabel.Position = UDim2.new(0,5,0,5)
    debugLabel.BackgroundTransparency = 1
    debugLabel.Text = ""
    debugLabel.TextColor3 = Color3.fromRGB(0,255,100)
    debugLabel.Font = Enum.Font.Code
    debugLabel.TextSize = 10
    debugLabel.TextXAlignment = Enum.TextXAlignment.Left
    debugLabel.TextYAlignment = Enum.TextYAlignment.Top
    debugLabel.Parent = debugFrame
    debugFrame.Parent = scroll
    task.spawn(function()
        while debugLabel.Parent do
            local msg = _G.AhKaiDebug and _G.AhKaiDebug.Messages or {}
            debugLabel.Text = table.concat(msg, "\n")
            task.wait(0.5)
        end
    end)
    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.fromOffset(24,24)
    minBtn.Position = UDim2.new(1,-60,0,4)
    minBtn.BackgroundColor3 = Color3.fromRGB(255,200,0)
    minBtn.Text = "🐱"
    minBtn.TextColor3 = Color3.fromRGB(0,0,0)
    minBtn.Font = Enum.Font.GothamBold
    minBtn.TextSize = 14
    Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0,6)
    minBtn.Parent = main
    minBtn.MouseButton1Click:Connect(MinimizeToggle)
    Utils.Services.TweenService:Create(main, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {Position = UDim2.new(0.01,0,0.5,-260)}):Play()
    Core.StartLoops()
end
ShowIntro()

return UI
