-- ╔══════════════════════════════════════════╗
-- ║           ROSE HUB  •  Ball TP          ║
-- ║          dev by vateax                  ║
-- ╚══════════════════════════════════════════╝
-- Compatible: Xeno, Solara, Delta, Wave, Synapse X

-- ────────────────────────────────────────────
--  SERVICES
-- ────────────────────────────────────────────
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UIS               = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
local CoreGui           = game:GetService("CoreGui")
local Workspace         = game:GetService("Workspace")

local player = Players.LocalPlayer
local plr    = player

-- ────────────────────────────────────────────
--  REACH STATE
-- ────────────────────────────────────────────
local levels            = {5, 10, 20, 30, 50}
local currentLevel      = 1
local reachSize         = levels[currentLevel]
local reachEnabled      = false
local guiVisible        = true
local originalSizes     = {}
local hiddenWrapTargets = {}

-- ────────────────────────────────────────────
--  JZ MECHANICS STATE  (all silent)
-- ────────────────────────────────────────────
local WALK_SPEED_ENABLED    = true
local CUSTOM_WALKSPEED      = 21.5
local DEFAULT_WALKSPEED     = 21.0
local JUMP_SPEED_ENABLED    = true
local JUMP_MULTIPLIER       = 1.0
local BASE_JUMP_POWER       = 50.0
local JUMP_POWER_MULTIPLIER = 2.2
local JUMP_COOLDOWN         = 1.0
local SUPER_FALL_GRAVITY    = 220
local NORMAL_GRAVITY        = 196.2
local PROX_GRAVITY_ENABLED  = true
local TRIGGER_RADIUS        = 40.0
local LOW_GRAVITY           = 192.0
local DEFAULT_GRAVITY       = 196.2
local BALL_NAME             = "Football"
local TAG_NAME              = "Football"
local HITBOX_ENABLED        = true
local HITBOX_SIZE           = 2.3
local DEFAULT_HITBOX_SIZE   = Vector3.new(2, 2, 1)
local TR_ENABLED            = true
local TR_SIZE               = 4.0
local TR_TRANS              = 1
local STICKY_HEAD_ENABLED   = false
local STICKY_PULL           = 1.7
local STICKY_POWER          = 1.4
local BOOST_POWER           = 36.0
local BOOST_COOLDOWN        = 4.0
local isAirborne            = false
local lockedInAir           = false
local cachedBall            = nil
local onBoostCooldown       = false
local boostCdRemaining      = 0
local playerJumpStates      = {}
local playerJumpTimers      = {}
local lastHitboxUpdate      = 0
local lastReachUpdate       = 0
local lastBallSearch        = 0

-- ────────────────────────────────────────────
--  FONT COMPAT
-- ────────────────────────────────────────────
local fontBold   = (pcall(function() return Enum.Font.GothamBold end)) and Enum.Font.GothamBold or Enum.Font.Arial
local fontNormal = (pcall(function() return Enum.Font.Gotham     end)) and Enum.Font.Gotham     or Enum.Font.Arial

-- ────────────────────────────────────────────
--  SCREEN GUI
-- ────────────────────────────────────────────
local existing = CoreGui:FindFirstChild("RoseHub")
if existing then existing:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name           = "RoseHub"
ScreenGui.ResetOnSpawn   = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder   = 999

if syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = player:WaitForChild("PlayerGui")
elseif gethui then
    ScreenGui.Parent = gethui()
else
    ScreenGui.Parent = CoreGui
end

-- ────────────────────────────────────────────
--  LOADING SCREEN
-- ────────────────────────────────────────────
local LoadFrame = Instance.new("Frame")
LoadFrame.Size             = UDim2.new(1, 0, 1, 0)
LoadFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
LoadFrame.BorderSizePixel  = 0
LoadFrame.ZIndex           = 100
LoadFrame.Parent           = ScreenGui

local LoadTitle = Instance.new("TextLabel")
LoadTitle.Size               = UDim2.new(0, 360, 0, 60)
LoadTitle.AnchorPoint        = Vector2.new(0.5, 0.5)
LoadTitle.Position           = UDim2.new(0.5, 0, 0.44, 0)
LoadTitle.BackgroundTransparency = 1
LoadTitle.TextColor3         = Color3.fromRGB(255, 255, 255)
LoadTitle.Font               = fontBold
LoadTitle.TextSize           = 44
LoadTitle.Text               = "Rose Hub"
LoadTitle.ZIndex             = 101
LoadTitle.Parent             = LoadFrame

local LoadSub = Instance.new("TextLabel")
LoadSub.Size                 = UDim2.new(0, 360, 0, 28)
LoadSub.AnchorPoint          = Vector2.new(0.5, 0.5)
LoadSub.Position             = UDim2.new(0.5, 0, 0.52, 0)
LoadSub.BackgroundTransparency = 1
LoadSub.TextColor3           = Color3.fromRGB(150, 150, 150)
LoadSub.Font                 = fontNormal
LoadSub.TextSize             = 15
LoadSub.Text                 = "dev by vateax"
LoadSub.ZIndex               = 101
LoadSub.Parent               = LoadFrame

local LoadBarBG = Instance.new("Frame")
LoadBarBG.Size             = UDim2.new(0, 340, 0, 6)
LoadBarBG.AnchorPoint      = Vector2.new(0.5, 0.5)
LoadBarBG.Position         = UDim2.new(0.5, 0, 0.64, 0)
LoadBarBG.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
LoadBarBG.BorderSizePixel  = 0
LoadBarBG.ZIndex           = 101
Instance.new("UICorner", LoadBarBG).CornerRadius = UDim.new(1, 0)
LoadBarBG.Parent           = LoadFrame

local LoadBar = Instance.new("Frame")
LoadBar.Size             = UDim2.new(0, 0, 1, 0)
LoadBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
LoadBar.BorderSizePixel  = 0
LoadBar.ZIndex           = 102
Instance.new("UICorner", LoadBar).CornerRadius = UDim.new(1, 0)
LoadBar.Parent           = LoadBarBG

local spinnerParts = {}
for i = 1, 4 do
    local dot = Instance.new("Frame")
    dot.Size             = UDim2.new(0, 14, 0, 14)
    dot.AnchorPoint      = Vector2.new(0.5, 0.5)
    dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    dot.BorderSizePixel  = 0
    dot.ZIndex           = 102
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
    dot.Parent           = LoadFrame
    spinnerParts[i]      = dot
end

-- ────────────────────────────────────────────
--  RESET HITBOXES  (defined early for GUI use)
-- ────────────────────────────────────────────
local function resetHitboxes()
    for _, v in ipairs(Players:GetPlayers()) do
        if v ~= plr then
            pcall(function()
                local hrp = v.Character and v.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.Size        = DEFAULT_HITBOX_SIZE
                    hrp.Transparency = 1
                end
            end)
        end
    end
end

-- ────────────────────────────────────────────
--  MAIN FRAME  (scrollable, white/black theme)
-- ────────────────────────────────────────────
local MainFrame = Instance.new("Frame")
MainFrame.Size             = UDim2.new(0, 380, 0, 480)
MainFrame.Position         = UDim2.new(0.5, -190, 0.5, -240)
MainFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
MainFrame.BorderSizePixel  = 0
MainFrame.Visible          = false
MainFrame.ClipsDescendants = true
MainFrame.ZIndex           = 10
MainFrame.Parent           = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

local Stroke = Instance.new("UIStroke")
Stroke.Color        = Color3.fromRGB(255, 255, 255)
Stroke.Thickness    = 1.5
Stroke.Transparency = 0.55
Stroke.Parent       = MainFrame

-- White title bar
local TitleBar = Instance.new("Frame")
TitleBar.Size             = UDim2.new(1, 0, 0, 64)
TitleBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TitleBar.BorderSizePixel  = 0
TitleBar.ZIndex           = 11
TitleBar.Parent           = MainFrame
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 12)

-- Square off bottom corners of title bar
local TitleFix = Instance.new("Frame")
TitleFix.Size             = UDim2.new(1, 0, 0, 12)
TitleFix.Position         = UDim2.new(0, 0, 1, -12)
TitleFix.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TitleFix.BorderSizePixel  = 0
TitleFix.ZIndex           = 11
TitleFix.Parent           = TitleBar

-- Thin dark separator under title bar
local TitleAccent = Instance.new("Frame")
TitleAccent.Size             = UDim2.new(1, -20, 0, 1)
TitleAccent.Position         = UDim2.new(0, 10, 1, 0)
TitleAccent.BackgroundColor3 = Color3.fromRGB(210, 210, 210)
TitleAccent.BorderSizePixel  = 0
TitleAccent.ZIndex           = 13
TitleAccent.Parent           = TitleBar

-- ── DRAWN ROSE (right side of title bar) ────
-- Stem
local roseStem = Instance.new("Frame")
roseStem.Size             = UDim2.new(0, 2, 0, 20)
roseStem.Position         = UDim2.new(1, -38, 0, 34)
roseStem.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
roseStem.BorderSizePixel  = 0
roseStem.ZIndex           = 14
roseStem.Parent           = TitleBar

-- Petals — 5 overlapping rounded frames
local petalData = {
    {w=18, h=13, x=-46, y=10},
    {w=13, h=18, x=-38, y=8 },
    {w=18, h=13, x=-42, y=18},
    {w=15, h=15, x=-44, y=14},
    {w=11, h=11, x=-39, y=16},
}
for i, d in ipairs(petalData) do
    local p = Instance.new("Frame")
    p.Size             = UDim2.new(0, d.w, 0, d.h)
    p.Position         = UDim2.new(1, d.x, 0, d.y)
    p.BackgroundColor3 = i <= 2 and Color3.fromRGB(40, 40, 40)
                      or i <= 4 and Color3.fromRGB(25, 25, 25)
                      or             Color3.fromRGB(12, 12, 12)
    p.BorderSizePixel  = 0
    p.ZIndex           = 12 + i
    p.Parent           = TitleBar
    Instance.new("UICorner", p).CornerRadius = UDim.new(1, 0)
end

-- Leaf
local roseLeaf = Instance.new("Frame")
roseLeaf.Size             = UDim2.new(0, 12, 0, 7)
roseLeaf.Position         = UDim2.new(1, -47, 0, 46)
roseLeaf.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
roseLeaf.BorderSizePixel  = 0
roseLeaf.ZIndex           = 14
roseLeaf.Parent           = TitleBar
Instance.new("UICorner", roseLeaf).CornerRadius = UDim.new(1, 0)

-- Title text
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size               = UDim2.new(1, -70, 0, 34)
TitleLabel.Position           = UDim2.new(0, 14, 0, 6)
TitleLabel.BackgroundTransparency = 1
TitleLabel.TextColor3         = Color3.fromRGB(10, 10, 10)
TitleLabel.Font               = fontBold
TitleLabel.TextSize           = 21
TitleLabel.TextXAlignment     = Enum.TextXAlignment.Left
TitleLabel.Text               = "Rose Hub"
TitleLabel.ZIndex             = 12
TitleLabel.Parent             = TitleBar

local TitleSub = Instance.new("TextLabel")
TitleSub.Size               = UDim2.new(1, -70, 0, 16)
TitleSub.Position           = UDim2.new(0, 14, 0, 42)
TitleSub.BackgroundTransparency = 1
TitleSub.TextColor3         = Color3.fromRGB(130, 130, 130)
TitleSub.Font               = fontNormal
TitleSub.TextSize           = 11
TitleSub.TextXAlignment     = Enum.TextXAlignment.Left
TitleSub.Text               = "Ball TP  •  dev by vateax  •  Ctrl=Hide"
TitleSub.ZIndex             = 12
TitleSub.Parent             = TitleBar

-- ── SCROLLING CONTENT AREA ──────────────────
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size                 = UDim2.new(1, 0, 1, -64)
ScrollFrame.Position             = UDim2.new(0, 0, 0, 64)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel      = 0
ScrollFrame.ScrollBarThickness   = 3
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(160, 160, 160)
ScrollFrame.AutomaticCanvasSize  = Enum.AutomaticSize.Y
ScrollFrame.CanvasSize           = UDim2.new(0, 0, 0, 0)
ScrollFrame.ZIndex               = 11
ScrollFrame.Parent               = MainFrame

local ScrollLayout = Instance.new("UIListLayout")
ScrollLayout.Padding             = UDim.new(0, 8)
ScrollLayout.SortOrder           = Enum.SortOrder.LayoutOrder
ScrollLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
ScrollLayout.Parent              = ScrollFrame

local ScrollPad = Instance.new("UIPadding")
ScrollPad.PaddingTop    = UDim.new(0, 10)
ScrollPad.PaddingBottom = UDim.new(0, 14)
ScrollPad.PaddingLeft   = UDim.new(0, 14)
ScrollPad.PaddingRight  = UDim.new(0, 14)
ScrollPad.Parent        = ScrollFrame

-- ── SECTION HEADER HELPER ───────────────────
local sectionOrder = 0
local function makeSection(title)
    sectionOrder += 1
    local hdr = Instance.new("Frame")
    hdr.LayoutOrder         = sectionOrder
    hdr.Size                = UDim2.new(1, 0, 0, 26)
    hdr.BackgroundColor3    = Color3.fromRGB(35, 35, 35)
    hdr.BorderSizePixel     = 0
    hdr.ZIndex              = 12
    hdr.Parent              = ScrollFrame
    Instance.new("UICorner", hdr).CornerRadius = UDim.new(0, 7)
    local hdrStroke = Instance.new("UIStroke")
    hdrStroke.Color        = Color3.fromRGB(255, 255, 255)
    hdrStroke.Thickness    = 1
    hdrStroke.Transparency = 0.75
    hdrStroke.Parent       = hdr
    local lbl = Instance.new("TextLabel")
    lbl.Size                = UDim2.new(1, -12, 1, 0)
    lbl.Position            = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text                = title
    lbl.TextColor3          = Color3.fromRGB(255, 255, 255)
    lbl.TextSize            = 12
    lbl.Font                = fontBold
    lbl.TextXAlignment      = Enum.TextXAlignment.Left
    lbl.ZIndex              = 13
    lbl.Parent              = hdr
end

-- ── ROW HELPERS ─────────────────────────────
local function makeToggleRow(labelText, getVal, setVal, onRefresh)
    sectionOrder += 1
    local row = Instance.new("Frame")
    row.LayoutOrder         = sectionOrder
    row.Size                = UDim2.new(1, 0, 0, 44)
    row.BackgroundColor3    = Color3.fromRGB(22, 22, 22)
    row.BorderSizePixel     = 0
    row.ZIndex              = 12
    row.Parent              = ScrollFrame
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 9)
    local rowStroke = Instance.new("UIStroke")
    rowStroke.Color        = Color3.fromRGB(50, 50, 50)
    rowStroke.Thickness    = 1
    rowStroke.Parent       = row

    local lbl = Instance.new("TextLabel")
    lbl.Size                = UDim2.new(0.6, 0, 1, 0)
    lbl.Position            = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text                = labelText
    lbl.TextColor3          = Color3.fromRGB(220, 220, 220)
    lbl.TextSize            = 14
    lbl.Font                = fontBold
    lbl.TextXAlignment      = Enum.TextXAlignment.Left
    lbl.ZIndex              = 13
    lbl.Parent              = row

    local btn = Instance.new("TextButton")
    btn.Size              = UDim2.new(0, 80, 0, 28)
    btn.Position          = UDim2.new(1, -92, 0.5, -14)
    btn.BorderSizePixel   = 0
    btn.AutoButtonColor   = false
    btn.Font              = fontBold
    btn.TextSize          = 13
    btn.TextColor3        = Color3.fromRGB(255, 255, 255)
    btn.ZIndex            = 13
    btn.Parent            = row
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 7)

    local function refresh()
        local v = getVal()
        btn.Text             = v and "ON" or "OFF"
        btn.BackgroundColor3 = v and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(40, 40, 40)
        btn.TextColor3       = v and Color3.fromRGB(10, 10, 10) or Color3.fromRGB(180, 180, 180)
    end
    refresh()
    btn.MouseButton1Click:Connect(function()
        setVal(not getVal())
        refresh()
        if onRefresh then onRefresh() end
    end)
    return refresh
end

local function makeNumInputRow(labelText, getVal, setVal)
    sectionOrder += 1
    local row = Instance.new("Frame")
    row.LayoutOrder         = sectionOrder
    row.Size                = UDim2.new(1, 0, 0, 44)
    row.BackgroundColor3    = Color3.fromRGB(22, 22, 22)
    row.BorderSizePixel     = 0
    row.ZIndex              = 12
    row.Parent              = ScrollFrame
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 9)
    local rowStroke = Instance.new("UIStroke")
    rowStroke.Color     = Color3.fromRGB(50, 50, 50)
    rowStroke.Thickness = 1
    rowStroke.Parent    = row

    local lbl = Instance.new("TextLabel")
    lbl.Size                = UDim2.new(0.55, 0, 1, 0)
    lbl.Position            = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text                = labelText
    lbl.TextColor3          = Color3.fromRGB(190, 190, 190)
    lbl.TextSize            = 13
    lbl.Font                = fontNormal
    lbl.TextXAlignment      = Enum.TextXAlignment.Left
    lbl.ZIndex              = 13
    lbl.Parent              = row

    local bg = Instance.new("Frame")
    bg.Size             = UDim2.new(0, 110, 0, 30)
    bg.Position         = UDim2.new(1, -122, 0.5, -15)
    bg.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
    bg.BorderSizePixel  = 0
    bg.ZIndex           = 13
    bg.Parent           = row
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 7)
    local bgStroke = Instance.new("UIStroke")
    bgStroke.Color        = Color3.fromRGB(255, 255, 255)
    bgStroke.Thickness    = 1
    bgStroke.Transparency = 0.7
    bgStroke.Parent       = bg

    local tb = Instance.new("TextBox")
    tb.Size               = UDim2.new(1, -8, 1, 0)
    tb.Position           = UDim2.new(0, 4, 0, 0)
    tb.BackgroundTransparency = 1
    tb.BorderSizePixel    = 0
    tb.Text               = tostring(getVal())
    tb.TextColor3         = Color3.fromRGB(255, 255, 255)
    tb.TextSize           = 14
    tb.Font               = fontBold
    tb.ClearTextOnFocus   = false
    tb.ZIndex             = 14
    tb.Parent             = bg

    tb.FocusLost:Connect(function()
        local num = tonumber(tb.Text)
        if num then setVal(num) tb.Text = tostring(num)
        else tb.Text = tostring(getVal()) end
    end)
end

-- ── REACH SECTION ───────────────────────────
makeSection("❖  REACH / BALL TP")

-- Toggle button (kept as prominent full-width button)
sectionOrder += 1
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.LayoutOrder      = sectionOrder
ToggleBtn.Size             = UDim2.new(1, 0, 0, 54)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
ToggleBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font             = fontBold
ToggleBtn.TextSize         = 18
ToggleBtn.Text             = "Reach: OFF"
ToggleBtn.BorderSizePixel  = 0
ToggleBtn.ZIndex           = 12
ToggleBtn.Parent           = ScrollFrame
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 10)
local TogStroke = Instance.new("UIStroke")
TogStroke.Color        = Color3.fromRGB(255, 255, 255)
TogStroke.Thickness    = 1
TogStroke.Transparency = 0.75
TogStroke.Parent       = ToggleBtn

-- Size row (label + input + cycle)
sectionOrder += 1
local SizeRow = Instance.new("Frame")
SizeRow.LayoutOrder         = sectionOrder
SizeRow.Size                = UDim2.new(1, 0, 0, 44)
SizeRow.BackgroundColor3    = Color3.fromRGB(22, 22, 22)
SizeRow.BorderSizePixel     = 0
SizeRow.ZIndex              = 12
SizeRow.Parent              = ScrollFrame
Instance.new("UICorner", SizeRow).CornerRadius = UDim.new(0, 9)
local SizeRowStroke = Instance.new("UIStroke")
SizeRowStroke.Color     = Color3.fromRGB(50, 50, 50)
SizeRowStroke.Thickness = 1
SizeRowStroke.Parent    = SizeRow

local PowerLabel = Instance.new("TextLabel")
PowerLabel.Size               = UDim2.new(0, 64, 1, 0)
PowerLabel.Position           = UDim2.new(0, 12, 0, 0)
PowerLabel.BackgroundTransparency = 1
PowerLabel.TextColor3         = Color3.fromRGB(190, 190, 190)
PowerLabel.Font               = fontNormal
PowerLabel.TextSize           = 14
PowerLabel.TextXAlignment     = Enum.TextXAlignment.Left
PowerLabel.Text               = "Size:"
PowerLabel.ZIndex             = 13
PowerLabel.Parent             = SizeRow

local PowerBox = Instance.new("TextBox")
PowerBox.Size             = UDim2.new(0, 110, 0, 30)
PowerBox.Position         = UDim2.new(0, 76, 0.5, -15)
PowerBox.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
PowerBox.TextColor3       = Color3.fromRGB(255, 255, 255)
PowerBox.Font             = fontBold
PowerBox.TextSize         = 16
PowerBox.Text             = tostring(reachSize)
PowerBox.BorderSizePixel  = 0
PowerBox.ClearTextOnFocus = false
PowerBox.ZIndex           = 13
PowerBox.Parent           = SizeRow
Instance.new("UICorner", PowerBox).CornerRadius = UDim.new(0, 7)
local PBStroke = Instance.new("UIStroke")
PBStroke.Color        = Color3.fromRGB(255, 255, 255)
PBStroke.Thickness    = 1
PBStroke.Transparency = 0.7
PBStroke.Parent       = PowerBox

local CycleBtn = Instance.new("TextButton")
CycleBtn.Size             = UDim2.new(0, 100, 0, 30)
CycleBtn.Position         = UDim2.new(1, -112, 0.5, -15)
CycleBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
CycleBtn.TextColor3       = Color3.fromRGB(10, 10, 10)
CycleBtn.Font             = fontBold
CycleBtn.TextSize         = 14
CycleBtn.Text             = "Cycle"
CycleBtn.BorderSizePixel  = 0
CycleBtn.ZIndex           = 13
CycleBtn.Parent           = SizeRow
Instance.new("UICorner", CycleBtn).CornerRadius = UDim.new(0, 7)

-- ── STICKY HEAD SECTION ─────────────────────
makeSection("❖  STICKY HEAD  [R / RB]")
makeToggleRow("Sticky Head", function() return STICKY_HEAD_ENABLED end, function(v) STICKY_HEAD_ENABLED = v end)
makeNumInputRow("Pull Strength", function() return STICKY_PULL end, function(v) STICKY_PULL = v end)
makeNumInputRow("Stickiness", function() return STICKY_POWER end, function(v) STICKY_POWER = v end)
makeNumInputRow("Boost Power", function() return BOOST_POWER end, function(v) BOOST_POWER = v end)

-- ── HITBOX SECTION ───────────────────────────
makeSection("❖  HITBOX EXPANSION")
makeToggleRow("Hitbox", function() return HITBOX_ENABLED end, function(v)
    HITBOX_ENABLED = v
    if not v then resetHitboxes() end
end)
makeNumInputRow("Hitbox Size", function() return HITBOX_SIZE end, function(v) HITBOX_SIZE = v end)

-- ── HINT LABEL ───────────────────────────────
sectionOrder += 1
local HintLabel = Instance.new("TextLabel")
HintLabel.LayoutOrder        = sectionOrder
HintLabel.Size               = UDim2.new(1, 0, 0, 24)
HintLabel.BackgroundTransparency = 1
HintLabel.TextColor3         = Color3.fromRGB(80, 80, 80)
HintLabel.Font               = fontNormal
HintLabel.TextSize           = 12
HintLabel.Text               = "Toggle UI: Left Ctrl / H / T  •  Controller: Select"
HintLabel.TextXAlignment     = Enum.TextXAlignment.Center
HintLabel.ZIndex             = 12
HintLabel.Parent             = ScrollFrame

-- ────────────────────────────────────────────
--  TOGGLE REFRESH
-- ────────────────────────────────────────────
local function refreshToggle()
    TweenService:Create(ToggleBtn, TweenInfo.new(0.18), {
        BackgroundColor3 = reachEnabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(22, 22, 22),
        TextColor3       = reachEnabled and Color3.fromRGB(10, 10, 10)   or Color3.fromRGB(255, 255, 255),
    }):Play()
    ToggleBtn.Text = reachEnabled and "Reach: ON" or "Reach: OFF"
end

-- ────────────────────────────────────────────
--  BUTTON ANIMATIONS
-- ────────────────────────────────────────────
local function addButtonAnim(btn, base, hover)
    local orig = btn.Size
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = hover}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = base}):Play()
    end)
    btn.MouseButton1Down:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.07), {
            Size = UDim2.new(orig.X.Scale, orig.X.Offset - 6, orig.Y.Scale, orig.Y.Offset - 4)
        }):Play()
    end)
    btn.MouseButton1Up:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.14, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = orig
        }):Play()
    end)
end
addButtonAnim(ToggleBtn, Color3.fromRGB(22, 22, 22),   Color3.fromRGB(40, 40, 40))
addButtonAnim(CycleBtn,  Color3.fromRGB(255, 255, 255), Color3.fromRGB(210, 210, 210))

-- ────────────────────────────────────────────
--  DRAG
-- ────────────────────────────────────────────
do
    local dragging, dragInput, dragStart, startPos
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging  = true
            dragStart = input.Position
            startPos  = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    TitleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and input == dragInput and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ────────────────────────────────────────────
--  LOADING ANIMATION
-- ────────────────────────────────────────────
local spinnerAngle = 0
local spinnerConn

task.spawn(function()
    task.wait()
    spinnerConn = RunService.RenderStepped:Connect(function(dt)
        if not LoadFrame.Parent then spinnerConn:Disconnect() return end
        spinnerAngle = spinnerAngle + dt * 2.8
        local cx = LoadFrame.AbsoluteSize.X * 0.5
        local cy = LoadFrame.AbsoluteSize.Y * 0.33
        local r  = 48
        for i, dot in ipairs(spinnerParts) do
            local a = spinnerAngle + (i - 1) * (math.pi * 0.5)
            dot.Position = UDim2.new(0, cx + math.cos(a) * r, 0, cy + math.sin(a) * r)
            dot.BackgroundTransparency = 0.1 + 0.7 * ((i - 1) / 4)
        end
    end)
end)

TweenService:Create(LoadBar, TweenInfo.new(2.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
    Size = UDim2.new(1, 0, 1, 0)
}):Play()

task.spawn(function()
    task.wait(3.0)
    for _, obj in ipairs(LoadFrame:GetDescendants()) do
        if obj:IsA("TextLabel") then
            TweenService:Create(obj, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
        end
    end
    task.wait(0.35)
    TweenService:Create(LoadFrame, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        BackgroundTransparency = 1
    }):Play()
    for _, obj in ipairs(LoadFrame:GetDescendants()) do
        if obj:IsA("Frame") then
            TweenService:Create(obj, TweenInfo.new(0.45), {BackgroundTransparency = 1}):Play()
        end
    end
    task.wait(0.5)
    LoadFrame:Destroy()
    MainFrame.Position = UDim2.new(0.5, -190, 1.3, 0)
    MainFrame.Visible  = true
    TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -190, 0.5, -240)
    }):Play()
end)

-- ────────────────────────────────────────────
--  CHARACTER MANAGEMENT
-- ────────────────────────────────────────────
local character, humanoid, root

local function setupCharacter(char)
    character = char
    humanoid  = char:WaitForChild("Humanoid", 10)
    root      = char:WaitForChild("HumanoidRootPart", 10)
    if humanoid then
        humanoid.UseJumpPower = true
        humanoid.StateChanged:Connect(function(_, newState)
            if newState == Enum.HumanoidStateType.Freefall
            or newState == Enum.HumanoidStateType.Jumping then
                isAirborne = true
                if Workspace.Gravity == LOW_GRAVITY then lockedInAir = true end
            elseif newState == Enum.HumanoidStateType.Landed then
                isAirborne  = false
                lockedInAir = false
            end
        end)
        humanoid.Died:Connect(function() humanoid = nil root = nil end)
    end
end

if plr.Character then setupCharacter(plr.Character) end
plr.CharacterAdded:Connect(function(char)
    task.spawn(function()
        setupCharacter(char)
        task.wait(1)
        originalSizes     = {}
        hiddenWrapTargets = {}
        if reachEnabled then applyReach() end
    end)
end)

-- ────────────────────────────────────────────
--  BALL DETECTION
-- ────────────────────────────────────────────
local function isValidBall(part)
    if not part or not part:IsA("BasePart") then return false end
    if not part:IsDescendantOf(workspace) then
        local char = plr.Character
        if char and part:IsDescendantOf(char) then
            local n = part.Name:lower()
            if n:find("ball") or n:find("football") then return true end
        end
        return false
    end
    return true
end

local function findActiveBall()
    local char = plr.Character
    if char then
        for _, d in ipairs(char:GetDescendants()) do
            if d:IsA("BasePart") then
                local n = d.Name:lower()
                if n:find("ball") or n:find("football") then return d end
            end
        end
    end
    for _, obj in ipairs(CollectionService:GetTagged(TAG_NAME)) do
        if isValidBall(obj) then return obj end
    end
    local found = workspace:FindFirstChild(BALL_NAME, true)
    if isValidBall(found) then return found end
    for _, fn in pairs({"Games","MiniGames","Live","Balls","Active","Field"}) do
        local f = workspace:FindFirstChild(fn)
        if f then
            local b = f:FindFirstChild(BALL_NAME, true)
            if isValidBall(b) then return b end
        end
    end
    for _, d in ipairs(workspace:GetDescendants()) do
        if d:IsA("BasePart") then
            local n = d.Name:lower()
            if (n:find("ball") or n:find("football")) and isValidBall(d) then return d end
        end
    end
    return nil
end

CollectionService:GetInstanceAddedSignal(TAG_NAME):Connect(function(obj)
    if isValidBall(obj) then cachedBall = obj end
end)
workspace.ChildAdded:Connect(function(child)
    if (child.Name == BALL_NAME or child.Name:lower():find("ball")) and isValidBall(child) then
        cachedBall = child
    end
end)

-- ────────────────────────────────────────────
--  REACH / BALL-TP LOGIC
-- ────────────────────────────────────────────
local function safeset(obj, prop, val)
    pcall(function() obj[prop] = val end)
end

local function getHands()
    local char = player.Character
    if not char then return nil, nil end
    local right = char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm")
    local left  = char:FindFirstChild("LeftHand")  or char:FindFirstChild("Left Arm")
    return right, left
end

local function syncSkinTone(realHand, spoofer)
    if not realHand or not spoofer then return end
    local char = realHand.Parent
    if not char then return end
    local bodyColors = char:FindFirstChildOfClass("BodyColors")
    if bodyColors then
        spoofer.Color = realHand.Name:find("Right") and bodyColors.RightArmColor3 or bodyColors.LeftArmColor3
    else
        local head = char:FindFirstChild("Head")
        if head then spoofer.Color = head.Color end
    end
end

local function createSpoofer(realHand)
    if not realHand then return end
    local char = realHand.Parent
    if not char then return end
    local existing = char:FindFirstChild(realHand.Name .. "_Spoofer")
    if existing then syncSkinTone(realHand, existing) return end
    if not originalSizes[realHand] then originalSizes[realHand] = realHand.Size end
    local ok, spoofer = pcall(function() return realHand:Clone() end)
    if not ok or not spoofer then return end
    spoofer.Name = realHand.Name .. "_Spoofer"
    for _, child in ipairs(spoofer:GetChildren()) do
        if child:IsA("JointInstance") or child:IsA("Motor6D")
        or child:IsA("Script") or child:IsA("LocalScript") then child:Destroy() end
    end
    safeset(spoofer, "Size",         originalSizes[realHand])
    safeset(spoofer, "Transparency", 0)
    safeset(spoofer, "Massless",     true)
    safeset(spoofer, "CanCollide",   false)
    safeset(spoofer, "CFrame",       realHand.CFrame)
    spoofer.Parent = char
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = realHand weld.Part1 = spoofer weld.Parent = spoofer
    syncSkinTone(realHand, spoofer)
end

function applyReach()
    local right, left = getHands()
    local char = player.Character
    if not char then return end
    if reachEnabled then
        createSpoofer(right) createSpoofer(left)
        for _, hand in ipairs({right, left}) do
            if hand then
                for _, child in ipairs(hand:GetChildren()) do
                    if child:IsA("WrapTarget") then hiddenWrapTargets[child] = hand child.Parent = nil end
                end
                safeset(hand, "Size",        Vector3.new(reachSize, reachSize, reachSize))
                safeset(hand, "Transparency", 1)
                safeset(hand, "Massless",     true)
                safeset(hand, "CanCollide",   false)
            end
        end
    else
        if right then local sp = char:FindFirstChild(right.Name.."_Spoofer") if sp then sp:Destroy() end end
        if left  then local sp = char:FindFirstChild(left.Name .."_Spoofer") if sp then sp:Destroy() end end
        for _, hand in ipairs({right, left}) do
            if hand then
                safeset(hand, "Size",        originalSizes[hand] or Vector3.new(1,1,1))
                safeset(hand, "Transparency", 0)
                safeset(hand, "Massless",     false)
                safeset(hand, "CanCollide",   true)
                for wt, ph in pairs(hiddenWrapTargets) do
                    if ph == hand then wt.Parent = hand hiddenWrapTargets[wt] = nil end
                end
            end
        end
    end
end

-- ────────────────────────────────────────────
--  TACKLE REACH  (silent)
-- ────────────────────────────────────────────
local function applyTackleReach()
    if not TR_ENABLED then return end
    for _, folderName in pairs({"Games","MiniGames","ParkMap","ParkMatchMap"}) do
        local folder = Workspace:FindFirstChild(folderName)
        if folder then
            for _, inst in pairs(folder:GetChildren()) do
                local rep = inst:FindFirstChild("Replicated")
                if rep and rep:FindFirstChild("Hitboxes") then
                    for _, part in pairs(rep.Hitboxes:GetChildren()) do
                        if part:IsA("BasePart") and (part.Name == plr.Name or part.Name == tostring(plr.UserId)) then
                            if part.Size ~= Vector3.new(TR_SIZE, TR_SIZE*1.5, TR_SIZE) then
                                part.Size = Vector3.new(TR_SIZE, TR_SIZE*1.5, TR_SIZE)
                                part.Transparency = TR_TRANS
                                part.Material = Enum.Material.Neon
                                part.Color = Color3.fromRGB(180, 50, 90)
                            end
                        end
                    end
                end
            end
        end
    end
end

-- ────────────────────────────────────────────
--  STICKY HEAD  (silent)
-- ────────────────────────────────────────────
local function getClosestPlayer()
    local nearest, minDist = nil, 35
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= plr and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            local hum = p.Character:FindFirstChild("Humanoid")
            if hrp and hum and hum.Health > 0 and root then
                local d = (hrp.Position - root.Position).Magnitude
                if d < minDist then minDist = d nearest = p end
            end
        end
    end
    return nearest
end

local function doHeadBoost(rootPart)
    onBoostCooldown  = true
    boostCdRemaining = BOOST_COOLDOWN
    local bv = Instance.new("BodyVelocity")
    bv.Velocity = Vector3.new(0, BOOST_POWER, 0)
    bv.MaxForce = Vector3.new(0, 9e9, 0)
    bv.Parent   = rootPart
    task.spawn(function() task.wait(0.2) if bv then bv:Destroy() end end)
    task.spawn(function() task.wait(BOOST_COOLDOWN) onBoostCooldown = false end)
end

local function checkFeetOnHead(myHRP, theirHead)
    local myFeetY  = myHRP.Position.Y    - (myHRP.Size.Y    / 2)
    local headTopY = theirHead.Position.Y + (theirHead.Size.Y / 2)
    local dy = myFeetY - headTopY
    if dy < -0.5 or dy > 2 then return false end
    local dx = math.abs(myHRP.Position.X - theirHead.Position.X)
    local dz = math.abs(myHRP.Position.Z - theirHead.Position.Z)
    return dx <= theirHead.Size.X/2 + 0.5 and dz <= theirHead.Size.Z/2 + 0.5
end

-- ────────────────────────────────────────────
--  JUMP IMPULSE  (silent)
-- ────────────────────────────────────────────
local jumpOnCD = false
UIS.JumpRequest:Connect(function()
    if not character or not root then return end
    if JUMP_SPEED_ENABLED and JUMP_MULTIPLIER > 1.0 and humanoid
    and humanoid:GetState() ~= Enum.HumanoidStateType.Freefall then
        local boost = (JUMP_MULTIPLIER - 1) * 18
        root.AssemblyLinearVelocity = Vector3.new(
            root.AssemblyLinearVelocity.X,
            root.AssemblyLinearVelocity.Y + boost,
            root.AssemblyLinearVelocity.Z
        )
    end
    if not jumpOnCD then
        jumpOnCD = true
        root:ApplyImpulse(Vector3.new(0, JUMP_POWER_MULTIPLIER * root.AssemblyMass, 0))
        task.wait(JUMP_COOLDOWN)
        jumpOnCD = false
    end
end)

-- ────────────────────────────────────────────
--  BUTTON CONNECTIONS
-- ────────────────────────────────────────────
PowerBox.FocusLost:Connect(function()
    local num = tonumber(PowerBox.Text)
    if num then
        reachSize = math.clamp(num, 1, 500)
        PowerBox.Text = tostring(reachSize)
        if reachEnabled then applyReach() end
    else
        PowerBox.Text = tostring(reachSize)
    end
end)

CycleBtn.MouseButton1Click:Connect(function()
    currentLevel  = (currentLevel % #levels) + 1
    reachSize     = levels[currentLevel]
    PowerBox.Text = tostring(reachSize)
    if reachEnabled then applyReach() end
end)

ToggleBtn.MouseButton1Click:Connect(function()
    reachEnabled = not reachEnabled
    refreshToggle()
    applyReach()
end)

-- ────────────────────────────────────────────
--  HOTKEYS
-- ────────────────────────────────────────────
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    local key = input.KeyCode

    -- Toggle UI  (LeftCtrl, H, T, L1, Select)
    if key == Enum.KeyCode.LeftControl or key == Enum.KeyCode.H
    or key == Enum.KeyCode.T or key == Enum.KeyCode.ButtonSelect
    or key == Enum.KeyCode.ButtonL1 then
        guiVisible = not guiVisible
        if guiVisible then
            MainFrame.Visible  = true
            MainFrame.Position = UDim2.new(0.5, -190, 1.3, 0)
            TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Position = UDim2.new(0.5, -190, 0.5, -240)
            }):Play()
        else
            TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Position = UDim2.new(0.5, -190, 1.3, 0)
            }):Play()
            task.spawn(function() task.wait(0.3) MainFrame.Visible = false end)
        end
    end

    -- Speed toggle  V / LB  (LB already used for UI toggle above, keep V only to avoid conflict)
    if key == Enum.KeyCode.V then
        WALK_SPEED_ENABLED = not WALK_SPEED_ENABLED
        if humanoid then humanoid.WalkSpeed = WALK_SPEED_ENABLED and CUSTOM_WALKSPEED or DEFAULT_WALKSPEED end
    end

    -- Sticky head toggle  R / RB
    if key == Enum.KeyCode.R or key == Enum.KeyCode.ButtonR1 then
        STICKY_HEAD_ENABLED = not STICKY_HEAD_ENABLED
    end
end)

-- ────────────────────────────────────────────
--  MAIN LOOPS
-- ────────────────────────────────────────────
RunService.Stepped:Connect(function()
    if humanoid and humanoid.Parent then
        local targetSpeed = WALK_SPEED_ENABLED and CUSTOM_WALKSPEED or DEFAULT_WALKSPEED
        if humanoid.WalkSpeed ~= targetSpeed then humanoid.WalkSpeed = targetSpeed end
        if JUMP_SPEED_ENABLED then humanoid.JumpPower = BASE_JUMP_POWER * JUMP_MULTIPLIER end
    end
end)

RunService.RenderStepped:Connect(function()
    -- Reach skin sync
    if reachEnabled then
        local right, left = getHands()
        if right and right.Size.X ~= reachSize then applyReach() end
        if left  and left.Size.X  ~= reachSize then applyReach() end
        if right then syncSkinTone(right, right.Parent and right.Parent:FindFirstChild(right.Name.."_Spoofer")) end
        if left  then syncSkinTone(left,  left.Parent  and left.Parent:FindFirstChild(left.Name .."_Spoofer"))  end
    end

    local now = os.clock()

    -- Tackle reach
    if TR_ENABLED and (now - lastReachUpdate > 0.1) then
        lastReachUpdate = now
        applyTackleReach()
    end

    -- Hitbox expansion
    if HITBOX_ENABLED and (now - lastHitboxUpdate > 0.1) then
        lastHitboxUpdate = now
        local sz = Vector3.new(HITBOX_SIZE, HITBOX_SIZE, HITBOX_SIZE)
        for _, v in ipairs(Players:GetPlayers()) do
            if v ~= plr then
                local hrp = v.Character and v.Character:FindFirstChild("HumanoidRootPart")
                if hrp and hrp.Size ~= sz then
                    hrp.Size = sz hrp.Transparency = 1
                    hrp.Material = Enum.Material.Neon hrp.CanCollide = true
                end
            end
        end
    end

    -- Ball cache refresh
    if not cachedBall or not cachedBall.Parent or not cachedBall:IsDescendantOf(workspace) then
        local f = findActiveBall() if f then cachedBall = f end
    end
    if (not cachedBall or not isValidBall(cachedBall)) and (now - lastBallSearch > 0.3) then
        lastBallSearch = now cachedBall = findActiveBall()
    end

    -- Prox gravity
    if PROX_GRAVITY_ENABLED then
        local char = plr.Character
        local holdingBall = char and cachedBall and cachedBall:IsDescendantOf(char)
        local currentDist = nil
        if root and cachedBall and cachedBall.Parent then
            currentDist = holdingBall and 0 or (cachedBall.Position - root.Position).Magnitude
        end
        local lowG = holdingBall or lockedInAir or (currentDist and currentDist <= TRIGGER_RADIUS)
        if lowG then
            if Workspace.Gravity ~= LOW_GRAVITY then Workspace.Gravity = LOW_GRAVITY end
        else
            if Workspace.Gravity ~= DEFAULT_GRAVITY then Workspace.Gravity = DEFAULT_GRAVITY end
        end
    end

    -- Super fall gravity
    if humanoid and root then
        if root.AssemblyLinearVelocity.Y < -2 then
            Workspace.Gravity = SUPER_FALL_GRAVITY
        elseif not PROX_GRAVITY_ENABLED then
            Workspace.Gravity = NORMAL_GRAVITY
        end
    end

    -- Sticky head physics
    if STICKY_HEAD_ENABLED and humanoid and root then
        local target = getClosestPlayer()
        if target and target.Character then
            local targetHead = target.Character:FindFirstChild("Head")
            if targetHead and humanoid.FloorMaterial == Enum.Material.Air then
                local headPos = targetHead.Position + Vector3.new(0, 1.6, 0)
                local offset  = headPos - root.Position
                local dist    = offset.Magnitude
                local vel     = root.AssemblyLinearVelocity
                if dist > 2.5 then
                    local desired = offset.Unit * (STICKY_PULL * 18)
                    root.AssemblyLinearVelocity = Vector3.new(
                        vel.X + (desired.X - vel.X) * 0.25, vel.Y,
                        vel.Z + (desired.Z - vel.Z) * 0.25)
                end
                if dist <= 3 then
                    local h = Vector3.new((headPos-root.Position).X, 0, (headPos-root.Position).Z)
                    root.AssemblyLinearVelocity = root.AssemblyLinearVelocity + h.Unit*(STICKY_POWER*5)
                end
                if dist <= 2 then
                    local b = headPos - root.Position
                    root.AssemblyLinearVelocity = Vector3.new(b.X*(STICKY_POWER*5), root.AssemblyLinearVelocity.Y, b.Z*(STICKY_POWER*5))
                end
                if dist <= 1.2 then
                    local l = headPos - root.Position
                    root.AssemblyLinearVelocity = Vector3.new(l.X*(STICKY_POWER*6), root.AssemblyLinearVelocity.Y, l.Z*(STICKY_POWER*6))
                end
            end
        end
    end
end)

-- Head boost cooldown & trigger
RunService.Heartbeat:Connect(function(dt)
    if boostCdRemaining > 0 then
        boostCdRemaining = math.max(0, boostCdRemaining - dt)
    end
    if not STICKY_HEAD_ENABLED or onBoostCooldown then return end
    local myChar = plr.Character
    if not myChar then return end
    local myHRP = myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p == plr then continue end
        local char = p.Character
        if not char then continue end
        local hum       = char:FindFirstChildOfClass("Humanoid")
        local theirHead = char:FindFirstChild("Head")
        if not hum or not theirHead then continue end
        local wasJumping = playerJumpStates[p] or false
        local isJumping  = hum.FloorMaterial == Enum.Material.Air
        if isJumping and not wasJumping then playerJumpTimers[p] = 0.15 end
        if playerJumpTimers[p] and playerJumpTimers[p] > 0 then
            playerJumpTimers[p] = playerJumpTimers[p] - dt
            if checkFeetOnHead(myHRP, theirHead) then
                playerJumpTimers[p] = 0
                doHeadBoost(myHRP)
            end
        end
        playerJumpStates[p] = isJumping
    end
end)

Players.PlayerRemoving:Connect(function(p)
    playerJumpStates[p] = nil
    playerJumpTimers[p] = nil
end)
