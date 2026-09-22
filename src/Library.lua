-- DevampedLib Library module ("luminate" look)
-- Sidebar nav + panel columns, monochrome dark theme.
-- API:
--   local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/revampedbyvamp/devamped-Lib/main/Dist/DevampedLib.lua"))()
--   local Window = Library:CreateWindow({ Title = "luminate" })
--   local Tab = Window:CreateTab({ Name = "rage" })
--   local Panel = Tab:CreatePanel()  -- gray card, like the reference
--   Panel-less calls also work: Tab:CreateCheckbox({ Name = "Checkbox" })

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
		TextTruncate = properties.Truncate or Enum.TextTruncate.None,
		Size = properties.Size2 or UDim2.new(1, 0, 0, properties.Height or 18),
		Position = properties.Position or UDim2.new(),
		LayoutOrder = properties.LayoutOrder or 0,
	}, parent)
end

-- Triangular maze-ish logo mark (frames only, always renders).
local function buildLogo(parent, theme, size)
	local holder = create("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(size, size * 0.78),
	}, parent)
	local t = 4 / size
	local function bar(w, h, x, y, rot)
		local f = create("Frame", {
			BackgroundColor3 = theme.Text,
			BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.fromScale(w, h),
			Position = UDim2.fromScale(x, y),
			Rotation = rot or 0,
		}, holder)
		corner(f, UDim.new(1, 0))
		return f
	end
	bar(0.52, t + 0.03, 0.5, 0.2, 0) -- top
	bar(0.52, t + 0.03, 0.28, 0.62, 62) -- left edge
	bar(0.52, t + 0.03, 0.72, 0.62, -62) -- right edge
	bar(0.34, t + 0.02, 0.5, 0.52, 0) -- inner line
	bar(0.2, t + 0.02, 0.5, 0.72, 0) -- inner line 2
	return holder
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
	local theme = Theme.Create(options.Theme or options.ThemeName or "Luminate")
	local brand = options.Brand or options.Title or options.Name or "luminate"
	local footerText = options.Footer or "luminate.pw"
	local toggleKey = options.ToggleKey or options.Toggle or Enum.KeyCode.RightShift

	local player = Players.LocalPlayer
	local playerGui = player and player:WaitForChild("PlayerGui")
	local screenGui = create("ScreenGui", {
		Name = brand,
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		IgnoreGuiInset = true,
	}, playerGui)
	if gethui then
		pcall(function() screenGui.Parent = gethui() end)
	end

	local root = create("Frame", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1) }, screenGui)
	local scale = create("UIScale", { Scale = 1 }, root)

	local window = create("Frame", {
		BackgroundColor3 = theme.Background,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Size = options.Size or UDim2.fromScale(0.62, 0.66),
		Position = options.Position or UDim2.fromScale(0.19, 0.17),
		Active = true,
	}, root)
	corner(window, UDim.new(0, 10))

	-- ============ SIDEBAR ============
	local sidebar = create("Frame", {
		BackgroundColor3 = theme.Sidebar,
		BorderSizePixel = 0,
		Size = UDim2.new(0.27, 0, 1, 0),
		ClipsDescendants = true,
	}, window)

	-- diagonal two-tone wave (like the reference lower half)
	local wave = create("Frame", {
		BackgroundColor3 = theme.SidebarAlt,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0),
		Size = UDim2.new(2.2, 0, 0.62, 0),
		Position = UDim2.new(0.5, 0, 0.52, 0),
		Rotation = -14,
	}, sidebar)
	corner(wave, UDim.new(0, 0))
	wave.ZIndex = 0

	local sidePad = create("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), ZIndex = 2 }, sidebar)
	create("UIPadding", {
		PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 16),
		PaddingTop = UDim.new(0, 18), PaddingBottom = UDim.new(0, 12),
	}, sidePad)
	local sideLayout = create("UIListLayout", {
		Padding = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Top,
	}, sidePad)

	-- logo
	local logoBox = create("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 96), LayoutOrder = 0 }, sidePad)
	buildLogo(logoBox, theme, 52).Position = UDim2.new(0.5, -26, 0, 0)
	text(logoBox, brand, {
		Color = theme.Text, Font = theme.Font, Size = 20,
		XAlignment = Enum.TextXAlignment.Center,
		Position = UDim2.fromOffset(0, 52), Height = 30,
		Size2 = UDim2.new(1, 0, 0, 30),
	}, theme)

	-- nav list
	local nav = create("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, -170), LayoutOrder = 1 }, sidePad)
	create("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder }, nav)

	-- footer
	local footer = create("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30), LayoutOrder = 2 }, sidePad)
	text(footer, "◈", { Color = theme.TextFaint, Size = 13, Position = UDim2.fromOffset(2, 0), Height = 30, Size2 = UDim2.fromOffset(20, 30) }, theme)
	text(footer, footerText, { Color = theme.TextMuted, Size = 11, Position = UDim2.fromOffset(26, 0), Height = 30, Size2 = UDim2.new(1, -52, 0, 30) }, theme)
	text(footer, "◐", { Color = theme.TextFaint, Size = 13, XAlignment = Enum.TextXAlignment.Right, Position = UDim2.new(1, -22, 0, 0), Height = 30, Size2 = UDim2.fromOffset(22, 30) }, theme)

	-- ============ CONTENT ============
	local content = create("Frame", {
		BackgroundColor3 = theme.Background,
		BorderSizePixel = 0,
		Size = UDim2.new(0.73, 0, 1, 0),
		Position = UDim2.new(0.27, 0, 0, 0),
		ClipsDescendants = true,
	}, window)
	create("UIPadding", {
		PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10),
		PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10),
	}, content)

	local searchBox
	if options.Search then
		searchBox = create("TextBox", {
			BackgroundColor3 = theme.Surface,
			Text = "",
			PlaceholderText = "Search...",
			PlaceholderColor3 = theme.TextFaint,
			TextColor3 = theme.Text,
			TextSize = 11,
			Font = theme.Font,
			ClearTextOnFocus = false,
			Size = UDim2.new(1, 0, 0, 28),
		}, content)
		corner(searchBox, theme.SmallCornerRadius)
		create("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) }, searchBox)
	end

	local pages = create("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, searchBox and -36 or 0),
		Position = searchBox and UDim2.fromOffset(0, 36) or UDim2.new(),
	}, content)

	local grip = create("TextButton", {
		AutoButtonColor = false, BackgroundTransparency = 1,
		Text = "◢", TextColor3 = theme.TextFaint, TextTransparency = 0.5, TextSize = 13,
		AnchorPoint = Vector2.new(1, 1), Size = UDim2.fromOffset(22, 22),
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
					obj.Instance.Visible = string.find(string.lower(obj.Name or ""), query, 1, true) ~= nil
				end
			end
		end
	end
	if searchBox then
		searchBox:GetPropertyChangedSignal("Text"):Connect(function()
			applySearch(searchBox.Text)
		end)
	end

	local function setTab(tab)
		if currentTab == tab then
			return
		end
		currentTab = tab
		for _, item in ipairs(tabs) do
			local active = item == tab
			item.Button.BackgroundTransparency = 1
			item.NameLabel.TextColor3 = active and theme.Text or theme.TextMuted
			item.IconBox.BackgroundColor3 = active and theme.SurfaceMuted or theme.Sidebar
			item.IconBox.BackgroundTransparency = active and 0 or 1
			item.Page.Visible = active
		end
	end

	function api:CreateTab(tabOptions)
		tabOptions = tabOptions or {}
		local tabName = tabOptions.Name or tabOptions.Title or ("tab" .. (#tabs + 1))
		local glyph = tabOptions.Icon or string.upper(string.sub(tabName, 1, 1))

		local button = create("TextButton", {
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			Text = "",
			Size = UDim2.new(1, 0, 0, 32),
			LayoutOrder = #tabs,
		}, nav)
		local iconBox = create("Frame", {
			BackgroundColor3 = theme.Sidebar,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.fromOffset(24, 24),
			Position = UDim2.fromOffset(4, 4),
		}, button)
		corner(iconBox, UDim.new(0, 6))
		text(iconBox, glyph, {
			Color = theme.TextMuted, Size = 11, Font = theme.Font,
			XAlignment = Enum.TextXAlignment.Center, Size2 = UDim2.fromScale(1, 1),
		}, theme)
		local nameLabel = text(button, tabName, {
			Color = theme.TextMuted, Size = 13, Font = theme.Font,
			Position = UDim2.fromOffset(36, 0), Height = 32,
			Size2 = UDim2.new(1, -40, 0, 32),
		}, theme)

		local page = create("Frame", { BackgroundTransparency = 1, Visible = false, Size = UDim2.new(1, 0, 1, 0) }, pages)
		local columns = create("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0) }, page)
		create("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			VerticalAlignment = Enum.VerticalAlignment.Top,
			Padding = UDim.new(0, 8),
		}, columns)

		local tab = { Name = tabName, Button = button, IconBox = iconBox, NameLabel = nameLabel, Page = page, Columns = columns, _searchables = {}, _defaultColumn = nil }

		local function defaultColumn()
			if not tab._defaultColumn or not tab._defaultColumn.Parent then
				tab._defaultColumn = Components.Column(context, columns, 0.5, 0)
				tab._defaultColumn.Size = UDim2.new(0.5, -4, 1, 0)
			end
			return tab._defaultColumn
		end

		local function track(name, instance)
			local raw = (type(instance) == "table" and instance.Instance) or instance
			tab._searchables[#tab._searchables + 1] = { Name = name, Instance = raw }
			return instance
		end

		function tab:CreateColumn(width)
			return Components.Column(context, columns, width or 0.5, #columns:GetChildren())
		end
		function tab:CreatePanel(a, b)
			local panel
			if type(a) == "table" then
				a.Parent = a.Parent or defaultColumn()
				panel = Components.Groupbox(context, a)
			else
				panel = Components.Groupbox(context, a or defaultColumn(), b)
			end
			-- proxy so calls chain: local p = tab:CreatePanel() p:CreateCheckbox({...})
			local p = { Instance = panel, Name = (type(a) == "table" and (a.Title or a.Name)) or b }
			local function fix(x)
				if type(x) == "table" and x.Parent == nil then
					x.Parent = panel
				end
				return x
			end
			function p:CreateSection(x, y, z) if type(x) == "table" then return tab:CreateSection(fix(x)) end return tab:CreateSection(panel, x, y) end
			function p:CreateLabel(x, y, z, w) if type(x) == "table" then return tab:CreateLabel(fix(x)) end return tab:CreateLabel(panel, x, y, z) end
			function p:CreateButton(x, y, z) if type(x) == "table" then return tab:CreateButton(fix(x)) end return tab:CreateButton(panel, x, y) end
			function p:CreateToggle(x, y, z, w, v, u) if type(x) == "table" then return tab:CreateToggle(fix(x)) end return tab:CreateToggle(panel, x, y, z, w, v) end
			function p:CreateCheckbox(x, y, z, w, v) if type(x) == "table" then return tab:CreateCheckbox(fix(x)) end return tab:CreateCheckbox(panel, x, y, z, w) end
			function p:CreateSlider(x, y, z, w, v, u, t) if type(x) == "table" then return tab:CreateSlider(fix(x)) end return tab:CreateSlider(panel, x, y, z, w, v, u) end
			function p:CreateDropdown(x, y, z, w, v, u) if type(x) == "table" then return tab:CreateDropdown(fix(x)) end return tab:CreateDropdown(panel, x, y, z, w, v) end
			function p:CreateCombo(...) return p:CreateDropdown(...) end
			function p:CreateTextbox(x, y, z, w, v, u) if type(x) == "table" then return tab:CreateTextbox(fix(x)) end return tab:CreateTextbox(panel, x, y, z, w, v) end
			function p:CreateInput(...) return p:CreateTextbox(...) end
			function p:CreateKeybind(x, y, z, w, v) if type(x) == "table" then return tab:CreateKeybind(fix(x)) end return tab:CreateKeybind(panel, x, y, z, w) end
			function p:CreateColorPicker(x, y, z, w, v) if type(x) == "table" then return tab:CreateColorPicker(fix(x)) end return tab:CreateColorPicker(panel, x, y, z, w) end
			function p:CreateColorpicker(...) return p:CreateColorPicker(...) end
			function p:CreateFeature(x, y, z, w, v, u, t) if type(x) == "table" then return tab:CreateFeature(fix(x)) end return tab:CreateFeature(panel, x, y, z, w, v, u) end
			track(p.Name, p)
			return p
		end
		function tab:CreateGroupbox(...)
			return tab:CreatePanel(...)
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
				return track(a.Name or a.Title, Components.Button(context, a.Parent, a, c, d))
			end
			return track(b, Components.Button(context, a or defaultColumn(), b, c, d))
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
		function tab:CreateCombo(...)
			return tab:CreateDropdown(...)
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
				a.Parent = a.Parent or defaultColumn()
				return track(a.Name or a.Title, Components.FeatureCard(context, a))
			end
			return track(b, Components.FeatureCard(context, a or defaultColumn(), b, c, d, e, f, g))
		end

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
			Text = "", Size = UDim2.new(1, 0, 0, 58), LayoutOrder = #holder:GetChildren(),
		}, holder)
		corner(card, theme.SmallCornerRadius)
		text(card, notificationOptions.Title or "Notification", {
			Font = theme.FontBold, Size = 11, Position = UDim2.fromOffset(12, 6), Height = 17,
			Size2 = UDim2.new(1, -24, 0, 17),
		}, theme)
		text(card, notificationOptions.Content or notificationOptions.Text or "", {
			Color = theme.TextMuted, Size = 10, Position = UDim2.fromOffset(12, 24),
			Height = 26, Wrapped = true, Size2 = UDim2.new(1, -24, 0, 26),
		}, theme)
		if card:FindFirstChildOfClass("UIStroke") == nil then
			create("UIStroke", { Color = theme.Border, Thickness = 1 }, card)
		end
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
		sidebar.BackgroundColor3 = theme.Sidebar
		content.BackgroundColor3 = theme.Background
		return theme
	end

	function api:SetTitle(t)
		brand = t
		screenGui.Name = t
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

	-- Drag via sidebar (mouse + touch)
	local dragging = false
	local dragStart, startPosition
	connections[#connections + 1] = sidebar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPosition = window.Position
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
	end)
	connections[#connections + 1] = UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	-- Resize via grip (mouse + touch)
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
		window.Size = UDim2.fromScale(
			math.clamp((startSize.X + delta.X) / vw, 0.35, 0.95),
			math.clamp((startSize.Y + delta.Y) / vh, 0.4, 0.95))
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

	-- Toggle key
	connections[#connections + 1] = UserInputService.InputBegan:Connect(function(input, processed)
		if processed then
			return
		end
		if input.KeyCode == toggleKey then
			api:Toggle()
		end
	end)

	Library.Windows[#Library.Windows + 1] = api
	return api
end

return Library
