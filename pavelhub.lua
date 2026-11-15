local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local RS = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local TP = game:GetService("TeleportService")
local Http = game:GetService("HttpService")
local plr = Players.LocalPlayer
local cam = Workspace.CurrentCamera

local C = {
    Farm = false, Dist = 25, Delay = 0.5,
    Items = {["Gold Coin"]=false, ["Mysterious Arrow"]=false, ["Stone Mask"]=false},
    Sell = false, Hop = false, MinP = 5,
    ESP = false, Noclip = false, Inv = false,
    Boss = false, Troll = false, TPlyr = nil, TBoss = nil, Pilot = false
}

local Gui = Instance.new("ScreenGui", CoreGui)
Gui.Name = "PavelHub"
local Main = Instance.new("Frame", Gui)
Main.Size = UDim2.new(0, 500, 0, 380); Main.Position = UDim2.new(0.5,-250,0.5,-190)
Main.BackgroundColor3 = Color3.new(0,0,0); Main.Active = true; Main.Draggable = true

local Top = Instance.new("Frame", Main)
Top.Size = UDim2.new(1,0,0,30); Top.BackgroundColor3 = Color3.new(0,0,0)
local Txt = Instance.new("TextLabel", Top)
Txt.Size = UDim2.new(1,-30,1,0); Txt.Position = UDim2.new(0,10,0,0); Txt.BackgroundTransparency = 1
Txt.Text = "Pavel Hub"; Txt.TextColor3 = Color3.new(1,1,1); Txt.Font = Enum.Font.Gotham; Txt.TextSize = 14; Txt.TextXAlignment = Enum.TextXAlignment.Left
local X = Instance.new("TextButton", Top)
X.Size = UDim2.new(0,30,0,30); X.Position = UDim2.new(1,-30,0,0); X.BackgroundTransparency = 1; X.Text = "X"; X.TextColor3 = Color3.new(1,1,1)
X.MouseButton1Click:Connect(function() Gui:Destroy() end)

local Side = Instance.new("Frame", Main)
Side.Size = UDim2.new(0,130,1,-40); Side.Position = UDim2.new(0,10,0,35); Side.BackgroundTransparency = 1
local Cont = Instance.new("ScrollingFrame", Main)
Cont.Size = UDim2.new(1,-155,1,-40); Cont.Position = UDim2.new(0,145,0,35); Cont.BackgroundTransparency = 1; Cont.BorderSizePixel = 0; Cont.ScrollBarThickness = 3; Cont.ScrollBarImageColor3 = Color3.new(1,1,1)

local Tabs = {"YBA/Farm", "Auto Sell", "Trolling", "Misc/ESP", "Boss Farm", "Pilot", "Settings"}
local Pgs = {}

local function Switch(T)
    for n, f in pairs(Pgs) do f.Visible = (n==T) end
    for _, b in pairs(Side:GetChildren()) do
        if b:IsA("TextButton") then
            b.BackgroundColor3 = (b.Text==T) and Color3.fromRGB(30,30,30) or Color3.new(0,0,0)
        end
    end
end

for i, n in ipairs(Tabs) do
    local b = Instance.new("TextButton", Side)
    b.Size = UDim2.new(1,0,0,25); b.Position = UDim2.new(0,0,0,(i-1)*28)
    b.BackgroundColor3 = Color3.new(0,0,0); b.Text = n; b.TextColor3 = Color3.fromRGB(180,180,180); b.Font = Enum.Font.Gotham; b.TextSize = 12
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,4)
    b.MouseButton1Click:Connect(function() Switch(n) end)
    local p = Instance.new("Frame", Cont)
    p.Size = UDim2.new(1,0,1,0); p.BackgroundTransparency = 1; p.Visible = false
    Pgs[n] = p
end

local function UI(parent, text, y, cb, isBtn)
    local f = Instance.new("TextButton", parent)
    f.Size = UDim2.new(1,0,0,28); f.Position = UDim2.new(0,0,0,y)
    f.BackgroundColor3 = Color3.fromRGB(15,15,15); f.Text = "  " .. text; f.TextColor3 = Color3.new(1,1,1); f.Font = Enum.Font.Gotham; f.TextSize = 12; f.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", f).CornerRadius = UDim.new(0,4)
    if isBtn then
        f.MouseButton1Click:Connect(cb)
    else
        local dot = Instance.new("Frame", f)
        dot.Size = UDim2.new(0,12,0,12); dot.Position = UDim2.new(0,8,0.5,-6); dot.BackgroundColor3 = Color3.new(0,0,0); dot.BorderSizePixel = 2; dot.BorderColor3 = Color3.new(1,1,1)
        Instance.new("UICorner", dot).CornerRadius = UDim.new(1,0)
        f.Text = "    " .. text
        f.MouseButton1Click:Connect(function()
            local s = not (dot.BackgroundColor3 == Color3.new(1,1,1))
            dot.BackgroundColor3 = s and Color3.new(1,1,1) or Color3.new(0,0,0)
            cb(s)
        end)
    end
    return 32
end

local function Char() return plr.Character end
local function HRP() local c = Char() return c and c:FindFirstChild("HumanoidRootPart") end

local function Fire(n, t)
    for _, r in ipairs(RS:GetDescendants()) do
        if (r:IsA("RemoteEvent") or r:IsA("RemoteFunction")) and r.Name:lower():find(n:lower()) then
            pcall(function() if r:IsA("RemoteEvent") then r:FireServer(t) else r:InvokeServer(t) end end)
            return true
        end
    end
    return false
end

task.spawn(function() while task.wait(0.1) do
    if C.Farm and HRP() then
        for _, o in ipairs(Workspace:GetDescendants()) do
            if C.Items[o.Name] then
                local pt = o:IsA("Model") and o.PrimaryPart or o
                if pt then
                    local d = (pt.Position - HRP().Position).Magnitude
                    if d <= C.Dist + 5 then
                        task.wait(C.Delay)
                        if not Fire("Collect", o) then for _, p in ipairs(o:GetDescendants()) do if p:IsA("ProximityPrompt") then fireproximityprompt(p) end end end
                    else
                        HRP().CFrame = CFrame.new(HRP().Position:Lerp(pt.Position, 0.1))
                    end
                end
            end
        end
    end
end end)

task.spawn(function() while task.wait(2) do if C.Sell then Fire("Sell", nil) end end end)

task.spawn(function() while task.wait(10) do
    if C.Hop then
        local cnt = #Players:GetPlayers()
        if cnt > C.MinP then
            if writefile then pcall(function() writefile("pavel.json", Http:JSONEncode(C)) end) end
            TP:Teleport(game.PlaceId, plr)
        end
    end
end end)

task.spawn(function() while task.wait(0.1) do
    if C.Boss or C.Troll then
        local t = C.TPlyr or C.TBoss
        if t and HRP() then
            local tr = t:FindFirstChild("HumanoidRootPart")
            if tr then
                HRP().CFrame = CFrame.new(tr.Position + (HRP().Position - tr.Position).Unit * C.Dist)
                for _, o in ipairs(Workspace:GetChildren()) do
                    if o:IsA("Model") and o.Name:lower():find("stand") and o.PrimaryPart then
                        o.PrimaryPart.CFrame = CFrame.new(tr.Position + Vector3.new(0,1,0))
                    end
                end
                Fire("Attack", t)
            end
        end
    end
end end)

task.spawn(function() while task.wait(0.1) do
    if C.Pilot then
        for _, o in ipairs(Workspace:GetChildren()) do
            if o:IsA("Model") and o.Name:lower():find("stand") and o.PrimaryPart then
                cam.CameraSubject = o.PrimaryPart
                if Char() and Char():FindFirstChild("Humanoid") then Char().Humanoid.WalkSpeed = 0; Char().Humanoid.JumpPower = 0 end
                break
            end
        end
    else
        if Char() and Char():FindFirstChild("Humanoid") and cam.CameraSubject ~= Char().Humanoid then
            cam.CameraSubject = Char().Humanoid; Char().Humanoid.WalkSpeed = 16; Char().Humanoid.JumpPower = 50
        end
    end
end end)

RunService.Stepped:Connect(function()
    if C.Noclip and Char() then
        for _, p in ipairs(Char():GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end
    end
end)

task.spawn(function() while task.wait(1) do
    if Char() then
        for _, p in ipairs(Char():GetDescendants()) do
            if (p:IsA("BasePart") or p:IsA("Decal")) and p.Name ~= "HumanoidRootPart" then
                p.Transparency = C.Inv and 1 or 0
            end
        end
    end
end end)

local ESPS = {}
local function DrawESP()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= plr then
            if not ESPS[p] then
                ESPS[p] = {b=Drawing.new("Square"), n=Drawing.new("Text"), d=Drawing.new("Text")}
                ESPS[p].b.Thickness=1; ESPS[p].b.Color=Color3.new(1,1,1); ESPS[p].b.Filled=false
                ESPS[p].n.Size=14; ESPS[p].n.Center=true; ESPS[p].n.Outline=true; ESPS[p].n.Color=Color3.new(1,1,1)
                ESPS[p].d.Size=14; ESPS[p].d.Center=true; ESPS[p].d.Outline=true; ESPS[p].d.Color=Color3.fromRGB(200,200,200)
            end
            local ch = p.Character; local h = ch and ch:FindFirstChild("HumanoidRootPart")
            if h and C.ESP then
                local v, s = cam:WorldToViewportPoint(h.Position)
                if s then
                    local vh = cam:WorldToViewportPoint(h.Position + Vector3.new(0,3,0))
                    local vf = cam:WorldToViewportPoint(h.Position - Vector3.new(0,3,0))
                    local ht = math.abs(vh.Y - vf.Y); local wd = ht/2
                    ESPS[p].b.Size = Vector2.new(wd, ht); ESPS[p].b.Position = Vector2.new(v.X-wd/2, v.Y-ht/2); ESPS[p].b.Visible=true
                    ESPS[p].n.Text = p.Name; ESPS[p].n.Position = Vector2.new(v.X, v.Y-ht/2-15); ESPS[p].n.Visible=true
                    if HRP() then ESPS[p].d.Text = math.floor((h.Position - HRP().Position).Magnitude).." studs"; ESPS[p].d.Position = Vector2.new(v.X, v.Y+ht/2+5); ESPS[p].d.Visible=true end
                else
                    ESPS[p].b.Visible=false; ESPS[p].n.Visible=false; ESPS[p].d.Visible=false
                end
            else
                ESPS[p].b.Visible=false; ESPS[p].n.Visible=false; ESPS[p].d.Visible=false
            end
        end
    end
end
RunService.RenderStepped:Connect(DrawESP)

local y = 0
y = y + UI(Pgs["YBA/Farm"], "Start Item Farm", y, function(v) C.Farm = v end)
for k in pairs(C.Items) do y = y + UI(Pgs["YBA/Farm"], k, y, function(v) C.Items[k] = v end) end
y = y + UI(Pgs["YBA/Farm"], "Step Distance ("..C.Dist..")", y, function() C.Dist = (C.Dist>=30 and 10) or C.Dist+5 end, true)

y = 0
y = y + UI(Pgs["Auto Sell"], "Enable Auto Sell", y, function(v) C.Sell = v end)

y = 0
y = y + UI(Pgs["Trolling"], "Enable Troll", y, function(v) C.Troll = v end)
for _, p in ipairs(Players:GetPlayers()) do if p ~= plr then y = y + UI(Pgs["Trolling"], "Target: "..p.Name, y, function() C.TPlyr = p end, true) end end

y = 0
y = y + UI(Pgs["Misc/ESP"], "Enable ESP", y, function(v) C.ESP = v end)
y = y + UI(Pgs["Misc/ESP"], "Enable Noclip", y, function(v) C.Noclip = v end)
y = y + UI(Pgs["Misc/ESP"], "Enable Invisible", y, function(v) C.Inv = v end)

y = 0
y = y + UI(Pgs["Boss Farm"], "Enable Boss Farm", y, function(v) C.Boss = v end)

y = 0
y = y + UI(Pgs["Pilot"], "Enable Stand Pilot", y, function(v) C.Pilot = v end)

y = 0
y = y + UI(Pgs["Settings"], "Enable Auto SvHop", y, function(v) C.Hop = v end)
y = y + UI(Pgs["Settings"], "Min Players ("..C.MinP..")", y, function() C.MinP = (C.MinP>=10 and 2) or C.MinP+1 end, true)

Switch("YBA/Farm")