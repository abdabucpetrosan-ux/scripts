local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local plr = Players.LocalPlayer

local FarmEnabled = false
local ItemFolder = Workspace:WaitForChild("Item_Spawns"):WaitForChild("Items")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PandaItemFarm"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 250, 0, 150)
Frame.Position = UDim2.new(0.5, -125, 0.5, -75)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(1, -20, 0, 35)
ToggleBtn.Position = UDim2.new(0, 10, 0, 10)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ToggleBtn.Text = "Farm: OFF"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 14
ToggleBtn.Parent = Frame
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 6)

local Info = Instance.new("TextLabel")
Info.Size = UDim2.new(1, -20, 0, 30)
Info.Position = UDim2.new(0, 10, 0, 55)
Info.BackgroundTransparency = 1
Info.Text = "Ищу предметы..."
Info.TextColor3 = Color3.fromRGB(200, 200, 200)
Info.Font = Enum.Font.Gotham
Info.TextSize = 12
Info.Parent = Frame

local function GetHRP()
    local char = plr.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function FindNearestItem()
    local hrp = GetHRP()
    if not hrp then return nil end
    local nearest, minDist = nil, math.huge
    
    for _, item in ipairs(ItemFolder:GetChildren()) do
        if item:IsA("Model") and item.PrimaryPart then
            local dist = (item.PrimaryPart.Position - hrp.Position).Magnitude
            if dist < minDist then
                nearest = item
                minDist = dist
            end
        end
    end
    return nearest
end

-- НОВАЯ ЛОГИКА: Плавный шаг вместо телепорта
task.spawn(function()
    while task.wait(0.1) do
        if FarmEnabled then
            local target = FindNearestItem()
            local hrp = GetHRP()
            if target and hrp then
                local targetPos = target.PrimaryPart.Position
                local dist = (targetPos - hrp.Position).Magnitude
                
                Info.Text = "Иду к: " .. target.Name .. " (" .. math.floor(dist) .. " studs)"
                
                if dist > 10 then
                    -- Плавно двигаемся к цели (скорость 60 studs/sec, чтобы не спалиться)
                    local direction = (targetPos - hrp.Position).Unit
                    hrp.CFrame = hrp.CFrame + (direction * 0.6) 
                else
                    -- Если близко, прожимаем кнопку
                    local prompt = target:FindFirstChild("ProximityPrompt")
                    if prompt then
                        fireproximityprompt(prompt)
                    end
                end
            else
                Info.Text = "Жду спавн предметов..."
            end
        end
    end
end)

ToggleBtn.MouseButton1Click:Connect(function()
    FarmEnabled = not FarmEnabled
    ToggleBtn.Text = FarmEnabled and "Farm: ON" or "Farm: OFF"
    ToggleBtn.BackgroundColor3 = FarmEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(40, 40, 40)
    if not FarmEnabled then
        Info.Text = "Остановлено"
    end
end)