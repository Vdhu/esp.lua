--[[
    Universal ESP Script - ENHANCED v5
    Работает во ВСЕХ Roblox играх

    ИЗМЕНЕНИЯ v5:
    - Исправлены ползунки ESP (tonumber)
    - Исправлен Ноуклип (RenderStepped + полная обработка)
    - Меню заменено: Orion вместо Rayfield (без лагов при открытии)
    - Исправлен дубль ников в вкладке ТП
    - Добавлен FPS Booster (4 уровня + reset)
    - Бесконечный прыжок, СПИДхак, Ноуклип, ТП, Сохранение позиции

    Open Menu: RightShift
]]

if not game:IsLoaded() then game.Loaded:Wait() end

-- ========== ORION UI (легче, без лагов при открытии) ==========
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()

local Window = OrionLib:MakeWindow({
    Name = "Universal ESP v5",
    HidePremium = true,
    SaveConfig = true,
    ConfigFolder = "UniversalESP_v5",
    IntroEnabled = false,
    IntroText = "Universal ESP v5",
    IntroIcon = "rbxassetid://4483362458",
    -- Открывать/закрывать на RightShift
    ToggleKey = Enum.KeyCode.RightShift,
})

-- ========== ВКЛАДКИ ==========
local ESPTab   = Window:MakeTab({ Name = "ESP",       Icon = "rbxassetid://4483362458", PremiumOnly = false })
local TPTab    = Window:MakeTab({ Name = "Teleport",  Icon = "rbxassetid://4483362458", PremiumOnly = false })
local CheatTab = Window:MakeTab({ Name = "Cheats",    Icon = "rbxassetid://4483362458", PremiumOnly = false })
local FPSTab   = Window:MakeTab({ Name = "FPS Boost", Icon = "rbxassetid://4483362458", PremiumOnly = false })
local InfoTab  = Window:MakeTab({ Name = "Info",      Icon = "rbxassetid://4483362458", PremiumOnly = false })

-- ========== SERVICES ==========
local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS        = game:GetService("UserInputService")
local Lighting   = game:GetService("Lighting")
local LP         = Players.LocalPlayer
local Camera     = workspace.CurrentCamera

-- ========== ESP SETTINGS ==========
local Settings = {
    Enabled      = true,
    TeamCheck    = true,
    ShowBox      = true,
    ShowTracer   = true,
    ShowName     = true,
    ShowHealth   = true,
    ShowDistance = true,
    ShowSkeleton = true,
    ShowChams    = true,
    ShowAimDir   = false,
    ShowLookingAtYou = false,
    MaxDistance  = 1500,
    VisibleColor = Color3.fromRGB(50, 255, 80),
    HiddenColor  = Color3.fromRGB(255, 50, 50),
    TeamColor    = Color3.fromRGB(50, 150, 255),
    SkeletonThickness = 2,
    AimLineLength = 15,
    ChamsFillTransparency    = 0.45,
    ChamsOutlineTransparency = 0,
}

-- ========== CHEAT SETTINGS ==========
local CheatSettings = {
    InfiniteJump  = false,
    Noclip        = false,
    SpeedEnabled  = false,
    SpeedValue    = 16,
    SavedPosition = nil,
}

-- ========== FPS SETTINGS (сохранение оригиналов) ==========
local FPSOriginal = {
    Quality          = Enum.QualityLevel.Automatic,
    ShadowMap        = Lighting.GlobalShadows,
    Ambient          = Lighting.Ambient,
    OutdoorAmbient   = Lighting.OutdoorAmbient,
    FogEnd           = Lighting.FogEnd,
    -- rendering
    MeshDetail       = nil,
    Saved            = false,
}

local function SaveOriginalGraphics()
    if FPSOriginal.Saved then return end
    FPSOriginal.Quality        = settings().Rendering.QualityLevel
    FPSOriginal.ShadowMap      = Lighting.GlobalShadows
    FPSOriginal.Ambient        = Lighting.Ambient
    FPSOriginal.OutdoorAmbient = Lighting.OutdoorAmbient
    FPSOriginal.FogEnd         = Lighting.FogEnd
    FPSOriginal.Saved          = true
end

-- ========== PALETTE ==========
local Palette = {
    HealthHigh   = Color3.fromRGB(0, 255, 0),
    HealthMid    = Color3.fromRGB(255, 255, 0),
    HealthLow    = Color3.fromRGB(255, 0, 0),
    HealthBg     = Color3.fromRGB(40, 40, 40),
    LookingAtYou = Color3.fromRGB(255, 255, 0),
    AimDir       = Color3.fromRGB(255, 150, 0),
}

-- ========== CHAMS FOLDER ==========
local ChamsFolder = Instance.new("Folder")
ChamsFolder.Name  = "UniversalESP_Chams"
pcall(function()
    local CG  = game:GetService("CoreGui")
    local old = CG:FindFirstChild(ChamsFolder.Name)
    if old then old:Destroy() end
    ChamsFolder.Parent = CG
end)
if not ChamsFolder.Parent then
    pcall(function()
        local pg  = LP:WaitForChild("PlayerGui")
        local old = pg:FindFirstChild(ChamsFolder.Name)
        if old then old:Destroy() end
        ChamsFolder.Parent = pg
    end)
end
if not ChamsFolder.Parent then ChamsFolder.Parent = workspace end

-- ===================================================
-- =================== ESP TAB =======================
-- ===================================================

ESPTab:AddToggle({
    Name    = "Включить ESP",
    Default = Settings.Enabled,
    Save    = true,
    Flag    = "ESP_Enabled",
    Callback = function(v) Settings.Enabled = v end,
})

ESPTab:AddToggle({
    Name    = "Team Check (скрыть союзников)",
    Default = Settings.TeamCheck,
    Save    = true,
    Flag    = "TeamCheck",
    Callback = function(v) Settings.TeamCheck = v end,
})

ESPTab:AddDivider()

ESPTab:AddToggle({
    Name    = "Box ESP",
    Default = Settings.ShowBox,
    Save    = true, Flag = "BoxESP",
    Callback = function(v) Settings.ShowBox = v end,
})

ESPTab:AddToggle({
    Name    = "Tracers",
    Default = Settings.ShowTracer,
    Save    = true, Flag = "Tracers",
    Callback = function(v) Settings.ShowTracer = v end,
})

ESPTab:AddToggle({
    Name    = "Skeleton ESP",
    Default = Settings.ShowSkeleton,
    Save    = true, Flag = "SkeletonESP",
    Callback = function(v) Settings.ShowSkeleton = v end,
})

ESPTab:AddToggle({
    Name    = "Chams / Highlight ESP",
    Default = Settings.ShowChams,
    Save    = true, Flag = "ChamsESP",
    Callback = function(v) Settings.ShowChams = v end,
})

ESPTab:AddToggle({
    Name    = "Имя игрока",
    Default = Settings.ShowName,
    Save    = true, Flag = "NameESP",
    Callback = function(v) Settings.ShowName = v end,
})

ESPTab:AddToggle({
    Name    = "Полоска здоровья",
    Default = Settings.ShowHealth,
    Save    = true, Flag = "HealthESP",
    Callback = function(v) Settings.ShowHealth = v end,
})

ESPTab:AddToggle({
    Name    = "Дистанция",
    Default = Settings.ShowDistance,
    Save    = true, Flag = "DistanceESP",
    Callback = function(v) Settings.ShowDistance = v end,
})

ESPTab:AddToggle({
    Name    = "AIM DIR (направление взгляда)",
    Default = Settings.ShowAimDir,
    Save    = true, Flag = "AimDir",
    Callback = function(v) Settings.ShowAimDir = v end,
})

ESPTab:AddToggle({
    Name    = "Предупреждение 'Смотрит на тебя'",
    Default = Settings.ShowLookingAtYou,
    Save    = true, Flag = "LookingAtYou",
    Callback = function(v) Settings.ShowLookingAtYou = v end,
})

ESPTab:AddDivider()

-- ИСПРАВЛЕННЫЕ ПОЛЗУНКИ --
ESPTab:AddSlider({
    Name    = "Максимальная дистанция ESP",
    Min     = 100,
    Max     = 3000,
    Default = Settings.MaxDistance,
    Color   = Color3.fromRGB(255,255,255),
    Increment = 50,
    ValueName = "studs",
    Callback  = function(v)
        Settings.MaxDistance = tonumber(v) or 1500
    end,
})

ESPTab:AddSlider({
    Name    = "Толщина скелета",
    Min     = 1,
    Max     = 5,
    Default = Settings.SkeletonThickness,
    Color   = Color3.fromRGB(255,255,255),
    Increment = 1,
    ValueName = "px",
    Callback  = function(v)
        Settings.SkeletonThickness = tonumber(v) or 2
    end,
})

ESPTab:AddSlider({
    Name    = "Длина линии взгляда",
    Min     = 5,
    Max     = 50,
    Default = Settings.AimLineLength,
    Color   = Color3.fromRGB(255,255,255),
    Increment = 1,
    ValueName = "studs",
    Callback  = function(v)
        Settings.AimLineLength = tonumber(v) or 15
    end,
})

ESPTab:AddSlider({
    Name    = "Прозрачность заливки Chams",
    Min     = 0,
    Max     = 100,
    Default = math.floor(Settings.ChamsFillTransparency * 100),
    Color   = Color3.fromRGB(255,255,255),
    Increment = 5,
    ValueName = "%",
    Callback  = function(v)
        Settings.ChamsFillTransparency = (tonumber(v) or 45) / 100
    end,
})

ESPTab:AddSlider({
    Name    = "Прозрачность обводки Chams",
    Min     = 0,
    Max     = 100,
    Default = math.floor(Settings.ChamsOutlineTransparency * 100),
    Color   = Color3.fromRGB(255,255,255),
    Increment = 5,
    ValueName = "%",
    Callback  = function(v)
        Settings.ChamsOutlineTransparency = (tonumber(v) or 0) / 100
    end,
})

-- ===================================================
-- ================ TELEPORT TAB =====================
-- ===================================================

-- ИСПРАВЛЕНИЕ: убираем CreateSection/Label перед кнопками,
-- чтобы ники не дублировались. Только кнопка обновить + кнопки ТП.

local tpButtons = {}

local function ClearTPButtons()
    for _, b in pairs(tpButtons) do
        pcall(function() b:Destroy() end)
    end
    tpButtons = {}
end

local function BuildTPButtons()
    ClearTPButtons()
    local playerList = Players:GetPlayers()
    local added = 0
    for _, player in pairs(playerList) do
        if player ~= LP then
            local btn = TPTab:AddButton({
                Name = "🌀 ТП к: " .. player.Name,
                Callback = function()
                    local char  = LP.Character
                    local root  = char  and char:FindFirstChild("HumanoidRootPart")
                    local tChar = player.Character
                    local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
                    if root and tRoot then
                        root.CFrame = tRoot.CFrame + Vector3.new(0, 3, 0)
                        OrionLib:MakeNotification({
                            Name    = "Телепорт",
                            Content = "ТП к " .. player.Name .. " выполнен!",
                            Image   = "rbxassetid://4483362458",
                            Time    = 3,
                        })
                    else
                        OrionLib:MakeNotification({
                            Name    = "Ошибка",
                            Content = player.Name .. " — персонаж не найден.",
                            Image   = "rbxassetid://4483362458",
                            Time    = 3,
                        })
                    end
                end,
            })
            table.insert(tpButtons, btn)
            added = added + 1
        end
    end
    if added == 0 then
        local lbl = TPTab:AddLabel("— Нет других игроков на сервере —")
        table.insert(tpButtons, lbl)
    end
end

TPTab:AddButton({
    Name = "🔄 Обновить список игроков",
    Callback = function()
        BuildTPButtons()
        OrionLib:MakeNotification({
            Name    = "Список обновлён",
            Content = "Список игроков обновлён.",
            Image   = "rbxassetid://4483362458",
            Time    = 2,
        })
    end,
})

BuildTPButtons()

TPTab:AddDivider()

-- Сохранение позиции
TPTab:AddButton({
    Name = "📍 Сохранить текущее место",
    Callback = function()
        local char = LP.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            CheatSettings.SavedPosition = root.CFrame
            OrionLib:MakeNotification({
                Name    = "📍 Место сохранено",
                Content = "Позиция запомнена. Используй кнопку ниже для возврата.",
                Image   = "rbxassetid://4483362458",
                Time    = 3,
            })
        else
            OrionLib:MakeNotification({
                Name    = "Ошибка",
                Content = "Персонаж не найден!",
                Image   = "rbxassetid://4483362458",
                Time    = 3,
            })
        end
    end,
})

TPTab:AddButton({
    Name = "🔙 ТП на сохранённое место",
    Callback = function()
        if not CheatSettings.SavedPosition then
            OrionLib:MakeNotification({
                Name    = "Ошибка",
                Content = "Сначала сохрани место кнопкой выше!",
                Image   = "rbxassetid://4483362458",
                Time    = 3,
            })
            return
        end
        local char = LP.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            root.CFrame = CheatSettings.SavedPosition
            OrionLib:MakeNotification({
                Name    = "🔙 Телепортировано",
                Content = "Вернулся на сохранённое место!",
                Image   = "rbxassetid://4483362458",
                Time    = 3,
            })
        else
            OrionLib:MakeNotification({
                Name    = "Ошибка",
                Content = "Персонаж не найден!",
                Image   = "rbxassetid://4483362458",
                Time    = 3,
            })
        end
    end,
})

-- ===================================================
-- ================= CHEATS TAB ======================
-- ===================================================

-- БЕСКОНЕЧНЫЙ ПРЫЖОК
CheatTab:AddToggle({
    Name    = "🐇 Бесконечный прыжок",
    Default = false,
    Save    = false,
    Flag    = "InfJump",
    Callback = function(v)
        CheatSettings.InfiniteJump = v
        OrionLib:MakeNotification({
            Name    = "Бесконечный прыжок",
            Content = v and "ВКЛЮЧЁН ✅" or "ВЫКЛЮЧЕН ❌",
            Image   = "rbxassetid://4483362458",
            Time    = 2,
        })
    end,
})

-- СПИДХАК ТОГГЛ
CheatTab:AddToggle({
    Name    = "⚡ СПИДхак (SpeedHack)",
    Default = false,
    Save    = false,
    Flag    = "SpeedHack",
    Callback = function(v)
        CheatSettings.SpeedEnabled = v
        local char = LP.Character
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = v and CheatSettings.SpeedValue or 16
        end
        OrionLib:MakeNotification({
            Name    = "СПИДхак",
            Content = v and ("ВКЛЮЧЁН ✅ | Скорость: " .. CheatSettings.SpeedValue) or "ВЫКЛЮЧЕН ❌",
            Image   = "rbxassetid://4483362458",
            Time    = 2,
        })
    end,
})

-- СПИДХАК СЛАЙДЕР
CheatTab:AddSlider({
    Name      = "⚡ Скорость (WalkSpeed)",
    Min       = 16,
    Max       = 300,
    Default   = 16,
    Color     = Color3.fromRGB(255,255,255),
    Increment = 1,
    ValueName = "sp",
    Callback  = function(v)
        CheatSettings.SpeedValue = tonumber(v) or 16
        if CheatSettings.SpeedEnabled then
            local char = LP.Character
            local hum  = char and char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = CheatSettings.SpeedValue end
        end
    end,
})

CheatTab:AddDivider()

-- НОУКЛИП (исправленный)
CheatTab:AddToggle({
    Name    = "👻 Ноуклип (Noclip)",
    Default = false,
    Save    = false,
    Flag    = "Noclip",
    Callback = function(v)
        CheatSettings.Noclip = v
        if not v then
            -- восстанавливаем коллизии немедленно
            local char = LP.Character
            if char then
                for _, p in pairs(char:GetDescendants()) do
                    if p:IsA("BasePart") then
                        p.CanCollide = true
                    end
                end
            end
        end
        OrionLib:MakeNotification({
            Name    = "Ноуклип",
            Content = v and "ВКЛЮЧЁН ✅ — проходишь сквозь стены!" or "ВЫКЛЮЧЕН ❌ — коллизии восстановлены",
            Image   = "rbxassetid://4483362458",
            Time    = 2,
        })
    end,
})

-- ===================================================
-- ================ FPS BOOST TAB ====================
-- ===================================================

FPSTab:AddLabel("Выбери уровень буста FPS. Для возврата нажми Reset.")

FPSTab:AddDivider()

-- УРОВЕНЬ 1: лёгкий
FPSTab:AddButton({
    Name = "🟢 Boost Low — Лёгкий (+10-20 FPS)",
    Callback = function()
        SaveOriginalGraphics()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level05
        Lighting.GlobalShadows   = true
        Lighting.FogEnd          = 100000
        OrionLib:MakeNotification({
            Name    = "FPS Boost: Low",
            Content = "Лёгкое снижение качества. +10-20 FPS",
            Image   = "rbxassetid://4483362458",
            Time    = 3,
        })
    end,
})

-- УРОВЕНЬ 2: средний
FPSTab:AddButton({
    Name = "🔵 Boost Medium — Средний (+20-40 FPS)",
    Callback = function()
        SaveOriginalGraphics()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level03
        Lighting.GlobalShadows   = false
        Lighting.FogEnd          = 100000
        Lighting.Ambient         = Color3.fromRGB(140,140,140)
        OrionLib:MakeNotification({
            Name    = "FPS Boost: Medium",
            Content = "Тени отключены. Среднее снижение. +20-40 FPS",
            Image   = "rbxassetid://4483362458",
            Time    = 3,
        })
    end,
})

-- УРОВЕНЬ 3: сильный
FPSTab:AddButton({
    Name = "🟡 Boost High — Сильный (+40-60 FPS)",
    Callback = function()
        SaveOriginalGraphics()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        Lighting.GlobalShadows   = false
        Lighting.FogEnd          = 100000
        Lighting.Ambient         = Color3.fromRGB(178,178,178)
        Lighting.OutdoorAmbient  = Color3.fromRGB(178,178,178)
        -- Отключаем постэффекты Lighting
        for _, effect in pairs(Lighting:GetChildren()) do
            if effect:IsA("PostEffect") then
                effect.Enabled = false
            end
        end
        OrionLib:MakeNotification({
            Name    = "FPS Boost: High",
            Content = "Тени + постэффекты отключены. +40-60 FPS",
            Image   = "rbxassetid://4483362458",
            Time    = 3,
        })
    end,
})

-- УРОВЕНЬ 4: максимальный
FPSTab:AddButton({
    Name = "🔴 Boost Ultra — Максимальный (+60+ FPS)",
    Callback = function()
        SaveOriginalGraphics()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        Lighting.GlobalShadows   = false
        Lighting.FogEnd          = 100000
        Lighting.FogStart        = 99999
        Lighting.Ambient         = Color3.fromRGB(200,200,200)
        Lighting.OutdoorAmbient  = Color3.fromRGB(200,200,200)
        -- Отключаем все постэффекты
        for _, effect in pairs(Lighting:GetChildren()) do
            if effect:IsA("PostEffect") then
                effect.Enabled = false
            end
        end
        -- Упрощаем детализацию частиц через workspace
        workspace.StreamingEnabled = pcall(function()
            workspace.StreamingEnabled = true
        end)
        -- Ставим минимальный рендер-дистанс
        pcall(function()
            settings().Rendering.EagerBulkExecution = true
        end)
        OrionLib:MakeNotification({
            Name    = "FPS Boost: ULTRA",
            Content = "Максимальный буст! Графика снижена до минимума. +60+ FPS",
            Image   = "rbxassetid://4483362458",
            Time    = 4,
        })
    end,
})

FPSTab:AddDivider()

-- ВОССТАНОВЛЕНИЕ
FPSTab:AddButton({
    Name = "🔮 Восстановить графику (Reset)",
    Callback = function()
        if not FPSOriginal.Saved then
            OrionLib:MakeNotification({
                Name    = "Reset",
                Content = "Буст не был применён — нечего сбрасывать.",
                Image   = "rbxassetid://4483362458",
                Time    = 3,
            })
            return
        end
        settings().Rendering.QualityLevel = FPSOriginal.Quality
        Lighting.GlobalShadows   = FPSOriginal.ShadowMap
        Lighting.Ambient         = FPSOriginal.Ambient
        Lighting.OutdoorAmbient  = FPSOriginal.OutdoorAmbient
        Lighting.FogEnd          = FPSOriginal.FogEnd
        -- Включаем постэффекты обратно
        for _, effect in pairs(Lighting:GetChildren()) do
            если эффект:IsA("PostEffect") тогда
                effect.Enabled = true
            конец
        конец
        FPSOriginal.Saved = false
        OrionLib:MakeNotification({
            Name = "🔮 Графика восстановлена",
            Content = "Все графики настроек вернулись в исходное состояние.",
            Изображение = "rbxassetid://4483362458",
            Время = 3,
        })
    конец,
})

-- ==================================================
-- =================== ВКЛАДКА ИНФОРМАЦИЯ ======================
-- ==================================================

InfoTab:AddLabel("Универсальный скрипт ESP v5 — расширенная версия")
InfoTab:AddLabel("Работает во всех играх Roblox!")
InfoTab:AddDivider()
InfoTab:AddLabel("ESP: Коробка, Чамы, Скелет, Трейсеры, HP, Имя, Дистанция")
InfoTab:AddLabel("Зелёный = враг виден | Красный = за стеной")
InfoTab:AddLabel("Читы: Бесконечный прыжок | Взлом скорости | Отсутствие прохода")
InfoTab:AddLabel("Телепорт: ТП к игрокам | Сохранение места")
InfoTab:AddLabel("Повышение FPS: 4 уровня понижение графика + Сброс")
InfoTab:AddDivider()
InfoTab:AddLabel("RightShift — открыть/закрыть меню")

-- ==================================================
-- =========== ОСНОВНЫЕ ПОМОЩНИКИ ПО ЭКСТРАВАГАНТНЫМ СПОСОБНОСТЯМ ======================
-- ==================================================

локальная функция SetObjectVisible(obj, state)
    если не объект, то вернуть конец
    если typeof(obj) == "Instance", то
        if obj:IsA("Highlight") then obj.Enabled = state
        elseif obj:IsA("GuiObject") then obj.Visible = state end
    иначе вызов функции (функция `obj.Visible` = состояние) конец
конец

локальная функция RemoveObject(obj)
    если не объект, то вернуть конец
    pcall(function()
        if typeof(obj) == "Instance" then obj:Destroy()
        иначе obj:Remove() конец
    конец)
конец

локальная функция IsTeammate(Player)
    if not Settings.TeamCheck then return false end
    если LP.Team и Player.Team == Player.Team, то вернуть true.
    local lc, pc = LP.Character, Player.Character
    если lc и pc и lc.Parent и pc.Parent
       и lc.Parent == pc.Parent и lc.Parent ~= workspace тогда
        вернуть true
    конец
    вернуть false
конец

локальная функция GetColor(Player, IsVisible)
    Если IsTeammate(Player), то вернуть Settings.TeamColor.
    возвращает IsVisible и Settings.VisibleColor или Settings.HiddenColor
конец

локальная функция GetHealthColor(hp, max)
    локальное p = hp / max
    Если p > 0,6, то вернуть Palette.HealthHigh end
    Если p > 0,3, то вернуть Palette.HealthMid.
    return Palette.HealthLow
конец

локальная функция IsPartVisibleToCamera(part, targetChar)
    Если не Camera, не part, не part:IsA("BasePart") или не targetChar, то вернуть false.
    локальный источник = Camera.CFrame.Position
    локальное направление = часть.Положение - начало координат
    Если direction.Magnitude <= 0.1, то вернуть true.
    local ignore = {}
    if LP.Character then table.insert(ignore, LP.Character) end
    pcall(function() table.insert(ignore, Camera) end)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = ignore
    params.IgnoreWater = true
    местный кур = происхождение
    для _ = 1, 8 делать
        local cd = part.Position - cur
        Если cd.Magnitude <= 0.1, то вернуть true.
        local r = workspace:Raycast(cur, cd, params)
        если не r, то вернуть true конец
        Если r.Instance и r.Instance:IsDescendantOf(targetChar), то вернуть true.
        local skip = false
        pcall(function() skip = r.Instance.Transparency >= 0.75 or r.Instance.CanCollide == false end)
        если skip и r.Instance тогда
            table.insert(ignore, r.Instance)
            params.FilterDescendantsInstances = ignore
            cur = r.Position + cd.Unit * 0.05
        иначе вернуть false конец
    конец
    вернуть false
конец

локальная функция IsCharacterVisible(char)
    если не является символом, то вернуть false конец
    for _, n in ipairs({"Head","UpperTorso","Torso","HumanoidRootPart","LowerTorso"}) do
        local p = char:FindFirstChild(n)
        if p and p:IsA("BasePart") and IsPartVisibleToCamera(p, char) then return true end
    конец
    вернуть false
конец

локальная функция IsLookingAtYou(char)
    если не LP.Character, то вернуть false конец
    local mh = LP.Character:FindFirstChild("Head") or LP.Character:FindFirstChild("HumanoidRootPart")
    local h = char:FindFirstChild("Head")
    если не mh или не h, то вернуть false.
    local ok, res = pcall(function()
        return ((mh.Position - h.Position).Unit):Dot(h.CFrame.LookVector) > 0.85
    конец)
    возвращать ok и res или false
конец

-- ========== ESP OBJECTS ==========

local ESPCache = {}

локальная функция NewLine(t, tr)
    local l = Drawing.new("Line")
    l.Толщина = t или 1,5
    l.Прозрачность = tr или 0,7
    l.Visible = false
    возврат л
конец

локальная функция NewText(sz)
    local t = Drawing.new("Text")
    Размер = размер или 12
    t.Center = true
    t.Outline = true
    t.Font = 2
    t.Visible = false
    вернуть т
конец

локальная функция NewChams()
    local h = Instance.new("Highlight")
    h.Name = "UESP_Chams"
    h.Enabled = false
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.FillTransparency = Settings.ChamsFillTransparency
    h.OutlineTransparency = Settings.ChamsOutlineTransparency
    h.Parent = ChamsFolder
    возврат h
конец

локальная функция CreateESP(Player)
    Если Player == LP, то вернуться.
    if ESPCache[Player] then return end
    локальный Скел = {
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
        BoxTop = NewLine(), BoxBot = NewLine(),
        BoxLeft = NewLine(), BoxRight = NewLine(),
        Tracer = NewLine(1, 0.8),
        Имя = НовыйТекст(12), Расстояние = НовыйТекст(10),
        HpBg = NewLine(4, 1), HpFill = NewLine(4, 1),
        Skeleton = Skel,
        AimLine = NewLine(2, 0.9),
        LookingText = NewText(13),
        Chams = NewChams(),
    }
    ESPCache[Player].HpBg.Color = Palette.HealthBg
    ESPCache[Player].Distance.Font = 1
    ESPCache[Player].LookingText.Color = Palette.LookingAtYou
конец

локальная функция RemoveESP(Player)
    local o = ESPCache[Player]
    если не 0, то вернуться к концу
    for _, d in pairs(o) do
        если type(d) == "table", то
            for _, obj in pairs(d) do RemoveObject(obj) end
        иначе RemoveObject(d) конец
    конец
    ESPCache[Player] = nil
конец

локальная функция HideESP(o)
    for _, d in pairs(o) do
        если type(d) == "table", то
            for _, obj in pairs(d) do SetObjectVisible(obj, false) end
        else SetObjectVisible(d, false) end
    конец
конец

локальная функция UpdateChams(_, o, Char, Col)
    if not o.Chams then return end
    Если Settings.ShowChams и Char, то
        if o.Chams.Adornee ~= Char then o.Chams.Adornee = Char end
        o.Chams.FillColor = Col
        o.Chams.OutlineColor = Col
        o.Chams.FillTransparency = Settings.ChamsFillTransparency
        o.Chams.OutlineTransparency = Settings.ChamsOutlineTransparency
        o.Chams.Enabled = true
    иначе o.Chams.Enabled = false конец
конец

локальная функция DrawSkeleton(Player, o, Col)
    local Char = Player.Character
    если не Char, то вернуться.
    for _, line in pairs(o.Skeleton) do line.Visible = false end
    локальная функция GL(pName)
        local p = Char:FindFirstChild(pName)
        если p и p:IsA("BasePart"), то
            local ok, pos, on = pcall(function()
                local v, isOn = Camera:WorldToViewportPoint(p.Position)
                return v, isOn
            конец)
            Если ok и on, и pos.Z > 0, то вернуть Vector2.new(pos.X, pos.Y), true.
        конец
        возвращать nil, false
    конец
    local isR15 = Char:FindFirstChild("UpperTorso") ~= ноль
    local m = isR15 and {
        HeadTorso={"Head","UpperTorso"},TorsoHip={"UpperTorso","LowerTorso"},
        TorsoLeftShoulder={"UpperTorso","LeftUpperArm"},LeftShoulderElbow={"LeftUpperArm","LeftLowerArm"},
        LeftElbowHand={"LeftLowerArm","LeftHand"},TorsoRightShoulder={"UpperTorso","RightUpperArm"},
        RightShoulderElbow={"RightUpperArm","RightLowerArm"},RightElbowHand={"RightLowerArm","RightHand"},
        HipLeftKnee={"LowerTorso","LeftUpperLeg"},LeftKneeFoot={"LeftUpperLeg","LeftLowerLeg"},
        HipRightKnee={"LowerTorso","RightUpperLeg"},RightKneeFoot={"RightUpperLeg","RightLowerLeg"},
    } или {
        HeadTorso={"Head","Torso"},TorsoLeftShoulder={"Torso","Left Arm"},
        TorsoRightShoulder={"Torso","Right Arm"},HipLeftKnee={"Torso","Left Leg"},
        HipRightKnee={"Torso","Right Leg"},
    }
    for lname, parts in pairs(m) do
        локальная строка = o.Skeleton[lname]
        если строка тогда
            local p1,v1 = GL(parts[1])
            local p2,v2 = GL(parts[2])
            если p1 и p2 и v1 и v2 тогда
                line.From = p1 ; line.To = p2
                line.Color = Col
                line.Thickness = Settings.SkeletonThickness
                line.Visible = true
            конец
        конец
    конец
конец

локальная функция DrawAimDir(Player, o)
    if not Settings.ShowAimDir then o.AimLine.Visible = false ; return end
    local Char = Player.Character
    if not Char then o.AimLine.Visible = false ; return end
    local head = Char:FindFirstChild("Head")
    if not head or not head:IsA("BasePart") then o.AimLine.Visible = false ; return end
    local ok, res = pcall(function()
        local ae = head.Position + head.CFrame.LookVector * Settings.AimLineLength
        local hS, hOn = Camera:WorldToViewportPoint(head.Position)
        local aS, aOn = Camera:WorldToViewportPoint(ae)
        если hOn и aOn, а также hS.Z > 0 и aS.Z > 0, то
            o.AimLine.From = Vector2.new(hS.X, hS.Y)
            o.AimLine.To = Vector2.new(aS.X, aS.Y)
            o.AimLine.Color = Palette.AimDir
            o.AimLine.Visible = true
            вернуть true
        конец
        вернуть false
    конец)
    Если не работает или не имеет разрешения, то o.AimLine.Visible = false.
конец

-- ========== СОБЫТИЯ ==========
for _, p in pairs(Players:GetPlayers()) do CreateESP(p) end
Players.PlayerAdded:Connect(function(p)
    CreateESP(p)
    -- обновляем список ТП без дублей
    task.delay(1, BuildTPButtons)
конец)
Players.PlayerRemoving:Connect(function(p)
    RemoveESP(p)
    task.delay(0.5, BuildTPButtons)
конец)

-- Восстановить скорость при респавне
LP.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")
    если CheatSettings.SpeedEnabled, то
        hum.WalkSpeed ​​= CheatSettings.SpeedValue
    конец
конец)

-- ========== БЕСКОНЕЧНЫЙ ПРЫЖОК ==========
UIS.JumpRequest:Connect(function()
    if not CheatSettings.InfiniteJump then return end
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
конец)

-- ========== ОСНОВНОЙ ЦИКЛ (ESP + NOCLIP) ==========
-- НОКУЛИП ПРАВЛЕН: используйте RenderStepped, обрабатываем ВСЕ BasePart
-- включая HumanoidRootPart=false, чтобы не провалился, только часть тела
RunService.RenderStepped:Connect(функция()
    Камера = рабочая область.ТекущаяКамера
    Если камера отсутствует, то вернуться в конец.

    -- Noclip loop
    если CheatSettings.Noclip тогда
        local char = LP.Character
        если символ тогда
            for _, p in pairs(char:GetDescendants()) do
                если p:IsA("BasePart") и p.CanCollide тогда
                    p.CanCollide = false
                конец
            конец
        конец
    конец

    -- Цикл ESP
    for Player, o in pairs(ESPCache) do
        if not Settings.Enabled then HideESP(o) ; continue end
        if not Player or not Player.Parent then HideESP(o) ; continue end

        local Char = Player.Character
        local Root = Char and Char:FindFirstChild("HumanoidRootPart")
        local Hum = Char and Char:FindFirstChildOfClass("Humanoid")
        if not (Char and Root and Hum and Hum.Health > 0) then HideESP(o) ; continue end

        local ok, SP, OnScreen = pcall(function()
            local pos, isOn = Camera:WorldToViewportPoint(Root.Position)
            return pos, isOn
        конец)
        if not ok or not OnScreen or SP.Z <= 0 then HideESP(o) ; continue end

        local Dist = (Camera.CFrame.Position - Root.Position).Magnitude
        if Dist > Settings.MaxDistance then HideESP(o) ; continue end
        if IsTeammate(Player) then HideESP(o) ; continue end

        local IsVisible = false
        pcall(function() IsVisible = IsCharacterVisible(Char) end)

        локальный BH = 4000 / Dist
        локальная ширина полосы пропускания = 2200 / Расстояние
        локальный X = SP.X - BW / 2
        локальный Y = SP.Y - BH / 2
        local Col = GetColor(Player, IsVisible)
        local V2 = Vector2.new

        UpdateChams(Player, o, Char, Col)

        если Settings.ShowBox then
            o.BoxTop.From=V2(X,Y);o.BoxTop.To=V2(X+BW,Y)
            o.BoxBot.From=V2(X,Y+BH);o.BoxBot.To=V2(X+BW,Y+BH)
            o.BoxLeft.From=V2(X,Y);o.BoxLeft.To=V2(X,Y+BH)
            o.BoxRight.From=V2(X+BW,Y);o.BoxRight.To=V2(X+BW,Y+BH)
            for _,k in pairs({"BoxTop","BoxBot","BoxLeft","BoxRight"}) do
                o[k].Color=Col ; o[k].Visible=true
            конец
        еще
            for _,k in pairs({"BoxTop","BoxBot","BoxLeft","BoxRight"}) do o[k].Visible=false end
        конец

        o.Tracer.From=V2(Camera.ViewportSize.X/2,Camera.ViewportSize.Y)
        o.Tracer.To=V2(SP.X,SP.Y)
        o.Tracer.Color=Col ; o.Tracer.Visible=Settings.ShowTracer

        o.Name.Text=Player.Name ; o.Name.Position=V2(SP.X,Y-15)
        o.Name.Color=Col ; o.Name.Visible=Settings.ShowName

        o.Distance.Text=math.floor(Dist).."m"
        o.Distance.Position=V2(SP.X,Y+BH+4)
        o.Distance.Color = Color3.fromRGB(200, 200, 200)
        o.Distance.Visible=Settings.ShowDistance

        Если Settings.ShowHealth, то
            local pct = math.clamp(Hum.Health/Hum.MaxHealth,0,1)
            локальный bX = X-6
            o.HpBg.From=V2(bX,Y);o.HpBg.To=V2(bX,Y+BH);o.HpBg.Visible=true
            o.HpFill.From=V2(bX,Y+BH);o.HpFill.To=V2(bX,Y+BH-BH*pct)
            o.HpFill.Color = GetHealthColor(Hum.Health, Hum.MaxHealth); o.HpFill.Visible = true
        еще
            o.HpBg.Visible=false ; o.HpFill.Visible=false
        конец

        Если Settings.ShowSkeleton, то
            pcall(function() DrawSkeleton(Player,o,Col) end)
        еще
            for _,line in pairs(o.Skeleton) do line.Visible=false end
        конец

        Если используется Settings.ShowAimDir, то
            pcall(function() DrawAimDir(Player,o) end)
        иначе o.AimLine.Visible=false конец

        Если Settings.ShowLookingAtYou, то
            local okL, isL = pcall(function() return IsLookingAtYou(Char) end)
            если okL и isL тогда
                o.LookingText.Text="[!] СМОТРИТ НА ТЕБЯ"
                o.LookingText.Position=V2(SP.X,Y-35)
                o.LookingText.Visible=true
            иначе o.LookingText.Visible=false конец
        иначе o.LookingText.Visible=false конец
    конец
конец)

OrionLib:Init()
print(" ✅ Universal ESP v5 | RightShift = меню")
print("👻 Noclip FIXED | 🚀 FPS Booster | 🌀 ТП без дублей | ✅ Слайдеры работают")
