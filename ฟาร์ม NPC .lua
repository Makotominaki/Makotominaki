local playersList = {}
local floating = false
local noclip = false
local floatHeight = 7
local selectedHumanoid = nil

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:FindFirstChildOfClass("Humanoid")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HumanoidListGui"
screenGui.Parent = player:WaitForChild("PlayerGui")

-- สร้างอนิเมชั่นแสดงชื่อ "By. M4keitup"
local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, 0, 1, 0)
label.BackgroundTransparency = 1
label.Text = "By. M4keitup"
label.Font = Enum.Font.SourceSansBold
label.TextScaled = true
label.TextColor3 = Color3.new(1, 1, 1)
label.Parent = screenGui

-- อนิเมชั่นแสดงผล 5 วินาที
for i = 0, 1, 0.02 do
    label.TextTransparency = i
    label.TextStrokeTransparency = i
    wait(0.1)
end
label:Destroy()

-- สร้าง ScrollingFrame สำหรับรายชื่อ
local scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.Size = UDim2.new(0.25, 0, 0.5, 0)
scrollingFrame.Position = UDim2.new(0.02, 0, 0.1, 0)
scrollingFrame.BackgroundTransparency = 0.3
scrollingFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
scrollingFrame.BorderSizePixel = 2
scrollingFrame.Parent = screenGui
scrollingFrame.CanvasSize = UDim2.new(0, 0, 1, 0)

local layout = Instance.new("UIListLayout")
layout.Parent = scrollingFrame
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 5)

-- ฟังก์ชันสร้างปุ่ม
local function createButton(text, position, color, size)
    local button = Instance.new("TextButton")
    button.Size = size
    button.Position = position
    button.BackgroundColor3 = color
    button.Text = text
    button.Font = Enum.Font.SourceSansBold
    button.TextScaled = true
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.BorderSizePixel = 2
    button.Parent = screenGui
    return button
end

local stopButton = createButton("🚫 STOP", UDim2.new(0.85, 0, 0.01, 0), Color3.fromRGB(200, 50, 50), UDim2.new(0.14, 0, 0.05, 0))
local noclipButton = createButton("👻 NoClip: OFF", UDim2.new(0.85, 0, 0.07, 0), Color3.fromRGB(50, 200, 50), UDim2.new(0.14, 0, 0.05, 0))
local toggleUIButton = createButton("👁️ Hide UI", UDim2.new(0.75, 0, 0.01, 0), Color3.fromRGB(80, 80, 120), UDim2.new(0.14, 0, 0.05, 0))

local increaseHeightButton = createButton("🔼 เพิ่ม", UDim2.new(0.85, 0, 0.13, 0), Color3.fromRGB(100, 150, 255), UDim2.new(0.07, 0, 0.05, 0))
local decreaseHeightButton = createButton("🔽 ลด", UDim2.new(0.92, 0, 0.13, 0), Color3.fromRGB(255, 100, 100), UDim2.new(0.07, 0, 0.05, 0))

game:GetService("RunService").Stepped:Connect(function()
    if noclip and character then
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

noclipButton.MouseButton1Click:Connect(function()
    noclip = not noclip
    noclipButton.Text = noclip and "👻 NoClip: ON" or "👻 NoClip: OFF"
    noclipButton.BackgroundColor3 = noclip and Color3.fromRGB(200, 100, 50) or Color3.fromRGB(50, 200, 50)
end)

game:GetService("RunService").RenderStepped:Connect(function()
    if floating and selectedHumanoid then
        local root = character:FindFirstChild("HumanoidRootPart")
        local humanoidRoot = selectedHumanoid.Parent and selectedHumanoid.Parent:FindFirstChild("HumanoidRootPart")
        if root and humanoidRoot then
            local targetPosition = humanoidRoot.Position + Vector3.new(5, floatHeight, 0)
            root.Velocity = (targetPosition - root.Position) * 3
        end
    end
end)

humanoid.Died:Connect(function()
    floating = false
    selectedHumanoid = nil
    stopButton.Text = "🚫 STOPPED"
end)

stopButton.MouseButton1Click:Connect(function()
    floating = false
    selectedHumanoid = nil
    stopButton.Text = "🚫 STOPPED"
end)

increaseHeightButton.MouseButton1Click:Connect(function()
    floatHeight = floatHeight + 1
end)

decreaseHeightButton.MouseButton1Click:Connect(function()
    floatHeight = floatHeight - 1
end)

toggleUIButton.MouseButton1Click:Connect(function()
    local isVisible = scrollingFrame.Visible
    scrollingFrame.Visible = not isVisible
    stopButton.Visible = not isVisible
    noclipButton.Visible = not isVisible
    increaseHeightButton.Visible = not isVisible
    decreaseHeightButton.Visible = not isVisible
    toggleUIButton.Text = isVisible and "👁️ Show UI" or "👁️ Hide UI"
end)

local function createLabel(name, count, humanoid)
    local label = Instance.new("TextButton")
    label.Size = UDim2.new(1, 0, 0, 30)
    label.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextScaled = true
    label.Font = Enum.Font.SourceSansBold
    label.Text = "👤 " .. name .. " #" .. count
    label.Parent = scrollingFrame

    label.MouseButton1Click:Connect(function()
        if humanoid and humanoid.Parent then
            selectedHumanoid = humanoid
            floating = true
            stopButton.Text = "🚫 STOP"
        end
    end)
end

local function updateList()
    for _, child in pairs(scrollingFrame:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    playersList = {}
    local nameCount = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Humanoid") then
            local humanoidName = obj.Parent.Name
            nameCount[humanoidName] = (nameCount[humanoidName] or 0) + 1
            table.insert(playersList, {name = humanoidName, count = nameCount[humanoidName], humanoid = obj})
        end
    end

    for _, data in pairs(playersList) do
        createLabel(data.name, data.count, data.humanoid)
    end

    scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, #playersList * 35)
end

while true do
    updateList()
    wait(1.5)
end