--[[
    Universal ESP Script - УЛУЧШЕННАЯ ВЕРСИЯ v3
    Работает во ВСЕХ Roblox играх

    Изменения v3:
    - Видимые противники = зелёные
    - Невидимые/закрытые стеной противники = красные
    - Добавлены универсальные Chams / Highlight без привязки к PlaceId
    - Отключён рекламный Rayfield prompt: "Rayfield Interface ... sirius.menu/discord"
    - Исправлены HTML-сущности &gt; / &lt; на обычные > / <

    Open Menu: RightShift
]]

if not game:IsLoaded() then game.Loaded:Wait() end

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name  = "Universal ESP Script [УЛУЧШЕННЫЙ]",
    Icon  = 4483362458,
    LoadingTitle    = "Universal ESP Script",
    LoadingSubtitle = "Loading Enhanced Version...",

    -- Убирает периодическое уведомление:
    -- "Rayfield Interface / Enjoying this UI library? Find it at sirius.menu/discord"
    DisableRayfieldPrompts = true,
    DisableBuildWarnings = true,

    ConfigurationSaving = {
        Enabled    = true,
        FolderName = "UniversalESPScript",
        FileName   = "ESPSettings"
    },

    -- Оставил старое поле + новое поле Rayfield, чтобы работало на разных версиях библиотеки
    Keybind = Enum.KeyCode.RightShift,
    ToggleUIKeybind = Enum.KeyCode.RightShift,
})

local ESPTab  = Window:CreateTab("ESP Settings", 4483362458)
local ExtraTab = Window:CreateTab("Extra Features", 4483362458)
local InfoTab = Window:CreateTab("Info", 4483362458)

-- ========== SERVICES ==========
local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS        = game:GetService("UserInputService")
local LP         = Players.LocalPlayer
local Camera     = workspace.CurrentCamera

-- ========== SETTINGS ==========
local Settings = {
    Enabled      = true,
    TeamCheck    = true,
    ShowBox      = true,
    ShowTracer   = true,
    ShowName     = true,
    ShowHealth   = true,
    ShowDistance = true,
    ShowSkeleton = true,
    ShowChams    = true,  -- НОВОЕ: Chams / Highlight ESP
    ShowAimDir   = false,
    ShowLookingAtYou = false,
    MaxDistance  = 1500,

    -- НОВОЕ: цвет зависит от видимости противника
    VisibleColor = Color3.fromRGB(50, 255, 80),   -- виден = зелёный
    HiddenColor  = Color3.fromRGB(255, 50, 50),   -- не виден = красный

    -- Для союзников, если TeamCheck выключен/меняется логика
    TeamColor    = Color3.fromRGB(50, 150, 255),

    SkeletonThickness = 2,
    AimLineLength = 15,

    -- Chams настройки
    ChamsFillTransparency = 0.45,
    ChamsOutlineTransparency = 0,
}

-- ========== PALETTE ==========
local Palette = {
    HealthHigh = Color3.fromRGB(0, 255, 0),
    HealthMid = Color3.fromRGB(255, 255, 0),
    HealthLow = Color3.fromRGB(255, 0, 0),
    HealthBg = Color3.fromRGB(40, 40, 40),
    LookingAtYou = Color3.fromRGB(255, 255, 0),
    AimDir = Color3.fromRGB(255, 150, 0),
}

-- ========== CHAMS FOLDER ==========
local ChamsFolder = Instance.new("Folder")
ChamsFolder.Name = "UniversalESP_Chams"

pcall(function()
    local CoreGui = game:GetService("CoreGui")
    local old = CoreGui:FindFirstChild(ChamsFolder.Name)
    if old then old:Destroy() end
    ChamsFolder.Parent = CoreGui
end)

if not ChamsFolder.Parent then
    pcall(function()
        local PlayerGui = LP:WaitForChild("PlayerGui")
        local old = PlayerGui:FindFirstChild(ChamsFolder.Name)
        if old then old:Destroy() end
        ChamsFolder.Parent = PlayerGui
    end)
end

if not ChamsFolder.Parent then
    ChamsFolder.Parent = workspace
end

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
    Name         = "Chams / Highlight ESP",
    CurrentValue = Settings.ShowChams,
    Flag         = "ChamsESP",
    Callback     = function(v) Settings.ShowChams = v end,
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

-- ========== EXTRA FEATURES TAB ==========
ExtraTab:CreateToggle({
    Name         = "🎯 Направление взгляда (AIM DIR)",
    CurrentValue = Settings.ShowAimDir,
    Flag         = "AimDir",
    Callback     = function(v)
        Settings.ShowAimDir = v
        print("Направление взгляда:", v and "ВКЛ" or "ВЫКЛ")
    end,
})

ExtraTab:CreateToggle({
    Name         = "👁️ Предупреждение 'Смотрит на тебя'",
    CurrentValue = Settings.ShowLookingAtYou,
    Flag         = "LookingAtYou",
    Callback     = function(v)
        Settings.ShowLookingAtYou = v
        print("Предупреждение 'Смотрит на тебя':", v and "ВКЛ" or "ВЫКЛ")
    end,
})

ExtraTab:CreateDivider()

ExtraTab:CreateSlider({
    Name         = "Длина линии направления взгляда",
    Range        = {5, 50},
    Increment    = 1,
    Suffix       = "studs",
    CurrentValue = Settings.AimLineLength,
    Flag         = "AimLineLength",
    Callback     = function(v) Settings.AimLineLength = v end,
})

ExtraTab:CreateSlider({
    Name         = "Толщина скелета",
    Range        = {1, 5},
    Increment    = 1,
    Suffix       = "px",
    CurrentValue = Settings.SkeletonThickness,
    Flag         = "SkeletonThickness",
    Callback     = function(v) Settings.SkeletonThickness = v end,
})

-- ========== INFO TAB ==========
InfoTab:CreateParagraph({
    Title   = "Universal ESP Script [ENHANCED v3]",
    Content = "Работает во ВСЕХ Roblox играх!\n\n🆕 ДОБАВЛЕНО:\n• Видимый противник = зелёный\n• Не видимый/за стеной = красный\n• Универсальные Chams / Highlight без game.PlaceId\n• Отключён Rayfield рекламный prompt\n\nОСНОВНЫЕ ФУНКЦИИ:\n• Box ESP\n• Chams ESP\n• Skeleton ESP\n• Tracers\n• Имя, HP, Дистанция\n• Team Check\n\nУПРАВЛЕНИЕ:\n• RightShift — открыть/закрыть меню"
})

-- ========== GENERIC OBJECT HELPERS ==========
local function SetObjectVisible(obj, state)
    if not obj then return end

    if typeof(obj) == "Instance" then
        if obj:IsA("Highlight") then
            obj.Enabled = state
        elseif obj:IsA("GuiObject") then
            obj.Visible = state
        end
    else
        pcall(function()
            obj.Visible = state
        end)
    end
end

local function RemoveObject(obj)
    if not obj then return end

    pcall(function()
        if typeof(obj) == "Instance" then
            obj:Destroy()
        else
            obj:Remove()
        end
    end)
end

-- ========== HELPERS ==========
-- УНИВЕРСАЛЬНАЯ ПРОВЕРКА НА СОЮЗНИКА
local function IsTeammate(Player)
    if not Settings.TeamCheck then return false end

    -- Проверка 1: По команде Roblox
    if LP.Team and Player.Team then
        if LP.Team == Player.Team then
            return true
        end
    end

    -- Проверка 2: По родителю персонажа.
    -- Важно: в большинстве игр все персонажи лежат прямо в workspace,
    -- поэтому workspace НЕ считаем "одной командой", иначе ESP скроет всех игроков.
    local lc = LP.Character
    local pc = Player.Character
    if lc and pc then
        if lc.Parent and pc.Parent and lc.Parent == pc.Parent and lc.Parent ~= workspace then
            return true
        end
    end

    return false
end

-- Цвет ESP: враг виден = зелёный, не виден = красный
local function GetColor(Player, IsVisible)
    if IsTeammate(Player) then
        return Settings.TeamColor
    end

    return IsVisible and Settings.VisibleColor or Settings.HiddenColor
end

-- Цвет здоровья
local function GetHealthColor(hp, max)
    local pct = hp / max
    if pct > 0.6 then return Palette.HealthHigh end
    if pct > 0.3 then return Palette.HealthMid end
    return Palette.HealthLow
end

-- Проверка Line Of Sight: есть ли прямая видимость до части персонажа
local function IsPartVisibleToCamera(part, targetChar)
    if not Camera or not part or not part:IsA("BasePart") or not targetChar then
        return false
    end

    local origin = Camera.CFrame.Position
    local target = part.Position
    local direction = target - origin

    if direction.Magnitude <= 0.1 then
        return true
    end

    local ignoreList = {}

    if LP.Character then
        table.insert(ignoreList, LP.Character)
    end

    -- Иногда камера может иметь собственные части/объекты
    pcall(function()
        table.insert(ignoreList, Camera)
    end)

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = ignoreList
    params.IgnoreWater = true

    local currentOrigin = origin
    local maxChecks = 8

    for _ = 1, maxChecks do
        local currentDirection = target - currentOrigin
        if currentDirection.Magnitude <= 0.1 then
            return true
        end

        local result = workspace:Raycast(currentOrigin, currentDirection, params)

        -- Если ничего не попали, значит между камерой и точкой нет препятствий
        if not result then
            return true
        end

        local hit = result.Instance

        -- Если первым попали в нужного игрока — он виден
        if hit and hit:IsDescendantOf(targetChar) then
            return true
        end

        -- Пропускаем почти прозрачные / неколлизионные объекты, чтобы стекло/декор не ломали проверку
        local canSkip = false
        pcall(function()
            canSkip = (hit.Transparency >= 0.75) or (hit.CanCollide == false)
        end)

        if canSkip and hit then
            table.insert(ignoreList, hit)
            params.FilterDescendantsInstances = ignoreList
            currentOrigin = result.Position + currentDirection.Unit * 0.05
        else
            return false
        end
    end

    return false
end

local function IsCharacterVisible(char)
    if not char then return false end

    -- Проверяем несколько важных частей, чтобы видимость не зависела только от HumanoidRootPart
    local partNames = {
        "Head",
        "UpperTorso",
        "Torso",
        "HumanoidRootPart",
        "LowerTorso",
        "LeftUpperArm",
        "RightUpperArm",
        "Left Arm",
        "Right Arm",
    }

    for _, name in ipairs(partNames) do
        local part = char:FindFirstChild(name)
        if part and part:IsA("BasePart") then
            if IsPartVisibleToCamera(part, char) then
                return true
            end
        end
    end

    return false
end

-- УНИВЕРСАЛЬНАЯ ПРОВЕРКА "смотрит на тебя"
local function IsLookingAtYou(char)
    if not LP.Character then return false end

    local myHead = LP.Character:FindFirstChild("Head") or LP.Character:FindFirstChild("HumanoidRootPart")
    local head = char:FindFirstChild("Head")

    if not myHead or not head then return false end

    local success, result = pcall(function()
        local toYou = (myHead.Position - head.Position).Unit
        local lookVector = head.CFrame.LookVector
        return toYou:Dot(lookVector) > 0.85
    end)

    return success and result or false
end

-- ========== ESP OBJECTS ==========
local ESPCache = {}

local function NewLine(thickness, transp)
    local l = Drawing.new("Line")
    l.Thickness    = thickness or 1.5
    l.Transparency = transp    or 0.7
    l.Visible      = false
    return l
end

local function NewText(size)
    local t = Drawing.new("Text")
    t.Size    = size or 12
    t.Center  = true
    t.Outline = true
    t.Font    = 2
    t.Visible = false
    return t
end

local function NewChams()
    local h = Instance.new("Highlight")
    h.Name = "UniversalESP_Chams_Highlight"
    h.Enabled = false
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop -- видно через стены
    h.FillTransparency = Settings.ChamsFillTransparency
    h.OutlineTransparency = Settings.ChamsOutlineTransparency
    h.Parent = ChamsFolder
    return h
end

local function CreateESP(Player)
    if Player == LP then return end
    if ESPCache[Player] then return end

    -- Skeleton lines
    local SkeletonLines = {
        -- R15 bones
        HeadTorso = NewLine(Settings.SkeletonThickness, 0.8),
        TorsoHip = NewLine(Settings.SkeletonThickness, 0.8),
        TorsoLeftShoulder = NewLine(Settings.SkeletonThickness, 0.8),
        LeftShoulderElbow = NewLine(Settings.SkeletonThickness, 0.8),
        LeftElbowHand = NewLine(Settings.SkeletonThickness, 0.8),
        TorsoRightShoulder = NewLine(Settings.SkeletonThickness, 0.8),
        RightShoulderElbow = NewLine(Settings.SkeletonThickness, 0.8),
        RightElbowHand = NewLine(Settings.SkeletonThickness, 0.8),
        HipLeftKnee = NewLine(Settings.SkeletonThickness, 0.8),
        LeftKneeFoot = NewLine(Settings.SkeletonThickness, 0.8),
        HipRightKnee = NewLine(Settings.SkeletonThickness, 0.8),
        RightKneeFoot = NewLine(Settings.SkeletonThickness, 0.8),
    }

    ESPCache[Player] = {
        BoxTop   = NewLine(),
        BoxBot   = NewLine(),
        BoxLeft  = NewLine(),
        BoxRight = NewLine(),
        Tracer   = NewLine(1, 0.8),
        Name     = NewText(12),
        Distance = NewText(10),
        HpBg     = NewLine(4, 1),
        HpFill   = NewLine(4, 1),
        Skeleton = SkeletonLines,
        AimLine  = NewLine(2, 0.9),
        LookingText = NewText(13),
        Chams = NewChams(),
    }

    ESPCache[Player].HpBg.Color = Palette.HealthBg
    ESPCache[Player].Distance.Font = 1
    ESPCache[Player].LookingText.Color = Palette.LookingAtYou
end

local function RemoveESP(Player)
    local o = ESPCache[Player]
    if not o then return end

    for _, d in pairs(o) do
        if type(d) == "table" then
            for _, obj in pairs(d) do
                RemoveObject(obj)
            end
        else
            RemoveObject(d)
        end
    end

    ESPCache[Player] = nil
end

local function HideESP(o)
    for _, d in pairs(o) do
        if type(d) == "table" then
            for _, obj in pairs(d) do
                SetObjectVisible(obj, false)
            end
        else
            SetObjectVisible(d, false)
        end
    end
end

local function UpdateChams(Player, o, Char, Col)
    if not o.Chams then return end

    if Settings.ShowChams and Char then
        if o.Chams.Adornee ~= Char then
            o.Chams.Adornee = Char
        end

        o.Chams.FillColor = Col
        o.Chams.OutlineColor = Col
        o.Chams.FillTransparency = Settings.ChamsFillTransparency
        o.Chams.OutlineTransparency = Settings.ChamsOutlineTransparency
        o.Chams.Enabled = true
    else
        o.Chams.Enabled = false
    end
end

-- ========== УЛУЧШЕННАЯ УНИВЕРСАЛЬНАЯ ФУНКЦИЯ СКЕЛЕТА ==========
local function DrawSkeleton(Player, o, Col)
    local Char = Player.Character
    if not Char then return end

    -- Сначала скрываем все кости, чтобы при смене R15/R6 не оставались старые линии
    for _, line in pairs(o.Skeleton) do
        line.Visible = false
    end

    local function GetLimbPos(partName)
        local part = Char:FindFirstChild(partName)
        if part and part:IsA("BasePart") then
            local success, pos, onScreen = pcall(function()
                local p, isOnScreen = Camera:WorldToViewportPoint(part.Position)
                return p, isOnScreen
            end)

            if success and onScreen and pos.Z > 0 then
                return Vector2.new(pos.X, pos.Y), true
            end
        end

        return nil, false
    end

    -- R15 skeleton map
    local skeletonMapR15 = {
        HeadTorso = {"Head", "UpperTorso"},
        TorsoHip = {"UpperTorso", "LowerTorso"},
        TorsoLeftShoulder = {"UpperTorso", "LeftUpperArm"},
        LeftShoulderElbow = {"LeftUpperArm", "LeftLowerArm"},
        LeftElbowHand = {"LeftLowerArm", "LeftHand"},
        TorsoRightShoulder = {"UpperTorso", "RightUpperArm"},
        RightShoulderElbow = {"RightUpperArm", "RightLowerArm"},
        RightElbowHand = {"RightLowerArm", "RightHand"},
        HipLeftKnee = {"LowerTorso", "LeftUpperLeg"},
        LeftKneeFoot = {"LeftUpperLeg", "LeftLowerLeg"},
        HipRightKnee = {"LowerTorso", "RightUpperLeg"},
        RightKneeFoot = {"RightUpperLeg", "RightLowerLeg"},
    }

    -- R6 skeleton map
    local skeletonMapR6 = {
        HeadTorso = {"Head", "Torso"},
        TorsoLeftShoulder = {"Torso", "Left Arm"},
        TorsoRightShoulder = {"Torso", "Right Arm"},
        HipLeftKnee = {"Torso", "Left Leg"},
        HipRightKnee = {"Torso", "Right Leg"},
    }

    -- Определяем тип рига
    local isR15 = Char:FindFirstChild("UpperTorso") ~= nil
    local currentMap = isR15 and skeletonMapR15 or skeletonMapR6

    for lineName, parts in pairs(currentMap) do
        local line = o.Skeleton[lineName]
        if line then
            local pos1, vis1 = GetLimbPos(parts[1])
            local pos2, vis2 = GetLimbPos(parts[2])

            if pos1 and pos2 and vis1 and vis2 then
                line.From = pos1
                line.To = pos2
                line.Color = Col
                line.Thickness = Settings.SkeletonThickness
                line.Visible = true
            else
                line.Visible = false
            end
        end
    end
end

-- ========== УНИВЕРСАЛЬНАЯ ФУНКЦИЯ: НАПРАВЛЕНИЕ ВЗГЛЯДА ==========
local function DrawAimDirection(Player, o, Col)
    if not Settings.ShowAimDir then
        o.AimLine.Visible = false
        return
    end

    local Char = Player.Character
    if not Char then
        o.AimLine.Visible = false
        return
    end

    local head = Char:FindFirstChild("Head")
    if not head or not head:IsA("BasePart") then
        o.AimLine.Visible = false
        return
    end

    local success, result = pcall(function()
        local aimEnd = head.Position + head.CFrame.LookVector * Settings.AimLineLength
        local headScreen, headOn = Camera:WorldToViewportPoint(head.Position)
        local aimScreen, aimOn = Camera:WorldToViewportPoint(aimEnd)

        if headOn and aimOn and headScreen.Z > 0 and aimScreen.Z > 0 then
            o.AimLine.From = Vector2.new(headScreen.X, headScreen.Y)
            o.AimLine.To = Vector2.new(aimScreen.X, aimScreen.Y)
            o.AimLine.Color = Palette.AimDir
            o.AimLine.Visible = true
            return true
        end

        return false
    end)

    if not success or not result then
        o.AimLine.Visible = false
    end
end

for _, p in pairs(Players:GetPlayers()) do CreateESP(p) end
Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(RemoveESP)

-- ========== MAIN LOOP ==========
RunService.RenderStepped:Connect(function()
    Camera = workspace.CurrentCamera
    if not Camera then return end

    for Player, o in pairs(ESPCache) do
        if not Settings.Enabled then
            HideESP(o)
            continue
        end

        -- Проверка существования игрока
        if not Player or not Player.Parent then
            HideESP(o)
            continue
        end

        local Char = Player.Character
        local Root = Char and Char:FindFirstChild("HumanoidRootPart")
        local Hum  = Char and Char:FindFirstChildOfClass("Humanoid")

        if not (Char and Root and Hum and Hum.Health > 0) then
            HideESP(o)
            continue
        end

        -- Безопасная проверка экрана
        local success, SP, OnScreen = pcall(function()
            local pos, onScreen = Camera:WorldToViewportPoint(Root.Position)
            return pos, onScreen
        end)

        if not success or not OnScreen or SP.Z <= 0 then
            HideESP(o)
            continue
        end

        local Dist = (Camera.CFrame.Position - Root.Position).Magnitude

        if Dist > Settings.MaxDistance then
            HideESP(o)
            continue
        end

        if IsTeammate(Player) then
            HideESP(o)
            continue
        end

        -- НОВОЕ: проверка видимости. Видит камера хотя бы одну важную часть игрока = зелёный, иначе красный.
        local IsVisible = false
        pcall(function()
            IsVisible = IsCharacterVisible(Char)
        end)

        local BH  = 4000 / Dist
        local BW  = 2200 / Dist
        local X   = SP.X - BW/2
        local Y   = SP.Y - BH/2
        local Col = GetColor(Player, IsVisible)
        local V2  = Vector2.new

        -- Chams / Highlight ESP
        UpdateChams(Player, o, Char, Col)

        -- Box ESP
        if Settings.ShowBox then
            o.BoxTop.From = V2(X,Y)       ; o.BoxTop.To = V2(X+BW,Y)
            o.BoxBot.From = V2(X,Y+BH)   ; o.BoxBot.To = V2(X+BW,Y+BH)
            o.BoxLeft.From = V2(X,Y)     ; o.BoxLeft.To = V2(X,Y+BH)
            o.BoxRight.From = V2(X+BW,Y) ; o.BoxRight.To = V2(X+BW,Y+BH)
            for _,k in pairs({"BoxTop","BoxBot","BoxLeft","BoxRight"}) do
                o[k].Color = Col
                o[k].Visible = true
            end
        else
            for _,k in pairs({"BoxTop","BoxBot","BoxLeft","BoxRight"}) do
                o[k].Visible = false
            end
        end

        -- Tracer
        o.Tracer.From    = V2(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
        o.Tracer.To      = V2(SP.X, SP.Y)
        o.Tracer.Color   = Col
        o.Tracer.Visible = Settings.ShowTracer

        -- Name
        o.Name.Text     = Player.Name
        o.Name.Position = V2(SP.X, Y - 15)
        o.Name.Color    = Col
        o.Name.Visible  = Settings.ShowName

        -- Distance
        o.Distance.Text     = math.floor(Dist) .. "m"
        o.Distance.Position = V2(SP.X, Y + BH + 4)
        o.Distance.Color    = Color3.fromRGB(200, 200, 200)
        o.Distance.Visible  = Settings.ShowDistance

        -- Health Bar
        if Settings.ShowHealth then
            local pct = math.clamp(Hum.Health / Hum.MaxHealth, 0, 1)
            local barX = X - 6
            local barHeight = BH

            o.HpBg.From      = V2(barX, Y)
            o.HpBg.To        = V2(barX, Y + barHeight)
            o.HpBg.Visible   = true

            local fillHeight = barHeight * pct
            o.HpFill.From    = V2(barX, Y + barHeight)
            o.HpFill.To      = V2(barX, Y + barHeight - fillHeight)
            o.HpFill.Color   = GetHealthColor(Hum.Health, Hum.MaxHealth)
            o.HpFill.Visible = true
        else
            o.HpBg.Visible   = false
            o.HpFill.Visible = false
        end

        -- Skeleton ESP
        if Settings.ShowSkeleton then
            pcall(function() DrawSkeleton(Player, o, Col) end)
        else
            for _, line in pairs(o.Skeleton) do
                line.Visible = false
            end
        end

        -- Направление взгляда
        if Settings.ShowAimDir then
            pcall(function() DrawAimDirection(Player, o, Col) end)
        else
            o.AimLine.Visible = false
        end

        -- Предупреждение "Смотрит на тебя"
        if Settings.ShowLookingAtYou then
            local successLook, isLooking = pcall(function() return IsLookingAtYou(Char) end)
            if successLook and isLooking then
                o.LookingText.Text = "[!] СМОТРИТ НА ТЕБЯ"
                o.LookingText.Position = V2(SP.X, Y - 35)
                o.LookingText.Visible = true
            else
                o.LookingText.Visible = false
            end
        else
            o.LookingText.Visible = false
        end
    end
end)

print("✅ Universal ESP Script [ENHANCED v3] loaded | RightShift = menu")
print("🟢 Видимые противники = зелёные | 🔴 Не видимые = красные")
print("✨ Chams / Highlight ESP добавлены без привязки к PlaceId")
print("🚫 Rayfield рекламный prompt отключён")
