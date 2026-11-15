local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local plr = Players.LocalPlayer

local FarmEnabled = false
local Speed = 150 -- Скорость полета (150 studs/sec). Если кикает - уменьши до 80.

local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
ScreenGui.ResetOnSpawn = false
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 250, 0, 120)
Frame.Position = UDim2.new(0.5, -125, 0.5, -60)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Frame.Active = true; Frame.Draggable = true
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)

local ToggleBtn = Instance.new("TextButton", Frame)
ToggleBtn.Size = UDim2.new(1, -20, 0, 35)
ToggleBtn.Position = UDim2.new(0, 10, 0, 10)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ToggleBtn.Text = "Stealth Farm: OFF"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 14
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 6)

local Info = Instance.new("TextLabel", Frame)
Info.Size = UDim2.new(1, -20, 0, 30)
Info.Position = UDim2.new(0, 10, 0, 55)
Info.BackgroundTransparency = 1
Info.Text = "Ожидание..."
Info.TextColor3 = Color3.fromRGB(200, 200, 200)
Info.Font = Enum.Font.Gotham
Info.TextSize = 12

-- Функция для получения HRP
local function GetHRP()
    local char = plr.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

-- Включаем ноклип (чтобы пролетать сквозь стены)
local function ApplyNoclip(enable)
    local char = plr.Character
    if not char then return end
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") then
            p.CanCollide = not enable
        end
    end
end

-- Ищем ближайший предмет (стрелу, рокакаку, монету и т.д.)
local function FindNearestItem()
    local hrp = GetHRP()
    if not hrp then return nil end
    local nearest, minDist = nil, math.huge
    
    -- Ищем во всей карте (если знаешь точную папку в YBA, можно сузить)
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("BasePart") then
            -- Фильтр предметов YBA (чтобы не лететь к мусору)
            if obj.Name == "Mysterious Arrow" or obj.Name == "Rokakaka" or obj.Name == "Gold Coin" or obj.Name == "Stone Mask" or obj.Name == "Pure Rokakaka" then
                local pos = obj:IsA("Model") and obj.PrimaryPart and obj.PrimaryPart.Position or obj.Position
                if pos then
                    local dist = (pos - hrp.Position).Magnitude
                    if dist < minDist then
                        nearest = obj
                        minDist = dist
                    end
                end
            end
        end
    end
    return nearest
end

-- Главный цикл
task.spawn(function()
    while task.wait(0.05) do -- 20 раз в секунду
        if FarmEnabled then
            ApplyNoclip(true) -- Включаем проход сквозь стены
            
            local target = FindNearestItem()
            local hrp = GetHRP()
            
            if target and hrp then
                local targetPos = target:IsA("Model") and target.PrimaryPart.Position or target.Position
                local dist = (targetPos - hrp.Position).Magnitude
                
                Info.Text = "Цель: " .. target.Name .. " | " .. math.floor(dist) .. " studs"
                
                if dist > 8 then
                    -- ЕДЕМ К ЦЕЛИ (ПЛАВНО, БЕЗ РЫВКОВ)
                    local direction = (targetPos - hrp.Position).Unit
                    -- Умножаем на скорость и время кадра
                    hrp.CFrame = hrp.CFrame + (direction * Speed * 0.05)
                else
                    -- Если приехали, подбираем
                    local prompt = target:FindFirstChild("ProximityPrompt") or (target:IsA("Model") and target.PrimaryPart and target.PrimaryPart:FindFirstChild("ProximityPrompt"))
                    if prompt then
                        fireproximityprompt(prompt)
                    end
                end
            else
                Info.Text = "Жду спавн предметов..."
            end
        else
            ApplyNoclip(false)
        end
    end
end)

ToggleBtn.MouseButton1Click:Connect(function()
    FarmEnabled = not FarmEnabled
    ToggleBtn.Text = FarmEnabled and "Stealth Farm: ON" or "Stealth Farm: OFF"
    ToggleBtn.BackgroundColor3 = FarmEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(40, 40, 40)
    if not FarmEnabled then Info.Text = "Ожидание..." end
end)