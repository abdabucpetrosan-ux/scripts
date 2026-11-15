local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local RS = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TP = game:GetService("TeleportService")
local plr = Players.LocalPlayer
local cam = Workspace.CurrentCamera

local Config = {
    ItemFarm = false, Noclip = false, Invisible = false, Pilot = false, 
    AutoSell = false, StandFarm = false, BossFarm = false, Troll = false,
    Dist = 25, TargetBoss = {}, SelectedStands = {}, SellFilter = {}, TargetTroll = {}, ItemFilter = {},
    Lang = "RU", Theme = "Default"
}

local LangTable = {
    RU = { Farm = "Фарм", Sell = "Продажа", Stands = "Стенды", Bosses = "Боссы", Misc = "Разное", Settings = "Настройки", 
           EnFarm = "Включить фарм", SelectItems = "Выбрать предметы", SellAll = "ПРОДАТЬ ВСЁ" },
    EN = { Farm = "Farm", Sell = "Sell", Stands = "Stands", Bosses = "Bosses", Misc = "Misc", Settings = "Settings", 
           EnFarm = "Enable Farm", SelectItems = "Select Items", SellAll = "SELL ALL" }
}

local AllItems = {"Mysterious Arrow", "Rokakaka", "Pure Rokakaka", "Stone Mask", "DIO's Diary", "Rib Cage", "Gold Coin", "Diamond", "Steel Ball", "Zeppelin's Headband", "Quinton's Glove", "Ancient Scroll", "Lucky Arrow", "Lucky Stone Mask", "Requiem Arrow"}
local AllStands = {"Star Platinum", "The World", "King Crimson", "Whitesnake", "C-Moon", "Made in Heaven", "The World Over Heaven", "D4C", "Soft & Wet", "Tusk ACT 4", "Gold Experience Requiem"}
local AllBosses = {"DIO", "Diavolo", "Jotaro Kujo", "Heaven Ascension DIO", "Leaky Eye Luca", "Bruno Bucciarati", "Pannacotta Fugo", "Pesci", "Ghiaccio", "Funny Valentine", "Enrico Pucci"}

local Gui = Instance.new("ScreenGui", CoreGui)
Gui.Name = "PavelHub"; Gui.ResetOnSpawn = false
local Main = Instance.new("Frame", Gui)
Main.Size = UDim2.new(0, 520, 0, 420); Main.Position = UDim2.new(0.5,-260,0.5,-210)
Main.BackgroundColor3 = Color3.new(0,0,0); Main.Active = true; Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 6)

local Top = Instance.new("Frame", Main)
Top.Size = UDim2.new(1,0,0,30); Top.BackgroundColor3 = Color3.fromRGB(10,10,10)
local Title = Instance.new("TextLabel", Top)
Title.Size = UDim2.new(1,-30,1,0); Title.Position = UDim2.new(0,10,0,0); Title.BackgroundTransparency = 1
Title.Text = "Pavel Hub | Mega Edition"; Title.TextColor3 = Color3.new(1,1,1); Title.Font = Enum.Font.Gotham; Title.TextSize = 14; Title.TextXAlignment = Enum.TextXAlignment.Left

local Side = Instance.new("Frame", Main)
Side.Size = UDim2.new(0, 130, 1, -40); Side.Position = UDim2.new(0, 10, 0, 35); Side.BackgroundTransparency = 1
local Cont = Instance.new("ScrollingFrame", Main)
Cont.Size = UDim2.new(1, -155, 1, -40); Cont.Position = UDim2.new(0, 145, 0, 35); Cont.BackgroundTransparency = 1; Cont.BorderSizePixel = 0; Cont.ScrollBarThickness = 3; Cont.ScrollBarImageColor3 = Color3.new(1,1,1)

local Tabs = {"Item Farm", "Auto Sell", "Stand Farm", "Boss Farm", "Misc", "Settings"}
local Pages = {}

local function SwitchTab(Name)
    for n, p in pairs(Pages) do p.Visible = (n == Name) end
    for _, b in pairs(Side:GetChildren()) do
        if b:IsA("TextButton") then
            b.BackgroundColor3 = (b.Text == Name) and Color3.fromRGB(30,30,30) or Color3.new(0,0,0)
            b.TextColor3 = (b.Text == Name) and Color3.new(1,1,1) or Color3.fromRGB(150,150,150)
        end
    end
end

for i, name in ipairs(Tabs) do
    local b = Instance.new("TextButton", Side)
    b.Size = UDim2.new(1,0,0,25); b.Position = UDim2.new(0,0,0,(i-1)*28)
    b.BackgroundColor3 = Color3.new(0,0,0); b.Text = name; b.TextColor3 = Color3.fromRGB(150,150,150); b.Font = Enum.Font.Gotham; b.TextSize = 12
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,4)
    b.MouseButton1Click:Connect(function() SwitchTab(name) end)
    local p = Instance.new("ScrollingFrame", Cont)
    p.Size = UDim2.new(1,0,1,0); p.BackgroundTransparency = 1; p.Visible = false; p.BorderSizePixel = 0; p.ScrollBarThickness = 3
    Pages[name] = p
end

local function CreateToggle(parent, text, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1,0,0,28); btn.BackgroundColor3 = Color3.fromRGB(15,15,15); btn.Text = "    " .. text; btn.TextColor3 = Color3.new(1,1,1); btn.Font = Enum.Font.Gotham; btn.TextSize = 12; btn.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,4)
    local dot = Instance.new("Frame", btn)
    dot.Size = UDim2.new(0,12,0,12); dot.Position = UDim2.new(0,8,0.5,-6); dot.BackgroundColor3 = Color3.new(0,0,0); dot.BorderSizePixel = 2; dot.BorderColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1,0)
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        dot.BackgroundColor3 = state and Color3.new(1,1,1) or Color3.new(0,0,0)
        callback(state)
    end)
end

local function CreateDropdown(parent, text, list, tableToSave)
    local mainBtn = Instance.new("TextButton", parent)
    mainBtn.Size = UDim2.new(1,0,0,28); mainBtn.BackgroundColor3 = Color3.fromRGB(15,15,15); mainBtn.Text = "    " .. text; mainBtn.TextColor3 = Color3.new(1,1,1); mainBtn.Font = Enum.Font.Gotham; mainBtn.TextSize = 12; mainBtn.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", mainBtn).CornerRadius = UDim.new(0,4)
    
    local listFrame = Instance.new("Frame", parent)
    listFrame.Size = UDim2.new(1,0,0,0); listFrame.BackgroundTransparency = 1; listFrame.Visible = false
    local layout = Instance.new("UIListLayout", listFrame)
    
    mainBtn.MouseButton1Click:Connect(function()
        listFrame.Visible = not listFrame.Visible
        if listFrame.Visible then
            for _, child in ipairs(listFrame:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
            for i, item in ipairs(list) do
                local subBtn = Instance.new("TextButton", listFrame)
                subBtn.Size = UDim2.new(1,0,0,24); subBtn.BackgroundColor3 = Color3.fromRGB(25,25,25); subBtn.Text = "  - " .. item; subBtn.TextColor3 = Color3.fromRGB(200,200,200); subBtn.Font = Enum.Font.Gotham; subBtn.TextSize = 11; subBtn.TextXAlignment = Enum.TextXAlignment.Left
                Instance.new("UICorner", subBtn).CornerRadius = UDim.new(0,4)
                subBtn.MouseButton1Click:Connect(function()
                    tableToSave[item] = not tableToSave[item]
                    subBtn.BackgroundColor3 = tableToSave[item] and Color3.fromRGB(30,90,200) or Color3.fromRGB(25,25,25)
                end)
            end
            listFrame.Size = UDim2.new(1,0,0,#list*26)
        end
    end)
end

local function GetChar() return plr.Character end
local function GetHRP() local c = GetChar(); return c and c:FindFirstChild("HumanoidRootPart") end

local function Fire(n, t)
    for _, r in ipairs(RS:GetDescendants()) do
        if (r:IsA("RemoteEvent") or r:IsA("RemoteFunction")) and r.Name:lower():find(n:lower()) then
            pcall(function() if r:IsA("RemoteEvent") then r:FireServer(t) else r:InvokeServer(t) end end)
            return true
        end
    end
    return false
end

-- Заполнение UI
local UIList1 = Instance.new("UIListLayout", Pages["Item Farm"])
UIList1.Padding = UDim.new(0,4)
CreateToggle(Pages["Item Farm"], "Enable Item Farm", function(s) Config.ItemFarm = s end)
CreateDropdown(Pages["Item Farm"], "Select Items", AllItems, Config.ItemFilter)

local UIList2 = Instance.new("UIListLayout", Pages["Auto Sell"])
UIList2.Padding = UDim.new(0,4)
CreateToggle(Pages["Auto Sell"], "Enable Auto Sell", function(s) Config.AutoSell = s end)
CreateDropdown(Pages["Auto Sell"], "Select Items to Sell", AllItems, Config.SellFilter)

local UIList3 = Instance.new("UIListLayout", Pages["Stand Farm"])
UIList3.Padding = UDim.new(0,4)
CreateToggle(Pages["Stand Farm"], "Enable Stand Farm", function(s) Config.StandFarm = s end)
CreateDropdown(Pages["Stand Farm"], "Select Stands", AllStands, Config.SelectedStands)

local UIList4 = Instance.new("UIListLayout", Pages["Boss Farm"])
UIList4.Padding = UDim.new(0,4)
CreateToggle(Pages["Boss Farm"], "Enable Boss Farm", function(s) Config.BossFarm = s end)
CreateDropdown(Pages["Boss Farm"], "Select Boss", AllBosses, Config.TargetBoss)

local UIList5 = Instance.new("UIListLayout", Pages["Misc"])
UIList5.Padding = UDim.new(0,4)
CreateToggle(Pages["Misc"], "Noclip", function(s) Config.Noclip = s end)
CreateToggle(Pages["Misc"], "Invisible", function(s) Config.Invisible = s end)
CreateToggle(Pages["Misc"], "Stand Pilot", function(s) Config.Pilot = s end)

-- Настройки
local UIList6 = Instance.new("UIListLayout", Pages["Settings"])
UIList6.Padding = UDim.new(0,4)

local btnLang = Instance.new("TextButton", Pages["Settings"])
btnLang.Size = UDim2.new(1,0,0,28); btnLang.BackgroundColor3 = Color3.fromRGB(15,15,15); btnLang.Text = "Language: RU"; btnLang.TextColor3 = Color3.new(1,1,1); btnLang.Font = Enum.Font.Gotham; btnLang.TextSize = 12
Instance.new("UICorner", btnLang).CornerRadius = UDim.new(0,4)
btnLang.MouseButton1Click:Connect(function()
    Config.Lang = (Config.Lang == "RU") and "EN" or "RU"
    btnLang.Text = "Language: " .. Config.Lang
    -- Тут можно добавить логику смены текста, если нужно
end)

local btnRed = Instance.new("TextButton", Pages["Settings"])
btnRed.Size = UDim2.new(1,0,0,28); btnRed.BackgroundColor3 = Color3.fromRGB(200,50,50); btnRed.Text = "Theme: Red"; btnRed.TextColor3 = Color3.new(1,1,1); btnRed.Font = Enum.Font.Gotham; btnRed.TextSize = 12
Instance.new("UICorner", btnRed).CornerRadius = UDim.new(0,4)
btnRed.MouseButton1Click:Connect(function() Main.BackgroundColor3 = Color3.fromRGB(30,0,0); Title.TextColor3 = Color3.fromRGB(255,100,100) end)

local btnBlue = Instance.new("TextButton", Pages["Settings"])
btnBlue.Size = UDim2.new(1,0,0,28); btnBlue.BackgroundColor3 = Color3.fromRGB(50,50,200); btnBlue.Text = "Theme: Blue"; btnBlue.TextColor3 = Color3.new(1,1,1); btnBlue.Font = Enum.Font.Gotham; btnBlue.TextSize = 12
Instance.new("UICorner", btnBlue).CornerRadius = UDim.new(0,4)
btnBlue.MouseButton1Click:Connect(function() Main.BackgroundColor3 = Color3.fromRGB(0,0,30); Title.TextColor3 = Color3.fromRGB(100,100,255) end)

local btnTelegram = Instance.new("TextButton", Pages["Settings"])
btnTelegram.Size = UDim2.new(1,0,0,28); btnTelegram.BackgroundColor3 = Color3.fromRGB(34,158,217); btnTelegram.Text = "Telegram: @mehslarp"; btnTelegram.TextColor3 = Color3.new(1,1,1); btnTelegram.Font = Enum.Font.Gotham; btnTelegram.TextSize = 12
Instance.new("UICorner", btnTelegram).CornerRadius = UDim.new(0,4)
btnTelegram.MouseButton1Click:Connect(function() setclipboard("https://t.me/mehslarp") end)

SwitchTab("Item Farm")

-- Логика
local function GetStand()
    for _, o in ipairs(Workspace:GetChildren()) do
        if o:IsA("Model") and (o.Name:lower():find("stand") or o.Name:lower():find(plr.Name:lower())) then return o end
    end
end

task.spawn(function()
    while task.wait(2) do
        if Config.AutoSell then
            for name, state in pairs(Config.SellFilter) do
                if state then Fire("Sell", name) end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.1) do
        if Config.BossFarm and GetHRP() then
            for _, obj in ipairs(Workspace:GetChildren()) do
                if obj:IsA("Model") and Config.TargetBoss[obj.Name] then
                    local tr = obj:FindFirstChild("HumanoidRootPart")
                    if tr then
                        GetHRP().CFrame = CFrame.new(tr.Position + (GetHRP().Position - tr.Position).Unit * Config.Dist)
                        Fire("Attack", obj)
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.1) do
        if Config.ItemFarm and GetHRP() then
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if Config.ItemFilter[obj.Name] then
                    local part = obj:IsA("Model") and obj.PrimaryPart or obj
                    if part then
                        if (part.Position - GetHRP().Position).Magnitude < 30 then
                            if not Fire("Collect", obj) then
                                for _, p in ipairs(obj:GetDescendants()) do
                                    if p:IsA("ProximityPrompt") then fireproximityprompt(p) end
                                end
                            end
                        else
                            GetHRP().CFrame = CFrame.new(GetHRP().Position:Lerp(part.Position, 0.1))
                        end
                    end
                end
            end
        end
    end
end)

RunService.Stepped:Connect(function()
    if Config.Noclip and GetChar() then
        for _, p in ipairs(GetChar():GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end
end)

task.spawn(function()
    while task.wait(1) do
        if GetChar() then
            for _, p in ipairs(GetChar():GetDescendants()) do
                if (p:IsA("BasePart") or p:IsA("Decal")) and p.Name ~= "HumanoidRootPart" then
                    p.Transparency = Config.Invisible and 1 or 0
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.1) do
        if Config.Pilot then
            local stand = GetStand()
            if stand and stand.PrimaryPart then
                cam.CameraSubject = stand.PrimaryPart
                if GetChar() and GetChar():FindFirstChild("Humanoid") then GetChar().Humanoid.WalkSpeed = 0 end
            end
        else
            if GetChar() and GetChar():FindFirstChild("Humanoid") and cam.CameraSubject ~= GetChar().Humanoid then
                cam.CameraSubject = GetChar().Humanoid; GetChar().Humanoid.WalkSpeed = 16
            end
        end
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        Main.Visible = not Main.Visible
    end
end)