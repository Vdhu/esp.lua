--[[
    Universal ESP Script - ENHANCED v5 + MOBILE BUTTON
    Works in ALL Roblox games

    Open Menu:
      [PC]     -> RightShift
      [Mobile] -> Кнопка "ESP" на экране (перетаскивается!)

    ВАЖНО: Вставляй части по порядку: сначала Часть 1, потом 2, потом 3
    ИЛИ вставь все три части подряд в один файл/окно эксплоита
]]

if not game:IsLoaded() then game.Loaded:Wait() end

-- ========== ORION UI ==========
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()

local Window = OrionLib:MakeWindow({
    Name = "Universal ESP v5",
    HidePremium = true,
    SaveConfig = true,
    ConfigFolder = "UniversalESP_v5",
    IntroEnabled = false,
    IntroText = "Universal ESP v5",
    IntroIcon = "rbxassetid://4483362458",
    ToggleKey = Enum.KeyCode.RightShift,
})

-- ========== MOBILE BUTTON ==========
local UIS2 = game:GetService("UserInputService")

local mobileGui, mobileBtn
pcall(function()
    mobileGui = Instance.new("ScreenGui")
    mobileGui.Name = "ESP_MobileToggle"
    mobileGui.ResetOnSpawn = false
    mobileGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    mobileGui.DisplayOrder = 9999
    pcall(function() mobileGui.Parent = game:GetService("CoreGui") end)
    if not mobileGui.Parent then
        mobileGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    end

    local frame = Instance.new("Frame")
    frame.Name = "BtnFrame"
    frame.Size = UDim2.new(0, 90, 0, 42)
    frame.Position = UDim2.new(0, 12, 0.5, -21)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    frame.BackgroundTransparency = 0.15
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Draggable = true
    frame.Parent = mobileGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(80, 200, 255)
    stroke.Thickness = 1.5
    stroke.Transparency = 0.3
    stroke.Parent = frame

    mobileBtn = Instance.new("TextButton")
    mobileBtn.Name = "MobileMenuBtn"
    mobileBtn.Size = UDim2.new(1, 0, 1, 0)
    mobileBtn.Position = UDim2.new(0, 0, 0, 0)
    mobileBtn.BackgroundTransparency = 1
    mobileBtn.Text = "ESP"
    mobileBtn.TextColor3 = Color3.fromRGB(80, 210, 255)
    mobileBtn.TextSize = 16
    mobileBtn.Font = Enum.Font.GothamBold
    mobileBtn.Parent = frame

    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 40)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 25)),
    })
    grad.Rotation = 90
    grad.Parent = frame

    frame.Visible = true

    local menuOpen = false
    mobileBtn.MouseButton1Click:Connect(function()
        menuOpen = not menuOpen
        local ok = pcall(function() Window:Toggle() end)
        if not ok then
            pcall(function()
                local gui = game:GetService("CoreGui"):FindFirstChild("Orion")
                if gui then gui.Enabled = not gui.Enabled end
            end)
        end
        if menuOpen then
            mobileBtn.Text = "X ESP"
            mobileBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
            stroke.Color = Color3.fromRGB(255, 100, 100)
        else
            mobileBtn.Text = "ESP"
            mobileBtn.TextColor3 = Color3.fromRGB(80, 210, 255)
            stroke.Color = Color3.fromRGB(80, 200, 255)
        end
    end)
end)

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

-- ========== FPS SETTINGS ==========
local FPSOriginal = {
    Quality        = Enum.QualityLevel.Automatic,
    ShadowMap      = Lighting.GlobalShadows,
    Ambient        = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    FogEnd         = Lighting.FogEnd,
    MeshDetail     = nil,
    Saved          = false,
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
-- ========== ESP TAB ==========
ESPTab:AddToggle({
    Name    = "Включить ESP",
    Default = Settings.Enabled,
    Save    = true, Flag = "ESP_Enabled",
    Callback = function(v) Settings.Enabled = v end,
})
ESPTab:AddToggle({
    Name    = "Team Check (скрыть союзников)",
    Default = Settings.TeamCheck,
    Save    = true, Flag = "TeamCheck",
    Callback = function(v) Settings.TeamCheck = v end,
})
ESPTab:AddDivider()
ESPTab:AddToggle({ Name = "Box ESP",          Default = Settings.ShowBox,          Save = true, Flag = "BoxESP",      Callback = function(v) Settings.ShowBox      = v end })
ESPTab:AddToggle({ Name = "Tracers",          Default = Settings.ShowTracer,       Save = true, Flag = "Tracers",     Callback = function(v) Settings.ShowTracer   = v end })
ESPTab:AddToggle({ Name = "Skeleton ESP",     Default = Settings.ShowSkeleton,     Save = true, Flag = "SkeletonESP", Callback = function(v) Settings.ShowSkeleton = v end })
ESPTab:AddToggle({ Name = "Chams/Highlight",  Default = Settings.ShowChams,        Save = true, Flag = "ChamsESP",    Callback = function(v) Settings.ShowChams    = v end })
ESPTab:AddToggle({ Name = "Имя игрока",       Default = Settings.ShowName,         Save = true, Flag = "NameESP",     Callback = function(v) Settings.ShowName     = v end })
ESPTab:AddToggle({ Name = "Полоска здоровья", Default = Settings.ShowHealth,       Save = true, Flag = "HealthESP",   Callback = function(v) Settings.ShowHealth   = v end })
ESPTab:AddToggle({ Name = "Дистанция",        Default = Settings.ShowDistance,     Save = true, Flag = "DistanceESP", Callback = function(v) Settings.ShowDistance = v end })
ESPTab:AddToggle({ Name = "AIM DIR",          Default = Settings.ShowAimDir,       Save = true, Flag = "AimDir",      Callback = function(v) Settings.ShowAimDir   = v end })
ESPTab:AddToggle({ Name = "Смотрит на тебя", Default = Settings.ShowLookingAtYou, Save = true, Flag = "LookingAtYou",Callback = function(v) Settings.ShowLookingAtYou = v end })
ESPTab:AddDivider()
ESPTab:AddSlider({ Name = "Макс. дистанция", Min = 100, Max = 3000, Default = Settings.MaxDistance,              Color = Color3.fromRGB(255,255,255), Increment = 50, ValueName = "studs", Callback = function(v) Settings.MaxDistance        = tonumber(v) or 1500 end })
ESPTab:AddSlider({ Name = "Толщина скелета", Min = 1,   Max = 5,    Default = Settings.SkeletonThickness,        Color = Color3.fromRGB(255,255,255), Increment = 1,  ValueName = "px",    Callback = function(v) Settings.SkeletonThickness  = tonumber(v) or 2    end })
ESPTab:AddSlider({ Name = "Длина взгляда",   Min = 5,   Max = 50,   Default = Settings.AimLineLength,            Color = Color3.fromRGB(255,255,255), Increment = 1,  ValueName = "studs", Callback = function(v) Settings.AimLineLength      = tonumber(v) or 15   end })
ESPTab:AddSlider({ Name = "Прозр. Chams",    Min = 0,   Max = 100,  Default = math.floor(Settings.ChamsFillTransparency*100), Color = Color3.fromRGB(255,255,255), Increment = 5, ValueName = "%", Callback = function(v) Settings.ChamsFillTransparency = (tonumber(v) or 45)/100 end })

-- ========== TELEPORT TAB ==========
local tpButtons = {}
TPTab:AddButton({
    Name = "Обновить список игроков",
    Callback = function()
        for _,b in pairs(tpButtons) do pcall(function() b:Destroy() end) end
        tpButtons = {}
        for _,plr in pairs(Players:GetPlayers()) do
            if plr ~= LP then
                local btn = TPTab:AddButton({
                    Name = "ТП к: "..plr.Name,
                    Callback = function()
                        pcall(function()
                            local char = plr.Character
                            if char then
                                local root = char:FindFirstChild("HumanoidRootPart")
                                if root and LP.Character then
                                    LP.Character:FindFirstChild("HumanoidRootPart").CFrame = root.CFrame + Vector3.new(3,0,0)
                                end
                            end
                        end)
                    end,
                })
                table.insert(tpButtons, btn)
            end
        end
    end,
})

-- ========== CHEATS TAB ==========
CheatTab:AddToggle({
    Name = "Бесконечный прыжок",
    Default = CheatSettings.InfiniteJump,
    Save = true, Flag = "InfJump",
    Callback = function(v)
        CheatSettings.InfiniteJump = v
        if v then
            UIS.JumpRequest:Connect(function()
                if CheatSettings.InfiniteJump then
                    pcall(function()
                        LP.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
                    end)
                end
            end)
        end
    end,
})

local noclipConn
CheatTab:AddToggle({
    Name = "Ноуклип",
    Default = CheatSettings.Noclip,
    Save = true, Flag = "Noclip",
    Callback = function(v)
        CheatSettings.Noclip = v
        if v then
            noclipConn = RunService.RenderStepped:Connect(function()
                if CheatSettings.Noclip then
                    pcall(function()
                        for _,p in pairs(LP.Character:GetDescendants()) do
                            if p:IsA("BasePart") then p.CanCollide = false end
                        end
                    end)
                end
            end)
        else
            if noclipConn then noclipConn:Disconnect() noclipConn = nil end
            pcall(function()
                for _,p in pairs(LP.Character:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = true end
                end
            end)
        end
    end,
})

CheatTab:AddToggle({
    Name = "СПИДхак",
    Default = CheatSettings.SpeedEnabled,
    Save = true, Flag = "Speed",
    Callback = function(v)
        CheatSettings.SpeedEnabled = v
        pcall(function()
            local hum = LP.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = v and CheatSettings.SpeedValue or 16 end
        end)
    end,
})

CheatTab:AddSlider({
    Name = "Скорость",
    Min = 16, Max = 200, Default = CheatSettings.SpeedValue,
    Color = Color3.fromRGB(255,255,255), Increment = 1, ValueName = "sp",
    Callback = function(v)
        CheatSettings.SpeedValue = tonumber(v) or 16
        if CheatSettings.SpeedEnabled then
            pcall(function()
                LP.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = CheatSettings.SpeedValue
            end)
        end
    end,
})

CheatTab:AddButton({
    Name = "Сохранить позицию",
    Callback = function()
        pcall(function()
            local root = LP.Character:FindFirstChild("HumanoidRootPart")
            if root then CheatSettings.SavedPosition = root.CFrame end
        end)
    end,
})

CheatTab:AddButton({
    Name = "Вернуться на позицию",
    Callback = function()
        if CheatSettings.SavedPosition then
            pcall(function()
                LP.Character:FindFirstChild("HumanoidRootPart").CFrame = CheatSettings.SavedPosition
            end)
        end
    end,
})

-- ========== FPS TAB ==========
FPSTab:AddButton({
    Name = "FPS Boost: Низкое качество",
    Callback = function()
        SaveOriginalGraphics()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
    end,
})
FPSTab:AddButton({
    Name = "FPS Boost: Среднее качество",
    Callback = function()
        SaveOriginalGraphics()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level05
        Lighting.GlobalShadows = false
    end,
})
FPSTab:AddButton({
    Name = "FPS Boost: Макс. boost",
    Callback = function()
        SaveOriginalGraphics()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.fromRGB(178,178,178)
        Lighting.OutdoorAmbient = Color3.fromRGB(178,178,178)
        Lighting.FogEnd = 9e9
        for _,v in pairs(workspace:GetDescendants()) do
            pcall(function()
                if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") then
                    v.Enabled = false
                end
            end)
        end
    end,
})
FPSTab:AddButton({
    Name = "Сбросить графику",
    Callback = function()
        if FPSOriginal.Saved then
            settings().Rendering.QualityLevel = FPSOriginal.Quality
            Lighting.GlobalShadows  = FPSOriginal.ShadowMap
            Lighting.Ambient        = FPSOriginal.Ambient
            Lighting.OutdoorAmbient = FPSOriginal.OutdoorAmbient
            Lighting.FogEnd         = FPSOriginal.FogEnd
        end
    end,
})

-- ========== INFO TAB ==========
InfoTab:AddParagraph("Universal ESP v5 + Mobile", "Автор: Vdhu | Версия: 5 Mobile Edition

ПК -> RightShift
Мобилка -> кнопка ESP на экране (перетаскивается)")
InfoTab:AddParagraph("Функции", "Box ESP, Tracers, Skeleton, Chams, Имя, HP, Дистанция, AIM DIR, Inf Jump, Noclip, Speed, TP, FPS Boost")
    -- ========== ESP DRAWING ENGINE ==========
local Drawings = {}

local function NewDrawing(type_, props)
    local d = Drawing.new(type_)
    for k,v in pairs(props) do d[k] = v end
    return d
end

local function GetHealthColor(pct)
    if pct > 0.5 then
        return Color3.fromRGB(math.floor((1-pct)*2*255), 255, 0)
    else
        return Color3.fromRGB(255, math.floor(pct*2*255), 0)
    end
end

local function WorldToViewport(pos)
    local vp, onScreen = Camera:WorldToViewportPoint(pos)
    return Vector2.new(vp.X, vp.Y), vp.Z > 0 and onScreen
end

local function GetCharacterInfo(player)
    local char = player.Character
    if not char then return nil end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum  = char:FindFirstChildOfClass("Humanoid")
    local head = char:FindFirstChild("Head")
    if not root or not hum or not head then return nil end
    if hum.Health <= 0 then return nil end
    return {
        Root  = root, Hum = hum, Head = head, Char = char,
        HpPct = hum.Health / hum.MaxHealth,
        Dist  = (LP.Character and LP.Character:FindFirstChild("HumanoidRootPart"))
                and (root.Position - LP.Character.HumanoidRootPart.Position).Magnitude or 0,
    }
end

local BONES = {
    {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
    {"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},
    {"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},
    {"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},
    {"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"},
    {"Head","Torso"},{"Torso","Left Arm"},{"Torso","Right Arm"},{"Torso","Left Leg"},{"Torso","Right Leg"},
}

local function ClearPlayerDrawings(name)
    if Drawings[name] then
        for _,d in pairs(Drawings[name]) do
            pcall(function() d:Remove() end)
        end
        Drawings[name] = nil
    end
end

local function EnsureDrawings(name)
    if not Drawings[name] then
        Drawings[name] = {
            Box      = NewDrawing("Square", {Visible=false, Filled=false, Thickness=1.5, Color=Color3.new(1,1,1)}),
            Tracer   = NewDrawing("Line",   {Visible=false, Thickness=1.5}),
            Name     = NewDrawing("Text",   {Visible=false, Size=13, Center=true, Outline=true, Font=Drawing.Fonts.Plex}),
            HealthBg = NewDrawing("Square", {Visible=false, Filled=true, Color=Palette.HealthBg}),
            HealthFg = NewDrawing("Square", {Visible=false, Filled=true}),
            Dist     = NewDrawing("Text",   {Visible=false, Size=11, Center=true, Outline=true, Font=Drawing.Fonts.Plex}),
            Bones    = {},
            LookWarn = NewDrawing("Text",   {Visible=false, Size=14, Center=true, Outline=true, Font=Drawing.Fonts.Plex, Color=Palette.LookingAtYou, Text="!!! СМОТРИТ"}),
            AimLine  = NewDrawing("Line",   {Visible=false, Thickness=1.5, Color=Palette.AimDir}),
        }
        for i=1,#BONES do
            Drawings[name].Bones[i] = NewDrawing("Line",{Visible=false,Thickness=2,Color=Color3.new(1,1,1)})
        end
    end
    return Drawings[name]
end

RunService.RenderStepped:Connect(function()
    if not Settings.Enabled then
        for name,_ in pairs(Drawings) do ClearPlayerDrawings(name) end
        return
    end
    local activePlayers = {}
    for _,player in pairs(Players:GetPlayers()) do
        if player == LP then continue end
        if Settings.TeamCheck and player.Team == LP.Team and player.Team ~= nil then
            ClearPlayerDrawings(player.Name)
            continue
        end
        local info = GetCharacterInfo(player)
        if not info or info.Dist > Settings.MaxDistance then
            ClearPlayerDrawings(player.Name)
            continue
        end
        activePlayers[player.Name] = true
        local d = EnsureDrawings(player.Name)
        local rootPos = info.Root.Position
        local headPos = info.Head.Position + Vector3.new(0,0.5,0)
        local feetPos = rootPos - Vector3.new(0,3,0)
        local rootVP, rootVis = WorldToViewport(rootPos)
        local headVP          = WorldToViewport(headPos)
        local feetVP          = WorldToViewport(feetPos)
        if not rootVis then
            for _,dr in pairs(d) do
                if type(dr) == "userdata" then pcall(function() dr.Visible = false end) end
            end
            for _,bone in pairs(d.Bones) do pcall(function() bone.Visible = false end) end
            continue
        end
        local espColor = Settings.VisibleColor
        local height = math.abs(headVP.Y - feetVP.Y)
        local width  = height * 0.6
        local bx = rootVP.X - width/2
        local by = headVP.Y
        -- Box
        d.Box.Visible  = Settings.ShowBox
        d.Box.Position = Vector2.new(bx, by)
        d.Box.Size     = Vector2.new(width, height)
        d.Box.Color    = espColor
        -- Tracer
        d.Tracer.Visible = Settings.ShowTracer
        d.Tracer.From    = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
        d.Tracer.To      = Vector2.new(rootVP.X, rootVP.Y)
        d.Tracer.Color   = espColor
        -- Name
        d.Name.Visible  = Settings.ShowName
        d.Name.Position = Vector2.new(rootVP.X, by - 16)
        d.Name.Text     = player.Name
        d.Name.Color    = espColor
        -- Distance
        d.Dist.Visible  = Settings.ShowDistance
        d.Dist.Position = Vector2.new(rootVP.X, by + height + 2)
        d.Dist.Text     = string.format("[%.0fm]", info.Dist)
        d.Dist.Color    = Color3.fromRGB(200,200,200)
        -- Health bar
        local hpColor = GetHealthColor(info.HpPct)
        local barW, barH = 4, height
        local barX = bx - barW - 3
        local barY = by
        d.HealthBg.Visible  = Settings.ShowHealth
        d.HealthBg.Position = Vector2.new(barX, barY)
        d.HealthBg.Size     = Vector2.new(barW, barH)
        d.HealthFg.Visible  = Settings.ShowHealth
        d.HealthFg.Position = Vector2.new(barX, barY + barH*(1-info.HpPct))
        d.HealthFg.Size     = Vector2.new(barW, barH*info.HpPct)
        d.HealthFg.Color    = hpColor
        -- Skeleton
        for i, bone in pairs(BONES) do
            local p0 = info.Char:FindFirstChild(bone[1])
            local p1 = info.Char:FindFirstChild(bone[2])
            if p0 and p1 then
                local v0, ok0 = WorldToViewport(p0.Position)
                local v1, ok1 = WorldToViewport(p1.Position)
                if ok0 and ok1 and Settings.ShowSkeleton then
                    d.Bones[i].Visible   = true
                    d.Bones[i].From      = v0
                    d.Bones[i].To        = v1
                    d.Bones[i].Color     = espColor
                    d.Bones[i].Thickness = Settings.SkeletonThickness
                else
                    d.Bones[i].Visible = false
                end
            else
                d.Bones[i].Visible = false
            end
        end
        -- Chams
        if Settings.ShowChams then
            for _,part in pairs(info.Char:GetDescendants()) do
                if part:IsA("BasePart") then
                    local hi = part:FindFirstChildOfClass("SelectionBox") or Instance.new("SelectionBox")
                    hi.Name = "ESP_Chams"
                    hi.Adornee = part
                    hi.Color3  = espColor
                    hi.LineThickness = 0.03
                    hi.SurfaceTransparency = Settings.ChamsFillTransparency
                    hi.SurfaceColor3 = espColor
                    if not hi.Parent then hi.Parent = ChamsFolder end
                end
            end
        else
            for _,hi in pairs(ChamsFolder:GetChildren()) do hi:Destroy() end
        end
        -- AIM DIR
        if Settings.ShowAimDir then
            local lookDir = info.Root.CFrame.LookVector
            local aimEnd  = rootPos + lookDir * Settings.AimLineLength
            local aimVP, aimOk = WorldToViewport(aimEnd)
            d.AimLine.Visible = aimOk
            if aimOk then
                d.AimLine.From = rootVP
                d.AimLine.To   = aimVP
            end
        else
            d.AimLine.Visible = false
        end
        -- Looking at you
        if Settings.ShowLookingAtYou and LP.Character then
            local myRoot = LP.Character:FindFirstChild("HumanoidRootPart")
            if myRoot then
                local toMe = (myRoot.Position - info.Root.Position).Unit
                local dot  = info.Root.CFrame.LookVector:Dot(toMe)
                d.LookWarn.Visible  = dot > 0.9
                d.LookWarn.Position = Vector2.new(rootVP.X, by - 30)
            end
        else
            d.LookWarn.Visible = false
        end
    end
    -- Cleanup
    for name,_ in pairs(Drawings) do
        if not activePlayers[name] then ClearPlayerDrawings(name) end
    end
end)

OrionLib:Init()
