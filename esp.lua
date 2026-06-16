--[[
    Universal ESP Script - УЛУЧШЕННАЯ ВЕРСИЯ v4
    Работает во ВСЕХ Roblox играх

    Изменения v4:
    - Видимые противники = зелёные
    - Невидимые/закрытые стеной противники = красные
    - Добавлены универсальные Chams / Highlight без привязки к PlaceId
    - Отключён рекламный Rayfield prompt: "Rayfield Interface ... sirius.menu/discord"
    - Исправлены HTML-сущности &gt; / &lt; на обычные > / <
    - Починена загрузка/сохранение настроек Rayfield через Rayfield:LoadConfiguration()
    - Добавлены TP к игрокам, сохранение точки, TP на сохранённую точку
    - Добавлены Infinite Jump, SpeedHack, Noclip

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
local MovementTab = Window:CreateTab("Movement / TP", 4483362458)
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

    -- Movement / TP настройки
    SpeedHack = false,
    WalkSpeed = 32,
    InfiniteJump = false,
    Noclip = false,
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


-- ========== SMALL HELPERS ==========
local function ClampNumber(value, minValue, maxValue, fallback)
    local n = tonumber(value)
    if not n then return fallback end
    if math.clamp then
        return math.clamp(n, minValue, maxValue)
    end
    return math.max(minValue, math.min(maxValue, n))
end

local function Notify(title, content, duration)
    pcall(function()
        Rayfield:Notify({
            Title = tostring(title or "Universal ESP"),
            Content = tostring(content or ""),
            Duration = duration or 4,
            Image = 4483362458,
        })
    end)
    print("[Universal ESP] " .. tostring(title) .. " | " .. tostring(content))
end

-- ========== MOVEMENT / TP HELPERS ==========
local NO_PLAYERS_TEXT = "Нет игроков"
local SelectedTeleportPlayer = nil
local SavedCFrame = nil
local PlayerDropdown = nil
local OriginalWalkSpeeds = {}
local OriginalCollisions = {}

local function GetCharacterRoot(char)
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
        or char:FindFirstChild("Torso")
        or char:FindFirstChild("UpperTorso")
end

local function GetLocalRoot()
    return GetCharacterRoot(LP.Character)
end

local function GetLocalHumanoid()
    return LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") or nil
end

local function GetPlayerNames()
    local names = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LP then
            table.insert(names, player.Name)
        end
    end
    table.sort(names)
    if #names == 0 then
        table.insert(names, NO_PLAYERS_TEXT)
    end
    return names
end

local function RefreshPlayerDropdown()
    if not PlayerDropdown then return end

    local options = GetPlayerNames()

    pcall(function()
        PlayerDropdown:Refresh(options)
    end)

    if options[1] == NO_PLAYERS_TEXT then
        SelectedTeleportPlayer = nil
        pcall(function() PlayerDropdown:Set({NO_PLAYERS_TEXT}) end)
        return
    end

    if not SelectedTeleportPlayer or not Players:FindFirstChild(SelectedTeleportPlayer) then
        SelectedTeleportPlayer = options[1]
        pcall(function() PlayerDropdown:Set({SelectedTeleportPlayer}) end)
    end
end

local function TeleportToCFrame(cf)
    local root = GetLocalRoot()
    if not root or not cf then
        Notify("TP", "Не найден HumanoidRootPart / точка телепорта", 3)
        return false
    end

    pcall(function()
        root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
    end)

    root.CFrame = cf
    return true
end

local function TeleportToSelectedPlayer()
    if not SelectedTeleportPlayer or SelectedTeleportPlayer == NO_PLAYERS_TEXT then
        Notify("TP к игроку", "Сначала выбери игрока в списке", 3)
        return
    end

    local target = Players:FindFirstChild(SelectedTeleportPlayer)
    local targetRoot = target and GetCharacterRoot(target.Character)

    if not targetRoot then
        Notify("TP к игроку", "Игрок не найден или ещё не заспавнился", 3)
        RefreshPlayerDropdown()
        return
    end

    -- Телепорт чуть выше и сзади выбранного игрока, чтобы не застревать в нём
    if TeleportToCFrame(targetRoot.CFrame * CFrame.new(0, 3, 4)) then
        Notify("TP к игроку", "Телепорт к " .. target.Name, 3)
    end
end

local function SaveCurrentPlace()
    local root = GetLocalRoot()
    if not root then
        Notify("Сохранить место", "Не найден HumanoidRootPart", 3)
        return
    end

    SavedCFrame = root.CFrame
    Notify("Сохранить место", "Точка сохранена", 3)
end

local function TeleportToSavedPlace()
    if not SavedCFrame then
        Notify("TP на точку", "Сначала нажми 'Сохранить место'", 3)
        return
    end

    if TeleportToCFrame(SavedCFrame) then
        Notify("TP на точку", "Телепорт выполнен", 3)
    end
end

local function ApplyWalkSpeed()
    local hum = GetLocalHumanoid()
    if not hum then return end

    if OriginalWalkSpeeds[hum] == nil then
        OriginalWalkSpeeds[hum] = hum.WalkSpeed
    end

    if Settings.SpeedHack then
        hum.WalkSpeed = ClampNumber(Settings.WalkSpeed, 16, 250, 32)
    else
        hum.WalkSpeed = OriginalWalkSpeeds[hum] or 16
        OriginalWalkSpeeds[hum] = nil
    end
end

local function ApplyNoclip()
    if not Settings.Noclip then return end
    if not LP.Character then return end

    for _, obj in ipairs(LP.Character:GetDescendants()) do
        if obj:IsA("BasePart") then
            if OriginalCollisions[obj] == nil then
                OriginalCollisions[obj] = obj.CanCollide
            end
            obj.CanCollide = false
        end
    end
end

local function RestoreCollisions()
    for part, oldValue in pairs(OriginalCollisions) do
        if part and part.Parent then
            pcall(function()
                part.CanCollide = oldValue
            end)
        end
    end
    table.clear(OriginalCollisions)
end

UIS.JumpRequest:Connect(function()
    if not Settings.InfiniteJump then return end

    local hum = GetLocalHumanoid()
    if hum then
        pcall(function()
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end)
        hum.Jump = true
    end
end)

RunService.Stepped:Connect(function()
    if Settings.SpeedHack then
        ApplyWalkSpeed()
    end

    if Settings.Noclip then
        ApplyNoclip()
    end
end)

LP.CharacterAdded:Connect(function()
    table.clear(OriginalWalkSpeeds)
    RestoreCollisions()
    task.wait(0.8)
    if Settings.SpeedHack then
        ApplyWalkSpeed()
    end
end)

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
    Callback     = function(v)
        Settings.MaxDistance = ClampNumber(v, 100, 3000, Settings.MaxDistance)
        print("MaxDistance:", Settings.MaxDistance)
    end,
})

-- Если в твоём executor'е Rayfield-ползунки багуются, можно выставить дистанцию вручную здесь.
ESPTab:CreateInput({
    Name = "Макс. дистанция вручную",
    CurrentValue = tostring(Settings.MaxDistance),
    PlaceholderText = "Например: 1500",
    RemoveTextAfterFocusLost = false,
    Callback = function(txt)
        Settings.MaxDistance = ClampNumber(txt, 100, 3000, Settings.MaxDistance)
        Notify("MaxDistance", "Установлено: " .. tostring(Settings.MaxDistance), 3)
    end,
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
    Callback     = function(v)
        Settings.AimLineLength = ClampNumber(v, 5, 50, Settings.AimLineLength)
    end,
})

ExtraTab:CreateInput({
    Name = "Длина AIM DIR вручную",
    CurrentValue = tostring(Settings.AimLineLength),
    PlaceholderText = "Например: 15",
    RemoveTextAfterFocusLost = false,
    Callback = function(txt)
        Settings.AimLineLength = ClampNumber(txt, 5, 50, Settings.AimLineLength)
        Notify("AimLineLength", "Установлено: " .. tostring(Settings.AimLineLength), 3)
    end,
})

ExtraTab:CreateSlider({
    Name         = "Толщина скелета",
    Range        = {1, 5},
    Increment    = 1,
    Suffix       = "px",
    CurrentValue = Settings.SkeletonThickness,
    Flag         = "SkeletonThickness",
    Callback     = function(v)
        Settings.SkeletonThickness = ClampNumber(v, 1, 5, Settings.SkeletonThickness)
    end,
})

ExtraTab:CreateInput({
    Name = "Толщина скелета вручную",
    CurrentValue = tostring(Settings.SkeletonThickness),
    PlaceholderText = "1-5",
    RemoveTextAfterFocusLost = false,
    Callback = function(txt)
        Settings.SkeletonThickness = ClampNumber(txt, 1, 5, Settings.SkeletonThickness)
        Notify("SkeletonThickness", "Установлено: " .. tostring(Settings.SkeletonThickness), 3)
    end,
})

-- ========== MOVEMENT / TP TAB ==========
local initialPlayerOptions = GetPlayerNames()
if initialPlayerOptions[1] ~= NO_PLAYERS_TEXT then
    SelectedTeleportPlayer = initialPlayerOptions[1]
end

PlayerDropdown = MovementTab:CreateDropdown({
    Name = "Игрок для TP",
    Options = initialPlayerOptions,
    CurrentOption = {initialPlayerOptions[1]},
    MultipleOptions = false,
    Callback = function(option)
        local selected = option
        if type(option) == "table" then
            selected = option[1]
        end

        if selected and selected ~= NO_PLAYERS_TEXT then
            SelectedTeleportPlayer = selected
            print("Выбран игрок для TP:", selected)
        else
            SelectedTeleportPlayer = nil
        end
    end,
})

MovementTab:CreateButton({
    Name = "🔄 Обновить список игроков",
    Callback = function()
        RefreshPlayerDropdown()
        Notify("Список игроков", "Обновлён", 2)
    end,
})

MovementTab:CreateButton({
    Name = "➡️ TP к выбранному игроку",
    Callback = function()
        TeleportToSelectedPlayer()
    end,
})

MovementTab:CreateDivider()

MovementTab:CreateButton({
    Name = "💾 Сохранить место",
    Callback = function()
        SaveCurrentPlace()
    end,
})

MovementTab:CreateButton({
    Name = "📍 TP на сохранённое место",
    Callback = function()
        TeleportToSavedPlace()
    end,
})

MovementTab:CreateDivider()

MovementTab:CreateToggle({
    Name = "♾️ Бесконечный прыжок",
    CurrentValue = Settings.InfiniteJump,
    Flag = "InfiniteJump",
    Callback = function(v)
        Settings.InfiniteJump = v
        Notify("Infinite Jump", v and "ВКЛ" or "ВЫКЛ", 2)
    end,
})

local SpeedToggle = MovementTab:CreateToggle({
    Name = "🏃 SpeedHack",
    CurrentValue = Settings.SpeedHack,
    Flag = "SpeedHack",
    Callback = function(v)
        Settings.SpeedHack = v
        ApplyWalkSpeed()
        Notify("SpeedHack", v and ("ВКЛ: " .. tostring(Settings.WalkSpeed)) or "ВЫКЛ", 2)
    end,
})

MovementTab:CreateSlider({
    Name = "Скорость WalkSpeed",
    Range = {16, 250},
    Increment = 1,
    Suffix = "WS",
    CurrentValue = Settings.WalkSpeed,
    Flag = "WalkSpeed",
    Callback = function(v)
        Settings.WalkSpeed = ClampNumber(v, 16, 250, Settings.WalkSpeed)
        ApplyWalkSpeed()
        print("WalkSpeed:", Settings.WalkSpeed)
    end,
})

-- Дубль через ручной ввод — на случай если Rayfield-ползунок в executor'е не двигается.
MovementTab:CreateInput({
    Name = "Скорость вручную",
    CurrentValue = tostring(Settings.WalkSpeed),
    PlaceholderText = "Например: 50",
    RemoveTextAfterFocusLost = false,
    Callback = function(txt)
        Settings.WalkSpeed = ClampNumber(txt, 16, 250, Settings.WalkSpeed)
        ApplyWalkSpeed()
        Notify("WalkSpeed", "Установлено: " .. tostring(Settings.WalkSpeed), 3)
    end,
})

MovementTab:CreateButton({
    Name = "Скорость 16 / Reset",
    Callback = function()
        Settings.WalkSpeed = 16
        table.clear(OriginalWalkSpeeds)
        local hum = GetLocalHumanoid()
        if hum then hum.WalkSpeed = 16 end

        if SpeedToggle and SpeedToggle.Set then
            SpeedToggle:Set(false)
        else
            Settings.SpeedHack = false
            ApplyWalkSpeed()
        end

        Notify("WalkSpeed", "Сброшено на 16", 2)
    end,
})

MovementTab:CreateButton({
    Name = "Скорость 50",
    Callback = function()
        Settings.WalkSpeed = 50

        if SpeedToggle and SpeedToggle.Set then
            SpeedToggle:Set(true)
        else
            Settings.SpeedHack = true
            ApplyWalkSpeed()
        end

        Notify("WalkSpeed", "Установлено 50", 2)
    end,
})

MovementTab:CreateButton({
    Name = "Скорость 100",
    Callback = function()
        Settings.WalkSpeed = 100

        if SpeedToggle and SpeedToggle.Set then
            SpeedToggle:Set(true)
        else
            Settings.SpeedHack = true
            ApplyWalkSpeed()
        end

        Notify("WalkSpeed", "Установлено 100", 2)
    end,
})

MovementTab:CreateToggle({
    Name = "🚪 Noclip",
    CurrentValue = Settings.Noclip,
    Flag = "Noclip",
    Callback = function(v)
        Settings.Noclip = v
        if not v then
            RestoreCollisions()
        end
        Notify("Noclip", v and "ВКЛ" or "ВЫКЛ", 2)
    end,
})

-- ========== INFO TAB ==========
InfoTab:CreateParagraph({
    Title   = "Universal ESP Script [ENHANCED v4]",
    Content = "Работает во ВСЕХ Roblox играх!\n\n🆕 ДОБАВЛЕНО:\n• Видимый противник = зелёный\n• Не видимый/за стеной = красный\n• Универсальные Chams / Highlight без game.PlaceId\n• Отключён Rayfield рекламный prompt\n• TP к игрокам / TP на сохранённую точку\n• Infinite Jump / SpeedHack / Noclip\n\nОСНОВНЫЕ ФУНКЦИИ:\n• Box ESP\n• Chams ESP\n• Skeleton ESP\n• Tracers\n• Имя, HP, Дистанция\n• Team Check\n\nУПРАВЛЕНИЕ:\n• RightShift — открыть/закрыть меню"
})

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
Players.PlayerAdded:Connect(function(p)
    CreateESP(p)
    task.defer(RefreshPlayerDropdown)
end)
Players.PlayerRemoving:Connect(function(p)
    RemoveESP(p)
    task.defer(RefreshPlayerDropdown)
end)

-- Загружаем сохранённые настройки Rayfield после создания всех элементов UI.
-- Это также фиксит ситуацию, когда ползунки/переключатели визуально менялись, но после перезапуска значения сбрасывались.
pcall(function()
    Rayfield:LoadConfiguration()
end)

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

print("✅ Universal ESP Script [ENHANCED v4] loaded | RightShift = menu")
print("🟢 Видимые противники = зелёные | 🔴 Не видимые = красные")
print("✨ Chams / Highlight ESP добавлены без привязки к PlaceId")
print("🚫 Rayfield рекламный prompt отключён")
print("🧭 Movement / TP: TP к игрокам, save point TP, Infinite Jump, speed hack,noclip")
