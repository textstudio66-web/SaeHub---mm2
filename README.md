-- ==========================================
-- 👑 Sae Hub V1 | MM2 Mobile Final Edition
-- ==========================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Camera = Workspace.CurrentCamera
local Mouse = Players.LocalPlayer:GetMouse()

local localPlayer = Players.LocalPlayer
local farmActive = false
local evadeActive = false
local gunEspActive = false
local killAllActive = false
local autoFetchGunActive = false
local tpToolActive = false
local aimbotActive = false
local gunEspConnections = {}

-- 📋 نسخ رابط قناتك تلقائياً
pcall(function()
	if setclipboard then
		setclipboard("https://youtube.com/@itushi_sae")
	end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SaeHubGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

pcall(function()
	if syn and syn.protect_gui then
		syn.protect_gui(ScreenGui)
		ScreenGui.Parent = CoreGui
	elseif CoreGui:FindFirstChild("CoreGui") then
		ScreenGui.Parent = CoreGui
	else
		ScreenGui.Parent = localPlayer:WaitForChild("PlayerGui")
	end
end)

if not ScreenGui.Parent then
	ScreenGui.Parent = localPlayer:WaitForChild("PlayerGui")
end

local function findDroppedGun()
	local activeMap = Workspace:FindFirstChild("Normal") or Workspace:FindFirstChild("ActiveMap")
	if activeMap then
		local gun = activeMap:FindFirstChild("GunDrop")
		if gun and gun:IsA("BasePart") then return gun end
	end
	for _, obj in pairs(Workspace:GetDescendants()) do
		if obj.Name == "GunDrop" and obj:IsA("BasePart") then return obj end
	end
	return nil
end

local function getMurdererCharacter()
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= localPlayer and p.Character then
			local char = p.Character
			if char:FindFirstChild("Knife") or char:FindFirstChild("RealKnife") then
				return char, p.Name
			end
			local backpack = p:FindFirstChild("Backpack")
			if backpack and (backpack:FindFirstChild("Knife") or backpack:FindFirstChild("RealKnife")) then
				return char, p.Name
			end
			local humanoid = char:FindFirstChild("Humanoid")
			if humanoid and char:FindFirstChild("Head") then
				for _, child in pairs(char:GetChildren()) do
					if child:IsA("Highlight") and (child.FillColor == Color3.fromRGB(255, 0, 0) or child.Name == "WatermelonESP") then
						return char, p.Name
					end
				end
			end
		end
	end
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= localPlayer and p.Character then
			if p.Character:FindFirstChildOfClass("Tool") then
				local tool = p.Character:FindFirstChildOfClass("Tool")
				if string.find(string.lower(tool.Name), "knife") then
					return p.Character, p.Name
				end
			end
		end
	end
	return nil, nil
end

local function getTargetPlayer(nameText)
	if not nameText or nameText == "" then return nil end
	local lowerText = string.lower(nameText)
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= localPlayer then
			if string.find(string.lower(p.Name), lowerText) or string.find(string.lower(p.DisplayName), lowerText) then
				return p
			end
		end
	end
	return nil
end

local function makeDraggable(frame, handle)
	local dragging, dragInput, dragStart, startPos
	handle = handle or frame
	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	handle.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end

local ThemeColors = {
	MainBg = Color3.fromRGB(15, 18, 15),
	SidebarBg = Color3.fromRGB(10, 13, 10),
	AccentGreen = Color3.fromRGB(0, 255, 100),
	ButtonDefault = Color3.fromRGB(22, 28, 22),
	ToggleBgOff = Color3.fromRGB(30, 38, 30),
	ToggleBgOn = Color3.fromRGB(15, 60, 30),
	ToggleBallOff = Color3.fromRGB(110, 120, 110),
	ToggleBallOn = Color3.fromRGB(0, 255, 100),
	TextGreen = Color3.fromRGB(0, 255, 100),
	TextDim = Color3.fromRGB(110, 150, 120)
}

local LangFrame = Instance.new("Frame")
LangFrame.Size = UDim2.new(0, 320, 0, 160)
LangFrame.Position = UDim2.new(0.5, -160, 0.5, -80)
LangFrame.BackgroundColor3 = ThemeColors.MainBg
LangFrame.ZIndex = 20
LangFrame.Parent = ScreenGui
Instance.new("UICorner", LangFrame).CornerRadius = UDim.new(0, 10)
local LangStroke = Instance.new("UIStroke") LangStroke.Color = ThemeColors.AccentGreen LangStroke.Thickness = 1.5 LangStroke.Parent = LangFrame

local LangTitle = Instance.new("TextLabel")
LangTitle.Size = UDim2.new(1, 0, 0, 40) LangTitle.BackgroundTransparency = 1 LangTitle.Text = "Choose Language | اختر اللغة" LangTitle.TextColor3 = ThemeColors.TextGreen LangTitle.Font = Enum.Font.GothamMedium LangTitle.TextSize = 15 LangTitle.ZIndex = 20 LangTitle.Parent = LangFrame

local ArBtn = Instance.new("TextButton")
ArBtn.Size = UDim2.new(0, 130, 0, 45) ArBtn.Position = UDim2.new(0, 20, 0, 70) ArBtn.BackgroundColor3 = ThemeColors.ButtonDefault ArBtn.Text = "العربية 🇸🇦" ArBtn.TextColor3 = ThemeColors.TextGreen ArBtn.Font = Enum.Font.GothamMedium ArBtn.TextSize = 14 ArBtn.ZIndex = 20 ArBtn.Parent = LangFrame
Instance.new("UICorner", ArBtn).CornerRadius = UDim.new(0, 8)
local ArStroke = Instance.new("UIStroke") ArStroke.Color = ThemeColors.AccentGreen ArStroke.Thickness = 1 ArStroke.Parent = ArBtn

local EnBtn = Instance.new("TextButton")
EnBtn.Size = UDim2.new(0, 130, 0, 45) EnBtn.Position = UDim2.new(1, -150, 0, 70) EnBtn.BackgroundColor3 = ThemeColors.ButtonDefault EnBtn.Text = "English 🇺🇸" EnBtn.TextColor3 = ThemeColors.TextGreen EnBtn.Font = Enum.Font.GothamMedium EnBtn.TextSize = 14 EnBtn.ZIndex = 20 EnBtn.Parent = LangFrame
Instance.new("UICorner", EnBtn).CornerRadius = UDim.new(0, 8)
local EnStroke = Instance.new("UIStroke") EnStroke.Color = ThemeColors.AccentGreen EnStroke.Thickness = 1 EnStroke.Parent = EnBtn

local ToggleIcon = Instance.new("TextButton")
ToggleIcon.Name = "SaeToggleIcon"
ToggleIcon.Size = UDim2.new(0, 60, 0, 60)
ToggleIcon.Position = UDim2.new(0.02, 0, 0.2, 0)
ToggleIcon.BackgroundColor3 = ThemeColors.MainBg
ToggleIcon.Text = "Sae"
ToggleIcon.TextColor3 = ThemeColors.TextGreen
ToggleIcon.Font = Enum.Font.GothamBold
ToggleIcon.TextSize = 16
ToggleIcon.Visible = false
ToggleIcon.ZIndex = 15
ToggleIcon.Parent = ScreenGui
Instance.new("UICorner", ToggleIcon).CornerRadius = UDim.new(0, 12)
local IconStroke = Instance.new("UIStroke") IconStroke.Color = ThemeColors.AccentGreen IconStroke.Thickness = 1.5 IconStroke.Parent = ToggleIcon

makeDraggable(ToggleIcon)

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 500, 0, 340)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -170)
MainFrame.BackgroundColor3 = ThemeColors.MainBg
MainFrame.Visible = false
MainFrame.ZIndex = 5
local menuVisible = false
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
local MainStroke = Instance.new("UIStroke") MainStroke.Color = ThemeColors.AccentGreen MainStroke.Thickness = 1.5 MainStroke.Parent = MainFrame

makeDraggable(MainFrame, MainFrame)

local ToggleIconState = false
ToggleIcon.MouseButton1Click:Connect(function()
	if ToggleIconState then return end
	ToggleIconState = true
	if not menuVisible then
		MainFrame.Visible = true
		MainFrame.Size = UDim2.new(0, 460, 0, 310)
		TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 500, 0, 340)}):Play()
		menuVisible = true
		task.wait(0.25)
	else
		TweenService:Create(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0, 460, 0, 310)}):Play()
		task.wait(0.2)
		MainFrame.Visible = false
		MainFrame.Size = UDim2.new(0, 500, 0, 340)
		menuVisible = false
	end
	ToggleIconState = false
end)

local Title = Instance.new("TextLabel") Title.Size = UDim2.new(1, 0, 0, 40) Title.BackgroundColor3 = ThemeColors.SidebarBg Title.TextColor3 = ThemeColors.TextGreen Title.Font = Enum.Font.GothamMedium Title.TextSize = 15 Title.TextXAlignment = Enum.TextXAlignment.Left Title.Position = UDim2.new(0, 15, 0, 0) Title.BackgroundTransparency = 1 Title.ZIndex = 6 Title.Parent = MainFrame 
local Sidebar = Instance.new("Frame") Sidebar.Size = UDim2.new(0, 135, 1, -40) Sidebar.Position = UDim2.new(0, 0, 0, 40) Sidebar.BackgroundColor3 = ThemeColors.SidebarBg Sidebar.ZIndex = 6 Sidebar.Parent = MainFrame
local Container = Instance.new("Frame") Container.Size = UDim2.new(1, -145, 1, -50) Container.Position = UDim2.new(0, 140, 0, 45) Container.BackgroundTransparency = 1 Container.ZIndex = 6 Container.Parent = MainFrame

local Tabs = {
	ESP = Instance.new("Frame"),
	Farm = Instance.new("Frame"),
	Auto = Instance.new("Frame"),
	Player = Instance.new("Frame"),
	Teleport = Instance.new("Frame"),
	Server = Instance.new("Frame"),
	Other = Instance.new("Frame"),
	Extra = Instance.new("Frame")
}

for name, frame in pairs(Tabs) do 
	frame.Size = UDim2.new(1, 0, 1, 0) 
	frame.BackgroundTransparency = 1 
	frame.Visible = false 
	frame.ZIndex = 7 
	frame.Parent = Container 
end
Tabs.ESP.Visible = true

local TabButtons = {}
local function createTabButton(name, pos, targetFrame)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 125, 0, 26) btn.BackgroundTransparency = 1 btn.TextColor3 = ThemeColors.TextDim btn.Font = Enum.Font.GothamMedium btn.TextSize = 11 btn.TextXAlignment = Enum.TextXAlignment.Left btn.Position = UDim2.new(0, 10, 0, pos) btn.ZIndex = 8 btn.Parent = Sidebar
	btn.MouseButton1Click:Connect(function() 
		for _, frame in pairs(Tabs) do frame.Visible = false end 
		for _, tBtn in pairs(TabButtons) do tBtn.TextColor3 = ThemeColors.TextDim end
		targetFrame.Visible = true 
		btn.TextColor3 = ThemeColors.TextGreen
	end)
	TabButtons[name] = btn
end

createTabButton("ESP", 8, Tabs.ESP)
createTabButton("Farm", 36, Tabs.Farm)
createTabButton("Auto", 64, Tabs.Auto)
createTabButton("Player", 92, Tabs.Player)
createTabButton("Teleport", 120, Tabs.Teleport)
createTabButton("Server", 148, Tabs.Server)
createTabButton("Other", 176, Tabs.Other)
createTabButton("Extra", 204, Tabs.Extra)

local function createToggleButton(parent, textKey, pos, callback)
	local baseFrame = Instance.new("TextButton")
	baseFrame.Size = UDim2.new(0, 330, 0, 40) baseFrame.BackgroundColor3 = ThemeColors.ButtonDefault baseFrame.Text = "" baseFrame.Position = UDim2.new(0, 10, pos.Y.Scale, pos.Y.Offset) baseFrame.ZIndex = 8 baseFrame.Parent = parent
	Instance.new("UICorner", baseFrame).CornerRadius = UDim.new(0, 6)
	local fStroke = Instance.new("UIStroke") fStroke.Color = Color3.fromRGB(35, 48, 35) fStroke.Thickness = 1 fStroke.Parent = baseFrame

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -60, 1, 0) label.Position = UDim2.new(0, 12, 0, 0) label.BackgroundTransparency = 1 label.TextColor3 = ThemeColors.TextGreen label.Font = Enum.Font.GothamMedium label.TextSize = 12 label.TextXAlignment = Enum.TextXAlignment.Left label.ZIndex = 9 label.Parent = baseFrame

	local switchBg = Instance.new("Frame")
	switchBg.Size = UDim2.new(0, 36, 0, 20) switchBg.Position = UDim2.new(1, -48, 0.5, -10) switchBg.BackgroundColor3 = ThemeColors.ToggleBgOff switchBg.ZIndex = 9 switchBg.Parent = baseFrame
	Instance.new("UICorner", switchBg).CornerRadius = UDim.new(0, 10)

	local switchBall = Instance.new("Frame")
	switchBall.Size = UDim2.new(0, 14, 0, 14) switchBall.Position = UDim2.new(0, 3, 0.5, -7) switchBall.BackgroundColor3 = ThemeColors.ToggleBallOff switchBall.ZIndex = 10 switchBall.Parent = switchBg
	Instance.new("UICorner", switchBall).CornerRadius = UDim.new(0, 7)

	local state = false
	local function updateText()
		label.Text = _G.SaeLang == "AR" and textKey.AR or textKey.EN
	end
	
	baseFrame.MouseButton1Click:Connect(function()
		state = not state
		local targetPos = state and UDim2.new(0, 19, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
		TweenService:Create(switchBall, TweenInfo.new(0.15), {Position = targetPos, BackgroundColor3 = state and ThemeColors.ToggleBallOn or ThemeColors.ToggleBallOff}):Play()
		TweenService:Create(switchBg, TweenInfo.new(0.15), {BackgroundColor3 = state and ThemeColors.ToggleBgOn or ThemeColors.ToggleBgOff}):Play()
		fStroke.Color = state and ThemeColors.AccentGreen or Color3.fromRGB(35, 48, 35)
		callback(state)
	end)
	
	return baseFrame, updateText
end

local TargetInput = Instance.new("TextBox")
TargetInput.Size = UDim2.new(0, 330, 0, 40) TargetInput.Position = UDim2.new(0, 10, 0, 10) TargetInput.BackgroundColor3 = ThemeColors.ButtonDefault TargetInput.TextColor3 = ThemeColors.TextGreen TargetInput.Font = Enum.Font.GothamMedium TargetInput.TextSize = 12 TargetInput.ZIndex = 8 TargetInput.Parent = Tabs.Player
Instance.new("UICorner", TargetInput).CornerRadius = UDim.new(0, 6)
local TargetStroke = Instance.new("UIStroke") TargetStroke.Color = ThemeColors.AccentGreen TargetStroke.Parent = TargetInput

local KillMurdererBtn = Instance.new("TextButton")
KillMurdererBtn.Size = UDim2.new(0, 330, 0, 40) KillMurdererBtn.Position = UDim2.new(0, 10, 0, 60) KillMurdererBtn.BackgroundColor3 = ThemeColors.ButtonDefault KillMurdererBtn.TextColor3 = ThemeColors.TextGreen KillMurdererBtn.Font = Enum.Font.GothamMedium KillMurdererBtn.TextSize = 12 KillMurdererBtn.ZIndex = 8 KillMurdererBtn.Parent = Tabs.Player
Instance.new("UICorner", KillMurdererBtn).CornerRadius = UDim.new(0, 6)

local FlingBtn = Instance.new("TextButton")
FlingBtn.Size = UDim2.new(0, 330, 0, 40) FlingBtn.Position = UDim2.new(0, 10, 0, 110) FlingBtn.BackgroundColor3 = ThemeColors.ButtonDefault FlingBtn.TextColor3 = ThemeColors.TextGreen FlingBtn.Font = Enum.Font.GothamMedium FlingBtn.TextSize = 12 FlingBtn.ZIndex = 8 FlingBtn.Parent = Tabs.Player
Instance.new("UICorner", FlingBtn).CornerRadius = UDim.new(0, 6)

local SpeedLabel = Instance.new("TextLabel") SpeedLabel.Size = UDim2.new(0, 140, 0, 30) SpeedLabel.Position = UDim2.new(0, 10, 0, 75) SpeedLabel.BackgroundTransparency = 1 SpeedLabel.TextColor3 = ThemeColors.TextGreen SpeedLabel.Font = Enum.Font.GothamMedium SpeedLabel.TextSize = 12 SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left SpeedLabel.ZIndex = 8 SpeedLabel.Parent = Tabs.Farm
local SpeedInput = Instance.new("TextBox") SpeedInput.Size = UDim2.new(0, 60, 0, 30) SpeedInput.Position = UDim2.new(0, 160, 0, 75) SpeedInput.BackgroundColor3 = ThemeColors.ButtonDefault SpeedInput.Text = "16" SpeedInput.TextColor3 = ThemeColors.TextGreen SpeedInput.Font = Enum.Font.GothamMedium SpeedInput.TextSize = 12 SpeedInput.ZIndex = 8 SpeedInput.Parent = Tabs.Farm Instance.new("UICorner", SpeedInput).CornerRadius = UDim.new(0, 6)

SpeedInput.FocusLost:Connect(function()
	local val = tonumber(SpeedInput.Text)
	if val then
		if val > 110 then val = 110 SpeedInput.Text = "110" elseif val < 16 then val = 16 end
		local char = localPlayer.Character
		if char and char:FindFirstChild("Humanoid") then char.Humanoid.WalkSpeed = val end
	end
end)

local NoteLabel = Instance.new("TextLabel") NoteLabel.Size = UDim2.new(0, 320, 0, 40) NoteLabel.Position = UDim2.new(0, 10, 0, 115) NoteLabel.BackgroundTransparency = 1 NoteLabel.TextColor3 = Color3.fromRGB(255, 120, 120) NoteLabel.Font = Enum.Font.GothamMedium NoteLabel.TextSize = 11 NoteLabel.TextWrapped = true NoteLabel.TextXAlignment = Enum.TextXAlignment.Left NoteLabel.ZIndex = 8 NoteLabel.Parent = Tabs.Farm

local TpButton = Instance.new("TextButton") TpButton.Size = UDim2.new(0, 330, 0, 40) TpButton.Position = UDim2.new(0, 10, 0, 70) TpButton.BackgroundColor3 = ThemeColors.ButtonDefault TpButton.TextColor3 = ThemeColors.TextGreen TpButton.Font = Enum.Font.GothamMedium TpButton.TextSize = 12 TpButton.ZIndex = 8 TpButton.Parent = Tabs.Teleport Instance.new("UICorner", TpButton).CornerRadius = UDim.new(0, 6)
local TpToolBtn = Instance.new("TextButton") TpToolBtn.Size = UDim2.new(0, 330, 0, 40) TpToolBtn.Position = UDim2.new(0, 10, 0, 20) TpToolBtn.BackgroundColor3 = ThemeColors.ButtonDefault TpToolBtn.TextColor3 = ThemeColors.TextGreen TpToolBtn.Font = Enum.Font.GothamMedium TpToolBtn.TextSize = 12 TpToolBtn.ZIndex = 8 TpToolBtn.Parent = Tabs.Teleport Instance.new("UICorner", TpToolBtn).CornerRadius = UDim.new(0, 6)

TpToolBtn.MouseButton1Click:Connect(function()
	pcall(function()
		local tool = Instance.new("Tool")
		tool.Name = "Teleport Tool 🪄"
		tool.RequiresHandle = false
		tool.Parent = localPlayer.Backpack
		tool.Activated:Connect(function()
			local char = localPlayer.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			if hrp and Mouse.Target then
				hrp.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0, 3, 0))
			end
		end)
	end)
end)

-- Server Tab Buttons (Regoin Server & Hop Server)
local RegoinServerBtn = Instance.new("TextButton")
RegoinServerBtn.Size = UDim2.new(0, 330, 0, 45)
RegoinServerBtn.Position = UDim2.new(0, 10, 0, 20)
RegoinServerBtn.BackgroundColor3 = ThemeColors.ButtonDefault
RegoinServerBtn.TextColor3 = ThemeColors.TextGreen
RegoinServerBtn.Font = Enum.Font.GothamMedium
RegoinServerBtn.TextSize = 13
RegoinServerBtn.ZIndex = 8
RegoinServerBtn.Parent = Tabs.Server
Instance.new("UICorner", RegoinServerBtn).CornerRadius = UDim.new(0, 6)

local HopServerBtn = Instance.new("TextButton")
HopServerBtn.Size = UDim2.new(0, 330, 0, 45)
HopServerBtn.Position = UDim2.new(0, 10, 0, 75)
HopServerBtn.BackgroundColor3 = ThemeColors.ButtonDefault
HopServerBtn.TextColor3 = ThemeColors.TextGreen
HopServerBtn.Font = Enum.Font.GothamMedium
HopServerBtn.TextSize = 13
HopServerBtn.ZIndex = 8
HopServerBtn.Parent = Tabs.Server
Instance.new("UICorner", HopServerBtn).CornerRadius = UDim.new(0, 6)

RegoinServerBtn.MouseButton1Click:Connect(function()
	pcall(function()
		TeleportService:Teleport(game.PlaceId, localPlayer)
	end)
end)

HopServerBtn.MouseButton1Click:Connect(function()
	pcall(function()
		local servers = {}
		local req = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
		for _, s in pairs(req.data) do
			if type(s) == "table" and s.maxPlayers and s.playing and s.playing < s.maxPlayers and s.id ~= game.JobId then
				table.insert(servers, s.id)
			end
		end
		if #servers > 0 then
			TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], localPlayer)
		else
			TeleportService:Teleport(game.PlaceId, localPlayer)
		end
	end)
end)

local YarhmBtn = Instance.new("TextButton") YarhmBtn.Size = UDim2.new(0, 330, 0, 40) YarhmBtn.Position = UDim2.new(0, 10, 0, 20) YarhmBtn.BackgroundColor3 = ThemeColors.ButtonDefault YarhmBtn.TextColor3 = ThemeColors.TextGreen YarhmBtn.Font = Enum.Font.GothamMedium YarhmBtn.TextSize = 12 YarhmBtn.ZIndex = 8 YarhmBtn.Parent = Tabs.Other Instance.new("UICorner", YarhmBtn).CornerRadius = UDim.new(0, 6)

-- AimBot GUI
local AimGuiBtn = Instance.new("TextButton")
AimGuiBtn.Name = "SaeAimButton"
AimGuiBtn.Size = UDim2.new(0, 110, 0, 45)
AimGuiBtn.Position = UDim2.new(0.5, -120, 0.35, 0)
AimGuiBtn.BackgroundColor3 = ThemeColors.MainBg
AimGuiBtn.Text = "AimBot 🎯"
AimGuiBtn.TextColor3 = ThemeColors.TextDim
AimGuiBtn.Font = Enum.Font.GothamBold
AimGuiBtn.TextSize = 13
AimGuiBtn.Visible = false
AimGuiBtn.ZIndex = 15
AimGuiBtn.Parent = ScreenGui
Instance.new("UICorner", AimGuiBtn).CornerRadius = UDim.new(0, 8)
local AimIconStroke = Instance.new("UIStroke") AimIconStroke.Color = Color3.fromRGB(35, 48, 35) AimIconStroke.Thickness = 1.5 AimIconStroke.Parent = AimGuiBtn
makeDraggable(AimGuiBtn)

AimGuiBtn.MouseButton1Click:Connect(function()
	aimbotActive = not aimbotActive
	AimGuiBtn.TextColor3 = aimbotActive and ThemeColors.TextGreen or ThemeColors.TextDim
	AimIconStroke.Color = aimbotActive and ThemeColors.AccentGreen or Color3.fromRGB(35, 48, 35)
end)

-- Shoot GUI
local ShootGuiBtn = Instance.new("TextButton")
ShootGuiBtn.Name = "SaeShootButton"
ShootGuiBtn.Size = UDim2.new(0, 110, 0, 45)
ShootGuiBtn.Position = UDim2.new(0.5, 10, 0.35, 0)
ShootGuiBtn.BackgroundColor3 = ThemeColors.MainBg
ShootGuiBtn.Text = "Shoot 🔫"
ShootGuiBtn.TextColor3 = ThemeColors.TextDim
ShootGuiBtn.Font = Enum.Font.GothamBold
ShootGuiBtn.TextSize = 13
ShootGuiBtn.Visible = false
ShootGuiBtn.ZIndex = 15
ShootGuiBtn.Parent = ScreenGui
Instance.new("UICorner", ShootGuiBtn).CornerRadius = UDim.new(0, 8)
local ShootIconStroke = Instance.new("UIStroke") ShootIconStroke.Color = Color3.fromRGB(35, 48, 35) ShootIconStroke.Thickness = 1.5 ShootIconStroke.Parent = ShootGuiBtn
makeDraggable(ShootGuiBtn)

local function triggerMobileShot()
	pcall(function()
		local murdererChar, _ = getMurdererCharacter()
		local myChar = localPlayer.Character
		local gun = myChar and (myChar:FindFirstChild("Gun") or myChar:FindFirstChild("Revolver")) 
			or (localPlayer.Backpack and (localPlayer.Backpack:FindFirstChild("Gun") or localPlayer.Backpack:FindFirstChild("Revolver")))
		
		if murdererChar then
			local targetHrp = murdererChar:FindFirstChild("HumanoidRootPart") or murdererChar:FindFirstChild("Head")
			if targetHrp and gun then
				if gun.Parent == localPlayer.Backpack then
					gun.Parent = myChar
					task.wait(0.05)
				end
				gun:Activate()
				for _, remote in pairs(gun:GetDescendants()) do
					if remote:IsA("RemoteEvent") then
						remote:FireServer(targetHrp.Position)
					elseif remote:IsA("RemoteFunction") then
						pcall(function() remote:InvokeServer(targetHrp.Position) end)
					end
				end
				VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
				task.wait(0.05)
				VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
			end
		end
	end)
end

ShootGuiBtn.MouseButton1Click:Connect(triggerMobileShot)
ShootGuiBtn.TouchTap:Connect(triggerMobileShot)

RunService.RenderStepped:Connect(function()
	if aimbotActive then
		pcall(function()
			local murdererChar, _ = getMurdererCharacter()
			local myChar = localPlayer.Character
			if murdererChar and myChar then
				local mHrp = murdererChar:FindFirstChild("HumanoidRootPart") or murdererChar:FindFirstChild("Head")
				local myHrp = myChar:FindFirstChild("HumanoidRootPart") or myChar:FindFirstChild("Head")
				if mHrp and myHrp then
					Camera.CFrame = CFrame.new(Camera.CFrame.Position, (mHrp.Position + myHrp.Position) / 2)
				end
			end
		end)
	end
end)

local updateRegistry = {}
local keys = {
	Esp1 = {AR = "تشغيل Watermelon ESP 🍉", EN = "Run Watermelon ESP 🍉"},
	Esp2 = {AR = "كشف مكان المسدس الساقط 🎯", EN = "Show Dropped Gun Location 🎯"},
	Farm1 = {AR = "روبوت تجميع الكوينز (EasterFarm)", EN = "Auto Collect Coins (EasterFarm)"},
	KillAll = {AR = "تفعيل تصفية السيرفر (Kill All) ⚔️", EN = "Enable Server Kill All ⚔️"},
	AutoFetch = {AR = "جلب المسدس تلقائياً والعودة فوراً 🔫", EN = "Auto Fetch Gun & Return 🔫"},
	AimBotToggle = {AR = "إظهار/إخفاء زر AimBot في الشاشة 🎯", EN = "Show/Hide AimBot Screen Button 🎯"},
	ShootToggle = {AR = "إظهار زر إطلاق النار السريع 🔫", EN = "Show Fast Shoot Button 🔫"},
	Extra1 = {AR = "الهروب التلقائي الذكي", EN = "Smart Auto Evade"}
}

local function applyLanguage()
	if _G.SaeLang == "AR" then
		Title.Text = "Sae Hub V1 | النسخة الأساسية 🧪"
		TabButtons.ESP.Text = "👁️ ESP | كشف"
		TabButtons.Farm.Text = "💵 تجميع وسرعة"
		TabButtons.Auto.Text = "🤖 Auto | تلقائي"
		TabButtons.Player.Text = "👤 لاعبين | Player"
		TabButtons.Teleport.Text = "🌀 Teleport | انتقال"
		TabButtons.Server.Text = "🌐 سيرفر | Server"
		TabButtons.Other.Text = "📜 سكربتات أخرى"
		TabButtons.Extra.Text = "⚡ ميزات إضافية"
		TargetInput.PlaceholderText = "ضع اسم اللاعب هنا..."
		KillMurdererBtn.Text = "قتل الهدف (إذا كنت القاتل ومعي السكين) 🗡️"
		FlingBtn.Text = "دفـع/تطير اللاعب (Fling Target) 🌀"
		RegoinServerBtn.Text = "إعادة الدخول لنفس السيرفر (Regoin Server) 🔄"
		HopServerBtn.Text = "تغيير لسيرفر عشوائي (Hop Server) 🔀"
		YarhmBtn.Text = "تشغيل سكربت YARHM 🔫"
		SpeedLabel.Text = "سرعة الشخصية (أقصى 110):"
		NoteLabel.Text = "⚠️ ملاحظة: سرعة عالية جداً قد تعرضك للـ Kick!"
		TpButton.Text = "جلب المسدس الساقط 🔫 (يدوي)"
		TpToolBtn.Text = "تفعيل أداة التليبرت (Teleport Tool) 🪄"
	else
		Title.Text = "Sae Hub V1 | Base Edition 🧪"
		TabButtons.ESP.Text = "👁️ ESP | Detection"
		TabButtons.Farm.Text = "💵 Farm & Speed"
		TabButtons.Auto.Text = "🤖 Auto | Features"
		TabButtons.Player.Text = "👤 Player Control"
		TabButtons.Teleport.Text = "🌀 Teleportation"
		TabButtons.Server.Text = "🌐 Server Options"
		TabButtons.Other.Text = "📜 Other Scripts"
		TabButtons.Extra.Text = "⚡ Extra Features"
		TargetInput.PlaceholderText = "Enter player name here..."
		KillMurdererBtn.Text = "Kill Target (If I Am Murderer) 🗡️"
		FlingBtn.Text = "Fling Target Player 🌀"
		RegoinServerBtn.Text = "Rejoin Same Server (Regoin Server) 🔄"
		HopServerBtn.Text = "Hop Random Server (Hop Server) 🔀"
		YarhmBtn.Text = "Execute YARHM Script 🔫"
		SpeedLabel.Text = "WalkSpeed (Max 110):"
		NoteLabel.Text = "⚠️ Note: Excessive speed may cause a kick!"
		TpButton.Text = "Fetch Dropped Gun 🔫 (Manual)"
		TpToolBtn.Text = "Enable Teleport Tool 🪄"
	end
	TabButtons.ESP.TextColor3 = ThemeColors.TextGreen
	for _, updateFunc in pairs(updateRegistry) do updateFunc() end
end

KillMurdererBtn.MouseButton1Click:Connect(function()
	local target = getTargetPlayer(TargetInput.Text)
	if not target or not target.Character then return end
	local tHrp = target.Character:FindFirstChild("HumanoidRootPart")
	local char = localPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if hrp and tHrp then
		local knife = char:FindFirstChild("Knife") or char:FindFirstChild("RealKnife") or (localPlayer.Backpack and localPlayer.Backpack:FindFirstChild("Knife"))
		if knife then knife.Parent = char end
		hrp.CFrame = tHrp.CFrame * CFrame.new(0, 0, 1.5)
		task.wait(0.1)
		local activeKnife = char:FindFirstChild("Knife") or char:FindFirstChild("RealKnife")
		if activeKnife then pcall(function() activeKnife:Activate() end) end
	end
end)

FlingBtn.MouseButton1Click:Connect(function()
	local target = getTargetPlayer(TargetInput.Text)
	if not target or not target.Character then return end
	local tHrp = target.Character:FindFirstChild("HumanoidRootPart")
	local char = localPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if hrp and tHrp then
		local bav = Instance.new("BodyAngularVelocity")
		bav.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
		bav.AngularVelocity = Vector3.new(0, 99999, 0)
		bav.Parent = hrp
		task.spawn(function()
			for i = 1, 30 do
				if not hrp or not tHrp then break end
				hrp.CFrame = tHrp.CFrame * CFrame.new(0, 0, 0)
				task.wait(0.05)
			end
			bav:Destroy()
		end)
	end
end)

YarhmBtn.MouseButton1Click:Connect(function()
	pcall(function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/EverydayxD/Roblox-Scripts/main/YARHM.lua"))()
	end)
end)

local _, up1 = createToggleButton(Tabs.ESP, keys.Esp1, UDim2.new(0, 10, 0, 10), function(state)
	if state then pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/Ihaveash0rtnamefordiscord/Releases/main/MurderMystery2HighlightESP"))(' Watermelon ?') end) end
end) table.insert(updateRegistry, up1)

local _, up2 = createToggleButton(Tabs.ESP, keys.Esp2, UDim2.new(0, 10, 0, 60), function(state)
	gunEspActive = state
	if state then
		local gunLoop
		gunLoop = RunService.Heartbeat:Connect(function()
			if not gunEspActive then gunLoop:Disconnect() return end
			local droppedGun = findDroppedGun()
			if droppedGun and not droppedGun:FindFirstChild("GunHighlight") then
				local highlight = Instance.new("Highlight")
				highlight.Name = "GunHighlight"
				highlight.FillColor = ThemeColors.AccentGreen
				highlight.FillTransparency = 0.3
				highlight.Adornee = droppedGun
				highlight.Parent = droppedGun
			end
		end)
		table.insert(gunEspConnections, gunLoop)
	else
		for _, c in pairs(gunEspConnections) do c:Disconnect() end gunEspConnections = {}
	end
end) table.insert(updateRegistry, up2)

local _, up3 = createToggleButton(Tabs.Farm, keys.Farm1, UDim2.new(0, 10, 0, 20), function(state)
	if state then pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/moonlastfr/MM2/refs/heads/main/EasterFarm"))() end) end
end) table.insert(updateRegistry, up3)

local _, up4 = createToggleButton(Tabs.Auto, keys.KillAll, UDim2.new(0, 10, 0, 20), function(state)
	killAllActive = state
	if state then
		task.spawn(function()
			while killAllActive do
				task.wait(0.1)
				local char = localPlayer.Character
				local knife = char and (char:FindFirstChild("Knife") or char:FindFirstChild("RealKnife"))
				local hrp = char and char:FindFirstChild("HumanoidRootPart")
				if knife and hrp then
					for _, targetPlayer in pairs(Players:GetPlayers()) do
						if targetPlayer ~= localPlayer and killAllActive then
							local tChar = targetPlayer.Character
							local tHrp = tChar and tChar:FindFirstChild("HumanoidRootPart")
							if tHrp and tChar:FindFirstChild("Humanoid") and tChar.Humanoid.Health > 0 then
								hrp.CFrame = tHrp.CFrame * CFrame.new(0, 0, 1.5)
								task.wait(0.15)
								pcall(function() knife:Activate() end)
							end
						end
					end
				end
			end
		end)
	end
end) table.insert(updateRegistry, up4)

local _, upAutoGun = createToggleButton(Tabs.Auto, keys.AutoFetch, UDim2.new(0, 10, 0, 70), function(state)
	autoFetchGunActive = state
	if state then
		task.spawn(function()
			while autoFetchGunActive do
				task.wait(0.5)
				local char = localPlayer.Character
				local hrp = char and char:FindFirstChild("HumanoidRootPart")
				if hrp then
					local droppedGun = findDroppedGun()
					if droppedGun then
						local originalPosition = hrp.CFrame
						hrp.CFrame = droppedGun.CFrame
						task.wait(0.25)
						hrp.CFrame = originalPosition
						repeat task.wait(1) until not findDroppedGun() or not autoFetchGunActive
					end
				end
			end
		end)
	end
end) table.insert(updateRegistry, upAutoGun)

local _, upAimToggle = createToggleButton(Tabs.Auto, keys.AimBotToggle, UDim2.new(0, 10, 0, 120), function(state)
	AimGuiBtn.Visible = state
	if not state then aimbotActive = false AimGuiBtn.TextColor3 = ThemeColors.TextDim AimIconStroke.Color = Color3.fromRGB(35, 48, 35) end
end) table.insert(updateRegistry, upAimToggle)

local _, upShootToggle = createToggleButton(Tabs.Auto, keys.ShootToggle, UDim2.new(0, 10, 0, 170), function(state)
	ShootGuiBtn.Visible = state
	if not state then ShootGuiBtn.TextColor3 = ThemeColors.TextDim ShootIconStroke.Color = Color3.fromRGB(35, 48, 35) end
end) table.insert(updateRegistry, upShootToggle)

TpButton.MouseButton1Click:Connect(function()
	local char = localPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	local droppedGun = findDroppedGun()
	if droppedGun then
		local originalPosition = hrp.CFrame
		hrp.CFrame = droppedGun.CFrame
		task.wait(0.2)
		hrp.CFrame = originalPosition
	end
end)

local _, up5 = createToggleButton(Tabs.Extra, keys.Extra1, UDim2.new(0, 10, 0, 20), function(state)
	evadeActive = state
	if state then
		local conn
		conn = RunService.Heartbeat:Connect(function()
			if not evadeActive then conn:Disconnect() return end
			local hrp = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
			if hrp then
				for _, p in pairs(Players:GetPlayers()) do
					if p ~= localPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
						if p.Character:FindFirstChild("Knife") or p.Character:FindFirstChild("RealKnife") then
							if (hrp.Position - p.Character.HumanoidRootPart.Position).Magnitude < 15 then hrp.CFrame = hrp.CFrame * CFrame.new(0, 50, 0) end
						end
					end
				end
			end
		end)
	end
end) table.insert(updateRegistry, up5)

ArBtn.MouseButton1Click:Connect(function() _G.SaeLang = "AR" LangFrame:Destroy() applyLanguage() ToggleIcon.Visible = true end)
EnBtn.MouseButton1Click:Connect(function() _G.SaeLang = "EN" LangFrame:Destroy() applyLanguage() ToggleIcon.Visible = true end)
