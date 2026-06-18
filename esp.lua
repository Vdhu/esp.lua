--[[
    Универсальный ESP скрипт - УЛУЧШЕННАЯ ВЕРСИЯ v4
    Работает во ВСЕХ Roblox играх

    Изменения версии 4:
    - ИСПРАВЛЕНЫ ползунки (слайдеры) ESP и Дополнительные разделы
    - Добавлено ТП к игрокам (список выбора)
    - Добавлено сохранение позиции + ТП на сохранённое место
    - Бесконечный прыжок
    - СПИДхак (слайдер скорости)
    - Ноуклип (проходить сквозь стену)

    Открыть меню: Правая клавиша Shift
]]

if  not game:IsLoaded() then game.Loaded:Wait() end

local  Rayfield = loadstring(game:HttpGet( "https://sirius.menu/rayfield" ))()

local  Window = Rayfield:CreateWindow({
    Name = «Универсальный сценарий ESP [v4]» ,
    Иконка = 4483362458 ,
    LoadingTitle = "Универсальный ESP-скрипт" ,
    LoadingSubtitle = "Загрузка улучшенной версии 4..." ,
    DisableRayfieldPrompts = true ,
    DisableBuildWarnings = true ,
    ConfigurationSaving = {
        Enabled = true ,
        FolderName = "UniversalESPScript" ,
        FileName = "ESPSettings"
    },
    Keybind = Enum.KeyCode.RightShift,
    ToggleUIKeybind = Enum.KeyCode.RightShift,
})

local  ESPTab    = Window:CreateTab( "ESP Settings" , 4483362458 )
 local  TPTab     = Window:CreateTab( "Teleport" , 4483362458 )
 local  CheatTab = Window:CreateTab( "Cheats" , 4483362458 )
 local  ExtraTab = Window:CreateTab( "Extra" , 4483362458 )
 local  InfoTab   = Window:CreateTab( "Info" , 4483362458 )

-- ========== СЕРВИСЫ ========== 
local  Players     = game:GetService( "Players" )
 local  RunService = game:GetService( "RunService" )
 local  UIS         = game:GetService( "UserInputService" )
 local  LP          = Players.LocalPlayer
 local  Camera      = workspace.CurrentCamera

-- ========== НАСТРОЙКИ ========== 
локальные  настройки = {
    Enabled = true ,
    TeamCheck = true ,
    ShowBox = true ,
    ShowTracer = true ,
    ShowName = true ,
    ShowHealth = true ,
    ShowDistance = true ,
    ShowSkeleton = true ,
    ShowChams = true ,
    ShowAimDir = false ,
    ShowLookingAtYou = false ,
    MaxDistance = 1500 ,
    VisibleColor = Color3.fromRGB( 50 , 255 , 80 ),
    HiddenColor = Color3.fromRGB( 255 , 50 , 50 ),
    TeamColor = Color3.fromRGB( 50 , 150 , 255 ),
    Толщина скелета = 2 ,
    AimLineLength = 15 ,
    ChamsFillTransparency = 0.45 ,
    ChamsOutlineTransparency = 0 ,
}

-- ========== НАСТРОЙКИ ЧИТОВ ========== 
local  CheatSettings = {
    InfiniteJump = false ,
    Noclip = false ,
    SpeedEnabled = false ,
    SpeedValue = 16 ,
    SavedPosition = nil ,   -- CFrame для сохранённого места
}

-- ========== ПАЛЕТТА ========== 
локальная  палитра = {
    HealthHigh = Color3.fromRGB( 0 , 255 , 0 ),
    HealthMid = Color3.fromRGB( 255 , 255 , 0 ),
    HealthLow = Color3.fromRGB( 255 , 0 , 0 ),
    HealthBg = Color3.fromRGB( 40 , 40 , 40 ),
    LookingAtYou = Color3.fromRGB( 255 , 255 , 0 ),
    AimDir = Color3.fromRGB( 255 , 150 , 0 ),
}

-- ========== ПАПКА CHAMS ========== 
local  ChamsFolder = Instance.new( "Folder" )
ChamsFolder.Name = "UniversalESP_Chams" 
pcall( function ()
     local  CoreGui = game:GetService( "CoreGui" )
     local  old = CoreGui:FindFirstChild(ChamsFolder.Name)
     if old then old:Destroy() end
    ChamsFolder.Parent = CoreGui
конец )
 если  не ChamsFolder.Parent , то 
    pcall( function ()
         local  pg = LP:WaitForChild( "PlayerGui" )
         local  old = pg:FindFirstChild(ChamsFolder.Name)
         if old then old:Destroy() end
        ChamsFolder.Parent = pg
    конец )
 конец 
если  не ChamsFolder.Parent тогда ChamsFolder.Parent = рабочая область конец

-- ==================================================
-- =================== ESP TAB ======================
-- ==================================================

ESPTab:CreateToggle({
    Имя = "Включить ESP" ,
    CurrentValue = Settings.Enabled,
    Флаг = "ESP_Enabled" ,
    Callback = function (v) Settings.Enabled = v end ,
})

ESPTab:CreateToggle({
    Название = "Проверка команды" ,
    CurrentValue = Settings.TeamCheck,
    Флаг = "TeamCheck" ,
    Callback = function (v) Settings.TeamCheck = v end ,
})

ESPTab:CreateDivider()

ESPTab:CreateToggle({
    Имя = "Box ESP" ,
    CurrentValue = Settings.ShowBox,
    Флаг = "BoxESP" ,
    Callback = function (v) Settings.ShowBox = v end ,
})

ESPTab:CreateToggle({
    Название = "Трассеры" ,
    CurrentValue = Settings.ShowTracer,
    Флаг = "Трассеры" ,
    Callback = function (v) Settings.ShowTracer = v end ,
})

ESPTab:CreateToggle({
    Имя = "Skeleton ESP" ,
    CurrentValue = Settings.ShowSkeleton,
    Флаг = "SkeletonESP" ,
    Callback = function (v) Settings.ShowSkeleton = v end ,
})

ESPTab:CreateToggle({
    Имя = "Chams / Highlight ESP" ,
    CurrentValue = Settings.ShowChams,
    Флаг = "ChamsESP" ,
    Callback = function (v) Settings.ShowChams = v end ,
})

ESPTab:CreateToggle({
    Name = "Имя игрока" ,
    CurrentValue = Settings.ShowName,
    Флаг = "NameESP" ,
    Callback = function (v) Settings.ShowName = v end ,
})

ESPTab:CreateToggle({
    Имя = "Полоска здоровья" ,
    CurrentValue = Settings.ShowHealth,
    Флаг = "HealthESP" ,
    Callback = function (v) Settings.ShowHealth = v end ,
})

ESPTab:CreateToggle({
    Name = "Дистанция" ,
    CurrentValue = Settings.ShowDistance,
    Флаг = "DistanceESP" ,
    Callback = function (v) Settings.ShowDistance = v end ,
})

ESPTab:CreateToggle({
    Name = "🎯 Направление взгляда (AIM DIR)" ,
    CurrentValue = Settings.ShowAimDir,
    Flag = "AimDir" ,
    Callback = function (v) Settings.ShowAimDir = v end ,
})

ESPTab:CreateToggle({
    Name = "👁️ Предупреждение 'Смотрит на тебя'" ,
    CurrentValue = Settings.ShowLookingAtYou,
    Флаг = "LookingAtYou" ,
    Callback = function (v) Settings.ShowLookingAtYou = v end ,
})

ESPTab:CreateDivider()

-- ИСПРАВЛЕННЫЕ ПОЛЗУНКИ: использование правильного синтаксиса Rayfield
ESPTab:CreateSlider({
    Name = "Максимальная дистанция ESP" ,
    Диапазон = { 100 , 3000 },
    Шаг = 50 ,
    Суффикс = "шпильки" ,
    CurrentValue = Settings.MaxDistance,
    Flag = "MaxDistance" ,
    Функция обратного вызова = функция (v)
        Settings.MaxDistance = tonumber(v) or  1500 
    end ,
})

ESPTab:CreateSlider({
    Name = "Толщина скелета" ,
    Диапазон = { 1 , 5 },
    Шаг = 1 ,
    Суффикс = "px" ,
    CurrentValue = Settings.SkeletonThickness,
    Flag = "SkeletonThickness" ,
    Функция обратного вызова = функция (v)
        Settings.SkeletonThickness = tonumber(v) or  2 
    end ,
})

ESPTab:CreateSlider({
    Name = "Длина линии взгляда" ,
    Диапазон = { 5 , 50 },
    Шаг = 1 ,
    Суффикс = "шпильки" ,
    CurrentValue = Settings.AimLineLength,
    Flag = "AimLineLength" ,
    Функция обратного вызова = функция (v)
        Settings.AimLineLength = tonumber(v) or  15 
    end ,
})

-- ==================================================
-- ================ ВКЛАДКА ТЕЛЕПОРТАЦИИ =====================
-- ==================================================

TPTab:CreateSection( "Телепорт к игрокам" )

-- Кнопка обновления списка + кнопка ТП режима воздействия 
local  tpButtonsCache = {}

локальная функция  RefreshPlayerButtons ()
     -- Удаляем старые кнопки 
    for _, btn in пары(tpButtonsCache) do 
        pcall( function () btn:Destroy() end )
     end
    tpButtonsCache = {}

    for _, player in pairs(Players:GetPlayers()) do 
        if player ~= LP then 
            local  btn = TPTab:CreateButton({
                Name= "🌀 ТП к: " .. player.Name,
                Callback = function ()
                     local  char = LP.Character
                     local  root = char and char:FindFirstChild( "HumanoidRootPart" )
                     local  tChar = player.Character
                     local  tRoot = tChar and tChar:FindFirstChild( "HumanoidRootPart" )
                     if root and tRoot then 
                        root.CFrame = tRoot.CFrame + Vector3.new( 0 , 3 , 0 )
                        Рэйфилд:Уведомить({
                            Заголовок = "Телепорт" ,
                            Content= "ТП к" .. player.Name .. " выполнено!" ,
                            Длительность = 3 ,
                        })
                    еще
                        Рэйфилд:Уведомить({
                            Title = "Ошибка" ,
                            Content = "Игрок" .. player.Name .. " не имеет персонажа." ,
                            Длительность = 3 ,
                        })
                    
                конец конец ,
            })
            table.insert(tpButtonsCache, btn)
        конец 
    конец

    if #tpButtonsCache == 0  then 
        local  stub = TPTab:CreateLabel( "— Нет других игроков на сервере —" )
        table.insert(tpButtonsCache, stub)
    конец 
конец

TPTab:CreateButton({
    Name = "🔄 Обновить список игроков" ,
    Функция обратного вызова = функция ()
        RefreshPlayerButtons()
        Рэйфилд:Уведомить({
            Title = "Список обновлён" ,
            Content = "Список игроков обновлён." ,
            Длительность = 2 ,
        })
    конец ,
})

RefreshPlayerButtons()

Players.PlayerAdded:Connect( function () RefreshPlayerButtons() end )
Players.PlayerRemoving:Connect( function () RefreshPlayerButtons() end )

TPTab:CreateDivider()
TPTab:CreateSection( "Сохранение позиции" )

TPTab:CreateButton({
    Name = "📍 сохранить текущее место" ,
    Callback = function ()
         local  char = LP.Character
         local  root = char and char:FindFirstChild( "HumanoidRootPart" )
         if root then
            CheatSettings.SavedPosition = root.CFrame
            Рэйфилд:Уведомить({
                Title = "📍 Место сохранено" ,
                Content = "Позиция сохранена! Используй 'ТП на сохранённое место'." ,
                Длительность = 3 ,
            })
        еще
            Рэйфилд:Уведомить({
                Title = "Ошибка" ,
                Content = "Персонаж не найден." ,
                Длительность = 3 ,
            })
        
    конец конец ,
})

TPTab:CreateButton({
    Name= "🔙 ТП на сохранённое место" ,
    Функция обратного вызова = функция ()
         если  не CheatSettings.SavedPosition тогда
            Рэйфилд:Уведомить({
                Title = "Ошибка" ,
                Content = "Сначала сохранилось место клавиши выше!" ,
                Длительность = 3 ,
            })
            return 
        end 
        local  char = LP.Character
         local  root = char and char:FindFirstChild( "HumanoidRootPart" )
         if root then
            root.CFrame = CheatSettings.SavedPosition
            Рэйфилд:Уведомить({
                Title = "🔙 Телепортировано" ,
                Content = "Вернулся на сохранённое место!" ,
                Длительность = 3 ,
            })
        еще
            Рэйфилд:Уведомить({
                Title = "Ошибка" ,
                Content = "Персонаж не найден." ,
                Длительность = 3 ,
            })
        
    конец конец ,
})

-- ==================================================
-- ================= Вкладка ЧИТЫ ======================
-- ==================================================

CheatTab:CreateSection( "Движение" )

-- БЕСКОНЕЧНЫЙ ПРЫЖОК
CheatTab:CreateToggle({
    Name = "🐇 Бесконечный прыжок" ,
    CurrentValue = CheatSettings.InfiniteJump,
    Флаг = "Бесконечный прыжок" ,
    Функция обратного вызова = функция (v)
        CheatSettings.InfiniteJump = v
        Рэйфилд:Уведомить({
            Title = "Бесконечный прыжок" ,
            Content = v и  «ВКЛЮЧЕН ✅»  или  «ВЫКЛЮЧЕН ❌» ,
            Длительность = 2 ,
        })
    конец ,
})

-- СПИДхак - ВКЛЮЧАТЕЛЬ
CheatTab:CreateToggle({
    Name= "⚡ СПИДхак (SpeedHack)" ,
    CurrentValue = CheatSettings.SpeedEnabled,
    Flag = "SpeedEnabled" ,
    Функция обратного вызова = функция (v)
        CheatSettings.SpeedEnabled = v
        local  char = LP.Character
         local  hum = char and char:FindFirstChildOfClass( "Humanoid" )
         if hum then 
            hum.WalkSpeed = v and CheatSettings.SpeedValue or  16 
        end
        Рэйфилд:Уведомить({
            Title = "потреблениехак" ,
            Content = v and ( "ВКЛЮЧЁН ✅ | Скорость: " .. CheatSettings.SpeedValue) или  "ВЫКЛЮЧЕН ❌ | Скорость сброшена" ,
            Длительность = 2 ,
        })
    конец ,
})

-- СПИДхак - ПОЛЗУНОК
CheatTab:CreateSlider({
    Имя = "⚡ Скорость (WalkSpeed)" ,
    Диапазон = { 16 , 300 },
    Шаг = 1 ,
    Суффикс = "sp" ,
    CurrentValue = CheatSettings.SpeedValue,
    Flag = "SpeedValue" ,
    Функция обратного вызова = функция (v)
        CheatSettings.SpeedValue = tonumber(v) or  16 
        if CheatSettings.SpeedEnabled then 
            local  char = LP.Character
             local  hum = char and char:FindFirstChildOfClass( "Humanoid" )
             if hum then
                hum.WalkSpeed = CheatSettings.SpeedValue
            конец 
        конец 
    конец ,
})

CheatTab:CreateDivider()
CheatTab:CreateSection( "Коллизии" )

-- НОУКЛИП
CheatTab:CreateToggle({
    Name= "👻 Ноуклип (Noclip)" ,
    CurrentValue = CheatSettings.Noclip,
    Flag = "Noclip" ,
    Функция обратного вызова = функция (v)
        CheatSettings.Noclip = v
        -- При отключении — сразу восстановить коллизии, 
        если  не v, то 
            локальный  char = LP.Character
             , если char , то 
                для _, часть парами (char:GetDescendants()) do 
                    if part:IsA( "BasePart" ) и part.Name ~= "HumanoidRootPart"  then 
                        part.CanCollide = true 
                    end 
                end 
            end 
        end
        Рэйфилд:Уведомить({
            Title = "Ноуклип" ,
            Content = v и  «ВКЛЮЧЁН ✅ — проходишь сквозь стену!»  или  «ВЫКЛЮЧЕН ❌ — коллизии восстановлены» ,
            Длительность = 2 ,
        })
    конец ,
})

-- ========== ЛОГИКА БЕСКОНЕЧНОГО ПРЫЖКА ========== 
UIS.JumpRequest:Connect( function ()
     if CheatSettings.InfiniteJump then 
        local  char = LP.Character
         local  hum = char and char:FindFirstChildOfClass( "Humanoid" )
         if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        конец 
    конец 
конец )

-- ========== NOCLIP + SPEED LOOP ========== 
RunService.Stepped:Connect( function ()
     if CheatSettings.Noclip then 
        local  char = LP.Character
         if char then 
            for _, part in pairs(char:GetDescendants()) do 
                if part:IsA( "BasePart" ) and part.Name ~= "HumanoidRootPart"  then 
                    part.CanCollide = false 
                end 
            end 
        end 
    end 
end )

-- Восстанавливаем скорость приспавне 
LP.CharacterAdded:Connect( function (char)
     local  hum = char:WaitForChild( "Humanoid" )
     if CheatSettings.SpeedEnabled then
        hum.WalkSpeed = CheatSettings.SpeedValue
    конец 
конец )

-- ========== ДОПОЛНИТЕЛЬНАЯ ВКЛАДКА (ESP) ==========

ExtraTab:CreateParagraph({
    Title = "Дополнительные опции ESP" ,
    Content = «Дополнительные параметры ESP — переработано из старых вкладок Extra». ,
})

ExtraTab:CreateSlider({
    Name = "Прозрачность заливки Chams" ,
    Диапазон = { 0 , 100 },
    Шаг = 5 ,
    Суффикс = " %" ,
    CurrentValue = math.floor(Settings.ChamsFillTransparency * 100 ),
    Flag = "ChamsFill" ,
    Функция обратного вызова = функция (v)
        Settings.ChamsFillTransparency = (tonumber(v) or  45 ) / 100 
    end ,
})

ExtraTab:CreateSlider({
    Name = "Прозрачность обводки Chams" ,
    Диапазон = { 0 , 100 },
    Шаг = 5 ,
    Суффикс = " %" ,
    CurrentValue = math.floor(Settings.ChamsOutlineTransparency * 100 ),
    Flag = "ChamsOutline" ,
    Функция обратного вызова = функция (v)
        Settings.ChamsOutlineTransparency = (tonumber(v) or  0 ) / 100 
    end ,
})

-- ========== Вкладка ИНФОРМАЦИЯ ==========

InfoTab:CreateParagraph({
    Заголовок = "Универсальный скрипт ESP [v4]" ,
    Content = "🔧 ИСПРАВЛЕНО:\n• Ползунки ESP теперь работают корректно\n\n🆕 ДОБАВЛЕНО:\n• ТП к игрокам (вкладка Teleport)\n• Сохранение места +\n• Бесконечный прыжок\n• СПИДхак с ползунком\n• Ноуклип\n\n📌 ESP ФУНКЦИИ:\n• Box ESP\n• Chams/Highlight ESP\n• Скелет ESP\n• Трейсеры\n• Имя, HP, Дистанция\n• Зелёный = виден, Красный = за стеной\n• Team Check\n\n⌨️ УПРАВЛЕНИЕ:\n• RightShift — открыть/закрыть меню"
})

-- ==================================================
-- ========= ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ / ОСНОВНЫЕ ФУНКЦИИ ESP ============
-- ==================================================

локальная функция  SetObjectVisible (obj, state)
     если  не obj, то  вернуть  конец 
    , если typeof(obj) == "Instance"  , то 
        если obj:IsA( "Highlight" ) , то
            obj.Enabled = state
        elseif obj:IsA( "GuiObject" ) then
            obj.Visible = state
        end 
    else 
        pcall( function () obj.Visible = state end )
     end 
end

локальная функция  RemoveObject (obj)
     если  не obj тогда  вернуть  конец 
    pcall( функция ()
         если typeof(obj) == "Instance"  тогда
            obj:Destroy()
        еще
            obj:Remove()
        конец 
    конец )
 конец

локальная функция  IsTeammate (Player)
     если  не Settings.TeamCheck , то  вернуть  false  конец 
    если LP.Team и Player.Team и LP.Team == Player.Team , то  вернуть  true  конец 
    локальная функция  lc , pc = LP.Character, Player.Character
     если lc и pc и lc.Parent и pc.Parent
         и lc.Parent == pc.Parent и lc.Parent ~= workspace , то 
        вернуть  true 
    конец 
    вернуть  false 
конец

локальная функция  GetColor (Player, IsVisible)
     если IsTeammate(Player) тогда  вернуть Settings.TeamColor конец 
    вернуть IsVisible и Settings.VisibleColor или Settings.HiddenColor
 конец

локальная функция  GetHealthColor (hp, max)
     локальный  pct = hp / max
     если pct > 0.6  тогда  вернуть Palette.HealthHigh конец 
    если pct > 0.3  тогда  вернуть Palette.HealthMid конец 
    вернуть Palette.HealthLow
 конец

local function  IsPartVisibleToCamera (part, targetChar)
     if  not Camera or  not part or  not part:IsA( "BasePart" ) or  not targetChar then  return  false  end 
    local  origin = Camera.CFrame.Position
     local  target = part.Position
     local  direction = target - origin
     if direction.Magnitude <= 0.1  then  return  true  end 
    local  ignoreList = {}
     if LP.Character then table.insert(ignoreList, LP.Character) end 
    pcall( function () table.insert(ignoreList, Camera) end )
     local  params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = ignoreList
    params.IgnoreWater = true 
    local  currentOrigin = origin
     for _ = 1 , 8  do 
        local  curDir = target - currentOrigin
         if curDir.Magnitude <= 0.1  then  return  true  end 
        local  result = workspace:Raycast(currentOrigin, curDir, params)
         if  not result then  return  true  end 
        local  hit = result.Instance
         if hit and hit:IsDescendantOf(targetChar) then  return  true  end 
        local  canSkip = false 
        pcall( function () canSkip = (hit.Transparency >= 0.75 ) or (hit.CanCollide == false ) end )
         if canSkip and hit then
            table.insert(ignoreList, hit)
            params.FilterDescendantsInstances = ignoreList
            currentOrigin = result.Position + curDir.Unit * 0.05 
        else 
            return  false 
        end 
    end 
    return  false 
end

local function  IsCharacterVisible (char)
     if  not char then  return  false  end 
    for _, name in ipairs({ "Head" , "UpperTorso" , "Torso" , "HumanoidRootPart" , "LowerTorso" }) do 
        local  part = char:FindFirstChild(name)
         if part and part:IsA( "BasePart" ) and IsPartVisibleToCamera(part, char) then 
            return  true 
        end 
    end 
    return  false 
end

local function  IsLookingAtYou (char)
     if  not LP.Character then  return  false  end 
    local  myHead = LP.Character:FindFirstChild( "Head" ) or LP.Character:FindFirstChild( "HumanoidRootPart" )
     local  head = char:FindFirstChild( "Head" )
     if  not myHead or  not head then  return  false  end 
    local  ok , res = pcall( function ()
         return ((myHead.Position - head.Position).Unit):Dot(head.CFrame.LookVector) > 0.85 
    end )
     return ok and res or  false 
end

-- ========== ESP DRAWING OBJECTS ==========

local  ESPCache = {}

локальная функция  NewLine (thickness, transp)
     local  l = Drawing.new( "Line" )
    l.Thickness = thickness or  1.5 
    l.Transparency = transp or  0.7 
    l.Visible = false 
    return l
 end

локальная функция  NewText (размер)
     локальная  t = Drawing.new( "Text" )
    t.Size = size or  12 
    t.Center = true 
    t.Outline = true 
    t.Font = 2 
    t.Visible = false 
    return t
 end

локальная функция  NewChams ()
     local  h = Instance.new( "Highlight" )
    h.Name = "UniversalESP_Chams" 
    h.Enabled = false
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.FillTransparency = Settings.ChamsFillTransparency
    h.OutlineTransparency = Settings.ChamsOutlineTransparency
    h.Parent = ChamsFolder
    возврат h
 конец

локальная функция  CreateESP (Player)
     если Player == LP тогда  вернуть  конец 
    если ESPCache[Player] тогда  вернуть  конец 
    локальный  Skel = {
        HeadTorso = NewLine(Settings.SkeletonThickness, 0.8 ),
        TorsoHip = NewLine(Settings.SkeletonThickness, 0.8 ),
        TorsoLeftShoulder = NewLine(Settings.SkeletonThickness, 0.8 ),
        LeftShoulderElbow = NewLine(Settings.SkeletonThickness, 0.8 ),
        LeftElbowHand = NewLine(Settings.SkeletonThickness, 0.8 ),
        TorsoRightShoulder = NewLine(Settings.SkeletonThickness, 0.8 ),
        RightShoulderElbow = NewLine(Settings.SkeletonThickness, 0.8 ),
        RightElbowHand = NewLine(Settings.SkeletonThickness, 0.8 ),
        HipLeftKnee = NewLine(Settings.SkeletonThickness, 0.8 ),
        LeftKneeFoot = NewLine(Settings.SkeletonThickness, 0.8 ),
        HipRightKnee = NewLine(Settings.SkeletonThickness, 0.8 ),
        RightKneeFoot = NewLine(Settings.SkeletonThickness, 0.8 ),
    }
    ESPCache[Player] = {
        BoxTop = NewLine(), BoxBot = NewLine(),
        BoxLeft = NewLine(), BoxRight = NewLine(),
        Tracer = NewLine( 1 , 0.8 ),
        Имя = НовыйТекст( 12 ),
        Расстояние = NewText( 10 ),
        HpBg = NewLine( 4 , 1 ),
        HpFill = NewLine( 4 , 1 ),
        Skeleton = Skel,
        AimLine = NewLine( 2 , 0.9 ),
        LookingText = NewText( 13 ),
        Chams = NewChams(),
    }
    ESPCache[Player].HpBg.Color = Palette.HealthBg
    ESPCache[Player].Distance.Font = 1
    ESPCache[Player].LookingText.Color = Palette.LookingAtYou
конец

локальная функция  RemoveESP (Player)
     local  o = ESPCache[Player]
     if  not o then  return  end 
    for _, d in pairs(o) do 
        if type(d) == "table"  then 
            for _, obj in pairs(d) do RemoveObject(obj) end 
        else
            RemoveObject(d)
        конец 
    конец 
    ESPCache[Player] = nil 
конец

локальная функция  HideESP (o)
     для _, d в pairs(o) выполнить 
        , если type(d) == "table",  тогда 
            для _, obj в pairs(d) выполнить SetObjectVisible(obj, false ) в 
        противном случае 
            SetObjectVisible(d, false )
         конец 
    конец 
конец

локальная функция  UpdateChams (Player, o, Char, Col)
     если  не o.Chams , то  вернуть  конец 
    , если Settings.ShowChams и Char , то 
        если o.Chams.Adornee ~= Char , то o.Chams.Adornee = Char конец
        o.Chams.FillColor = Col
        o.Chams.OutlineColor = Col
        o.Chams.FillTransparency = Settings.ChamsFillTransparency
        o.Chams.OutlineTransparency = Settings.ChamsOutlineTransparency
        o.Chams.Enabled = true 
    else 
        o.Chams.Enabled = false 
    end 
end

local function  DrawSkeleton (Player, o, Col)
     local  Char = Player.Character
     if  not Char then  return  end 
    for _, line in pairs(o.Skeleton) do line.Visible = false  end 
    local function  GetLimbPos (pName)
         local  part = Char:FindFirstChild(pName)
         if part and part:IsA( "BasePart" ) then 
            local  ok , p , on = pcall( function ()
                 local  pos , isOn = Camera:WorldToViewportPoint(part.Position)
                 return pos, isOn
             end )
             if ok and on and pZ > 0  then 
                return Vector2.new(pX, pY), true 
            end 
        end 
        return  nil , false 
    end 
    local  isR15 = Char:FindFirstChild( "UpperTorso" ) ~= nil 
    local  skelMap = isR15 and {
        HeadTorso={ "Head" , "UpperTorso" },TorsoHip={ "UpperTorso" , "LowerTorso" },
        TorsoLeftShoulder={ "UpperTorso" , "LeftUpperArm" },LeftShoulderElbow={ "LeftUpperArm" , "LeftLowerArm" },
        LeftElbowHand={ "LeftLowerArm" , "LeftHand" },TorsoRightShoulder={ "UpperTorso" , "RightUpperArm" },
        RightShoulderElbow={ "RightUpperArm" , "RightLowerArm" },RightElbowHand={ "RightLowerArm" , "RightHand" },
        HipLeftKnee={ "LowerTorso" , "LeftUpperLeg" },LeftKneeFoot={ "LeftUpperLeg" , "LeftLowerLeg" },
        HipRightKnee={ "LowerTorso" , "RightUpperLeg" },RightKneeFoot={ "RightUpperLeg" , "RightLowerLeg" },
    } или {
        HeadTorso={ "Head" , "Torso" },TorsoLeftShoulder={ "Torso" , "Left Arm" },
        TorsoRightShoulder={ "Torso" , "Right Arm" },HipLeftKnee={ "Torso" , "Left Leg" },
        HipRightKnee={ "Torso" , "Right Leg" },
    }
    for lineName, parts in pairs(skelMap) do 
        local  line = o.Skeleton[lineName]
         if line then 
            local  p1 , v1 = GetLimbPos(parts[ 1 ])
             local  p2 , v2 = GetLimbPos(parts[ 2 ])
             if p1 and p2 and v1 and v2 then
                line.From = p1 ; line.To = p2
                line.Color = Col
                line.Thickness = Settings.SkeletonThickness
                line.Visible = true 
            end 
        end 
    end 
end

local function  DrawAimDirection (Player, o, Col)
     if  not Settings.ShowAimDir then o.AimLine.Visible = false ; return  end 
    local  Char = Player.Character
     if  not Char then o.AimLine.Visible = false ; return  end 
    local  head = Char:FindFirstChild( "Head" )
     if  not head or  not head:IsA( "BasePart" ) then o.AimLine.Visible = false ; return  end 
    local  ok , res = pcall( function ()
         local  aimEnd = head.Position + head.CFrame.LookVector * Settings.AimLineLength
         local  hS , hOn = Camera:WorldToViewportPoint(head.Position)
         local  aS , aOn = Camera:WorldToViewportPoint(aimEnd)
         if hOn and aOn and hS.Z > 0  and aS.Z > 0  then
            o.AimLine.From = Vector2.new(hS.X, hS.Y)
            o.AimLine.To = Vector2.new(aS.X, aS.Y)
            o.AimLine.Color = Palette.AimDir
            o.AimLine.Visible = true 
            return  true 
        end 
        return  false 
    end )
     if  not ok or  not res then o.AimLine.Visible = false  end 
end

-- ========== СОБЫТИЯ ДЛЯ ИГРОКОВ ==========

for _, p in pairs(Players:GetPlayers()) do CreateESP(p) end
Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(RemoveESP)

-- ========== ОСНОВНОЙ ЦИКЛ ESP ==========

RunService.RenderStepped:Connect( функция ()
    Камера = рабочая область.ТекущаяКамера
    Если  камера отсутствует , то  вернуться в  конец.

    for Player, o in pairs(ESPCache) do 
        if  not Settings.Enabled then HideESP(o) ; continue  end 
        if  not Player or  not Player.Parent then HideESP(o) ; continue  end

        local  Char = Player.Character
         local  Root = Char and Char:FindFirstChild( "HumanoidRootPart" )
         local  Hum   = Char and Char:FindFirstChildOfClass( "Humanoid" )

        if  not (Char and Root and Hum and Hum.Health > 0 ) then 
            HideESP(o) ; continue 
        end

        local  ok , SP , OnScreen = pcall( function ()
             local  pos , isOn = Camera:WorldToViewportPoint(Root.Position)
             return pos, isOn
         end )
         if  not ok or  not OnScreen or SP.Z <= 0  then HideESP(o) ; continue  end

        local  Dist = (Camera.CFrame.Position - Root.Position).Magnitude
         if Dist > Settings.MaxDistance then HideESP(o) ; continue  end 
        if IsTeammate(Player) then HideESP(o) ; continue  end

        local  IsVisible = false 
        pcall( function () IsVisible = IsCharacterVisible(Char) end )

        local  BH   = 4000 / Dist
         local  BW   = 2200 / Dist
         local  X    = SP.X - BW/ 2 
        local  Y    = SP.Y - BH/ 2 
        local  Col = GetColor(Player, IsVisible)
         local  V2   = Vector2.new

        UpdateChams(Player, o, Char, Col)

        если Settings.ShowBox then
            o.BoxTop.From=V2(X,Y);o.BoxTop.To=V2(X+BW,Y)
            o.BoxBot.From=V2(X,Y+BH);o.BoxBot.To=V2(X+BW,Y+BH)
            o.BoxLeft.From=V2(X,Y);o.BoxLeft.To=V2(X,Y+BH)
            o.BoxRight.From=V2(X+BW,Y);o.BoxRight.To=V2(X+BW,Y+BH)
            for _,k in pairs({ "BoxTop" , "BoxBot" , "BoxLeft" , "BoxRight" }) do 
                o[k].Color=Col ; o[k].Visible= true 
            end 
        else 
            for _,k in pairs({ "BoxTop" , "BoxBot" , "BoxLeft" , "BoxRight" }) do 
                o[k].Visible= false 
            end 
        end

        o.Tracer.From=V2(Camera.ViewportSize.X/ 2 ,Camera.ViewportSize.Y)
        o.Tracer.To=V2(SP.X,SP.Y)
        o.Tracer.Color=Col ; o.Tracer.Visible=Settings.ShowTracer

        o.Name.Text=Player.Name ; o.Name.Position=V2(SP.X,Y- 15 )
        o.Name.Color=Col ; o.Name.Visible=Settings.ShowName

        o.Distance.Text = math.floor(Dist) ... "m" 
        o.Distance.Position = V2(SP.X, Y + BH + 4 )
        o.Distance.Color = Color3.fromRGB( 200 , 200 , 200 )
        o.Distance.Visible=Settings.ShowDistance

        if Settings.ShowHealth then 
            local  pct = math.clamp(Hum.Health/Hum.MaxHealth, 0 , 1 )
             local  bX = X- 6 
            o.HpBg.From=V2(bX,Y) ; o.HpBg.To=V2(bX,Y+BH) ; o.HpBg.Visible= true
            o.HpFill.From=V2(bX,Y+BH) ; o.HpFill.To=V2(bX,Y+BH-BH*pct)
            o.HpFill.Color = GetHealthColor(Hum.Health, Hum.MaxHealth); o.HpFill.Visible = true; 
        else 
            o.HpBg.Visible = false ; o.HpFill.Visible = false; 
        end

        if Settings.ShowSkeleton then 
            pcall( function () DrawSkeleton(Player,o,Col) end )
         else 
            for _,line in pairs(o.Skeleton) do line.Visible= false  end 
        end

        if Settings.ShowAimDir then 
            pcall( function () DrawAimDirection(Player,o,Col) end )
         else 
            o.AimLine.Visible= false 
        end

        if Settings.ShowLookingAtYou then 
            local  okL , isLooking = pcall( function () return IsLookingAtYou(Char) end )
             if okL and isLooking then 
                o.LookingText.Text= "[!] СМОТРИТ НА ТЕБЯ" 
                o.LookingText.Position=V2(SP.X,Y- 35 )
                o.LookingText.Visible = true, 
            иначе 
                o.LookingText.Visible = false; 
            иначе 
            o.LookingText.Visible = false; конец 
        ; конец ; конец ;
        
    


print( "✅ Универсальный ESP v4 загружен | RightShift = menu" )
print( "🐇 Бесконечный прыжок | ⚡ SpeedHack | 👻 Noclip | 🌀 TP" )
