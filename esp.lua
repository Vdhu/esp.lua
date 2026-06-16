--[[
    Universal ESP Script
    Works in ALL Roblox games
    Features: Box ESP, Tracers, Name, Health Bar, Distance, Team Check, Skeleton ESP
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

local ESPTab  = Window:CreateTab("ESP Settings", 4483362458)
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
    MaxDistance  = 1500,
    EnemyColor   = Color3.fromRGB(255, 50,  50),
    TeamColor    = Color3.fromRGB(50,  150, 255),
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

-- ========== INFO TAB ==========
InfoTab:CreateParagraph({
    Title   = "Universal ESP Script",
    Content = "Работает во ВСЕХ Roblox играх!\n\nФУНКЦИИ:\n• Box ESP (рамка вокруг игрока)\n• Skeleton ESP (скелет игрока)\n• Tracers (линии к игрокам)\n• Имя игрока\n• Полоска здоровья\n• Дистанция\n• Team Check\n\nУПРАВЛЕНИЕ:\n• RightShift — открыть/закрыть меню"
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

local function GetColor(Player)
    return IsTeammate(Player) and Settings.TeamColor or Settings.EnemyColor
end

local function GetHealthColor(hp, max)
    local p = hp / max
    if p > 0.7 then return Color3.fromRGB(0, 255, 100) end
    if p > 0.3 then return Color3.fromRGB(255, 200, 0) end
    return Color3.fromRGB(255, 50, 50)
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

local function CreateESP(Player)
    if Player == LP then return end
    if ESPCache[Player] then return end
    
    -- Skeleton lines
    local SkeletonLines = {
        -- Head to Torso
        HeadTorso = NewLine(2, 0.8),
        -- Torso
        TorsoHip = NewLine(2, 0.8),
        -- Left Arm
        TorsoLeftShoulder = NewLine(2, 0.8),
        LeftShoulderElbow = NewLine(2, 0.8),
        LeftElbowHand = NewLine(2, 0.8),
        -- Right Arm
        TorsoRightShoulder = NewLine(2, 0.8),
        RightShoulderElbow = NewLine(2, 0.8),
        RightElbowHand = NewLine(2, 0.8),
        -- Left Leg
        HipLeftKnee = NewLine(2, 0.8),
        LeftKneeFoot = NewLine(2, 0.8),
        -- Right Leg
        HipRightKnee = NewLine(2, 0.8),
        RightKneeFoot = NewLine(2, 0.8),
    }
    
    ESPCache[Player] = {
        BoxTop   = NewLine(),
        BoxBot   = NewLine(),
        BoxLeft  = NewLine(),
        BoxRight = NewLine(),
        Tracer   = NewLine(1, 0.8),
        Name     = NewText(12),
        Distance = NewText(10),
        HpBg     = NewLine(3, 0),
        HpFill   = NewLine(3, 0),
        Skeleton = SkeletonLines,
    }
    ESPCache[Player].HpBg.Color    = Color3.fromRGB(30, 30, 40)
    ESPCache[Player].Distance.Font = 1
end

local function RemoveESP(Player)
    local o = ESPCache[Player]
    if not o then return end
    for _, d in pairs(o) do 
        if type(d) == "table" then
            for _, line in pairs(d) do
                line:Remove()
            end
        else
            d:Remove() 
        end
    end
    ESPCache[Player] = nil
end

local function HideESP(o)
    for _, d in pairs(o) do 
        if type(d) == "table" then
            for _, line in pairs(d) do
                line.Visible = false
            end
        else
            d.Visible = false
        end
    end
end

-- ========== SKELETON HELPER ==========
local function DrawSkeleton(Player, o, Col)
    local Char = Player.Character
    if not Char then return end
    
    local function GetLimbPos(partName)
        local part = Char:FindFirstChild(partName)
        if part then
            local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
            if onScreen then
                return Vector2.new(pos.X, pos.Y), true
            end
        end
        return nil, false
    end
    
    -- R15 skeleton points
    local skeletonMap = {
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
    
    -- R6 fallback
    local skeletonMapR6 = {
        HeadTorso = {"Head", "Torso"},
        TorsoLeftShoulder = {"Torso", "Left Arm"},
        TorsoRightShoulder = {"Torso", "Right Arm"},
        HipLeftKnee = {"Torso", "Left Leg"},
        HipRightKnee = {"Torso", "Right Leg"},
    }
    
    -- Check if R15 or R6
    local isR15 = Char:FindFirstChild("UpperTorso") ~= nil
    local currentMap = isR15 and skeletonMap or skeletonMapR6
    
    for lineName, parts in pairs(currentMap) do
        local line = o.Skeleton[lineName]
        if line then
            local pos1, vis1 = GetLimbPos(parts[1])
            local pos2, vis2 = GetLimbPos(parts[2])
            
            if pos1 and pos2 and vis1 and vis2 then
                line.From = pos1
                line.To = pos2
                line.Color = Col
                line.Visible = Settings.ShowSkeleton
            else
                line.Visible = false
            end
        end
    end
end

for _, p in pairs(Players:GetPlayers()) do CreateESP(p) end
Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(RemoveESP)

-- ========== MAIN LOOP ==========
RunService.RenderStepped:Connect(function()
    for Player, o in pairs(ESPCache) do
        if not Settings.Enabled then HideESP(o) continue end

        local Char = Player.Character
        local Root = Char and Char:FindFirstChild("HumanoidRootPart")
        local Hum  = Char and Char:FindFirstChildOfClass("Humanoid")

        if not (Char and Root and Hum and Hum.Health > 0) then
            HideESP(o) continue
        end

        local SP, OnScreen = Camera:WorldToViewportPoint(Root.Position)
        local Dist          = (Camera.CFrame.Position - Root.Position).Magnitude

        if not OnScreen or Dist > Settings.MaxDistance then
            HideESP(o) continue
        end

        local BH  = 4000 / Dist
        local BW  = 2200 / Dist
        local X   = SP.X - BW/2
        local Y   = SP.Y - BH/2
        local Col = GetColor(Player)
        local V2  = Vector2.new

        if Settings.ShowBox then
            o.BoxTop.From = V2(X,Y)       ; o.BoxTop.To = V2(X+BW,Y)
            o.BoxBot.From = V2(X,Y+BH)   ; o.BoxBot.To = V2(X+BW,Y+BH)
            o.BoxLeft.From = V2(X,Y)     ; o.BoxLeft.To = V2(X,Y+BH)
            o.BoxRight.From = V2(X+BW,Y) ; o.BoxRight.To = V2(X+BW,Y+BH)
            for _,k in pairs({"BoxTop","BoxBot","BoxLeft","BoxRight"}) do
                o[k].Color = Col ; o[k].Visible = true
            end
        else
            for _,k in pairs({"BoxTop","BoxBot","BoxLeft","BoxRight"}) do
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
            local hp = Hum.Health / Hum.MaxHealth
            local bx = X - 6
            o.HpBg.From      = V2(bx, Y+BH)
            o.HpBg.To        = V2(bx, Y)
            o.HpBg.Visible   = true
            o.HpFill.From    = V2(bx, Y+BH)
            o.HpFill.To      = V2(bx, Y+BH - BH*hp)
            o.HpFill.Color   = GetHealthColor(Hum.Health, Hum.MaxHealth)
            o.HpFill.Visible = true
        else
            o.HpBg.Visible   = false
            o.HpFill.Visible = false
        end
        
        -- Draw Skeleton
        if Settings.ShowSkeleton then
            DrawSkeleton(Player, o, Col)
        else
            for _, line in pairs(o.Skeleton) do
                line.Visible = false
            end
        end
    end
end)

print("✅ Universal ESP Script loaded | RightShift = menu")
