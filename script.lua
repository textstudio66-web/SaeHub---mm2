-- الأجهزة والخدمات الأساسية
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local localPlayer = Players.LocalPlayer
local farmActive = false
local evadeActive = false
local gunEspActive = false
local killAllActive = false

local gunEspConnections = {}

-- وظيفة للبحث عن المسدس الساقط
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

-- وظيفة لجعل أي عنصر واجهة قابل للسحب يدوياً
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

-- ==========================================
-- 🎨 إنشاء واجهة المستخدم (ScreenGui) - ثيم مقتبس من الصور
-- ==========================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SaeHub_MM2_BetaV1"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = localPlayer:WaitForChild("PlayerGui") end

-- الألوان الموحدة للثيم
local ThemeColors = {
	MainBg = Color3.fromRGB(18, 18, 22),
	SidebarBg = Color3.fromRGB(12, 12, 14),
	AccentPurple = Color3.fromRGB(130, 50, 250),
	ButtonDefault = Color3.fromRGB(24, 24, 26),
	ToggleBgOff = Color3.fromRGB(35, 35, 40),
	ToggleBgOn = Color3.fromRGB(60, 30, 110),
	ToggleBallOff = Color3.fromRGB(100, 100, 105),
	ToggleBallOn = Color3.fromRGB(150, 80, 255),
	TextWhite = Color3.fromRGB(245, 245, 245),
	TextDim = Color3.fromRGB(160, 160, 170)
}

-- ==========================================
-- 🌐 نافذة اختيار اللغة (Language Selection)
-- ==========================================

local LangFrame = Instance.new("Frame")
LangFrame.Size = UDim2.new(0, 320, 0, 160)
LangFrame.Position = UDim2.new(0.5, -160, 0.5, -80)
LangFrame.BackgroundColor3 = ThemeColors.MainBg
LangFrame.ZIndex = 20
LangFrame.Parent = ScreenGui
Instance.new("UICorner", LangFrame).CornerRadius = UDim.new(0, 10)
local LangStroke = Instance.new("UIStroke") LangStroke.Color = ThemeColors.AccentPurple LangStroke.Thickness = 2 LangStroke.Parent = LangFrame

local LangTitle = Instance.new("TextLabel")
LangTitle.Size = UDim2.new(1, 0, 0, 40) LangTitle.BackgroundTransparency = 1 LangTitle.Text = "Choose Language | اختر اللغة" LangTitle.TextColor3 = ThemeColors.TextWhite LangTitle.Font = Enum.Font.GothamBold LangTitle.TextSize = 16 LangTitle.ZIndex = 20 LangTitle.Parent = LangFrame

local ArBtn = Instance.new("TextButton")
ArBtn.Size = UDim2.new(0, 130, 0, 45) ArBtn.Position = UDim2.new(0, 20, 0, 70) ArBtn.BackgroundColor3 = ThemeColors.ButtonDefault ArBtn.Text = "العربية 🇸🇦" ArBtn.TextColor3 = ThemeColors.TextWhite ArBtn.Font = Enum.Font.GothamBold ArBtn.TextSize = 15 ArBtn.ZIndex = 20 ArBtn.Parent = LangFrame
Instance.new("UICorner", ArBtn).CornerRadius = UDim.new(0, 8)
local ArStroke = Instance.new("UIStroke") ArStroke.Color = ThemeColors.AccentPurple ArStroke.Thickness = 1 ArStroke.Parent = ArBtn

local EnBtn = Instance.new("TextButton")
EnBtn.Size = UDim2.new(0, 130, 0, 45) EnBtn.Position = UDim2.new(1, -150, 0, 70) EnBtn.BackgroundColor3 = ThemeColors.ButtonDefault EnBtn.Text = "English 🇺🇸" EnBtn.TextColor3 = ThemeColors.TextWhite EnBtn.Font = Enum.Font.GothamBold EnBtn.TextSize = 15 EnBtn.ZIndex = 20 EnBtn.Parent = LangFrame
Instance.new("UICorner", EnBtn).CornerRadius = UDim.new(0, 8)
local EnStroke = Instance.new("UIStroke") EnStroke.Color = ThemeColors.AccentPurple EnStroke.Thickness = 1 EnStroke.Parent = EnBtn

-- ==========================================
-- 🎨 القائمة الرئيسية وأيقونة التصغير
-- ==========================================

local ToggleIcon = Instance.new("TextButton")
ToggleIcon.Name = "SaeToggleIcon"
ToggleIcon.Size = UDim2.new(0, 65, 0, 65)
ToggleIcon.Position = UDim2.new(0.02, 0, 0.2, 0)
ToggleIcon.BackgroundColor3 = ThemeColors.MainBg
ToggleIcon.Text = "Sae"
ToggleIcon.TextColor3 = ThemeColors.TextWhite
ToggleIcon.Font = Enum.Font.GothamBlack
ToggleIcon.TextSize = 22
ToggleIcon.Visible = false -- تختفي تماماً في البداية حتى لا تظهر مع واجهة اللغة
ToggleIcon.Parent = ScreenGui
Instance.new("UICorner", ToggleIcon).CornerRadius = UDim.new(0, 32.5)
local IconStroke = Instance.new("UIStroke") IconStroke.Color = ThemeColors.AccentPurple IconStroke.Thickness = 2.5 IconStroke.Parent = ToggleIcon

makeDraggable(ToggleIcon)

-- استخدام CanvasGroup للحصول على أنميشن ظهور واختفاء واقعي
local MainFrame = Instance.new("CanvasGroup")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 480, 0, 320)
MainFrame.Position = UDim2.new(0.5, -240, 0.5, -160)
MainFrame.BackgroundColor3 = ThemeColors.MainBg
MainFrame.BorderSizePixel = 0
MainFrame.GroupTransparency = 1 
MainFrame.Visible = false -- (حل مشكلة الظهور خلف نافذة اللغة): تبدأ القائمة مخفية بالكامل كعنصر
local menuVisible = false
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner") MainCorner.CornerRadius = UDim.new(0, 12) MainCorner.Parent = MainFrame
local MainStroke = Instance.new("UIStroke") MainStroke.Color = ThemeColors.AccentPurple MainStroke.Thickness = 2 MainStroke.Parent = MainFrame

makeDraggable(MainFrame, MainFrame)

-- 🔄 أنميشن الفتح والإغلاق التدريجي الواقعي (حل مشكلة بقاء الأزرار والخانات)
ToggleIcon.MouseButton1Click:Connect(function()
	menuVisible = not menuVisible
	if menuVisible then
		MainFrame.Visible = true -- اجعلها مرئية أولاً لبدء الفتح
		local tween = TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {GroupTransparency = 0})
		tween:Play()
	else
		local tween = TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {GroupTransparency = 1})
		tween:Play()
		-- إخفاء كامل العنصر فور انتهاء أنميشن التلاشي حتى لا يتبقى أي زر أو إطار فرعي ظاهراً
		tween.Completed:Connect(function()
			if not menuVisible then
				MainFrame.Visible = false
			end
		end)
	end
end)

local Title = Instance.new("TextLabel") Title.Size = UDim2.new(1, 0, 0, 40) Title.BackgroundColor3 = ThemeColors.SidebarBg Title.TextColor3 = ThemeColors.TextWhite Title.Font = Enum.Font.GothamBold Title.TextSize = 16 Title.TextXAlignment = Enum.TextXAlignment.Left Title.Position = UDim2.new(0, 15, 0, 0) Title.BackgroundTransparency = 1 Title.Parent = MainFrame 
local Sidebar = Instance.new("Frame") Sidebar.Size = UDim2.new(0, 130, 1, -40) Sidebar.Position = UDim2.new(0, 0, 0, 40) Sidebar.BackgroundColor3 = ThemeColors.SidebarBg Sidebar.BorderSizePixel = 0 Sidebar.Parent = MainFrame
local Container = Instance.new("Frame") Container.Size = UDim2.new(1, -140, 1, -50) Container.Position = UDim2.new(0, 135, 0, 45) Container.BackgroundTransparency = 1 Container.Parent = MainFrame

local Tabs = { ESP = Instance.new("Frame"), Farm = Instance.new("Frame"), Auto = Instance.new("Frame"), Teleport = Instance.new("Frame"), Extra = Instance.new("Frame") }
for name, frame in pairs(Tabs) do frame.Size = UDim2.new(1, 0, 1, 0) frame.BackgroundTransparency = 1 frame.Visible = false frame.Parent = Container end
Tabs.ESP.Visible = true

local TabButtons = {}
local function createTabButton(name, textKey, pos, targetFrame)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 120, 0, 32) btn.BackgroundTransparency = 1 btn.TextColor3 = ThemeColors.TextDim btn.Font = Enum.Font.GothamBold btn.TextSize = 13 btn.BorderSizePixel = 0 btn.TextXAlignment = Enum.TextXAlignment.Left btn.Position = UDim2.new(0, 12, 0, pos) btn.Parent = Sidebar
	
	btn.MouseButton1Click:Connect(function() 
		for _, frame in pairs(Tabs) do frame.Visible = false end 
		for _, tBtn in pairs(TabButtons) do tBtn.TextColor3 = ThemeColors.TextDim end
		targetFrame.Visible = true 
		btn.TextColor3 = ThemeColors.AccentPurple
	end)
	TabButtons[name] = btn
end

createTabButton("ESP", "", 10, Tabs.ESP)
createTabButton("Farm", "", 45, Tabs.Farm)
createTabButton("Auto", "", 80, Tabs.Auto)
createTabButton("Teleport", "", 115, Tabs.Teleport)
createTabButton("Extra", "", 150, Tabs.Extra)

-- نظام مفاتيح التوجل المنزلقة سريعة الاستجابة
local function createToggleButton(parent, textKey, pos, callback)
	local baseFrame = Instance.new("TextButton")
	baseFrame.Size = UDim2.new(0, 315, 0, 42) baseFrame.BackgroundColor3 = ThemeColors.ButtonDefault baseFrame.Text = "" baseFrame.Position = UDim2.new(0, 10, pos.Y.Scale, pos.Y.Offset) baseFrame.Parent = parent
	Instance.new("UICorner", baseFrame).CornerRadius = UDim.new(0, 6)
	local fStroke = Instance.new("UIStroke") fStroke.Color = Color3.fromRGB(40, 40, 45) fStroke.Thickness = 1 fStroke.Parent = baseFrame

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -60, 1, 0) label.Position = UDim2.new(0, 12, 0, 0) label.BackgroundTransparency = 1 label.TextColor3 = ThemeColors.TextWhite label.Font = Enum.Font.GothamBold label.TextSize = 13 label.TextXAlignment = Enum.TextXAlignment.Left label.Parent = baseFrame

	local switchBg = Instance.new("Frame")
	switchBg.Size = UDim2.new(0, 36, 0, 20) switchBg.Position = UDim2.new(1, -48, 0.5, -10) switchBg.BackgroundColor3 = ThemeColors.ToggleBgOff switchBg.Parent = baseFrame
	Instance.new("UICorner", switchBg).CornerRadius = UDim.new(0, 10)

	local switchBall = Instance.new("Frame")
	switchBall.Size = UDim2.new(0, 14, 0, 14) switchBall.Position = UDim2.new(0, 3, 0.5, -7) switchBall.BackgroundColor3 = ThemeColors.ToggleBallOff switchBall.Parent = switchBg
	Instance.new("UICorner", switchBall).CornerRadius = UDim.new(0, 7)

	local state = false
	
	local function updateText()
		local activeText = _G.SaeLang == "AR" and textKey.AR or textKey.EN
		label.Text = activeText
	end
	
	baseFrame.MouseButton1Click:Connect(function()
		state = not state
		local targetPos = state and UDim2.new(0, 19, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
		local targetBgColor = state and ThemeColors.ToggleBgOn or ThemeColors.ToggleBgOff
		local targetBallColor = state and ThemeColors.ToggleBallOn or ThemeColors.ToggleBallOff
		
		TweenService:Create(switchBall, TweenInfo.new(0.2), {Position = targetPos, BackgroundColor3 = targetBallColor}):Play()
		TweenService:Create(switchBg, TweenInfo.new(0.2), {BackgroundColor3 = targetBgColor}):Play()
		fStroke.Color = state and ThemeColors.AccentPurple or Color3.fromRGB(40, 40, 45)
		
		callback(state)
	end)
	
	return baseFrame, updateText
end

local SpeedLabel = Instance.new("TextLabel") SpeedLabel.Size = UDim2.new(0, 140, 0, 30) SpeedLabel.Position = UDim2.new(0, 10, 0, 75) SpeedLabel.BackgroundTransparency = 1 SpeedLabel.TextColor3 = ThemeColors.TextWhite SpeedLabel.Font = Enum.Font.GothamBold SpeedLabel.TextSize = 13 SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left SpeedLabel.Parent = Tabs.Farm
local SpeedInput = Instance.new("TextBox") SpeedInput.Size = UDim2.new(0, 60, 0, 30) SpeedInput.Position = UDim2.new(0, 160, 0, 75) SpeedInput.BackgroundColor3 = ThemeColors.ButtonDefault SpeedInput.Text = "20" SpeedInput.TextColor3 = ThemeColors.AccentPurple SpeedInput.Font = Enum.Font.GothamBold SpeedInput.TextSize = 14 SpeedInput.Parent = Tabs.Farm Instance.new("UICorner", SpeedInput).CornerRadius = UDim.new(0, 6) local SpStroke = Instance.new("UIStroke") SpStroke.Color = Color3.fromRGB(50, 50, 55) SpStroke.Parent = SpeedInput

local NoteLabel = Instance.new("TextLabel") NoteLabel.Size = UDim2.new(0, 300, 0, 40) NoteLabel.Position = UDim2.new(0, 10, 0, 120) NoteLabel.BackgroundTransparency = 1 NoteLabel.TextColor3 = Color3.fromRGB(200, 170, 255) NoteLabel.Font = Enum.Font.GothamBold NoteLabel.TextSize = 11 NoteLabel.TextWrapped = true NoteLabel.TextXAlignment = Enum.TextXAlignment.Left NoteLabel.Parent = Tabs.Farm
local TpButton = Instance.new("TextButton") TpButton.Size = UDim2.new(0, 315, 0, 42) TpButton.Position = UDim2.new(0, 10, 0, 20) TpButton.BackgroundColor3 = ThemeColors.ButtonDefault TpButton.TextColor3 = ThemeColors.TextWhite TpButton.Font = Enum.Font.GothamBold TpButton.TextSize = 13 TpButton.Parent = Tabs.Teleport Instance.new("UICorner", TpButton).CornerRadius = UDim.new(0, 6) local TpStroke = Instance.new("UIStroke") TpStroke.Color = ThemeColors.AccentPurple TpStroke.Parent = TpButton

SpeedInput.FocusLost:Connect(function()
	local num = tonumber(SpeedInput.Text)
	if num then farmSpeed = num else SpeedInput.Text = tostring(farmSpeed) end
end)

-- ==========================================
-- 🌐 نظام إدارة اللغات والترجمة
-- ==========================================

local updateRegistry = {}

local keys = {
	Esp1 = {AR = "تشغيل Watermelon ESP 🍉", EN = "Run Watermelon ESP 🍉"},
	Esp2 = {AR = "كشف مكان المسدس الساقط 🎯 (Gun ESP)", EN = "Show Dropped Gun Location 🎯"},
	Farm1 = {AR = "روبوت تجميع الكوينز التلقائي (EasterFarm)", EN = "Auto Collect Coins Robot (EasterFarm)"},
	KillAll = {AR = "تفعيل طحن وتصفية السيرفر (Kill All) ⚔️", EN = "Enable Server Kill All ⚔️"},
	Extra1 = {AR = "الهروب التلقائي الذكي", EN = "Smart Auto Evade"}
}

local function applyLanguage()
	if _G.SaeLang == "AR" then
		Title.Text = "Sae Hub | النسخة التجريبية Beta V1 🧪"
		TabButtons.ESP.Text = "👁️ ESP | كشف"
		TabButtons.Farm.Text = "💵 تجميع كوينز"
		TabButtons.Auto.Text = "🤖 Auto | تلقائي"
		TabButtons.Teleport.Text = "🌀 Teleport | انتقال"
		TabButtons.Extra.Text = "⚡ ميزات إضافية"
		SpeedLabel.Text = "سرعة الفارم الحالية:"
		NoteLabel.Text = "⚠️ ملاحظة: أهم شيء ما تكون السرعة مرة عالية عشان لا تنطرد"
		TpButton.Text = "جلب المسدس الساقط 🔫 (ثم العودة)"
	else
		Title.Text = "Sae Hub | Beta Edition V1 🧪"
		TabButtons.ESP.Text = "👁️ ESP | Detection"
		TabButtons.Farm.Text = "💵 Coin Farm"
		TabButtons.Auto.Text = "🤖 Auto | Features"
		TabButtons.Teleport.Text = "🌀 Teleportation"
		TabButtons.Extra.Text = "⚡ Extra Features"
		SpeedLabel.Text = "Current Farm Speed:"
		NoteLabel.Text = "⚠️ Note: Avoid setting the speed too high to prevent being kicked."
		TpButton.Text = "Fetch Dropped Gun 🔫 (Return Instantly)"
	end
	TabButtons.ESP.TextColor3 = ThemeColors.AccentPurple
	for _, updateFunc in pairs(updateRegistry) do updateFunc() end
end

-- ربط الميزات بالأزرار
local btn, up1 = createToggleButton(Tabs.ESP, keys.Esp1, UDim2.new(0, 10, 0, 10), function(state)
	if state then pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/Ihaveash0rtnamefordiscord/Releases/main/MurderMystery2HighlightESP"))(' Watermelon ?') end) end
end) table.insert(updateRegistry, up1)

local btn, up2 = createToggleButton(Tabs.ESP, keys.Esp2, UDim2.new(0, 10, 0, 60), function(state)
	gunEspActive = state
	if state then
		local gunLoop
		gunLoop = RunService.Heartbeat:Connect(function()
			if not gunEspActive then gunLoop:Disconnect() return end
			local droppedGun = findDroppedGun()
			if droppedGun and not droppedGun:FindFirstChild("GunHighlight") then
				local highlight = Instance.new("Highlight")
				highlight.Name = "GunHighlight"
				highlight.FillColor = ThemeColors.AccentPurple
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

local btn, up3 = createToggleButton(Tabs.Farm, keys.Farm1, UDim2.new(0, 10, 0, 20), function(state)
	farmActive = state
	if state then 
		pcall(function()
			loadstring(game:HttpGet("https://raw.githubusercontent.com/moonlastfr/MM2/refs/heads/main/EasterFarm"))()
		end)
	end
end) table.insert(updateRegistry, up3)

local btn, up4 = createToggleButton(Tabs.Auto, keys.KillAll, UDim2.new(0, 10, 0, 20), function(state)
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

local btn, up5 = createToggleButton(Tabs.Extra, keys.Extra1, UDim2.new(0, 10, 0, 20), function(state)
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

-- ⚡ تشغيل واجهة السكربت بنظافة تامة بعد اختيار اللغة
local function finalizeSetup()
	LangFrame:Destroy()
	applyLanguage()
	
	-- إظهار زر التفعيل والـ MainFrame وبدء الأنميشن بشكل نظيف جداً
	ToggleIcon.Visible = true
	MainFrame.Visible = true
	menuVisible = true
	TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {GroupTransparency = 0}):Play()
end

ArBtn.MouseButton1Click:Connect(function()
	_G.SaeLang = "AR"
	pcall(function() setclipboard("https://www.youtube.com/@Itushi_sae") end)
	finalizeSetup()
end)

EnBtn.MouseButton1Click:Connect(function()
	_G.SaeLang = "EN"
	pcall(function() setclipboard("https://www.youtube.com/@Itushi_sae") end)
	finalizeSetup()
end)
