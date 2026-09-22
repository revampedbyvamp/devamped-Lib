-- DevampedLib Library module
-- API:
--   local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/revampedbyvamp/devamped-Lib/main/Dist/DevampedLib.lua"))()
--   local Window = Library:CreateWindow({ Title = "My Hub", Theme = "Dark" })
--   local Tab = Window:CreateTab({ Name = "Main" })
--   Tab:CreateButton({ Name = "Click Me", Callback = function() end })

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local Theme = require(script.Parent.Theme)
local Animation = require(script.Parent.Animation)
local Components = require(script.Parent.Components)

local Library = {
	Theme = Theme,
	Animation = Animation,
	Components = Components,
	Windows = {},
	Flags = {},
}

local function create(className, properties, parent)
	local inst = Instance.new(className)
	for key, value in pairs(properties or {}) do
		pcall(function() inst[key] = value end)
	end
	inst.Parent = parent
	return inst
end

local function corner(parent, radius)
	return create("UICorner", { CornerRadius = radius }, parent)
end

local function stroke(parent, color, transparency)
	return create("UIStroke", { Color = color, Transparency = transparency or 0, Thickness = 1 }, parent)
end

local function text(parent, value, properties, theme)
	properties = properties or {}
	return create("TextLabel", {
		BackgroundTransparency = 1,
		Text = value or "",
		TextColor3 = properties.Color or theme.Text,
		TextSize = properties.Size or 12,
		Font = properties.Font or theme.Font,
		TextXAlignment = properties.XAlignment or Enum.TextXAlignment.Left,
		TextYAlignment = properties.YAlignment or Enum.TextYAlignment.Center,
		TextWrapped = properties.Wrapped or false,
		Size = properties.Size2 or UDim2.new(1, 0, 0, properties.Height or 18),
		Position = properties.Position or UDim2.new(),
		LayoutOrder = properties.LayoutOrder or 0,
	}, parent)
end

-- Simple config store: writefile/readfile on executors, memory fallback in Studio.
local ConfigStore = { _memory = {}, _flags = {} }
function ConfigStore:_registerFlag(flag, api)
	if flag then
		self._flags[flag] = api
	end
end
function ConfigStore:_onFlag(flag, value)
	if flag then
		Library.Flags[flag] = value
		if self._auto and self._autoName then
			task.defer(function() self:Save(self._autoName) end)
		end
	end
end
function ConfigStore:Save(name)
	name = name or "default"
	local data = {}
	for flag, api in pairs(self._flags) do
		local ok, v = pcall(function() return api:Get() end)
		if ok then
			if typeof(v) == "Color3" then
				data[flag] = { __type = "Color3", r = v.R, g = v.G, b = v.B }
			elseif typeof(v) == "EnumItem" then
				data[flag] = { __type = "KeyCode", name = v.Name }
			else
				data[flag] = v
			end
		end
	end
	local json = HttpService:JSONEncode(data)
	self._memory[name] = json
	pcall(function()
		if writefile then
			writefile("DevampedLib_" .. tostring(name) .. ".json", json)
		end
	end)
	return json
end
function ConfigStore:Load(name)
	name = name or "default"
	local json = self._memory[name]
	pcall(function()
		if readfile and isfile and isfile("DevampedLib_" .. tostring(name) .. ".json") then
			json = readfile("DevampedLib_" .. tostring(name) .. ".json")
		end
	end)
	if not json then
		return false
	end
	local ok, data = pcall(function() return HttpService:JSONDecode(json) end)
	if not ok or type(data) ~= "table" then
		return false
	end
	for flag, v in pairs(data) do
		local api = self._flags[flag]
		if api then
			if type(v) == "table" and v.__type == "Color3" then
				pcall(function() api:Set(Color3.new(v.r, v.g, v.b)) end)
			elseif type(v) == "table" and v.__type == "KeyCode" then
				pcall(function() api:Set(Enum.KeyCode[v.name]) end)
			else
				pcall(function() api:Set(v) end)
			end
			Library.Flags[flag] = v
		end
	end
	return true
end

function Library:CreateWindow(options)
	options = options or {}
	local theme = Theme.Create(options.Theme or options.ThemeName or "Light")
	local title = options.Title or options.Name or "DevampedLib"
	local toggleKey = options.ToggleKey or options.Toggle or Enum.KeyCode.RightShift

	local player = Players.LocalPlayer
	local playerGui = player and player:WaitForChild("PlayerGui")
	local screenGui = create("ScreenGui", {
		Name = title,
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		IgnoreGuiInset = true,
	}, playerGui)
	if gethui then
		pcall(function() screenGui.Parent = gethui() end)
	end

	local root = create("Frame", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1) }, screenGui)
	local scale = create("UIScale", { Scale = 1 }, root)

	local shadow = create("ImageLabel", {
		BackgroundTransparency = 1,
		Image = "rbxassetid://6014261993",
		ImageColor3 = theme.Shadow,
		ImageTransparency = 0.84,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(49, 49, 450, 450),
		Size = UDim2.fromScale(0.66, 0.78),
		Position = UDim2.fromScale(0.17, 0.12),
	}, root)

	local windowSize = options.Size or UDim2.fromScale(0.64, 0.72)
	local windowPos = options.Position or UDim2.fromScale(0.18, 0.14)
	local window = create("Frame", {
		BackgroundColor3 = theme.Background,
		ClipsDescendants = true,
		Size = windowSize,
		Position = windowPos,
		Active = true,
	}, root)
	corner(window, UDim.new(0, 15))
	stroke(window, theme.Border, 0.2)

	-- Topbar
	local topbar = create("Frame", { BackgroundColor3 = theme.Surface, Size = UDim2.new(1, 0, 0, 50), BorderSizePixel = 0 }, window)
	local titleLabel = text(topbar, (options.Logo or "➤") .. "  " .. title, {
		Color = theme.Text, Font = theme.FontBold, Size = 14,
		Position = UDim2.fromOffset(15, 0), Height = 50, Size2 = UDim2.new(0.5, -20, 0, 50),
	}, theme)

	local searchBox = create("TextBox", {
		BackgroundColor3 = theme.SurfaceMuted,
		Text = "",
		PlaceholderText = "Search...",
		PlaceholderColor3 = theme.TextFaint,
		TextColor3 = theme.Text,
		TextSize = 11,
		Font = theme.Font,
		ClearTextOnFocus = false,
		Size = UDim2.fromOffset(150, 30),
		Position = UDim2.new(0.5, -75, 0, 10),
	}, topbar)
	corner(searchBox, UDim.new(1, 0))
	create("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12) }, searchBox)

	local utility = create("Frame", { BackgroundTransparency = 1, Size = UDim2.fromOffset(110, 35), Position = UDim2.new(1, -120, 0, 7) }, topbar)
	create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Right, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 3) }, utility)
	local function iconBtn(glyph)
		local b = create("TextButton", {
			AutoButtonColor = false, BackgroundTransparency = 1,
			Text = glyph, TextColor3 = theme.TextMuted, TextSize = 16,
			Font = theme.Font, Size = UDim2.fromOffset(30, 30),
		}, utility)
		return b
	end
	local minimizeBtn = iconBtn("–")
	local closeBtn = iconBtn("✕")

	-- Body / tabs / pages
	local body = create("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, -50), Position = UDim2.fromOffset(0, 50) }, window)
	local tabStrip = create("ScrollingFrame", {
		BackgroundTransparency = 1, BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 40),
		CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.X,
		ScrollingDirection = Enum.ScrollingDirection.X, ScrollBarThickness = 0,
	}, body)
	create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Center, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 4) }, tabStrip)
	create("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) }, tabStrip)
	local pages = create("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, -40), Position = UDim2.fromOffset(0, 40) }, body)

	-- Resize grip
	local grip = create("TextButton", {
		AutoButtonColor = false, BackgroundTransparency = 1,
		Text = "◢", TextColor3 = theme.TextFaint, TextSize = 14,
		AnchorPoint = Vector2.new(1, 1), Size = UDim2.fromOffset(24, 24),
		Position = UDim2.new(1, 0, 1, 0), ZIndex = 10,
	}, window)

	local tabs = {}
	local currentTab
	local destroyed = false
	local connections = {}

	local context = { _objects = {}, Theme = theme, Animation = Animation, _config = ConfigStore }

	local api = { Instance = screenGui, Root = root, Window = window, Theme = theme, _context = context, Config = ConfigStore }

	local function applySearch(query)
		query = string.lower(query or "")
		for _, tab in ipairs(tabs) do
			for _, obj in ipairs(tab._searchables) do
				if query == "" then
					obj.Instance.Visible = true
				else
					local hay = string.lower(obj.Name or "")
					obj.Instance.Visible = string.find(hay, query, 1, true) ~= nil
				end
			end
		end
	end
	searchBox:GetPropertyChangedSignal("Text"):Connect(applySearch)

	local function setTab(tab)
		if currentTab == tab then
			return
		end
		currentTab = tab
		for _, item in ipairs(tabs) do
			local active = item == tab
			item.Button.BackgroundColor3 = active and theme.AccentSoft or theme.Surface
			item.Button.TextColor3 = active and theme.Accent or theme.TextMuted
			item.Page.Visible = active
			if active then
				Animation.Tween(item.Button, { BackgroundColor3 = theme.AccentSoft }, 0.15)
			end
		end
	end

	function api:CreateTab(tabOptions)
		tabOptions = tabOptions or {}
		local tabName = tabOptions.Name or tabOptions.Title or ("Tab" .. (#tabs + 1))
		local button = create("TextButton", {
			AutoButtonColor = false,
			BackgroundColor3 = theme.Surface,
			Text = (tabOptions.Icon and (tabOptions.Icon .. "  ") or "") .. tabName,
			TextColor3 = theme.TextMuted, TextSize = 11, Font = theme.FontBold,
			Size = UDim2.fromOffset(math.clamp(86 + #tabName * 3, 86, 160), 28),
			AutomaticSize = Enum.AutomaticSize.None,
		}, tabStrip)
		corner(button, UDim.new(1, 0))
		local page = create("Frame", { BackgroundTransparency = 1, Visible = false, Size = UDim2.new(1, 0, 1, 0) }, pages)
		local columns = create("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0) }, page)
		create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Center, VerticalAlignment = Enum.VerticalAlignment.Top, Padding = UDim.new(0, 2) }, columns)
		create("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6) }, columns)

		local tab = { Name = tabName, Button = button, Page = page, Columns = columns, _searchables = {}, _defaultColumn = nil }

		local function defaultColumn()
			if not tab._defaultColumn or not tab._defaultColumn.Parent then
				tab._defaultColumn = Components.Column(context, columns, 1, 0)
				tab._defaultColumn.Size = UDim2.new(1, -8, 1, 0)
			end
			return tab._defaultColumn
		end

		local function track(name, instance)
			tab._searchables[#tab._searchables + 1] = { Name = name, Instance = instance }
			return instance
		end

		function tab:CreateColumn(width)
			return Components.Column(context, columns, width or (1 / 3), #columns:GetChildren())
		end
		function tab:CreateSection(a, b, c)
			if type(a) == "table" then
				a.Parent = a.Parent or defaultColumn()
				return track(a.Title or a.Name, Components.Section(context, a.Parent, a.Title or a.Name, a.Subtitle or a.Description))
			end
			return track(b, Components.Section(context, a or defaultColumn(), b, c))
		end
		function tab:CreateLabel(a, b, c, d)
			if type(a) == "table" then
				a.Parent = a.Parent or defaultColumn()
				return track(a.Title or a.Text, Components.Label(context, a.Parent, a.Title or a.Name, a.Text or a.Value, a.Order))
			end
			return track(b, Components.Label(context, a or defaultColumn(), b, c, d))
		end
		function tab:CreateButton(a, b, c, d)
			if type(a) == "table" then
				a.Parent = a.Parent or defaultColumn()
				local r = Components.Button(context, a.Parent, a, c, d)
				return track(a.Name or a.Title, r.Instance and r or r)
			end
			local r = Components.Button(context, a or defaultColumn(), b, c, d)
			return track(b, r)
		end
		function tab:CreateToggle(a, b, c, d, e, f)
			if type(a) == "table" then
				a.Parent = a.Parent or defaultColumn()
				return track(a.Name or a.Title, Components.Toggle(context, a))
			end
			return track(b, Components.Toggle(context, a or defaultColumn(), b, c, d, e, f))
		end
		function tab:CreateCheckbox(a, b, c, d, e)
			if type(a) == "table" then
				local o = a
				o.Parent = o.Parent or defaultColumn()
				return track(o.Name or o.Title, Components.Checkbox(context, o.Parent, o.Name or o.Title, o.Default, o.Callback, o.Order))
			end
			return track(b, Components.Checkbox(context, a or defaultColumn(), b, c, d, e))
		end
		function tab:CreateSlider(a, b, c, d, e, f, g)
			if type(a) == "table" then
				a.Parent = a.Parent or defaultColumn()
				return track(a.Name or a.Title, Components.Slider(context, a))
			end
			return track(b, Components.Slider(context, a or defaultColumn(), b, c, d, e, f, g))
		end
		function tab:CreateDropdown(a, b, c, d, e, f)
			if type(a) == "table" then
				a.Parent = a.Parent or defaultColumn()
				return track(a.Name or a.Title, Components.Dropdown(context, a))
			end
			return track(b, Components.Dropdown(context, a or defaultColumn(), b, c, d, e, f))
		end
		function tab:CreateTextbox(a, b, c, d, e, f)
			if type(a) == "table" then
				a.Parent = a.Parent or defaultColumn()
				return track(a.Name or a.Title, Components.Textbox(context, a))
			end
			return track(b, Components.Textbox(context, a or defaultColumn(), b, c, d, e, f))
		end
		function tab:CreateInput(...)
			return tab:CreateTextbox(...)
		end
		function tab:CreateKeybind(a, b, c, d, e)
			if type(a) == "table" then
				a.Parent = a.Parent or defaultColumn()
				return track(a.Name or a.Title, Components.Keybind(context, a))
			end
			return track(b, Components.Keybind(context, a or defaultColumn(), b, c, d, e))
		end
		function tab:CreateColorPicker(a, b, c, d, e)
			if type(a) == "table" then
				a.Parent = a.Parent or defaultColumn()
				return track(a.Name or a.Title, Components.ColorPicker(context, a))
			end
			return track(b, Components.ColorPicker(context, a or defaultColumn(), b, c, d, e))
		end
		function tab:CreateColorpicker(...)
			return tab:CreateColorPicker(...)
		end
		function tab:CreateFeature(a, b, c, d, e, f, g)
			if type(a) == "table" then
				return track(a.Name or a.Title, Components.FeatureCard(context, defaultColumn(), a))
			end
			return track(b, Components.FeatureCard(context, a or defaultColumn(), b, c, d, e, f, g))
		end

		-- fix slider dict path: Components.Slider expects parent nil + opts in first arg,
		-- but needs actual parent. Patch: after creation, reparent.

		tabs[#tabs + 1] = tab
		button.MouseButton1Click:Connect(function() setTab(tab) end)
		if not currentTab then
			setTab(tab)
		end
		return tab
	end

	function api:Notify(notificationOptions)
		notificationOptions = notificationOptions or {}
		local holder = screenGui:FindFirstChild("Notifications")
		if not holder then
			holder = create("Frame", {
				Name = "Notifications", BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(1, 1),
				Position = UDim2.new(1, -18, 1, -18),
				Size = UDim2.fromOffset(280, 320),
			}, screenGui)
			create("UIListLayout", { VerticalAlignment = Enum.VerticalAlignment.Bottom, Padding = UDim.new(0, 7), SortOrder = Enum.SortOrder.LayoutOrder }, holder)
		end
		local card = create("TextButton", {
			AutoButtonColor = false, BackgroundColor3 = theme.Surface,
			Text = "", Size = UDim2.new(1, 0, 0, 60), LayoutOrder = #holder:GetChildren(),
		}, holder)
		corner(card, theme.SmallCornerRadius)
		stroke(card, theme.Border)
		text(card, notificationOptions.Title or "Notification", {
			Font = theme.FontBold, Size = 11, Position = UDim2.fromOffset(30, 6), Height = 18,
			Size2 = UDim2.new(1, -42, 0, 18),
		}, theme)
		text(card, notificationOptions.Content or notificationOptions.Text or "", {
			Color = theme.TextMuted, Size = 10, Position = UDim2.fromOffset(30, 25),
			Height = 26, Wrapped = true, Size2 = UDim2.new(1, -42, 0, 26),
		}, theme)
		local dot = create("Frame", {
			BackgroundColor3 = theme.Accent, BorderSizePixel = 0,
			Size = UDim2.fromOffset(8, 8), Position = UDim2.fromOffset(12, 12),
		}, card)
		corner(dot, UDim.new(1, 0))
		Animation.SlideIn(card, "Right", 0.25)
		task.delay(notificationOptions.Duration or 4, function()
			if card.Parent then
				Animation.Tween(card, { BackgroundTransparency = 1 }, 0.2)
				task.wait(0.22)
				if card.Parent then
					card:Destroy()
				end
			end
		end)
		return card
	end

	function api:SetTheme(overrides)
		local nextTheme = Theme.Create(overrides)
		for key, value in pairs(nextTheme) do
			theme[key] = value
		end
		window.BackgroundColor3 = theme.Background
		topbar.BackgroundColor3 = theme.Surface
		titleLabel.TextColor3 = theme.Text
		searchBox.BackgroundColor3 = theme.SurfaceMuted
		return theme
	end

	function api:SetTitle(t)
		title = t
		screenGui.Name = t
		titleLabel.Text = (options.Logo or "➤") .. "  " .. t
	end

	function api:Toggle(visible)
		root.Visible = visible == nil and not root.Visible or visible
	end

	function api:SaveConfig(name)
		return ConfigStore:Save(name)
	end
	function api:LoadConfig(name)
		return ConfigStore:Load(name)
	end
	function api:EnableAutoSave(name)
		ConfigStore._auto = true
		ConfigStore._autoName = name or "autosave"
	end

	function api:Destroy()
		if destroyed then
			return
		end
		destroyed = true
		for _, connection in ipairs(connections) do
			pcall(function() connection:Disconnect() end)
		end
		screenGui:Destroy()
	end

	-- Drag (mouse + touch)
	local dragging = false
	local dragStart, startPosition
	connections[#connections + 1] = topbar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPosition = window.Position
			pcall(function() input:ChangeCursorImage("") end)
		end
	end)
	connections[#connections + 1] = UserInputService.InputChanged:Connect(function(input)
		if not dragging then
			return
		end
		if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		local delta = input.Position - dragStart
		window.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X, startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
		shadow.Position = UDim2.new(window.Position.X.Scale - 0.01, window.Position.X.Offset, window.Position.Y.Scale - 0.02, window.Position.Y.Offset)
	end)
	connections[#connections + 1] = UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	-- Resize (mouse + touch)
	local resizing = false
	local resizeStart, startSize
	connections[#connections + 1] = grip.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			resizing = true
			resizeStart = input.Position
			startSize = window.AbsoluteSize
		end
	end)
	connections[#connections + 1] = UserInputService.InputChanged:Connect(function(input)
		if not resizing then
			return
		end
		if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		local delta = input.Position - resizeStart
		local vw = math.max(root.AbsoluteSize.X, 1)
		local vh = math.max(root.AbsoluteSize.Y, 1)
		local nx = math.clamp((startSize.X + delta.X) / vw, 0.3, 0.95)
		local ny = math.clamp((startSize.Y + delta.Y) / vh, 0.35, 0.95)
		window.Size = UDim2.fromScale(nx, ny)
		shadow.Size = UDim2.fromScale(nx + 0.02, ny + 0.06)
	end)
	connections[#connections + 1] = UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			resizing = false
		end
	end)

	-- Responsive scale
	local function updateScale()
		local viewport = root.AbsoluteSize
		if viewport.X <= 0 or viewport.Y <= 0 then
			return
		end
		scale.Scale = math.clamp(math.min(viewport.X / 900, viewport.Y / 620), 0.65, 1)
	end
	connections[#connections + 1] = root:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateScale)
	task.defer(updateScale)

	-- Toggle key + buttons
	connections[#connections + 1] = UserInputService.InputBegan:Connect(function(input, processed)
		if processed then
			return
		end
		if input.KeyCode == toggleKey then
			api:Toggle()
		end
	end)
	minimizeBtn.MouseButton1Click:Connect(function() api:Toggle(false) end)
	closeBtn.MouseButton1Click:Connect(function()
		-- minimize to keep config; full destroy via api:Destroy()
		api:Toggle(false)
	end)

	Library.Windows[#Library.Windows + 1] = api
	return api
end

return Library
