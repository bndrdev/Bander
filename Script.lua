--!strict
-- Mayor AimAssist - True Instant Counter-Snap (No Stickiness)
-- Client-side, StarterPlayerScripts

local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui          = game:GetService("CoreGui")
local RunService       = game:GetService("RunService")

local lp = Players.LocalPlayer

----------------------------------------------------------------
-- Config
----------------------------------------------------------------
local Config = {
    Power   = 55,
    Range   = 30,
    Enabled = true,
}

----------------------------------------------------------------
-- Original UI Setup
----------------------------------------------------------------
local sg = Instance.new("ScreenGui")
sg.Name = "MayorAimAssistUI"
sg.ResetOnSpawn = false
pcall(function() sg.Parent = CoreGui end)
if not sg.Parent then sg.Parent = lp:WaitForChild("PlayerGui") end

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 260, 0, 215)
frame.Position = UDim2.new(0.5, -130, 0.4, -107)
frame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.ClipsDescendants = true
frame.Parent = sg

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 35)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(12, 12, 16))
})
gradient.Rotation = 45
gradient.Parent = frame

local patternHolder = Instance.new("Frame")
patternHolder.Size = UDim2.new(1, 0, 1, 0)
patternHolder.BackgroundTransparency = 1
patternHolder.Parent = frame

for i = 0, 260, 15 do
    local line = Instance.new("Frame")
    line.Size = UDim2.new(0, 1, 1, 0)
    line.Position = UDim2.new(0, i, 0, 0)
    line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    line.BackgroundTransparency = 0.96
    line.BorderSizePixel = 0
    line.Parent = patternHolder
end

for j = 0, 215, 15 do
    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, 0, 0, 1)
    line.Position = UDim2.new(0, 0, 0, j)
    line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    line.BackgroundTransparency = 0.96
    line.BorderSizePixel = 0
    line.Parent = patternHolder
end

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 4)
title.Text = "Mayor AimAssist"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.BackgroundTransparency = 1
title.ZIndex = 2
title.Parent = frame

local function createSlider(name, min, max, defaultVal, parent, yPos, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(0.85, 0, 0, 40)
    container.Position = UDim2.new(0.075, 0, 0, yPos)
    container.BackgroundTransparency = 1
    container.ZIndex = 2
    container.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 16)
    label.Text = name .. ": " .. defaultVal
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.ZIndex = 2
    label.Parent = container

    local bgBar = Instance.new("Frame")
    bgBar.Size = UDim2.new(1, 0, 0, 6)
    bgBar.Position = UDim2.new(0, 0, 0, 22)
    bgBar.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
    bgBar.BorderSizePixel = 0
    bgBar.ZIndex = 2
    bgBar.Parent = container

    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(1, 0)
    barCorner.Parent = bgBar

    local fillBar = Instance.new("Frame")
    fillBar.Size = UDim2.new((defaultVal - min) / (max - min), 0, 1, 0)
    fillBar.BackgroundColor3 = Color3.fromRGB(110, 60, 200)
    fillBar.BorderSizePixel = 0
    fillBar.ZIndex = 2
    fillBar.Parent = bgBar

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fillBar

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 14)
    btn.Position = UDim2.new(0, 0, 0, -4)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.ZIndex = 3
    btn.Parent = bgBar

    local dragging = false

    local function updateValue(input)
        local absolutePosition = bgBar.AbsolutePosition.X
        local absoluteSize = bgBar.AbsoluteSize.X
        local inputX = input.Position.X
        local pos = math.clamp((inputX - absolutePosition) / absoluteSize, 0, 1)

        fillBar.Size = UDim2.new(pos, 0, 1, 0)
        local currentVal = math.floor(min + (max - min) * pos)
        label.Text = name .. ": " .. currentVal
        callback(currentVal)
    end

    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateValue(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateValue(input)
        end
    end)
end

createSlider("POWER", 1, 100, Config.Power, frame, 38, function(v)
    Config.Power = v
end)

createSlider("RANGE", 1, 50, Config.Range, frame, 90, function(v)
    Config.Range = v
end)

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.85, 0, 0, 32)
toggleBtn.Position = UDim2.new(0.075, 0, 0, 148)
toggleBtn.Text = "AIMASSIST: ON"
toggleBtn.BackgroundColor3 = Color3.fromRGB(110, 60, 200)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 12
toggleBtn.AutoButtonColor = false
toggleBtn.ZIndex = 2
toggleBtn.Parent = frame

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 6)
toggleCorner.Parent = toggleBtn

toggleBtn.MouseButton1Click:Connect(function()
    Config.Enabled = not Config.Enabled

    local targetColor = Config.Enabled and Color3.fromRGB(110, 60, 200) or Color3.fromRGB(28, 28, 38)
    local textColor   = Config.Enabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)
    local statusText  = Config.Enabled and "ON" or "OFF"

    toggleBtn.Text = "AIMASSIST: " .. statusText

    TweenService:Create(toggleBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundColor3 = targetColor,
        TextColor3 = textColor
    }):Play()
end)

frame.Size = UDim2.new(0, 0, 0, 0)
frame.Position = UDim2.new(0.5, 0, 0.4, 0)

TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, 260, 0, 215),
    Position = UDim2.new(0.5, -130, 0.4, -107)
}):Play()

----------------------------------------------------------------
-- Helpers
----------------------------------------------------------------
local function hasToolEquipped(character : Model) : boolean
    for _, item in ipairs(character:GetChildren()) do
        if item:IsA("Tool") then
            return true
        end
    end
    return false
end

local function getClosestTarget() : BasePart?
    local character = lp.Character
    if not character then return nil end
    local myRoot = character:FindFirstChild("HumanoidRootPart")
    if not myRoot or not myRoot:IsA("BasePart") then return nil end

    local closest : BasePart? = nil
    local shortest = Config.Range

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= lp and player.Character then
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            if hum and hum.Health > 0 and root and root:IsA("BasePart") then
                local dist = (root.Position - myRoot.Position).Magnitude
                if dist < shortest then
                    shortest = dist
                    closest = root
                end
            end
        end
    end
    return closest
end

----------------------------------------------------------------
-- Main Loop (Strict One-Shot Snap Backend)
----------------------------------------------------------------
local snapCooldown = 0

RunService.RenderStepped:Connect(function(dt)
    if not Config.Enabled then return end
    if Config.Power <= 0 or Config.Range <= 0 then return end

    if snapCooldown > 0 then
        snapCooldown -= dt
        return -- يوقف التدخل تماماً ويتركك تتحرك بحرية تامة لفترة بعد التفعيل
    end

    local character = lp.Character
    if not character then return end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local myRoot   = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not myRoot or not myRoot:IsA("BasePart") then return end
    if humanoid.Health <= 0 then return end

    if not hasToolEquipped(character) then return end

    local target = getClosestTarget()
    if not target then return end

    local myPos     = myRoot.Position
    local targetPos = target.Position

    local toTarget = Vector3.new(targetPos.X - myPos.X, 0, targetPos.Z - myPos.Z)
    if toTarget.Magnitude < 0.1 then return end
    toTarget = toTarget.Unit

    local moveDir = humanoid.MoveDirection
    local moveFlat = Vector3.new(moveDir.X, 0, moveDir.Z)

    if moveFlat.Magnitude > 0.05 then
        moveFlat = moveFlat.Unit
        local dot = moveFlat:Dot(toTarget)

        -- لو اتحركت في اتجاه معاكس للهدف (تراجع للخلف بالغلط)
        if dot < -0.3 then
            -- سحبك للحظة واحدة باتجاه العدو
            humanoid:Move(toTarget, false)
            -- فرض فترة راحة (Cooldown) عشان ما يلزقش فيك، ويسيبك تكمل حركتك وطريقك طبيعي جداً
            snapCooldown = 0.4
        end
    end
end)
