--[[
    Universal ESP Script - УЛУЧШЕННАЯ ВЕРСИЯ v6
    Работает во ВСЕХ Roblox играх

    Изменения v6:
    - ИСПРАВЛЕН краш при загрузке (settings().Rendering обёрнут в pcall)
    - ИСПРАВЛЕН ноуклип (HumanoidRootPart тоже отключает коллизию)
    - ИСПРАВЛЕНО дублирование ников в TP вкладке
    - ДОБАВЛЕН FPS Бустер (4 уровня + сброс)

    Open Menu: RightShift
]]

if not game:IsLoaded() then game.Loaded:Wait() end

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name  = "Universal ESP Script [v6]",
    Icon  = 4483362458,
    LoadingTitle    = "Universal ESP Script",
    LoadingSubtitle = "Loading Enhanced v6...",
    DisableRayfieldPrompts = true,
    DisableBuildWarnings = true,
    ConfigurationSaving = {
        Enabled    = true,
        FolderName = "UniversalESPScript",
        FileName   = "ESPSettings"
    },
    Keybind = Enum.KeyCode.RightShift,
    ToggleUIKeybind = Enum.KeyCode.RightShift,
})

local ESPTab   = Window:CreateTab("ESP Settings", 4483362458)
local TPTab    = Window:CreateTab("Teleport", 4483362458)
local CheatTab = Window:CreateTab("Cheats", 4483362458)
local FPSTab   = Window:CreateTab("FPS Boost", 4483362458)
local ExtraTab = Window:CreateTab("Extra", 4483362458)
local InfoTab  = Window:CreateTab("Info", 4483362458)

-- ========== SERVICES ==========
local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS        = game:GetService("UserInputService")
local Lighting   = game:GetService("Lighting")
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
    ShowChams    = true,
    ShowAimDir   = false,
    ShowLookingAtYou = false,
    MaxDistance  = 1500,
    VisibleColor = Color3.fromRGB(50, 255, 80),
    HiddenColor  = Color3.fromRGB(255, 50, 50),
    TeamColor    = Color3.fromRGB(50, 150, 255),
    SkeletonThickness = 2,
    AimLineLength = 15,
    ChamsFillTransparency = 0.45,
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

-- ========== PALETTE ==========
local Palette = {
    HealthHigh   = Color3.fromRGB(0, 255, 0),
    HealthMid    = Color3.fromRGB(255, 255, 0),
    HealthLow    = Color3.fromRGB(255, 0, 0),
    HealthBg     = Color3.fromRGB(40, 40, 40),
    LookingAtYou = Color3.fromRGB(255, 255, 0),
    AimDir       = Color3.fromRGB(255, 150, 0),
}

-- ===================================================
-- =================== FPS BOOST =====================
-- ===================================================

-- ИСПРАВЛЕНО: settings().Rendering.QualityLevel вызывал краш при
-- инициализации таблицы. Теперь всё читается через pcall.
local OriginalGraphics = {}

local function SaveOriginalGraphics()
    pcall(function()
        OriginalGraphics.QualityLevel = settings().Rendering.QualityLevel
    end)
    pcall(function()
        OriginalGraphics.GlobalShadows = Lighting.GlobalShadows
        OriginalGraphics.FogEnd        = Lighting.FogEnd
        OriginalGraphics.FogStart      = Lighting.FogStart
        OriginalGraphics.Brightness    = Lighting.Brightness
    end)
    OriginalGraphics.Saved = true
end

-- Сохраняем сразу при загрузке скрипта
SaveOriginalGraphics()

local function SetParticles(state)
    pcall(function()
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("Smoke")
               or obj:IsA("Fire") or obj:IsA("Sparkles") then
                pcall(function() obj.Enabled = state end)
            end
        end
    end)
end

local function SetDecals(state)
    pcall(function()
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Decal") or obj:IsA("Texture") then
                pcall(function() obj.Transparency = state and 0 or 1 end)
            end
        end
    end)
end

local function SetQuality(level)
    pcall(function()
        settings().Rendering.QualityLevel = level
    end)
end

local function ApplyFPSBoost(level)
    if level == 0 then
        -- СБРОС к оригинальным настройкам
        pcall(function()
            if OriginalGraphics.QualityLevel then
                settings().Rendering.QualityLevel = OriginalGraphics.QualityLevel
            end
        end)
        pcall(function()
            if OriginalGraphics.GlobalShadows ~= nil then
                Lighting.GlobalShadows = OriginalGraphics.GlobalShadows
            end
            if OriginalGraphics.FogEnd then
                Lighting.FogEnd = OriginalGraphics.FogEnd
            end
            if OriginalGraphics.FogStart then
                Lighting.FogStart = OriginalGraphics.FogStart
            end
            if OriginalGraphics.Brightness then
                Lighting.Brightness = OriginalGraphics.Brightness
            end
        end)
        SetParticles(true)
        SetDecals(true)
        return
    end

    -- Уровень 1: снижение качества рендера, убрать туман
    if level >= 1 then
        SetQuality(Enum.QualityLevel.Level05)
        pcall(function() Lighting.FogEnd = 100000 end)
    end

    -- Уровень 2: минимум качество, тени выкл
    if level >= 2 then
        SetQuality(Enum.QualityLevel.Level03)
        pcall(function() Lighting.GlobalShadows = false end)
    end

    -- Уровень 3: убрать частицы
    if level >= 3 then
        SetQuality(Enum.QualityLevel.Level01)
        pcall(function() Lighting.Brightness = 1 end)
        SetParticles(false)
    end

    -- Уровень 4: убрать декали и текстуры
    if level >= 4 then
        SetDecals(false)
    end
end

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
        local pg = LP:WaitForChild("PlayerGui")
        local old = pg:FindFirstChild(ChamsFolder.Name)
        if old then old:Destroy() end
        ChamsFolder.Parent = pg
    end)
end
if not ChamsFolder.Parent then ChamsFolder.Parent = workspace end

-- ===================================================
-- =================== ESP TAB =======================
-- ===================================================

ESPTab:CreateToggle({
    Name = "Включить ESP",
    CurrentValue = Settings.Enabled,
    Flag = "ESP_Enabled",
    Callback = function(v) Settings.Enabled = v end,
})

ESPTab:CreateToggle({
    Name = "Team Check",
    CurrentValue = Settings.TeamCheck,
    Flag = "TeamCheck",
    Callback = function(v) Settings.TeamCheck = v end,
})

ESPTab:CreateDivider()

ESPTab:CreateToggle({
    Name = "Box ESP",
    CurrentValue = Settings.ShowBox,
    Flag = "BoxESP",
    Callback = function(v) Settings.ShowBox = v end,
})

ESPTab:CreateToggle({
    Name = "Tracers",
    CurrentValue = Settings.ShowTracer,
    Flag = "Tracers",
    Callback = function(v) Settings.ShowTracer = v end,
})

ESPTab:CreateToggle({
    Name = "Skeleton ESP",
    CurrentValue = Settings.ShowSkeleton,
    Flag = "SkeletonESP",
    Callback = function(v) Settings.ShowSkeleton = v end,
})

ESPTab:CreateToggle({
    Name = "Chams / Highlight ESP",
    CurrentValue = Settings.ShowChams,
    Flag = "ChamsESP",
    Callback = function(v) Settings.ShowChams = v end,
})

ESPTab:CreateToggle({
    Name = "Имя игрока",
    CurrentValue = Settings.ShowName,
    Flag = "NameESP",
    Callback = function(v) Settings.ShowName = v end,
})

ESPTab:CreateToggle({
    Name = "Полоска здоровья",
    CurrentValue = Settings.ShowHealth,
    Flag = "HealthESP",
    Callback = function(v) Settings.ShowHealth = v end,
})

ESPTab:CreateToggle({
    Name = "Дистанция",
    CurrentValue = Settings.ShowDistance,
    Flag = "DistanceESP",
    Callback = function(v) Settings.ShowDistance = v end,
})

ESPTab:CreateToggle({
    Name = "Направление взгляда (AIM DIR)",
    CurrentValue = Settings.ShowAimDir,
    Flag = "AimDir",
    Callback = function(v) Settings.ShowAimDir = v end,
})

ESPTab:CreateToggle({
    Name = "Предупреждение 'Смотрит на тебя'",
    CurrentValue = Settings.ShowLookingAtYou,
    Flag = "LookingAtYou",
    Callback = function(v) Settings.ShowLookingAtYou = v end,
})

ESPTab:CreateDivider()

ESPTab:CreateSlider({
    Name = "Максимальная дистанция ESP",
    Range = {100, 3000},
    Increment = 50,
    Suffix = " studs",
    CurrentValue = Settings.MaxDistance,
    Flag = "MaxDistance",
    Callback = function(v)
        Settings.MaxDistance = tonumber(v) or 1500
    end,
})

ESPTab:CreateSlider({
    Name = "Толщина скелета",
    Range = {1, 5},
    Increment = 1,
    Suffix = " px",
    CurrentValue = Settings.SkeletonThickness,
    Flag = "SkeletonThickness",
    Callback = function(v)
        Settings.SkeletonThickness = tonumber(v) or 2
    end,
})

ESPTab:CreateSlider({
    Name = "Длина линии взгляда",
    Range = {5, 50},
    Increment = 1,
    Suffix = " studs",
    CurrentValue = Settings.AimLineLength,
    Flag = "AimLineLength",
    Callback = function(v)
        Settings.AimLineLength = tonumber(v) or 15
    end,
})

-- ===================================================
-- ================ TELEPORT TAB =====================
-- ===================================================
-- ИСПРАВЛЕНО: убрана TPTab:CreateSection над кнопками TP
-- из-за которой ники показывались дважды

local tpButtonsCache = {}

local function RefreshPlayerButtons()
    for _, btn in pairs(tpButtonsCache) do
        pcall(function() btn:Destroy() end)
    end
    tpButtonsCache = {}

    local found = false
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LP then
            found = true
            local btn = TPTab:CreateButton({
                Name = "ТП к: " .. player.Name,
                Callback = function()
                    local char  = LP.Character
                    local root  = char and char:FindFirstChild("HumanoidRootPart")
                    local tChar = player.Character
                    local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
                    if root and tRoot then
                        root.CFrame = tRoot.CFrame + Vector3.new(0, 3, 0)
                        Rayfield:Notify({
                            Title   = "Телепорт",
                            Content = "ТП к " .. player.Name .. " выполнен!",
                            Duration = 3,
                        })
                    else
                        Rayfield:Notify({
                            Title   = "Ошибка",
                            Content = "Игрок " .. player.Name .. " не имеет персонажа.",
                            Duration = 3,
                        })
                    end
                end,
            })
            table.insert(tpButtonsCache, btn)
        end
    end

    if not found then
        local stub = TPTab:CreateLabel("— Нет других игроков на сервере —")
        table.insert(tpButtonsCache, stub)
    end
end

TPTab:CreateButton({
    Name = "Обновить список игроков",
    Callback = function()
        RefreshPlayerButtons()
        Rayfield:Notify({
            Title   = "Список обновлён",
            Content = "Список игроков обновлён.",
            Duration = 2,
        })
    end,
})

RefreshPlayerButtons()
Players.PlayerAdded:Connect(function() RefreshPlayerButtons() end)
Players.PlayerRemoving:Connect(function() RefreshPlayerButtons() end)

TPTab:CreateDivider()

TPTab:CreateButton({
    Name = "Сохранить текущее место",
    Callback = function()
        local char = LP.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            CheatSettings.SavedPosition = root.CFrame
            Rayfield:Notify({
                Title   = "Место сохранено",
                Content = "Позиция сохранена! Используй 'ТП на сохранённое место'.",
                Duration = 3,
            })
        else
            Rayfield:Notify({
                Title   = "Ошибка",
                Content = "Персонаж не найден.",
                Duration = 3,
            })
        end
    end,
})

TPTab:CreateButton({
    Name = "ТП на сохранённое место",
    Callback = function()
        if not CheatSettings.SavedPosition then
            Rayfield:Notify({
                Title   = "Ошибка",
                Content = "Сначала сохрани место кнопкой выше!",
                Duration = 3,
            })
            return
        end
        local char = LP.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            root.CFrame = CheatSettings.SavedPosition
            Rayfield:Notify({
                Title   = "Телепортировано",
                Content = "Вернулся на сохранённое место!",
                Duration = 3,
            })
        else
            Rayfield:Notify({
                Title   = "Ошибка",
                Content = "Персонаж не найден.",
                Duration = 3,
            })
        end
    end,
})

-- ===================================================
-- ================= CHEATS TAB ======================
-- ===================================================

CheatTab:CreateSection("Движение")

CheatTab:CreateToggle({
    Name = "Бесконечный прыжок",
    CurrentValue = CheatSettings.InfiniteJump,
    Flag = "InfiniteJump",
    Callback = function(v)
        CheatSettings.InfiniteJump = v
        Rayfield:Notify({
            Title   = "Бесконечный прыжок",
            Content = v and "ВКЛЮЧЁН" or "ВЫКЛЮЧЕН",
            Duration = 2,
        })
    end,
})

CheatTab:CreateToggle({
    Name = "СПИДхак (SpeedHack)",
    CurrentValue = CheatSettings.SpeedEnabled,
    Flag = "SpeedEnabled",
    Callback = function(v)
        CheatSettings.SpeedEnabled = v
        local char = LP.Character
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = v and CheatSettings.SpeedValue or 16
        end
        Rayfield:Notify({
            Title   = "СПИДхак",
            Content = v and ("ВКЛЮЧЁН | Скорость: " .. CheatSettings.SpeedValue) or "ВЫКЛЮЧЕН",
            Duration = 2,
        })
    end,
})

CheatTab:CreateSlider({
    Name = "Скорость (WalkSpeed)",
    Range = {16, 300},
    Increment = 1,
    Suffix = " sp",
    CurrentValue = CheatSettings.SpeedValue,
    Flag = "SpeedValue",
    Callback = function(v)
        CheatSettings.SpeedValue = tonumber(v) or 16
        if CheatSettings.SpeedEnabled then
            local char = LP.Character
            local hum  = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = CheatSettings.SpeedValue
            end
        end
    end,
})

CheatTab:CreateDivider()
CheatTab:CreateSection("Коллизии")

-- ИСПРАВЛЕННЫЙ НОУКЛИП
-- v5 ошибка: HumanoidRootPart исключался (part.Name ~= "HumanoidRootPart"),
-- но HRP — это основной физический коллайдер персонажа.
-- Теперь CanCollide = false применяется ко ВСЕМ BasePart.
CheatTab:CreateToggle({
    Name = "Ноуклип (Noclip)",
    CurrentValue = CheatSettings.Noclip,
    Flag = "Noclip",
    Callback = function(v)
        CheatSettings.Noclip = v
        if not v then
            -- При выключении — сразу вернуть коллизии
            local char = LP.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        pcall(function() part.CanCollide = true end)
                    end
                end
            end
        end
        Rayfield:Notify({
            Title   = "Ноуклип",
            Content = v and "ВКЛЮЧЁН — проходишь сквозь стены!" or "ВЫКЛЮЧЕН — коллизии восстановлены",
            Duration = 2,
        })
    end,
})

-- ===================================================
-- ================== FPS BOOST TAB ==================
-- ===================================================

FPSTab:CreateParagraph({
    Title   = "FPS Бустер",
    Content = "Выбери уровень буста FPS. Чем выше уровень — тем сильнее снижается графика и больше FPS. Кнопка Сброс возвращает всё к оригиналу.",
})

FPSTab:CreateButton({
    Name = "Уровень 1 — Лёгкий буст",
    Callback = function()
        ApplyFPSBoost(1)
        Rayfield:Notify({
            Title   = "FPS Буст — Уровень 1",
            Content = "Лёгкий: качество снижено, туман отключён",
            Duration = 3,
        })
    end,
})

FPSTab:CreateButton({
    Name = "Уровень 2 — Средний буст",
    Callback = function()
        ApplyFPSBoost(2)
        Rayfield:Notify({
            Title   = "FPS Буст — Уровень 2",
            Content = "Средний: мин. качество + глобальные тени выключены",
            Duration = 3,
        })
    end,
})

FPSTab:CreateButton({
    Name = "Уровень 3 — Сильный буст",
    Callback = function()
        ApplyFPSBoost(3)
        Rayfield:Notify({
            Title   = "FPS Буст — Уровень 3",
            Content = "Сильный: + частицы, огонь, дым отключены",
            Duration = 3,
        })
    end,
})

FPSTab:CreateButton({
    Name = "Уровень 4 — МАКСИМАЛЬНЫЙ буст",
    Callback = function()
        ApplyFPSBoost(4)
        Rayfield:Notify({
            Title   = "FPS Буст — Уровень 4",
            Content = "МАКСИМУМ: + все текстуры и декали скрыты",
            Duration = 3,
        })
    end,
})

FPSTab:CreateDivider()

FPSTab:CreateButton({
    Name = "Сбросить графику (Restore)",
    Callback = function()
        ApplyFPSBoost(0)
        Rayfield:Notify({
            Title   = "Графика восстановлена",
            Content = "Все настройки графики возвращены к оригиналу!",
            Duration = 3,
        })
    end,
})

-- ===================================================
-- =================== EXTRA TAB =====================
-- ===================================================

ExtraTab:CreateParagraph({
    Title   = "Extra ESP опции",
    Content = "Дополнительные параметры ESP.",
})

ExtraTab:CreateSlider({
    Name = "Прозрачность заливки Chams",
    Range = {0, 100},
    Increment = 5,
    Suffix = " %",
    CurrentValue = math.floor(Settings.ChamsFillTransparency * 100),
    Flag = "ChamsFill",
    Callback = function(v)
        Settings.ChamsFillTransparency = (tonumber(v) or 45) / 100
    end,
})

ExtraTab:CreateSlider({
    Name = "Прозрачность обводки Chams",
    Range = {0, 100},
    Increment = 5,
    Suffix = " %",
    CurrentValue = math.floor(Settings.ChamsOutlineTransparency * 100),
    Flag = "ChamsOutline",
    Callback = function(v)
        Settings.ChamsOutlineTransparency = (tonumber(v) or 0) / 100
    end,
})

-- ===================================================
-- ==================== INFO TAB =====================
-- ===================================================

InfoTab:CreateParagraph({
    Title   = "Universal ESP Script [v6]",
    Content = "ИСПРАВЛЕНО в v6:
• Краш при загрузке — settings().Rendering теперь в pcall
• Ноуклип — HRP тоже получает CanCollide=false
• TP вкладка — ники больше не дублируются

ДОБАВЛЕНО:
• FPS Буст (4 уровня + сброс)

ESP ФУНКЦИИ:
• Box, Chams, Skeleton, Tracers
• Имя, HP, Дистанция
• Зелёный=виден, Красный=за стеной
• Team Check

УПРАВЛЕНИЕ:
• RightShift — открыть/закрыть меню"
})

-- ===================================================
-- ========= HELPERS / CORE ESP FUNCTIONS ============
-- ===================================================

local function SetObjectVisible(obj, state)
    if not obj then return end
    if typeof(obj) == "Instance" then
        if obj:IsA("Highlight") then
            obj.Enabled = state
        elseif obj:IsA("GuiObject") then
            obj.Visible = state
        end
    else
        pcall(function() obj.Visible = state end)
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

local function IsTeammate(Player)
    if not Settings.TeamCheck then return false end
    if LP.Team and Player.Team and LP.Team == Player.Team then return true end
    local lc, pc = LP.Character, Player.Character
    if lc and pc and lc.Parent and pc.Parent
        and lc.Parent == pc.Parent and lc.Parent ~= workspace then
        return true
    end
    return false
end

local function GetColor(Player, IsVisible)
    if IsTeammate(Player) then return Settings.TeamColor end
    return IsVisible and Settings.VisibleColor or Settings.HiddenColor
end

local function GetHealthColor(hp, max)
    local pct = hp / max
    if pct > 0.6 then return Palette.HealthHigh end
    if pct > 0.3 then return Palette.HealthMid end
    return Palette.HealthLow
end

local function IsPartVisibleToCamera(part, targetChar)
    if not Camera or not part or not part:IsA("BasePart") or not targetChar then return false end
    local origin    = Camera.CFrame.Position
    local target    = part.Position
    local direction = target - origin
    if direction.Magnitude <= 0.1 then return true end
    local ignoreList = {}
    if LP.Character then table.insert(ignoreList, LP.Character) end
    pcall(function() table.insert(ignoreList, Camera) end)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = ignoreList
    params.IgnoreWater = true
    local currentOrigin = origin
    for _ = 1, 8 do
        local curDir = target - currentOrigin
        if curDir.Magnitude <= 0.1 then return true end
        local result = workspace:Raycast(currentOrigin, curDir, params)
        if not result then return true end
        local hit = result.Instance
        if hit and hit:IsDescendantOf(targetChar) then return true end
        local canSkip = false
        pcall(function() canSkip = (hit.Transparency >= 0.75) or (hit.CanCollide == false) end)
        if canSkip and hit then
            table.insert(ignoreList, hit)
            params.FilterDescendantsInstances = ignoreList
            currentOrigin = result.Position + curDir.Unit * 0.05
        else
            return false
        end
    end
    return false
end

local function IsCharacterVisible(char)
    if not char then return false end
    for _, name in ipairs({"Head","UpperTorso","Torso","HumanoidRootPart","LowerTorso"}) do
        local part = char:FindFirstChild(name)
        if part and part:IsA("BasePart") and IsPartVisibleToCamera(part, char) then
            return true
        end
    end
    return false
end

local function IsLookingAtYou(char)
    if not LP.Character then return false end
    local myHead = LP.Character:FindFirstChild("Head") or LP.Character:FindFirstChild("HumanoidRootPart")
    local head   = char:FindFirstChild("Head")
    if not myHead or not head then return false end
    local ok, res = pcall(function()
        return ((myHead.Position - head.Position).Unit):Dot(head.CFrame.LookVector) > 0.85
    end)
    return ok and res or false
end

-- ========== ESP DRAWING OBJECTS ==========

local ESPCache = {}

local function NewLine(thickness, transp)
    local l = Drawing.new("Line")
    l.Thickness    = thickness or 1.5
    l.Transparency = transp or 0.7
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
    h.Name                  = "UniversalESP_Chams"
    h.Enabled               = false
    h.DepthMode             = Enum.HighlightDepthMode.AlwaysOnTop
    h.FillTransparency      = Settings.ChamsFillTransparency
    h.OutlineTransparency   = Settings.ChamsOutlineTransparency
    h.Parent                = ChamsFolder
    return h
end

local function CreateESP(Player)
    if Player == LP then return end
    if ESPCache[Player] then return end
    local Skel = {
        HeadTorso          = NewLine(Settings.SkeletonThickness, 0.8),
        TorsoHip           = NewLine(Settings.SkeletonThickness, 0.8),
        TorsoLeftShoulder  = NewLine(Settings.SkeletonThickness, 0.8),
        LeftShoulderElbow  = NewLine(Settings.SkeletonThickness, 0.8),
        LeftElbowHand      = NewLine(Settings.SkeletonThickness, 0.8),
        TorsoRightShoulder = NewLine(Settings.SkeletonThickness, 0.8),
        RightShoulderElbow = NewLine(Settings.SkeletonThickness, 0.8),
        RightElbowHand     = NewLine(Settings.SkeletonThickness, 0.8),
        HipLeftKnee        = NewLine(Settings.SkeletonThickness, 0.8),
        LeftKneeFoot       = NewLine(Settings.SkeletonThickness, 0.8),
        HipRightKnee       = NewLine(Settings.SkeletonThickness, 0.8),
        RightKneeFoot      = NewLine(Settings.SkeletonThickness, 0.8),
    }
    ESPCache[Player] = {
        BoxTop      = NewLine(), BoxBot      = NewLine(),
        BoxLeft     = NewLine(), BoxRight    = NewLine(),
        Tracer      = NewLine(1, 0.8),
        Name        = NewText(12),
        Distance    = NewText(10),
        HpBg        = NewLine(4, 1),
        HpFill      = NewLine(4, 1),
        Skeleton    = Skel,
        AimLine     = NewLine(2, 0.9),
        LookingText = NewText(13),
        Chams       = NewChams(),
    }
    ESPCache[Player].HpBg.Color       = Palette.HealthBg
    ESPCache[Player].Distance.Font    = 1
    ESPCache[Player].LookingText.Color = Palette.LookingAtYou
end

local function RemoveESP(Player)
    local o = ESPCache[Player]
    if not o then return end
    for _, d in pairs(o) do
        if type(d) == "table" then
            for _, obj in pairs(d) do RemoveObject(obj) end
        else
            RemoveObject(d)
        end
    end
    ESPCache[Player] = nil
end

local function HideESP(o)
    for _, d in pairs(o) do
        if type(d) == "table" then
            for _, obj in pairs(d) do SetObjectVisible(obj, false) end
        else
            SetObjectVisible(d, false)
        end
    end
end

local function UpdateChams(Player, o, Char, Col)
    if not o.Chams then return end
    if Settings.ShowChams and Char then
        if o.Chams.Adornee ~= Char then o.Chams.Adornee = Char end
        o.Chams.FillColor            = Col
        o.Chams.OutlineColor         = Col
        o.Chams.FillTransparency     = Settings.ChamsFillTransparency
        o.Chams.OutlineTransparency  = Settings.ChamsOutlineTransparency
        o.Chams.Enabled              = true
    else
        o.Chams.Enabled = false
    end
end

local function DrawSkeleton(Player, o, Col)
    local Char = Player.Character
    if not Char then return end
    for _, line in pairs(o.Skeleton) do line.Visible = false end
    local function GetLimbPos(pName)
        local part = Char:FindFirstChild(pName)
        if part and part:IsA("BasePart") then
            local ok, p, on = pcall(function()
                local pos, isOn = Camera:WorldToViewportPoint(part.Position)
                return pos, isOn
            end)
            if ok and on and p.Z > 0 then
                return Vector2.new(p.X, p.Y), true
            end
        end
        return nil, false
    end
    local isR15  = Char:FindFirstChild("UpperTorso") ~= nil
    local skelMap = isR15 and {
        HeadTorso          = {"Head","UpperTorso"},
        TorsoHip           = {"UpperTorso","LowerTorso"},
        TorsoLeftShoulder  = {"UpperTorso","LeftUpperArm"},
        LeftShoulderElbow  = {"LeftUpperArm","LeftLowerArm"},
        LeftElbowHand      = {"LeftLowerArm","LeftHand"},
        TorsoRightShoulder = {"UpperTorso","RightUpperArm"},
        RightShoulderElbow = {"RightUpperArm","RightLowerArm"},
        RightElbowHand     = {"RightLowerArm","RightHand"},
        HipLeftKnee        = {"LowerTorso","LeftUpperLeg"},
        LeftKneeFoot       = {"LeftUpperLeg","LeftLowerLeg"},
        HipRightKnee       = {"LowerTorso","RightUpperLeg"},
        RightKneeFoot      = {"RightUpperLeg","RightLowerLeg"},
    } or {
        HeadTorso          = {"Head","Torso"},
        TorsoLeftShoulder  = {"Torso","Left Arm"},
        TorsoRightShoulder = {"Torso","Right Arm"},
        HipLeftKnee        = {"Torso","Left Leg"},
        HipRightKnee       = {"Torso","Right Leg"},
    }
    for lineName, parts in pairs(skelMap) do
        local line = o.Skeleton[lineName]
        if line then
            local p1, v1 = GetLimbPos(parts[1])
            local p2, v2 = GetLimbPos(parts[2])
            if p1 and p2 and v1 and v2 then
                line.From      = p1
                line.To        = p2
                line.Color     = Col
                line.Thickness = Settings.SkeletonThickness
                line.Visible   = true
            end
        end
    end
end

local function DrawAimDirection(Player, o, Col)
    if not Settings.ShowAimDir then o.AimLine.Visible = false ; return end
    local Char = Player.Character
    if not Char then o.AimLine.Visible = false ; return end
    local head = Char:FindFirstChild("Head")
    if not head or not head:IsA("BasePart") then o.AimLine.Visible = false ; return end
    local ok, res = pcall(function()
        local aimEnd   = head.Position + head.CFrame.LookVector * Settings.AimLineLength
        local hS, hOn  = Camera:WorldToViewportPoint(head.Position)
        local aS, aOn  = Camera:WorldToViewportPoint(aimEnd)
        if hOn and aOn and hS.Z > 0 and aS.Z > 0 then
            o.AimLine.From  = Vector2.new(hS.X, hS.Y)
            o.AimLine.To    = Vector2.new(aS.X, aS.Y)
            o.AimLine.Color = Palette.AimDir
            o.AimLine.Visible = true
            return true
        end
        return false
    end)
    if not ok or not res then o.AimLine.Visible = false end
end

-- ========== PLAYER EVENTS ==========

for _, p in pairs(Players:GetPlayers()) do CreateESP(p) end
Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(RemoveESP)

-- ========== NOCLIP + CHARACTER EVENTS ==========

-- ИСПРАВЛЕННЫЙ НОУКЛИП: отключаем CanCollide у ВСЕХ BasePart (включая HRP)
RunService.Stepped:Connect(function()
    if CheatSettings.Noclip then
        local char = LP.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    pcall(function() part.CanCollide = false end)
                end
            end
        end
    end
end)

-- Бесконечный прыжок
UIS.JumpRequest:Connect(function()
    if CheatSettings.InfiniteJump then
        local char = LP.Character
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- Восстанавливаем скорость при респавне
LP.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")
    if CheatSettings.SpeedEnabled then
        hum.WalkSpeed = CheatSettings.SpeedValue
    end
end)

-- ========== MAIN ESP LOOP ==========

RunService.RenderStepped:Connect(function()
    Camera = workspace.CurrentCamera
    if not Camera then return end

    for Player, o in pairs(ESPCache) do
        if not Settings.Enabled then HideESP(o) ; continue end
        if not Player or not Player.Parent then HideESP(o) ; continue end

        local Char = Player.Character
        local Root = Char and Char:FindFirstChild("HumanoidRootPart")
        local Hum  = Char and Char:FindFirstChildOfClass("Humanoid")

        if not (Char and Root and Hum and Hum.Health > 0) then
            HideESP(o) ; continue
        end

        local ok, SP, OnScreen = pcall(function()
            local pos, isOn = Camera:WorldToViewportPoint(Root.Position)
            return pos, isOn
        end)
        if not ok or not OnScreen or SP.Z <= 0 then HideESP(o) ; continue end

        local Dist = (Camera.CFrame.Position - Root.Position).Magnitude
        if Dist > Settings.MaxDistance then HideESP(o) ; continue end
        if IsTeammate(Player) then HideESP(o) ; continue end

        local IsVisible = false
        pcall(function() IsVisible = IsCharacterVisible(Char) end)

        local BH  = 4000 / Dist
        local BW  = 2200 / Dist
        local X   = SP.X - BW / 2
        local Y   = SP.Y - BH / 2
        local Col = GetColor(Player, IsVisible)
        local V2  = Vector2.new

        UpdateChams(Player, o, Char, Col)

        if Settings.ShowBox then
            o.BoxTop.From  = V2(X, Y)      ; o.BoxTop.To    = V2(X+BW, Y)
            o.BoxBot.From  = V2(X, Y+BH)   ; o.BoxBot.To    = V2(X+BW, Y+BH)
            o.BoxLeft.From = V2(X, Y)      ; o.BoxLeft.To   = V2(X, Y+BH)
            o.BoxRight.From= V2(X+BW, Y)   ; o.BoxRight.To  = V2(X+BW, Y+BH)
            for _, k in pairs({"BoxTop","BoxBot","BoxLeft","BoxRight"}) do
                o[k].Color = Col ; o[k].Visible = true
            end
        else
            for _, k in pairs({"BoxTop","BoxBot","BoxLeft","BoxRight"}) do
                o[k].Visible = false
            end
        end

        o.Tracer.From    = V2(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
        o.Tracer.To      = V2(SP.X, SP.Y)
        o.Tracer.Color   = Col
        o.Tracer.Visible = Settings.ShowTracer

        o.Name.Text     = Player.Name
        o.Name.Position = V2(SP.X, Y - 15)
        o.Name.Color    = Col
        o.Name.Visible  = Settings.ShowName

        o.Distance.Text     = math.floor(Dist) .. "m"
        o.Distance.Position = V2(SP.X, Y + BH + 4)
        o.Distance.Color    = Color3.fromRGB(200, 200, 200)
        o.Distance.Visible  = Settings.ShowDistance

        if Settings.ShowHealth then
            local pct = math.clamp(Hum.Health / Hum.MaxHealth, 0, 1)
            local bX  = X - 6
            o.HpBg.From    = V2(bX, Y)
            o.HpBg.To      = V2(bX, Y + BH)
            o.HpBg.Visible = true
            o.HpFill.From    = V2(bX, Y + BH)
            o.HpFill.To      = V2(bX, Y + BH - BH * pct)
            o.HpFill.Color   = GetHealthColor(Hum.Health, Hum.MaxHealth)
            o.HpFill.Visible = true
        else
            o.HpBg.Visible   = false
            o.HpFill.Visible = false
        end

        if Settings.ShowSkeleton then
            pcall(function() DrawSkeleton(Player, o, Col) end)
        else
            for _, line in pairs(o.Skeleton) do line.Visible = false end
        end

        if Settings.ShowAimDir then
            pcall(function() DrawAimDirection(Player, o, Col) end)
        else
            o.AimLine.Visible = false
        end

        if Settings.ShowLookingAtYou then
            local okL, isLooking = pcall(function() return IsLookingAtYou(Char) end)
            if okL and isLooking then
                o.LookingText.Text     = "[!] СМОТРИТ НА ТЕБЯ"
                o.LookingText.Position = V2(SP.X, Y - 35)
                o.LookingText.Visible  = true
            else
                o.LookingText.Visible = false
            end
        else
            o.LookingText.Visible = false
        end
    end
end)

print("Universal ESP v6 loaded | RightShift = menu")
print("InfiniteJump | SpeedHack | Noclip | TP | FPS Boost")
