--[[
    Universal ESP Script
    Works in ALL Roblox games
    Features: Box ESP, Tracers, Name, Health Bar, Distance, Team Check, Skeleton ESP, Aim Direction, Looking At You Indicator
    Open Menu: RightShift
]]

if not game:IsLoaded() then game.Loaded:Wait() end

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name  = "Universal ESP Script",
    Icon  = 4483362458,
    LoadingTitle    = "Universal ESP Script",
    LoadingSubtitle = "Loading...",
    ConfigurationSaving = {
        Enabled    = true,
        FolderName = "UniversalESPScript",
        FileName   = "ESPSettings"
    },
    Keybind = Enum.KeyCode.RightShift,
})

local ESPTab    = Window:CreateTab("ESP Settings", 4483362458)
local ColorTab  = Window:CreateTab("Colors", 4483362458)
local InfoTab   = Window:CreateTab("Info", 4483362458)

-- ========== SERVICES ==========
local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS        = game:GetService("UserInputService")
local Workspace  = game:GetService("Workspace")
local LP         = Players.LocalPlayer
local Camera     = workspace.CurrentCamera

-- ========== SETTINGS ==========
local Settings = {
    Enabled         = true,
    TeamCheck       = true,
    ShowBox         = true,
    ShowTracer      = true,
    ShowName        = true,
    ShowHealth      = true,
    ShowDistance    = true,
    ShowSkeleton    = true,
    ShowAimDir      = true,
    ShowLookingAtYou = true,
    MaxDistance     = 1500,
    
    -- Colors
    EnemyColor      = Color3.fromRGB(255, 50, 50),
    EnemyVisibleColor = Color3.fromRGB(0, 255, 0),
    TeamColor       = Color3.fromRGB(50, 150, 255),
    SkeletonColor   = Color3.fromRGB(255, 255, 255),
    SkeletonVisibleColor = Color3.fromRGB(0, 255, 0),
    AimDirColor     = Color3.fromRGB(255, 150, 0),
    LookingAtYouColor = Color3.fromRGB(255, 255, 0),
    TracerColor     = Color3.fromRGB(255, 100, 100),
}

-- ========== TUNING ==========
local Tuning = {
    BoxWidthRatio = 0.6,
    HealthBarWidth = 4,
    HealthBarOffset = 6,
    NameOffset = 18,
    DistOffset = 4,
    AimLineLength = 15,
    LookingThreshold = 0.85,
    VisibilityRefreshRate = 0.2,
}

local Timers = {
    lastVisRefresh = 0,
}

local Cache = {
    visibility = {},
    lookingAtYou = {},
}

-- ========== UI: ESP SETTINGS ==========
ESPTab:CreateToggle({
    Name         = "Включить ESP",
    CurrentValue = Settings.Enabled,
    Flag         = "ESP_Enabled",
    Callback     = function(v) Settings.Enabled = v end,
})

ESPTab:CreateToggle({
    Name         = "Team Check (не показывать союзников)",
    CurrentValue = Settings.TeamCheck,
    Flag         = "TeamCheck",
    Callback     = function(v) Settings.TeamCheck = v end,
})

ESPTab:CreateDivider()

ESPTab:CreateToggle({
    Name         = "Box ESP",
    CurrentValue = Settings.ShowBox,
    Flag         = "BoxESP",
    Callback     = function(v) Settings.ShowBox = v end,
})

ESPTab:CreateToggle({
    Name         = "Tracers (линии к игрокам)",
    CurrentValue = Settings.ShowTracer,
    Flag         = "Tracers",
    Callback     = function(v) Settings.ShowTracer = v end,
})

ESPTab:CreateToggle({
    Name         = "Skeleton ESP (скелет игрока)",
    CurrentValue = Settings.ShowSkeleton,
    Flag         = "SkeletonESP",
    Callback     = function(v) Settings.ShowSkeleton = v end,
})

ESPTab:CreateToggle({
    Name         = "Aim Direction (куда смотрит)",
    CurrentValue = Settings.ShowAimDir,
    Flag         = "AimDirESP",
    Callback     = function(v) Settings.ShowAimDir = v end,
})

ESPTab:CreateToggle({
    Name         = "Looking At You (смотрит на вас)",
    CurrentValue = Settings.ShowLookingAtYou,
    Flag         = "LookingAtYouESP",
    Callback     = function(v) Settings.ShowLookingAtYou = v end,
})

ESPTab:CreateToggle({
    Name         = "Имя игрока",
    CurrentValue = Settings.ShowName,
    Flag         = "NameESP",
    Callback     = function(v) Settings.ShowName = v end,
})

ESPTab:CreateToggle({
    Name         = "Полоска здоровья",
    CurrentValue = Settings.ShowHealth,
    Flag         = "HealthESP",
    Callback     = function(v) Settings.ShowHealth = v end,
})

ESPTab:CreateToggle({
    Name         = "Дистанция до игрока",
    CurrentValue = Settings.ShowDistance,
    Flag         = "DistanceESP",
    Callback     = function(v) Settings.ShowDistance = v end,
})

ESPTab:CreateSlider({
    Name         = "Максимальная дистанция ESP",
    Range        = {100, 3000},
    Increment    = 50,
    Suffix       = "studs",
    CurrentValue = Settings.MaxDistance,
    Flag         = "MaxDistance",
    Callback     = function(v) Settings.MaxDistance = v end,
})

-- ========== COLOR SETTINGS ==========
ColorTab:CreateLabel("Цвета врагов")

ColorTab:CreateColorPicker({
    Name = "Цвет врага (не видно)",
    Color = Settings.EnemyColor,
    Flag = "EnemyColor",
    Callback = function(v) Settings.EnemyColor = v end
})

ColorTab:CreateColorPicker({
    Name = "Цвет врага (видно)",
    Color = Settings.EnemyVisibleColor,
    Flag = "EnemyVisibleColor",
    Callback = function(v) Settings.EnemyVisibleColor = v end
})

ColorTab:CreateDivider()
ColorTab:CreateLabel("Цвета команды")

ColorTab:CreateColorPicker({
    Name = "Цвет союзника",
    Color = Settings.TeamColor,
    Flag = "TeamColor",
    Callback = function(v) Settings.TeamColor = v end
})

ColorTab:CreateDivider()
ColorTab:CreateLabel("Цвета скелета")

ColorTab:CreateColorPicker({
    Name = "Скелет (не видно)",
    Color = Settings.SkeletonColor,
    Flag = "SkeletonColor",
    Callback = function(v) Settings.SkeletonColor = v end
})

ColorTab:CreateColorPicker({
    Name = "Скелет (видно)",
    Color = Settings.SkeletonVisibleColor,
    Flag = "SkeletonVisibleColor",
    Callback = function(v) Settings.SkeletonVisibleColor = v end
})

ColorTab:CreateDivider()
ColorTab:CreateLabel("Другие цвета")

ColorTab:CreateColorPicker({
    Name = "Направление взгляда",
    Color = Settings.AimDirColor,
    Flag = "AimDirColor",
    Callback = function(v) Settings.AimDirColor = v end
})

ColorTab:CreateColorPicker({
    Name = "Смотрит на вас",
    Color = Settings.LookingAtYouColor,
    Flag = "LookingAtYouColor",
    Callback = function(v) Settings.LookingAtYouColor = v end
})

ColorTab:CreateColorPicker({
    Name = "Tracers",
    Color = Settings.TracerColor,
    Flag = "TracerColor",
    Callback = function(v) Settings.TracerColor = v end
})

-- ========== INFO TAB ==========
InfoTab:CreateParagraph({
    Title   = "Universal ESP Script",
    Content = "Работает во ВСЕХ Roblox играх!\n\nФУНКЦИИ:\n• Box ESP (рамка вокруг игрока)\n• Skeleton ESP (скелет игрока)\n• Health Bar (полоска здоровья)\n• Aim Direction (куда смотрит враг)\n• Looking At You (предупреждение если враг смотрит на вас)\n• Tracers (линии к игрокам)\n• Имя игрока\n• Дистанция\n• Team Check\n• Настройка всех цветов\n\nУПРАВЛЕНИЕ:\n• RightShift — открыть/закрыть меню"
})

-- ========== HELPERS ==========
local function IsTeammate(Player)
    if not Settings.TeamCheck then return false end
    if LP.Team and Player.Team == LP.Team then return true end
    local lc = LP.Character
    local pc = Player.Character
    if lc and pc and lc.Parent == pc.Parent then return true end
    return false
end

local function IsVisible(character)
    if not character then return false end
    local cam = Camera
    if not cam then return false end
    
    local origin = cam.CFrame.Position
    local parts = {"Head", "Torso", "HumanoidRootPart", "UpperTorso"}
    
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    local filter = {cam}
    if LP.Character then table.insert(filter, LP.Character) end
    table.insert(filter, character)
    rayParams.FilterDescendantsInstances = filter
    
    for _, partName in pairs(parts) do
        local part = character:FindFirstChild(partName)
        if part then
            local dir = (part.Position - origin)
            local result = Workspace:Raycast(origin, dir.Unit * dir.Magnitude, rayParams)
            if not result or (result.Position - part.Position).Magnitude < 5 then
                return true
            end
        end
    end
    return false
end

local function IsLookingAtYou(char)
    if not LP.Character then return false end
    local myHead = LP.Character:FindFirstChild("Head") or LP.Character:FindFirstChild("HumanoidRootPart")
    local head = char:FindFirstChild("Head") or char:FindFirstChild("UpperTorso")
    if not myHead or not head then return false end
    local toYou = (myHead.Position - head.Position).Unit
    return toYou:Dot(head.CFrame.LookVector) > Tuning.LookingThreshold
end

local function GetColor(Player, visible)
    if IsTeammate(Player) then
        return Settings.TeamColor
    else
        return visible and Settings.EnemyVisibleColor or Settings.EnemyColor
    end
end

local function GetHealthColor(hp, max)
    local p = hp / max
    if p > 0.7 then return Color3.fromRGB(0, 255, 100) end
    if p > 0.3 then return Color3.fromRGB(255, 200, 0) end
    return Color3.fromRGB(255, 50, 50)
end

-- ========== DRAWING HELPERS ==========
local function DrawLine(frame, x1, y1, x2, y2, color, thickness)
    thickness = thickness or 1
    local dx = x2 - x1
    local dy = y2 - y1
    local length = math.sqrt(dx * dx + dy * dy)
    if length < 1 then
        frame.Visible = false
        return
    end
    local cx = (x1 + x2) / 2
    local cy = (y1 + y2) / 2
    local angle = math.atan2(dy, dx) * (180 / math.pi)
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.Position = UDim2.new(0, cx, 0, cy)
    frame.Size = UDim2.new(0, length, 0, thickness)
    frame.Rotation = angle
    if color then frame.BackgroundColor3 = color end
    frame.Visible = true
end

-- ========== ESP OBJECTS ==========
local ESPCache = {}

local function NewLine(thickness, transp)
    local l = Instance.new("Frame")
    l.BackgroundColor3 = Color3.new(1, 1, 1)
    l.BorderSizePixel = 0
    l.AnchorPoint = Vector2.new(0.5, 0.5)
    l.Visible = false
    return l
end

local function NewText(size)
    local t = Instance.new("TextLabel")
    t.BackgroundTransparency = 1
    t.Font = Enum.Font.RobotoMono
    t.TextSize = size or 12
    t.TextColor3 = Color3.new(1, 1, 1)
    t.TextStrokeTransparency = 0
    t.Size = UDim2.new(0, 200, 0, 16)
    t.TextXAlignment = Enum.TextXAlignment.Center
    t.Visible = false
    return t
end

local function CreateESP(Player)
    if Player == LP then return end
    if ESPCache[Player] then return end
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ESP_" .. Player.Name
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.DisplayOrder = 999
    ScreenGui.IgnoreGuiInset = true
    pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
    if not ScreenGui.Parent then ScreenGui.Parent = LP:WaitForChild("PlayerGui") end
    
    -- Box
    local box = Instance.new("Frame")
    box.BackgroundTransparency = 1
    box.BorderSizePixel = 0
    box.Visible = false
    box.Parent = ScreenGui
    local boxStroke = Instance.new("UIStroke")
    boxStroke.Thickness = 1.5
    boxStroke.Parent = box
    
    -- Name
    local name = NewText(12)
    name.Parent = ScreenGui
    
    -- Distance
    local dist = NewText(10)
    dist.Parent = ScreenGui
    
    -- Health Bar
    local healthBg = Instance.new("Frame")
    healthBg.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    healthBg.BorderSizePixel = 0
    healthBg.Visible = false
    healthBg.Parent = ScreenGui
    
    local healthBar = Instance.new("Frame")
    healthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    healthBar.BorderSizePixel = 0
    healthBar.Visible = false
    healthBar.Parent = ScreenGui
    
    -- Skeleton (R6 and R15 compatible)
    local Bones = {
        -- R6
        {"Head", "Torso"},
        {"Torso", "Left Arm"},
        {"Torso", "Right Arm"},
        {"Torso", "Left Leg"},
        {"Torso", "Right Leg"},
        -- R15
        {"Head", "UpperTorso"},
        {"UpperTorso", "LowerTorso"},
        {"UpperTorso", "LeftUpperArm"},
        {"LeftUpperArm", "LeftLowerArm"},
        {"LeftLowerArm", "LeftHand"},
        {"UpperTorso", "RightUpperArm"},
        {"RightUpperArm", "RightLowerArm"},
        {"RightLowerArm", "RightHand"},
        {"LowerTorso", "LeftUpperLeg"},
        {"LeftUpperLeg", "LeftLowerLeg"},
        {"LeftLowerLeg", "LeftFoot"},
        {"LowerTorso", "RightUpperLeg"},
        {"RightUpperLeg", "RightLowerLeg"},
        {"RightLowerLeg", "RightFoot"},
    }
    
    local skel = {}
    for i = 1, #Bones do
        skel[i] = NewLine(1.5, 0.8)
        skel[i].Parent = ScreenGui
    end
    
    -- Aim Direction Line
    local aimLine = NewLine(2, 0.8)
    aimLine.Parent = ScreenGui
    
    -- Looking At You Text
    local lookingText = NewText(13)
    lookingText.Text = "[!] LOOKING"
    lookingText.TextColor3 = Settings.LookingAtYouColor
    lookingText.Parent = ScreenGui
    
    -- Tracer
    local tracer = NewLine(1, 0.8)
    tracer.Parent = ScreenGui
    
    ESPCache[Player] = {
        ScreenGui = ScreenGui,
        Box = box,
        BoxStroke = boxStroke,
        Name = name,
        Dist = dist,
        HealthBg = healthBg,
        HealthBar = healthBar,
        Skel = skel,
        AimLine = aimLine,
        LookingText = lookingText,
        Tracer = tracer,
    }
end

local function RemoveESP(Player)
    local o = ESPCache[Player]
    if not o then return end
    pcall(function() o.ScreenGui:Destroy() end)
    ESPCache[Player] = nil
end

local function HideESP(o)
    o.Box.Visible = false
    o.Name.Visible = false
    o.Dist.Visible = false
    o.HealthBg.Visible = false
    o.HealthBar.Visible = false
    for _, l in ipairs(o.Skel) do l.Visible = false end
    o.AimLine.Visible = false
    o.LookingText.Visible = false
    o.Tracer.Visible = false
end

for _, p in pairs(Players:GetPlayers()) do CreateESP(p) end
Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(RemoveESP)

-- ========== VISIBILITY REFRESH ==========
local function RefreshVisibility()
    for Player, _ in pairs(ESPCache) do
        local Char = Player.Character
        if Char then
            Cache.visibility[Player] = IsVisible(Char)
            Cache.lookingAtYou[Player] = Cache.visibility[Player] and IsLookingAtYou(Char) or false
        end
    end
end

-- ========== MAIN LOOP ==========
RunService.RenderStepped:Connect(function()
    local now = tick()
    
    if now - Timers.lastVisRefresh > Tuning.VisibilityRefreshRate then
        Timers.lastVisRefresh = now
        RefreshVisibility()
    end
    
    for Player, o in pairs(ESPCache) do
        if not Settings.Enabled then HideESP(o) continue end

        local Char = Player.Character
        local Root = Char and Char:FindFirstChild("HumanoidRootPart")
        local Hum  = Char and Char:FindFirstChildOfClass("Humanoid")

        if not (Char and Root and Hum and Hum.Health > 0) then
            HideESP(o) continue
        end

        if Settings.TeamCheck and IsTeammate(Player) then
            HideESP(o) continue
        end

        local SP, OnScreen = Camera:WorldToViewportPoint(Root.Position)
        local Dist          = (Camera.CFrame.Position - Root.Position).Magnitude

        if not OnScreen or Dist > Settings.MaxDistance then
            HideESP(o) continue
        end

        local visible = Cache.visibility[Player] or false
        local lookingAtYou = Cache.lookingAtYou[Player] or false
        
        local BH  = 4000 / Dist
        local BW  = 2200 / Dist
        local X   = SP.X - BW/2
        local Y   = SP.Y - BH/2
        local Col = GetColor(Player, visible)
        local SkelCol = IsTeammate(Player) and Settings.TeamColor or (visible and Settings.SkeletonVisibleColor or Settings.SkeletonColor)
        local V2  = Vector2.new

        -- Box
        if Settings.ShowBox then
            o.Box.Position = V2(0, X, 0, Y)
            o.Box.Size = V2(0, BW, 0, BH)
            o.BoxStroke.Color = Col
            o.Box.Visible = true
        else
            o.Box.Visible = false
        end

        -- Name
        if Settings.ShowName then
            o.Name.Text = Player.Name
            o.Name.Position = V2(0, SP.X - 100, 0, Y - Tuning.NameOffset)
            o.Name.TextColor3 = Col
            o.Name.Visible = true
        else
            o.Name.Visible = false
        end

        -- Distance
        if Settings.ShowDistance then
            o.Dist.Text = math.floor(Dist) .. "m"
            o.Dist.Position = V2(0, SP.X - 100, 0, Y + BH + Tuning.DistOffset)
            o.Dist.Visible = true
        else
            o.Dist.Visible = false
        end

        -- Health Bar
        if Settings.ShowHealth then
            local pct = math.clamp(Hum.Health / Hum.MaxHealth, 0, 1)
            local barX = X - Tuning.HealthBarOffset
            o.HealthBg.Position = V2(0, barX - 1, 0, Y - 1)
            o.HealthBg.Size = V2(0, Tuning.HealthBarWidth + 2, 0, BH + 2)
            o.HealthBg.Visible = true
            local hh = BH * pct
            o.HealthBar.Position = V2(0, barX, 0, Y + BH - hh)
            o.HealthBar.Size = V2(0, Tuning.HealthBarWidth, 0, hh)
            o.HealthBar.BackgroundColor3 = GetHealthColor(Hum.Health, Hum.MaxHealth)
            o.HealthBar.Visible = true
        else
            o.HealthBg.Visible = false
            o.HealthBar.Visible = false
        end

        -- Skeleton
        if Settings.ShowSkeleton then
            local Bones = {
                {"Head", "Torso"}, {"Torso", "Left Arm"}, {"Torso", "Right Arm"},
                {"Torso", "Left Leg"}, {"Torso", "Right Leg"},
                {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
                {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
                {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
                {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
                {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"},
            }
            
            for i, b in ipairs(Bones) do
                if o.Skel[i] then
                    local p1, p2 = Char:FindFirstChild(b[1]), Char:FindFirstChild(b[2])
                    if p1 and p2 then
                        local s1, o1 = Camera:WorldToViewportPoint(p1.Position)
                        local s2, o2 = Camera:WorldToViewportPoint(p2.Position)
                        if o1 and o2 and s1.Z > 0 and s2.Z > 0 then
                            DrawLine(o.Skel[i], s1.X, s1.Y, s2.X, s2.Y, SkelCol, 1.5)
                        else
                            o.Skel[i].Visible = false
                        end
                    else
                        o.Skel[i].Visible = false
                    end
                end
            end
        else
            for _, l in ipairs(o.Skel) do l.Visible = false end
        end

        -- Aim Direction
        if Settings.ShowAimDir then
            local head = Char:FindFirstChild("Head") or Char:FindFirstChild("UpperTorso")
            if head then
                local aimEnd = head.Position + head.CFrame.LookVector * Tuning.AimLineLength
                local headScreen, headOn = Camera:WorldToViewportPoint(head.Position)
                local aimScreen, aimOn = Camera:WorldToViewportPoint(aimEnd)
                if headOn and aimOn and headScreen.Z > 0 and aimScreen.Z > 0 then
                    DrawLine(o.AimLine, headScreen.X, headScreen.Y, aimScreen.X, aimScreen.Y, Settings.AimDirColor, 2)
                else
                    o.AimLine.Visible = false
                end
            else
                o.AimLine.Visible = false
            end
        else
            o.AimLine.Visible = false
        end

        -- Looking At You
        if Settings.ShowLookingAtYou and lookingAtYou then
            o.LookingText.Position = V2(0, SP.X - 75, 0, Y - 35)
            o.LookingText.TextColor3 = Settings.LookingAtYouColor
            o.LookingText.Visible = true
        else
            o.LookingText.Visible = false
        end

        -- Tracer
        if Settings.ShowTracer then
            local screenSize = Camera.ViewportSize
            DrawLine(o.Tracer, screenSize.X/2, screenSize.Y, SP.X, SP.Y, Settings.TracerColor, 1)
        else
            o.Tracer.Visible = false
        end
    end
end)

print("✅ Universal ESP Script loaded | RightShift = menu")
