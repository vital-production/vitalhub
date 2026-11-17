-- VITAL HUB (Studio test version)
-- Place this LocalScript in StarterPlayer > StarterPlayerScripts.
-- Intended for testing in your own Roblox Studio experience.
-- Press RightShift to show/hide the panel.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local old = playerGui:FindFirstChild("VitalHub")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "VitalHub"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(300, 390)
frame.Position = UDim2.new(0, 24, 0.5, -195)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 27)
frame.BorderSizePixel = 0
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(130, 75, 255)
stroke.Thickness = 1.5
stroke.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 0, 42)
title.Position = UDim2.fromOffset(12, 4)
title.BackgroundTransparency = 1
title.Text = "VITAL HUB  |  STUDIO"
title.TextColor3 = Color3.fromRGB(220, 205, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 17
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -24, 0, 20)
subtitle.Position = UDim2.fromOffset(12, 39)
subtitle.BackgroundTransparency = 1
subtitle.Text = "LOCAL TEST CONTROLS"
subtitle.TextColor3 = Color3.fromRGB(145, 140, 160)
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 10
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = frame

local function makeButton(text, y)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -24, 0, 34)
    button.Position = UDim2.fromOffset(12, y)
    button.BackgroundColor3 = Color3.fromRGB(39, 37, 49)
    button.TextColor3 = Color3.fromRGB(235, 232, 245)
    button.Font = Enum.Font.GothamSemibold
    button.TextSize = 13
    button.Text = text .. ": OFF"
    button.AutoButtonColor = true
    button.Parent = frame
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 7)
    c.Parent = button
    return button
end

local function makeSliderLabel(text, y)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -24, 0, 22)
    label.Position = UDim2.fromOffset(12, y)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(210, 205, 220)
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    return label
end

local speedLabel = makeSliderLabel("WalkSpeed: 16  (click to cycle)", 69)
local speedButton = makeButton("Speed boost", 92)
local jumpButton = makeButton("High jump", 134)
local flyButton = makeButton("Fly (WASD + Space/Ctrl)", 176)
local noclipButton = makeButton("Noclip", 218)
local brightButton = makeButton("Fullbright", 260)
local resetButton = makeButton("Reset movement", 302)

local footer = Instance.new("TextLabel")
footer.Size = UDim2.new(1, -24, 0, 24)
footer.Position = UDim2.fromOffset(12, 350)
footer.BackgroundTransparency = 1
footer.Text = "RightShift: hide/show"
footer.TextColor3 = Color3.fromRGB(130, 125, 145)
footer.Font = Enum.Font.Gotham
footer.TextSize = 10
footer.TextXAlignment = Enum.TextXAlignment.Left
footer.Parent = frame

local function getCharacter()
    return player.Character
end

local function getHumanoid()
    local character = getCharacter()
    return character and character:FindFirstChildOfClass("Humanoid")
end

local function getRoot()
    local character = getCharacter()
    return character and character:FindFirstChild("HumanoidRootPart")
end

local speedOn, jumpOn, flyOn, noclipOn, brightOn = false, false, false, false, false
local flyVelocity, flyGyro
local savedLighting = {}
local originalWalkSpeed, originalJumpPower = 16, 50

local function setButton(button, name, enabled)
    button.Text = name .. (enabled and ": ON" or ": OFF")
    button.BackgroundColor3 = enabled and Color3.fromRGB(77, 48, 130) or Color3.fromRGB(39, 37, 49)
end

local function stopFly()
    flyOn = false
    if flyVelocity then flyVelocity:Destroy(); flyVelocity = nil end
    if flyGyro then flyGyro:Destroy(); flyGyro = nil end
    local hum = getHumanoid()
    if hum then hum.PlatformStand = false end
    setButton(flyButton, "Fly", false)
end

speedButton.MouseButton1Click:Connect(function()
    speedOn = not speedOn
    local hum = getHumanoid()
    if hum then hum.WalkSpeed = speedOn and 32 or originalWalkSpeed end
    setButton(speedButton, "Speed boost", speedOn)
end)

jumpButton.MouseButton1Click:Connect(function()
    jumpOn = not jumpOn
    local hum = getHumanoid()
    if hum then
        hum.UseJumpPower = true
        hum.JumpPower = jumpOn and 100 or originalJumpPower
    end
    setButton(jumpButton, "High jump", jumpOn)
end)

flyButton.MouseButton1Click:Connect(function()
    if flyOn then stopFly(); return end
    local root = getRoot()
    local hum = getHumanoid()
    if not root or not hum then return end
    flyOn = true
    hum.PlatformStand = true
    flyVelocity = Instance.new("BodyVelocity")
    flyVelocity.MaxForce = Vector3.new(1e6, 1e6, 1e6)
    flyVelocity.Velocity = Vector3.zero
    flyVelocity.Parent = root
    flyGyro = Instance.new("BodyGyro")
    flyGyro.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
    flyGyro.P = 1e4
    flyGyro.CFrame = workspace.CurrentCamera.CFrame
    flyGyro.Parent = root
    setButton(flyButton, "Fly", true)
end)

noclipButton.MouseButton1Click:Connect(function()
    noclipOn = not noclipOn
    setButton(noclipButton, "Noclip", noclipOn)
end)

brightButton.MouseButton1Click:Connect(function()
    brightOn = not brightOn
    if brightOn then
        savedLighting = {
            Brightness = Lighting.Brightness,
            ClockTime = Lighting.ClockTime,
            GlobalShadows = Lighting.GlobalShadows
        }
        Lighting.Brightness = 3
        Lighting.ClockTime = 14
        Lighting.GlobalShadows = false
    else
        for property, value in pairs(savedLighting) do
            Lighting[property] = value
        end
    end
    setButton(brightButton, "Fullbright", brightOn)
end)

speedLabel.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local hum = getHumanoid()
        if hum then
            local current = hum.WalkSpeed
            local nextSpeed = current >= 40 and 16 or current + 8
            originalWalkSpeed = nextSpeed
            hum.WalkSpeed = nextSpeed
            speedLabel.Text = "WalkSpeed: " .. tostring(nextSpeed) .. "  (click to cycle)"
        end
    end
end)

resetButton.MouseButton1Click:Connect(function()
    speedOn, jumpOn = false, false
    stopFly()
    local hum = getHumanoid()
    if hum then
        hum.WalkSpeed = 16
        hum.UseJumpPower = true
        hum.JumpPower = 50
    end
    originalWalkSpeed, originalJumpPower = 16, 50
    speedLabel.Text = "WalkSpeed: 16  (click to cycle)"
    setButton(speedButton, "Speed boost", false)
    setButton(jumpButton, "High jump", false)
    setButton(noclipButton, "Noclip", false)
    noclipOn = false
end)

RunService.Stepped:Connect(function()
    if noclipOn then
        local character = getCharacter()
        if character then
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if flyOn and flyVelocity and flyGyro then
        local camera = workspace.CurrentCamera
        local direction = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction += camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction -= camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction += camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction -= camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then direction += Vector3.yAxis end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then direction -= Vector3.yAxis end
        flyVelocity.Velocity = direction.Magnitude > 0 and direction.Unit * 55 or Vector3.zero
        flyGyro.CFrame = camera.CFrame
    end
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.RightShift then
        frame.Visible = not frame.Visible
    end
end)

player.CharacterAdded:Connect(function()
    task.wait(1)
    stopFly()
    local hum = getHumanoid()
    if hum then
        hum.WalkSpeed = speedOn and 32 or originalWalkSpeed
        hum.UseJumpPower = true
        hum.JumpPower = jumpOn and 100 or originalJumpPower
    end
end)
