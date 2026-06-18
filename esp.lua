--[[
    Universal ESP Script — УЛУЧШЕННАЯ ВЕРСИЯ v7
    Работает во ВСЕХ Roblox играх

    Изменения v7 (КРИТИЧЕСКИЕ ИСПРАВЛЕНИЯ):
    - УБРАН конфликт Keybind/ToggleUIKeybind (одинаковая клавиша = краш)
    - УБРАН параметр Icon (число не поддерживается в новых Rayfield)
    - ДОБАВЛЕНА проверка Drawing API перед использованием
    - ДОБАВЛЕНА защита Rayfield loadstring через pcall
    - ConfigurationSaving отключён по умолчанию (частая причина крашей)
    - Ноуклип исправлен (все BasePart включая HRP)
    - TP ники не дублируются
    - FPS Бустер (4 уровня + сброс)

    Open Menu: RightShift
]]

-- ══════════ БЕЗОПАСНАЯ ЗАГРУЗКА RAYFIELD ══════════
local RayfieldLoaded, Rayfield = pcall(function()
    return loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
end)

if not RayfieldLoaded or not Rayfield then
    warn("[ESP] Rayfield не загрузился! Попробуй другой executor или проверь интернет.")
    return
end

local Window = Rayfield:CreateWindow({
    Name  = "Universal ESP Script [v7]",
    LoadingTitle    = "Universal ESP Script",
    LoadingSubtitle = "Loading Enhanced v7...",
    DisableRayfieldPrompts = true,
    DisableBuildWarnings = true,
    ConfigurationSaving = {
        Enabled    = false,
        FolderName = nil,
        FileName   = nil,
    },
    ToggleUIKeybind = Enum.KeyCode.RightShift,
})

local ESPTab   = Window:CreateTab("ESP Settings", 4483362458)
local TPTab    = Window:CreateTab("Teleport", 4483362458)
local CheatTab = Window:CreateTab("Cheats", 4483362458)
local FPSTab   = Window:CreateTab("FPS Boost", 4483362458)
local ExtraTab = Window:CreateTab("Extra", 4483362458)
local InfoTab  = Window:CreateTab("Info", 4483362458)

-- ══════════ SERVICES ══════════
local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS        = game:GetService("UserInputService")
local Lighting   = game:GetService("Lighting")
local LP         = Players.LocalPlayer
local Camera     = workspace.CurrentCamera

-- ══════════ ПРОВЕРКА DRAWING API ══════════
local HasDrawing = false
pcall(function()
    if Drawing and Drawing.new then
        Drawing.new("Line"):Remove()
        HasDrawing = true
    end
end)

if not HasDrawing then
    warn("[ESP] Drawing API не найден! ESP будет работать без линий/текста, но Chams будут.")
end

-- ══════════ SETTINGS ══════════
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

-- ══════════ CHEAT SETTINGS ══════════
local CheatSettings = {
    InfiniteJump  = false,
    Noclip        = false,
    SpeedEnabled  = false,
    SpeedValue    = 16,
    SavedPosition = nil,
}

-- ══════════ PALETTE ══════════
local Palette = {
    HealthHigh   = Color3.fromRGB(0, 255, 0),
    HealthMid    = Color3.fromRGB(255, 255, 0),
    HealthLow    = Color3.fromRGB(255, 0, 0),
    HealthBg     = Color3.fromRGB(40, 40, 40),
    LookingAtYou = Color3.fromRGB(255, 255, 0),
    AimDir       = Color3.fromRGB(255, 150, 0),
}

-- ═══════════════════════════════════════════════════════════
-- =================== FPS BOOST ============================
-- ═══════════════════════════════════════════════════════════

local OriginalGraphics = {}

local function SaveOriginalGraphics()
    pcall(function() OriginalGraphics.QualityLevel = settings().Rendering.QualityLevel end)
    pcall(function()
        OriginalGraphics.GlobalShadows = Lighting.GlobalShadows
        OriginalGraphics.FogEnd        = Lighting.FogEnd
        OriginalGraphics.FogStart      = Lighting.FogStart
        OriginalGraphics.Brightness    = Lighting.Brightness
    end)
    OriginalGraphics.Saved = true
end

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
    pcall(function() settings().Rendering.QualityLevel = level end)
end

local function ApplyFPSBoost(level)
    if level == 0 then
        pcall(function()
            if OriginalGraphics.QualityLevel then
                settings().Rendering.QualityLevel = OriginalGraphics.QualityLevel
            end
        end)
        pcall(function()
            if OriginalGraphics.GlobalShadows ~= nil then
                Lighting.GlobalShadows = OriginalGraphics.GlobalShadows
            end
            if OriginalGraphics.FogEnd then Lighting.FogEnd = OriginalGraphics.FogEnd end
            if OriginalGraphics.FogStart then Lighting.FogStart = OriginalGraphics.FogStart end
            if OriginalGraphics.Brightness then Lighting.Brightness = OriginalGraphics.Brightness end
        end)
        SetParticles(true)
        SetDecals(true)
        return
    end

    if level >= 1 then
        SetQuality(Enum.QualityLevel.Level05)
        pcall(function() Lighting.FogEnd = 100000 end)
    end
    if level >= 2 then
        SetQuality(Enum.QualityLevel.Level03)
        pcall(function() Lighting.GlobalShadows = false end)
    end
    if level >= 3 then
        SetQuality(Enum.QualityLevel.Level01)
        pcall(function() Lighting.Brightness = 1 end)
        SetParticles(false)
    end
    if level >= 4 then
        SetDecals(false)
    end
end

-- ══════════ CHAMS FOLDER ══════════
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

-- ═══════════════════════════════════════════════════════════
-- =================== ESP TAB ==============================
-- ═══════════════════════════════════════════════════════════

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

-- ═══════════════════════════════════════════════════════════
-- ================ TELEPORT TAB ============================
-- ═══════════════════════════════════════════════════════════

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
                            Content = player.Name .. " не имеет персонажа.",
                            Duration = 3,
                        })
                    end
                end,
            })
            table.insert(tpButtonsCache, btn)
        end
    end

    if not found then
        local stub = TPTab:CreateLabel("-- Нет других игроков на сервере --")
        table.insert(tpButtonsCache, stub)
    end
end

TPTab:CreateButton({
    Name = "Обновить список игроков",
    Callback = function()
        RefreshPlayerButtons()
        Rayfield:Notify({
            Title   = "Обновлено",
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
                Content = "Сначала сохрани место!",
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

-- ═══════════════════════════════════════════════════════════
-- ================= CHEATS TAB =============================
-- ═══════════════════════════════════════════════════════════

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
    Name = "СПИДхак",
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

-- ИСПРАВЛЕННЫЙ НОУКЛИП — CanCollide = false для ВСЕХ BasePart (включая HRP)
CheatTab:CreateToggle({
    Name = "Ноуклип (Noclip)",
    CurrentValue = CheatSettings.Noclip,
    Flag = "Noclip",
    Callback = function(v)
        CheatSettings.Noclip = v
        if not v then
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

-- ═══════════════════════════════════════════════════════════
-- ================== FPS BOOST TAB =========================
-- ═══════════════════════════════════════════════════════════

FPSTab:CreateParagraph({
    Title   = "FPS Бустер",
    Content = "Выбери уровень буста FPS. Кнопка 'Сбросить' возвращает оригинальные настройки.",
})

FPSTab:CreateButton({
    Name = "Уровень 1 — Лёгкий буст",
    Callback = function()
        ApplyFPSBoost(1)
        Rayfield:Notify({
            Title   = "FPS Boost Lv.1",
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
            Title   = "FPS Boost Lv.2",
            Content = "Средний: мин. качество + тени выключены",
            Duration = 3,
        })
    end,
})

FPSTab:CreateButton({
    Name = "Уровень 3 — Сильный буст",
    Callback = function()
        ApplyFPSBoost(3)
        Rayfield:Notify({
            Title   = "FPS Boost Lv.3",
            Content = "Сильный: + частицы, огонь, дым отключены",
            Duration = 3,
        })
    end,
})

FPSTab:CreateButton({
    Name = "Уровень 4 — МАКСИМУМ",
    Callback = function()
        ApplyFPSBoost(4)
        Rayfield:Notify({
            Title   = "FPS Boost Lv.4",
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
            Content = "Все настройки возвращены к оригиналу!",
            Duration = 3,
        })
    end,
})

-- ═══════════════════════════════════════════════════════════
-- =================== EXTRA TAB ============================
-- ═══════════════════════════════════════════════════════════

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

-- ═══════════════════════════════════════════════════════════
-- ==================== INFO TAB ============================
-- ═══════════════════════════════════════════════════════════

InfoTab:CreateParagraph({
    Title   = "Universal ESP Script [v7]",
    Content = "ИСПРАВЛЕНО в v7:
"
        .. "• КРАШ Rayfield — убран конфликт Keybind/ToggleUIKeybind
"
        .. "• КРАШ Icon — убран параметр (не поддерживается)
"
        .. "• КРАШ ConfigurationSaving — отключён по умолчанию
"
        .. "• КРАШ settings().Rendering — обёрнут в pcall
"
        .. "• Ноуклип — HRP тоже получает CanCollide=false
"
        .. "• TP — ники больше не дублируются

"
        .. "НОВОЕ:
"
        .. "• FPS Boost (4 уровня + сброс)
"
        .. "• Проверка Drawing API

"
        .. "УПРАВЛЕНИЕ:
"
        .. "• RightShift — открыть/закрыть меню",
})

-- ═══════════════════════════════════════════════════════════
-- ========= HELPERS / CORE ESP FUNCTIONS ===================
