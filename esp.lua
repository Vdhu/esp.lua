--[[
    Universal ESP Script - ENHANCED v5
    Works in ALL Roblox games

    Open Menu: RightShift (PC) | Button [☰ ESP] (Mobile)
]]

if not game:IsLoaded() then game.Loaded:Wait() end

-- ========== SERVICES ==========
local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS        = game:GetService("UserInputService")
local Lighting   = game:GetService("Lighting")
local LP         = Players.LocalPlayer
local Camera     = workspace.CurrentCamera

-- ========== ORION UI ==========
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()

local Window = OrionLib:MakeWindow({
    Name         = "Universal ESP v5",
    HidePremium  = true,
    SaveConfig   = true,
    ConfigFolder = "UniversalESP_v5",
    IntroEnabled = false,
    ToggleKey    = Enum.KeyCode.RightShift,
})

-- ========== MOBILE BUTTON ==========
local menuOpen = false

local function CreateMobileButton()
    local playerGui = LP:WaitForChild("PlayerGui")
    local old = playerGui:FindFirstChild("ESP_MobileButton")
    if old then old:Destroy() end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name             = "ESP_MobileButton"
    ScreenGui.ResetOnSpawn     = false
    ScreenGui.IgnoreGuiInset   = true
    ScreenGui.ZIndexBehavior   = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent           = playerGui

    local Btn = Instance.new("TextButton")
    Btn.Size             = UDim2.new(0, 72, 0, 72)
    Btn.Position         = UDim2.new(1, -84, 0.5, -36)
    Btn.AnchorPoint      = Vector2.new(0, 0)
    Btn.BackgroundColor3 = Color3.fromRGB(88, 44, 180)
    Btn.Text             = "☰\nESP"
    Btn.TextColor3       = Color3.fromRGB(255, 255, 255)
    Btn.TextSize         = 14
    Btn.Font             = Enum.Font.GothamBold
    Btn.ZIndex           = 999
    Btn.Parent           = ScreenGui

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 16)
    Corner.Parent       = Btn

    local Stroke = Instance.new("UIStroke")
    Stroke.Color     = Color3.fromRGB(180, 120, 255)
    Stroke.Thickness = 2
    Stroke.Parent    = Btn

    Btn.MouseButton1Click:Connect(function()
        menuOpen = not menuOpen
        if menuOpen then
            Btn.BackgroundColor3 = Color3.fromRGB(50, 180, 100)
            Btn.Text = "✕\nESP"
        else
            Btn.BackgroundColor3 = Color3.fromRGB(88, 44, 180)
            Btn.Text = "☰\nESP"
        end
        pcall(function() OrionLib.Window:Toggle() end)
    end)

    -- Drag support
    local dragging  = false
    local dragStart = Vector2.new()
    local startPos  = UDim2.new()

    Btn.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = Vector2.new(inp.Position.X, inp.Position.Y)
            startPos  = Btn.Position
        end
    end)

    Btn.InputChanged:Connect(function(inp)
        if dragging and inp.UserInputType == Enum.UserInputType.Touch then
            local d = Vector2.new(inp.Position.X, inp.Position.Y) - dragStart
            if d.Magnitude > 10 then
                Btn.Position = UDim2.new(
                    startPos.X.Scale,  startPos.X.Offset + d.X,
                    startPos.Y.Scale,  startPos.Y.Offset + d.Y
                )
            end
        end
    end)

    Btn.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

CreateMobileButton()
LP.CharacterAdded:Connect(function()
    task.wait(1)
    CreateMobileButton()
end)

-- ========== TABS ==========
local ESPTab   = Window:MakeTab({ Name = "ESP",       Icon = "rbxassetid://4483362458", PremiumOnly = false })
local TPTab    = Window:MakeTab({ Name = "Teleport",  Icon = "rbxassetid://4483362458", PremiumOnly = false })
local CheatTab = Window:MakeTab({ Name = "Cheats",    Icon = "rbxassetid://4483362458", PremiumOnly = false })
local FPSTab   = Window:MakeTab({ Name = "FPS Boost", Icon = "rbxassetid://4483362458", PremiumOnly = false })

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
    ShowLookingAtYou         = false,
    MaxDistance              = 1500,
    VisibleColor             = Color3.fromRGB(50,  255, 80),
    HiddenColor              = Color3.fromRGB(255, 50,  50),
    TeamColor                = Color3.fromRGB(50,  150, 255),
    SkeletonThickness        = 2,
    AimLineLength            = 15,
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
    HealthBg     = Color3.fromRGB(40,  40,  40),
    LookingAtYou = Color3.fromRGB(255, 255, 0),
    AimDir       = Color3.fromRGB(255, 150, 0),
}

-- ========== CHAMS FOLDER ==========
local ChamsFolder = Instance.new("Folder")
ChamsFolder.Name = "UniversalESP_Chams"
pcall(function()
    local CG = game:GetService("CoreGui")
    local old = CG:FindFirstChild(ChamsFolder.Name)
    if old then old:Destroy() end
    ChamsFolder.Parent = CG
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

ESPTab:AddToggle({ Name = "Enable ESP",            Default = Settings.Enabled,      Save = true, Flag = "ESP_Enabled",  Callback = function(v) Settings.Enabled      = v end })
ESPTab:AddToggle({ Name = "Team Check",            Default = Settings.TeamCheck,    Save = true, Flag = "TeamCheck",    Callback = function(v) Settings.TeamCheck    = v end })
ESPTab:AddDivider()
ESPTab:AddToggle({ Name = "Box ESP",               Default = Settings.ShowBox,      Save = true, Flag = "BoxESP",       Callback = function(v) Settings.ShowBox      = v end })
ESPTab:AddToggle({ Name = "Tracers",               Default = Settings.ShowTracer,   Save = true, Flag = "Tracers",      Callback = function(v) Settings.ShowTracer   = v end })
ESPTab:AddToggle({ Name = "Skeleton ESP",          Default = Settings.ShowSkeleton, Save = true, Flag = "SkeletonESP",  Callback = function(v) Settings.ShowSkeleton = v end })
ESPTab:AddToggle({ Name = "Chams / Highlight",    Default = Settings.ShowChams,    Save = true, Flag = "ChamsESP",     Callback = function(v) Settings.ShowChams    = v end })
ESPTab:AddToggle({ Name = "Player Name",           Default = Settings.ShowName,     Save = true, Flag = "NameESP",      Callback = function(v) Settings.ShowName     = v end })
ESPTab:AddToggle({ Name = "Health Bar",            Default = Settings.ShowHealth,   Save = true, Flag = "HealthESP",    Callback = function(v) Settings.ShowHealth   = v end })
ESPTab:AddToggle({ Name = "Distance",              Default = Settings.ShowDistance, Save = true, Flag = "DistanceESP",  Callback = function(v) Settings.ShowDistance = v end })
ESPTab:AddToggle({ Name = "Aim Direction",         Default = Settings.ShowAimDir,   Save = true, Flag = "AimDir",       Callback = function(v) Settings.ShowAimDir   = v end })
ESPTab:AddToggle({ Name = "Looking At You Alert", Default = Settings.ShowLookingAtYou, Save = true, Flag = "LookingAtYou", Callback = function(v) Settings.ShowLookingAtYou = v end })
ESPTab:AddDivider()
ESPTab:AddSlider({ Name = "Max Distance",           Min = 100, Max = 3000, Default = 1500, Color = Color3.fromRGB(255,255,255), Increment = 50,  ValueName = "studs", Callback = function(v) Settings.MaxDistance              = tonumber(v) or 1500       end })
ESPTab:AddSlider({ Name = "Skeleton Thickness",      Min = 1,   Max = 5,    Default = 2,    Color = Color3.fromRGB(255,255,255), Increment = 1,   ValueName = "px",    Callback = function(v) Settings.SkeletonThickness        = tonumber(v) or 2          end })
ESPTab:AddSlider({ Name = "Aim Line Length",         Min = 5,   Max = 50,   Default = 15,   Color = Color3.fromRGB(255,255,255), Increment = 1,   ValueName = "studs", Callback = function(v) Settings.AimLineLength            = tonumber(v) or 15         end })
ESPTab:AddSlider({ Name = "Chams Fill Transparency", Min = 0,   Max = 100,  Default = 45,   Color = Color3.fromRGB(255,255,255), Increment = 5,   ValueName = "%",     Callback = function(v) Settings.ChamsFillTransparency    = (tonumber(v) or 45) / 100 end })
ESPTab:AddSlider({ Name = "Chams Outline Transparency", Min = 0, Max = 100, Default = 0,  Color = Color3.fromRGB(255,255,255), Increment = 5,   ValueName = "%",     Callback = function(v) Settings.ChamsOutlineTransparency = (tonumber(v) or 0)  / 100 end })

-- ===================================================
-- ================ TELEPORT TAB =====================
-- ===================================================

local tpButtons = {}

local function ClearTPButtons()
    for _, b in pairs(tpButtons) do pcall(function() b:Destroy() end) end
    tpButtons = {}
end

local function BuildTPButtons()
    ClearTPButtons()
    local added = 0
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LP then
            local btn = TPTab:AddButton({
                Name = "🌀 TP to: " .. player.Name,
                Callback = function()
                    local char  = LP.Character
                    local root  = char  and char:FindFirstChild("HumanoidRootPart")
                    local tChar = player.Character
                    local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
                    if root and tRoot then
                        root.CFrame = tRoot.CFrame + Vector3.new(0, 3, 0)
                        OrionLib:MakeNotification({ Name = "Teleport", Content = "TP to " .. player.Name .. " done!", Time = 3 })
                    else
                        OrionLib:MakeNotification({ Name = "Error", Content = player.Name .. " character not found.", Time = 3 })
                    end
                end,
            })
            table.insert(tpButtons, btn)
            added = added + 1
        end
    end
    if added == 0 then
        local lbl = TPTab:AddLabel("No other players on this server.")
        table.insert(tpButtons, lbl)
    end
end

TPTab:AddButton({
    Name = "🔄 Refresh Player List",
    Callback = function()
        BuildTPButtons()
        OrionLib:MakeNotification({ Name = "Refreshed", Content = "Player list updated.", Time = 2 })
    end,
})

BuildTPButtons()
TPTab:AddDivider()

TPTab:AddButton({
    Name = "📍 Save Current Position",
    Callback = function()
        local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if root then
            CheatSettings.SavedPosition = root.CFrame
            OrionLib:MakeNotification({ Name = "Saved", Content = "Position saved!", Time = 2 })
        else
            OrionLib:MakeNotification({ Name = "Error", Content = "Character not found!", Time = 3 })
        end
    end,
})

TPTab:AddButton({
    Name = "🔙 TP to Saved Position",
    Callback = function()
        if not CheatSettings.SavedPosition then
            OrionLib:MakeNotification({ Name = "Error", Content = "Save a position first!", Time = 3 })
            return
        end
        local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if root then
            root.CFrame = CheatSettings.SavedPosition
            OrionLib:MakeNotification({ Name = "Teleported", Content = "Returned to saved position!", Time = 2 })
        else
            OrionLib:MakeNotification({ Name = "Error", Content = "Character not found!", Time = 3 })
        end
    end,
})

-- ===================================================
-- ================= CHEATS TAB ======================
-- ===================================================

CheatTab:AddToggle({
    Name = "🐇 Infinite Jump", Default = false, Save = false, Flag = "InfJump",
    Callback = function(v)
        CheatSettings.InfiniteJump = v
        OrionLib:MakeNotification({ Name = "Infinite Jump", Content = v and "ON ✅" or "OFF ❌", Time = 2 })
    end,
})

CheatTab:AddToggle({
    Name = "⚡ Speed Hack", Default = false, Save = false, Flag = "SpeedHack",
    Callback = function(v)
        CheatSettings.SpeedEnabled = v
        local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = v and CheatSettings.SpeedValue or 16 end
        OrionLib:MakeNotification({ Name = "Speed Hack", Content = v and ("ON ✅ | Speed: " .. CheatSettings.SpeedValue) or "OFF ❌", Time = 2 })
    end,
})

CheatTab:AddSlider({
    Name = "⚡ WalkSpeed", Min = 16, Max = 300, Default = 16,
    Color = Color3.fromRGB(255,255,255), Increment = 1, ValueName = "sp",
    Callback = function(v)
        CheatSettings.SpeedValue = tonumber(v) or 16
        if CheatSettings.SpeedEnabled then
            local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = CheatSettings.SpeedValue end
        end
    end,
})

CheatTab:AddDivider()

CheatTab:AddToggle({
    Name = "👻 Noclip", Default = false, Save = false, Flag = "Noclip",
    Callback = function(v)
        CheatSettings.Noclip = v
        if not v then
            local char = LP.Character
            if char then
                for _, p in pairs(char:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = true end
                end
            end
        end
        OrionLib:MakeNotification({ Name = "Noclip", Content = v and "ON ✅" or "OFF ❌", Time = 2 })
    end,
})

-- ===================================================
-- ================ FPS BOOST TAB ====================
-- ===================================================

FPSTab:AddLabel("Select FPS boost level. Press Reset to restore graphics.")
FPSTab:AddDivider()

FPSTab:AddButton({ Name = "🟢 Boost Low (+10-20 FPS)", Callback = function()
    SaveOriginalGraphics()
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level05
    Lighting.GlobalShadows = true ; Lighting.FogEnd = 100000
    OrionLib:MakeNotification({ Name = "FPS Boost: Low", Content = "+10-20 FPS", Time = 3 })
end })

FPSTab:AddButton({ Name = "🔵 Boost Medium (+20-40 FPS)", Callback = function()
    SaveOriginalGraphics()
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level03
    Lighting.GlobalShadows = false ; Lighting.FogEnd = 100000
    Lighting.Ambient = Color3.fromRGB(140,140,140)
    OrionLib:MakeNotification({ Name = "FPS Boost: Medium", Content = "Shadows off. +20-40 FPS", Time = 3 })
end })

FPSTab:AddButton({ Name = "🟡 Boost High (+40-60 FPS)", Callback = function()
    SaveOriginalGraphics()
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    Lighting.GlobalShadows = false ; Lighting.FogEnd = 100000
    Lighting.Ambient = Color3.fromRGB(178,178,178)
    Lighting.OutdoorAmbient = Color3.fromRGB(178,178,178)
    for _, e in pairs(Lighting:GetChildren()) do if e:IsA("PostEffect") then e.Enabled = false end end
    OrionLib:MakeNotification({ Name = "FPS Boost: High", Content = "Shadows + PostFX off. +40-60 FPS", Time = 3 })
end })

FPSTab:AddButton({ Name = "🔴 Boost Ultra (+60+ FPS)", Callback = function()
    SaveOriginalGraphics()
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    Lighting.GlobalShadows = false ; Lighting.FogEnd = 100000 ; Lighting.FogStart = 99999
    Lighting.Ambient = Color3.fromRGB(200,200,200) ; Lighting.OutdoorAmbient = Color3.fromRGB(200,200,200)
    for _, e in pairs(Lighting:GetChildren()) do if e:IsA("PostEffect") then e.Enabled = false end end
    pcall(function() workspace.StreamingEnabled = true end)
    OrionLib:MakeNotification({ Name = "FPS Boost: ULTRA", Content = "Max boost! +60+ FPS", Time = 4 })
end })

FPSTab:AddDivider()

FPSTab:AddButton({ Name = "🔮 Reset Graphics", Callback = function()
    if not FPSOriginal.Saved then
        OrionLib:MakeNotification({ Name = "Reset", Content = "No boost applied yet.", Time = 2 })
        return
    end
    settings().Rendering.QualityLevel = FPSOriginal.Quality
    Lighting.GlobalShadows  = FPSOriginal.ShadowMap
    Lighting.Ambient        = FPSOriginal.Ambient
    Lighting.OutdoorAmbient = FPSOriginal.OutdoorAmbient
    Lighting.FogEnd         = FPSOriginal.FogEnd
    for _, e in pairs(Lighting:GetChildren()) do if e:IsA("PostEffect") then e.Enabled = true end end
    FPSOriginal.Saved = false
    OrionLib:MakeNotification({ Name = "✅ Graphics Restored", Content = "Original settings restored.", Time = 3 })
end })

-- ===================================================
-- =========== ESP DRAWING UTILITIES =================
-- ===================================================

local ESPCache = {}

local function NewLine(thickness, transparency)
    local l = Drawing.new("Line")
    l.Visible      = false
    l.Thickness    = thickness    or 1
    l.Transparency = transparency or 1
    l.Color        = Color3.fromRGB(255,255,255)
    return l
end

local function NewText(size)
    local t = Drawing.new("Text")
    t.Visible = false
    t.Size    = size or 13
    t.Center  = true
    t.Outline = true
    t.Color   = Color3.fromRGB(255,255,255)
    return t
end

local function NewChams()
    local h = Instance.new("SelectionBox")
    h.LineThickness      = 0.03
    h.SurfaceTransparency = Settings.ChamsFillTransparency
    h.SurfaceColor3      = Settings.VisibleColor
    h.Color3             = Settings.VisibleColor
    h.Parent             = ChamsFolder
    return h
end

local function RemoveObject(obj)
    pcall(function()
        if typeof(obj) == "Instance" then obj:Destroy() else obj:Remove() end
    end)
end

local function SetObjectVisible(obj, vis)
    pcall(function()
        if typeof(obj) == "Instance" then obj.Enabled = false else obj.Visible = vis end
    end)
end

local function IsTeammate(player)
    if not Settings.TeamCheck then return false end
    return player.Team and player.Team == LP.Team
end

local function IsCharacterVisible(Char)
    local root = Char:FindFirstChild("HumanoidRootPart")
    if not root then return false end
    local ray = Ray.new(Camera.CFrame.Position, (root.Position - Camera.CFrame.Position).Unit * 1000)
    local hit = workspace:FindPartOnRayWithIgnoreList(ray, {LP.Character, Char})
    return hit == nil
end

local function GetColor(player, isVisible)
    if player.Team and player.Team == LP.Team then return Settings.TeamColor end
    return isVisible and Settings.VisibleColor or Settings.HiddenColor
end

local function GetHealthColor(hp, maxHp)
    local pct = math.clamp(hp / maxHp, 0, 1)
    if pct > 0.5 then
        return Color3.fromRGB(math.floor((1-pct)*2*255), 255, 0)
    else
        return Color3.fromRGB(255, math.floor(pct*2*255), 0)
    end
end

local function IsLookingAtYou(Char)
    local head   = Char:FindFirstChild("Head")
    local myChar = LP.Character
    local myHead = myChar and myChar:FindFirstChild("Head")
    if not head or not myHead then return false end
    return head.CFrame.LookVector:Dot((myHead.Position - head.Position).Unit) > 0.97
end

local function CreateESP(Player)
    if Player == LP or ESPCache[Player] then return end
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
        BoxTop      = NewLine(),   BoxBot      = NewLine(),
        BoxLeft     = NewLine(),   BoxRight    = NewLine(),
        Tracer      = NewLine(1, 0.8),
        Name        = NewText(12), Distance    = NewText(10),
        HpBg        = NewLine(4, 1),  HpFill   = NewLine(4, 1),
        Skeleton    = Skel,
        AimLine     = NewLine(2, 0.9),
        LookingText = NewText(13),
        Chams       = NewChams(),
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

local function UpdateChams(_, o, Char, Col)
    if not o.Chams then return end
    if Settings.ShowChams and Char then
        if o.Chams.Adornee ~= Char then o.Chams.Adornee = Char end
        o.Chams.SurfaceColor3      = Col
        o.Chams.Color3             = Col
        o.Chams.SurfaceTransparency = Settings.ChamsFillTransparency
        o.Chams.LineThickness      = Settings.ChamsOutlineTransparency > 0.5 and 0 or 0.03
        o.Chams.Enabled            = true
    else
        o.Chams.Enabled = false
    end
end

local function DrawSkeleton(Player, o, Col)
    local Char = Player.Character
    if not Char then return end
    for _, line in pairs(o.Skeleton) do line.Visible = false end
    local function GL(pName)
        local p = Char:FindFirstChild(pName)
        if p and p:IsA("BasePart") then
            local ok, pos, on = pcall(function()
                local v, isOn = Camera:WorldToViewportPoint(p.Position)
                return v, isOn
            end)
            if ok and on and pos.Z > 0 then
                return Vector2.new(pos.X, pos.Y), true
            end
        end
        return nil, false
    end
    local isR15 = Char:FindFirstChild("UpperTorso") ~= nil
    local m = isR15 and {
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
    for lname, parts in pairs(m) do
        local line = o.Skeleton[lname]
        if line then
            local p1, v1 = GL(parts[1])
            local p2, v2 = GL(parts[2])
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

local function DrawAimDir(Player, o)
    if not Settings.ShowAimDir then o.AimLine.Visible = false ; return end
    local Char = Player.Character
    local head = Char and Char:FindFirstChild("Head")
    if not head or not head:IsA("BasePart") then o.AimLine.Visible = false ; return end
    local ok, res = pcall(function()
        local ae     = head.Position + head.CFrame.LookVector * Settings.AimLineLength
        local hS, hOn = Camera:WorldToViewportPoint(head.Position)
        local aS, aOn = Camera:WorldToViewportPoint(ae)
        if hOn and aOn and hS.Z > 0 and aS.Z > 0 then
            o.AimLine.From    = Vector2.new(hS.X, hS.Y)
            o.AimLine.To      = Vector2.new(aS.X, aS.Y)
            o.AimLine.Color   = Palette.AimDir
            o.AimLine.Visible = true
            return true
        end
        return false
    end)
    if not ok or not res then o.AimLine.Visible = false end
end

-- ========== EVENTS ==========
for _, p in pairs(Players:GetPlayers()) do CreateESP(p) end

Players.PlayerAdded:Connect(function(p)
    CreateESP(p)
    task.delay(1, BuildTPButtons)
end)

Players.PlayerRemoving:Connect(function(p)
    RemoveESP(p)
    task.delay(0.5, BuildTPButtons)
end)

LP.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")
    if CheatSettings.SpeedEnabled then
        hum.WalkSpeed = CheatSettings.SpeedValue
    end
end)

-- ========== INFINITE JUMP ==========
UIS.JumpRequest:Connect(function()
    if not CheatSettings.InfiniteJump then return end
    local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
end)

-- ========== MAIN LOOP (ESP + NOCLIP) ==========
RunService.RenderStepped:Connect(function()
    Camera = workspace.CurrentCamera
    if not Camera then return end

    -- Noclip loop
    if CheatSettings.Noclip then
        local char = LP.Character
        if char then
            for _, p in pairs(char:GetDescendants()) do
                if p:IsA("BasePart") and p.CanCollide then
                    p.CanCollide = false
                end
            end
        end
    end

    -- ESP loop
    for Player, o in pairs(ESPCache) do
        if not Settings.Enabled then HideESP(o) ; continue end
        if not Player or not Player.Parent then HideESP(o) ; continue end

        local Char = Player.Character
        local Root = Char and Char:FindFirstChild("HumanoidRootPart")
        local Hum  = Char and Char:FindFirstChildOfClass("Humanoid")
        if not (Char and Root and Hum and Hum.Health > 0) then HideESP(o) ; continue end

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
            o.BoxTop.From=V2(X,Y);             o.BoxTop.To=V2(X+BW,Y)
            o.BoxBot.From=V2(X,Y+BH);          o.BoxBot.To=V2(X+BW,Y+BH)
            o.BoxLeft.From=V2(X,Y);            o.BoxLeft.To=V2(X,Y+BH)
            o.BoxRight.From=V2(X+BW,Y);        o.BoxRight.To=V2(X+BW,Y+BH)
            for _, k in pairs({"BoxTop","BoxBot","BoxLeft","BoxRight"}) do
                o[k].Color = Col ; o[k].Visible = true
            end
        else
            for _, k in pairs({"BoxTop","BoxBot","BoxLeft","BoxRight"}) do o[k].Visible = false end
        end

        o.Tracer.From    = V2(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
        o.Tracer.To      = V2(SP.X, SP.Y)
        o.Tracer.Color   = Col
        o.Tracer.Visible = Settings.ShowTracer

        o.Name.Text     = Player.Name
        o.Name.Position = V2(SP.X, Y-15)
        o.Name.Color    = Col
        o.Name.Visible  = Settings.ShowName

        o.Distance.Text     = math.floor(Dist).."m"
        o.Distance.Position = V2(SP.X, Y+BH+4)
        o.Distance.Color    = Color3.fromRGB(200,200,200)
        o.Distance.Visible  = Settings.ShowDistance

        if Settings.ShowHealth then
            local pct = math.clamp(Hum.Health / Hum.MaxHealth, 0, 1)
            local bX  = X - 6
            o.HpBg.From=V2(bX,Y);   o.HpBg.To=V2(bX,Y+BH);   o.HpBg.Visible=true
            o.HpFill.From=V2(bX,Y+BH); o.HpFill.To=V2(bX,Y+BH-BH*pct)
            o.HpFill.Color   = GetHealthColor(Hum.Health, Hum.MaxHealth)
            o.HpFill.Visible = true
        else
            o.HpBg.Visible = false ; o.HpFill.Visible = false
        end

        if Settings.ShowSkeleton then
            pcall(function() DrawSkeleton(Player, o, Col) end)
        else
            for _, line in pairs(o.Skeleton) do line.Visible = false end
        end

        if Settings.ShowAimDir then
            pcall(function() DrawAimDir(Player, o) end)
        else
            o.AimLine.Visible = false
        end

        if Settings.ShowLookingAtYou then
            local okL, isL = pcall(function() return IsLookingAtYou(Char) end)
            if okL and isL then
                o.LookingText.Text     = "[!] LOOKING AT YOU"
                o.LookingText.Position = V2(SP.X, Y-35)
                o.LookingText.Visible  = true
            else
                o.LookingText.Visible = false
            end
        else
            o.LookingText.Visible = false
        end
    end
end)

OrionLib:Init()
print("✅ Universal ESP v5 loaded | RightShift = menu | 📱 Mobile button active")
