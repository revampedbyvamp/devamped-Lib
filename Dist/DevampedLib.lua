-- DevampedLib single-file bundle (loadstring-ready)
-- https://github.com/revampedbyvamp/devamped-Lib
-- Generated from src/. Do not edit by hand; edit src/ and rebuild.
do
-- DevampedLib Theme module
-- Light / Dark + custom overrides. Accepts string name or table.

local Theme = {}

Theme.Light = {
	Name = "Lavender Light",
	Accent = Color3.fromRGB(104, 67, 190),
	AccentSoft = Color3.fromRGB(235, 228, 251),
	Background = Color3.fromRGB(249, 249, 251),
	Surface = Color3.fromRGB(255, 255, 255),
	SurfaceMuted = Color3.fromRGB(244, 244, 247),
	Border = Color3.fromRGB(229, 229, 234),
	Text = Color3.fromRGB(31, 31, 36),
	TextMuted = Color3.fromRGB(117, 117, 127),
	TextFaint = Color3.fromRGB(166, 166, 175),
	Success = Color3.fromRGB(57, 164, 103),
	Danger = Color3.fromRGB(214, 75, 91),
	Shadow = Color3.fromRGB(30, 22, 56),
	Font = Enum.Font.Gotham,
	FontBold = Enum.Font.GothamSemibold,
	CornerRadius = UDim.new(0, 12),
	SmallCornerRadius = UDim.new(0, 8),
}

Theme.Dark = {
	Name = "Lavender Dark",
	Accent = Color3.fromRGB(139, 105, 240),
	AccentSoft = Color3.fromRGB(46, 36, 84),
	Background = Color3.fromRGB(17, 17, 22),
	Surface = Color3.fromRGB(26, 26, 33),
	SurfaceMuted = Color3.fromRGB(35, 35, 45),
	Border = Color3.fromRGB(52, 52, 66),
	Text = Color3.fromRGB(240, 240, 245),
	TextMuted = Color3.fromRGB(160, 160, 175),
	TextFaint = Color3.fromRGB(110, 110, 125),
	Success = Color3.fromRGB(74, 200, 128),
	Danger = Color3.fromRGB(240, 90, 105),
	Shadow = Color3.fromRGB(0, 0, 0),
	Font = Enum.Font.Gotham,
	FontBold = Enum.Font.GothamSemibold,
	CornerRadius = UDim.new(0, 12),
	SmallCornerRadius = UDim.new(0, 8),
}

Theme.Default = Theme.Light
Theme.Themes = { Light = Theme.Light, Dark = Theme.Dark }

function Theme.Get(name)
	if type(name) == "table" then
		return Theme.Create(name)
	end
	if type(name) == "string" and Theme.Themes[name] then
		return Theme.Create(Theme.Themes[name])
	end
	return Theme.Create(nil)
end

function Theme.Create(overrides)
	local result = {}
	for key, value in pairs(Theme.Default) do
		result[key] = value
	end
	if type(overrides) == "string" then
		overrides = Theme.Themes[overrides]
	end
	for key, value in pairs(overrides or {}) do
		result[key] = value
	end
	return result
end

_G.__DL_Theme = Theme
end
local Theme = _G.__DL_Theme
do
-- DevampedLib Animation module
-- Tween helpers, hover, press, fade, slide, ripple. Never errors when instance is destroyed.

local TweenService = game:GetService("TweenService")

Animation = {}

Animation.Easing = {
	Quad = Enum.EasingStyle.Quad,
	Sine = Enum.EasingStyle.Sine,
	Back = Enum.EasingStyle.Back,
	Elastic = Enum.EasingStyle.Elastic,
	Linear = Enum.EasingStyle.Linear,
}

function Animation.Tween(instance, properties, duration, style, direction)
	if typeof(instance) ~= "Instance" or instance.Parent == nil then
		return nil
	end
	local ok, tween = pcall(function()
		local info = TweenInfo.new(
			duration or 0.18,
			style or Enum.EasingStyle.Quad,
			direction or Enum.EasingDirection.Out
		)
		return TweenService:Create(instance, info, properties)
	end)
	if not ok or not tween then
		return nil
	end
	local playOk = pcall(function() tween:Play() end)
	if not playOk then
		return nil
	end
	return tween
end

function Animation.BindHover(button, normalColor, hoverColor, duration)
	if typeof(button) ~= "Instance" then
		return {}
	end
	duration = duration or 0.12
	local connections = {}
	connections[#connections + 1] = button.MouseEnter:Connect(function()
		Animation.Tween(button, { BackgroundColor3 = hoverColor }, duration)
	end)
	connections[#connections + 1] = button.MouseLeave:Connect(function()
		Animation.Tween(button, { BackgroundColor3 = normalColor }, duration)
	end)
	return connections
end

function Animation.Press(button, scaleObject)
	if typeof(button) ~= "Instance" or typeof(scaleObject) ~= "Instance" then
		return
	end
	button.MouseButton1Down:Connect(function()
		Animation.Tween(scaleObject, { Scale = 0.97 }, 0.08)
	end)
	button.MouseButton1Up:Connect(function()
		Animation.Tween(scaleObject, { Scale = 1 }, 0.12, Enum.EasingStyle.Back)
	end)
end

function Animation.Fade(instance, visible, duration)
	if typeof(instance) ~= "Instance" then
		return nil
	end
	duration = duration or 0.2
	local goal = visible and 0 or 1
	if instance:IsA("ImageLabel") or instance:IsA("ImageButton") then
		return Animation.Tween(instance, { ImageTransparency = goal }, duration)
	elseif instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox") then
		Animation.Tween(instance, { BackgroundTransparency = goal }, duration)
		return Animation.Tween(instance, { TextTransparency = goal }, duration)
	elseif instance:IsA("ScrollingFrame") or instance:IsA("Frame") or instance:IsA("CanvasGroup") then
		return Animation.Tween(instance, { BackgroundTransparency = goal }, duration)
	end
	return nil
end

function Animation.SlideIn(instance, direction, duration)
	if typeof(instance) ~= "Instance" then
		return nil
	end
	duration = duration or 0.25
	local start = instance.Position
	local offset = UDim2.fromOffset(0, direction == "Up" and 24 or direction == "Down" and -24 or 0)
	if direction == "Left" then
		offset = UDim2.fromOffset(24, 0)
	elseif direction == "Right" then
		offset = UDim2.fromOffset(-24, 0)
	end
	instance.Position = start + offset
	Animation.Tween(instance, { BackgroundTransparency = 0 }, 0.01)
	return Animation.Tween(instance, { Position = start }, duration, Enum.EasingStyle.Quad)
end

function Animation.Spring(instance, propertyMap, duration)
	return Animation.Tween(instance, propertyMap, duration or 0.35, Enum.EasingStyle.Back)
end

-- Click ripple on any GuiButton. Parent must be a GuiObject with ClipsDescendants.
function Animation.Ripple(button, color)
	if typeof(button) ~= "Instance" or not button:IsA("GuiButton") then
		return
	end
	button.AutoButtonColor = false
	button.ClipsDescendants = true
	button.MouseButton1Down:Connect(function(x, y)
		local ok = pcall(function()
			local absPos = button.AbsolutePosition
			local absSize = button.AbsoluteSize
			local diameter = math.max(absSize.X, absSize.Y) * 2.2
			local ripple = Instance.new("Frame")
			ripple.AnchorPoint = Vector2.new(0.5, 0.5)
			ripple.BackgroundColor3 = color or Color3.new(1, 1, 1)
			ripple.BackgroundTransparency = 0.75
			ripple.BorderSizePixel = 0
			ripple.Size = UDim2.fromOffset(8, 8)
			ripple.Position = UDim2.fromOffset(x - absPos.X, y - absPos.Y)
			local rc = Instance.new("UICorner")
			rc.CornerRadius = UDim.new(1, 0)
			rc.Parent = ripple
			ripple.Parent = button
			ripple.ZIndex = button.ZIndex + 1
			Animation.Tween(ripple, {
				Size = UDim2.fromOffset(diameter, diameter),
				BackgroundTransparency = 1,
			}, 0.45, Enum.EasingStyle.Quad)
			task.delay(0.5, function()
				if ripple.Parent then
					ripple:Destroy()
				end
			end)
		end)
		if not ok then
		end
	end)
end

_G.__DL_Animation = Animation
end
local Animation = _G.__DL_Animation
do
-- DevampedLib Components module
-- Buttons, toggles, sliders, dropdowns, textboxes, keybinds, color pickers,
-- labels, sections, columns, tooltips. All scale-based and touch friendly.

local UserInputService = game:GetService("UserInputService")

Components = {}

local function create(className, properties, parent)
	local object = Instance.new(className)
	for key, value in pairs(properties or {}) do
		local ok = pcall(function() object[key] = value end)
		if not ok then
			-- ignore invalid props on older clients
		end
	end
	object.Parent = parent
	return object
end

local function corner(parent, radius)
	return create("UICorner", { CornerRadius = radius }, parent)
end

local function stroke(parent, color, transparency)
	return create("UIStroke", { Color = color, Transparency = transparency or 0, Thickness = 1 }, parent)
end

local function text(parent, value, properties, theme)
	properties = properties or {}
	local label = create("TextLabel", {
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
	return label
end

local function register(context, object)
	context._objects = context._objects or {}
	context._objects[#context._objects + 1] = object
	return object
end

-- Normalizes dict-style vs positional calls.
-- Example: Tab:CreateButton({Name=, Callback=}) or Tab:CreateButton(parent, title, callback)
local function normArgs(first, second, third, fourth, fifth)
	if type(first) == "table" and (second == nil or type(second) ~= "Instance") then
		return nil, first
	end
	return first, second
end

function Components.Tooltip(context, parent, tipText)
	local theme = context.Theme
	local tip = create("TextLabel", {
		Visible = false,
		BackgroundColor3 = theme.Text,
		TextColor3 = theme.Surface,
		Text = tipText or "",
		TextSize = 10,
		Font = theme.Font,
		TextWrapped = true,
		AutomaticSize = Enum.AutomaticSize.XY,
		Size = UDim2.fromOffset(10, 10),
		ZIndex = 100,
	}, parent)
	corner(tip, UDim.new(0, 6))
	create("UIPadding", {
		PaddingLeft = UDim.new(0, 8),
		PaddingRight = UDim.new(0, 8),
		PaddingTop = UDim.new(0, 5),
		PaddingBottom = UDim.new(0, 5),
	}, tip)
	return tip
end

function Components.BindTooltip(context, hoverObject, tipText)
	if not tipText or tipText == "" then
		return nil
	end
	local layer = hoverObject:FindFirstAncestorOfClass("ScreenGui")
	local holder = layer or hoverObject.Parent
	local tip = Components.Tooltip(context, holder, tipText)
	hoverObject.MouseEnter:Connect(function()
		tip.Visible = true
		local pos = UserInputService:GetMouseLocation()
		tip.Position = UDim2.fromOffset(pos.X + 12, pos.Y + 10)
	end)
	hoverObject.MouseMoved:Connect(function(x, y)
		tip.Position = UDim2.fromOffset(x + 12, y + 10)
	end)
	hoverObject.MouseLeave:Connect(function()
		tip.Visible = false
	end)
	return tip
end

function Components.Section(context, parent, title, subtitle)
	local theme = context.Theme
	if type(parent) == "table" and title == nil then
		local o = parent
		parent = o.Parent or nil
		title, subtitle = o.Title or o.Name, o.Subtitle or o.Description
	end
	local frame = register(context, create("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, subtitle and 43 or 27),
	}, parent))
	text(frame, title or "Section", { Font = theme.FontBold, Size = 13, Height = 20 }, theme)
	if subtitle then
		text(frame, subtitle, { Color = theme.TextMuted, Size = 10, Position = UDim2.fromOffset(0, 21), Height = 18 }, theme)
	end
	return frame
end

function Components.Label(context, parent, title, value, order)
	local theme = context.Theme
	if type(parent) == "table" and title == nil then
		local o = parent
		return Components.Label(context, o.Parent, o.Title or o.Name or "", o.Text or o.Value, o.Order)
	end
	local row = register(context, create("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, value and 37 or 22),
		LayoutOrder = order or 0,
	}, parent))
	text(row, title or "", { Font = theme.FontBold, Size = 11, Height = 17 }, theme)
	if value then
		text(row, value, { Color = theme.TextMuted, Size = 10, Position = UDim2.fromOffset(0, 17), Height = 17 }, theme)
	end
	return row
end

function Components.Button(context, parent, title, callback, order)
	local theme = context.Theme
	local opts
	parent, opts = normArgs(parent, title)
	if opts then
		title = opts.Name or opts.Title or "Button"
		callback = opts.Callback
		order = opts.Order or order
		parent = opts.Parent or parent
	end
	local buttonObject = register(context, create("TextButton", {
		AutoButtonColor = false,
		BackgroundColor3 = theme.Accent,
		Text = title or "Button",
		TextColor3 = Color3.new(1, 1, 1),
		TextSize = 11,
		Font = theme.FontBold,
		Size = UDim2.new(1, 0, 0, 30),
		LayoutOrder = order or 0,
	}, parent))
	corner(buttonObject, theme.SmallCornerRadius)
	context.Animation.Ripple(buttonObject, Color3.new(1, 1, 1))
	context.Animation.BindHover(buttonObject, theme.Accent, theme.Accent, 0.12)
	buttonObject.MouseButton1Click:Connect(function()
		if callback then
			task.spawn(callback)
		end
	end)
	if opts and (opts.Tooltip or opts.Tip) then
		Components.BindTooltip(context, buttonObject, opts.Tooltip or opts.Tip)
	end
	local api = { Instance = buttonObject }
	function api:SetLabel(t) buttonObject.Text = t end
	function api:OnClick(cb) callback = cb end
	return api
end

function Components.Toggle(context, parent, title, description, defaultValue, callback, order)
	local theme = context.Theme
	local opts
	if type(parent) == "table" and title == nil then
		opts = parent
		parent = opts.Parent or nil
		title = opts.Name or opts.Title or "Toggle"
		description = opts.Description or opts.Subtitle
		defaultValue = opts.Default ~= nil and opts.Default or opts.Value
		callback = opts.Callback
		order = opts.Order
	end
	local rowHeight = description and 49 or 35
	local row = register(context, create("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, rowHeight),
		LayoutOrder = order or 0,
	}, parent))
	text(row, title or "Toggle", { Font = theme.FontBold, Size = 11, Height = 19 }, theme)
	if description then
		text(row, description, { Color = theme.TextMuted, Size = 10, Position = UDim2.fromOffset(0, 18), Height = 25, Wrapped = true }, theme)
	end
	local switch = create("TextButton", {
		AutoButtonColor = false,
		BackgroundColor3 = defaultValue and theme.Accent or theme.Border,
		Text = "",
		Size = UDim2.fromOffset(34, 19),
		Position = UDim2.new(1, -34, 0, 2),
	}, row)
	corner(switch, UDim.new(1, 0))
	local knob = create("Frame", {
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(15, 15),
		Position = defaultValue and UDim2.new(1, -17, 0, 2) or UDim2.fromOffset(2, 2),
	}, switch)
	corner(knob, UDim.new(1, 0))
	local value = defaultValue == true
	local api = { Instance = row }
	switch.MouseButton1Click:Connect(function()
		value = not value
		context.Animation.Tween(switch, { BackgroundColor3 = value and theme.Accent or theme.Border }, 0.16)
		context.Animation.Tween(knob, { Position = value and UDim2.new(1, -17, 0, 2) or UDim2.fromOffset(2, 2) }, 0.16, Enum.EasingStyle.Back)
		if callback then
			task.spawn(callback, value)
		end
		if context._config and context._config._onFlag then
			context._config._onFlag(api._flag, value)
		end
	end)
	function api:Set(nextValue)
		value = nextValue == true
		switch.BackgroundColor3 = value and theme.Accent or theme.Border
		knob.Position = value and UDim2.new(1, -17, 0, 2) or UDim2.fromOffset(2, 2)
	end
	function api:Get() return value end
	if opts and opts.Flag then
		api._flag = opts.Flag
		if context._config then
			context._config:_registerFlag(opts.Flag, api)
		end
	end
	if opts and (opts.Tooltip or opts.Tip) then
		Components.BindTooltip(context, row, opts.Tooltip or opts.Tip)
	end
	return api
end

function Components.Checkbox(context, parent, title, defaultValue, callback, order)
	local theme = context.Theme
	if type(parent) == "table" and title == nil then
		local o = parent
		parent = o.Parent or nil
		title, defaultValue, callback, order = o.Name or o.Title, o.Default, o.Callback, o.Order
	end
	local button = register(context, create("TextButton", {
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		Text = "",
		Size = UDim2.new(1, 0, 0, 25),
		LayoutOrder = order or 0,
	}, parent))
	local box = create("Frame", { BackgroundColor3 = defaultValue and theme.Accent or theme.Surface, Size = UDim2.fromOffset(16, 16), Position = UDim2.fromOffset(0, 4) }, button)
	corner(box, UDim.new(0, 4))
	stroke(box, defaultValue and theme.Accent or theme.Border)
	local mark = text(box, "✓", { Color = Color3.new(1, 1, 1), Font = theme.FontBold, Size = 12, XAlignment = Enum.TextXAlignment.Center, Size2 = UDim2.fromScale(1, 1) }, theme)
	text(button, title or "Checkbox", { Size = 11, Position = UDim2.fromOffset(25, 0), Height = 25 }, theme)
	local value = defaultValue == true
	mark.TextTransparency = value and 0 or 1
	button.MouseButton1Click:Connect(function()
		value = not value
		box.BackgroundColor3 = value and theme.Accent or theme.Surface
		box.UIStroke.Color = value and theme.Accent or theme.Border
		mark.TextTransparency = value and 0 or 1
		if callback then
			task.spawn(callback, value)
		end
	end)
	local api = { Instance = button }
	function api:Get() return value end
	function api:Set(v)
		value = v == true
		box.BackgroundColor3 = value and theme.Accent or theme.Surface
		mark.TextTransparency = value and 0 or 1
	end
	return api
end

function Components.Slider(context, parent, title, min, max, defaultValue, callback, order)
	local theme = context.Theme
	local opts
	if type(parent) == "table" and title == nil then
		opts = parent
		parent = opts.Parent or nil
		title = opts.Name or opts.Title or "Slider"
		min = opts.Min or 0
		max = opts.Max or 100
		defaultValue = opts.Default or opts.Value or min
		callback = opts.Callback
		order = opts.Order
	end
	min = min or 0
	max = max or 100
	if max <= min then
		max = min + 1
	end
	local value = math.clamp(defaultValue or min, min, max)
	local row = register(context, create("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 44),
		LayoutOrder = order or 0,
	}, parent))
	local titleLabel = text(row, title or "Slider", { Font = theme.FontBold, Size = 11, Height = 17 }, theme)
	local valueLabel = text(row, tostring(math.floor(value * 100) / 100), {
		Color = theme.TextMuted, Size = 10, Height = 17,
		XAlignment = Enum.TextXAlignment.Right,
		Size2 = UDim2.new(1, 0, 0, 17),
	}, theme)
	local track = create("TextButton", {
		AutoButtonColor = false,
		BackgroundColor3 = theme.SurfaceMuted,
		Text = "",
		Size = UDim2.new(1, 0, 0, 6),
		Position = UDim2.fromOffset(0, 28),
	}, row)
	corner(track, UDim.new(1, 0))
	local fill = create("Frame", {
		BackgroundColor3 = theme.Accent,
		BorderSizePixel = 0,
		Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
	}, track)
	corner(fill, UDim.new(1, 0))
	local knob = create("Frame", {
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromOffset(14, 14),
		Position = UDim2.new((value - min) / (max - min), 0, 0.5, 0),
		ZIndex = 2,
	}, track)
	corner(knob, UDim.new(1, 0))
	stroke(knob, theme.Border)
	local dragging = false
	local function applyFromX(x)
		local rel = math.clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
		value = min + (max - min) * rel
		value = math.floor(value * 100) / 100
		fill.Size = UDim2.new(rel, 0, 1, 0)
		knob.Position = UDim2.new(rel, 0, 0.5, 0)
		valueLabel.Text = tostring(value)
		if callback then
			task.spawn(callback, value)
		end
		if context._config and context._config._onFlag and opts and opts.Flag then
			context._config._onFlag(opts.Flag, value)
		end
	end
	track.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			applyFromX(input.Position.X)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if not dragging then
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			applyFromX(input.Position.X)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
	local api = { Instance = row }
	function api:Get() return value end
	function api:Set(v)
		value = math.clamp(v, min, max)
		local rel = (value - min) / (max - min)
		fill.Size = UDim2.new(rel, 0, 1, 0)
		knob.Position = UDim2.new(rel, 0, 0.5, 0)
		valueLabel.Text = tostring(value)
	end
	titleLabel:Destroy()
	if opts and opts.Flag then
		api._flag = opts.Flag
		if context._config then
			context._config:_registerFlag(opts.Flag, api)
		end
	end
	return api
end

function Components.Dropdown(context, parent, title, items, defaultValue, callback, order)
	local theme = context.Theme
	local opts
	if type(parent) == "table" and title == nil then
		opts = parent
		parent = opts.Parent or nil
		title = opts.Name or opts.Title or "Dropdown"
		items = opts.Options or opts.Items or {}
		defaultValue = opts.Default or opts.Value
		callback = opts.Callback
		order = opts.Order
	end
	items = items or {}
	local row = register(context, create("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 35),
		LayoutOrder = order or 0,
		ClipsDescendants = false,
	}, parent))
	row.ZIndex = 5
	text(row, title or "Dropdown", { Font = theme.FontBold, Size = 11, Height = 35, Size2 = UDim2.new(1, -120, 0, 35) }, theme)
	local box = create("TextButton", {
		AutoButtonColor = false,
		BackgroundColor3 = theme.SurfaceMuted,
		Text = "",
		Size = UDim2.new(0, 112, 0, 26),
		Position = UDim2.new(1, -112, 0, 4),
	}, row)
	corner(box, theme.SmallCornerRadius)
	local label = text(box, tostring(defaultValue or items[1] or "Select"), {
		Color = theme.TextMuted, Size = 10, Font = theme.FontBold,
		Position = UDim2.fromOffset(8, 0), Height = 26, Size2 = UDim2.new(1, -28, 0, 26),
	}, theme)
	text(box, "▾", { Color = theme.TextMuted, Size = 12, XAlignment = Enum.TextXAlignment.Right, Position = UDim2.new(1, -22, 0, 0), Height = 26, Size2 = UDim2.new(0, 16, 0, 26) }, theme)
	local list = create("Frame", {
		Visible = false,
		BackgroundColor3 = theme.Surface,
		Size = UDim2.new(0, 112, 0, math.min(#items * 26 + 8, 134)),
		Position = UDim2.new(1, -112, 0, 33),
		ZIndex = 20,
	}, row)
	corner(list, theme.SmallCornerRadius)
	stroke(list, theme.Border)
	create("UIPadding", {
		PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4),
		PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4),
	}, list)
	local layout = create("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder }, list)
	local value = defaultValue or items[1]
	local open = false
	local function setOpen(next)
		open = next
		list.Visible = next
		if next then
			context.Animation.Tween(list, {}, 0.01)
		end
	end
	box.MouseButton1Click:Connect(function() setOpen(not open) end)
	for i, item in ipairs(items) do
		local b = create("TextButton", {
			AutoButtonColor = false,
			BackgroundColor3 = theme.Surface,
			Text = tostring(item),
			TextColor3 = theme.Text,
			TextSize = 10,
			Font = theme.Font,
			Size = UDim2.new(1, 0, 0, 24),
			LayoutOrder = i,
			ZIndex = 21,
		}, list)
		corner(b, UDim.new(0, 5))
		b.MouseButton1Click:Connect(function()
			value = item
			label.Text = tostring(item)
			setOpen(false)
			if callback then
				task.spawn(callback, item)
			end
			if context._config and opts and opts.Flag then
				context._config._onFlag(opts.Flag, item)
			end
		end)
	end
	local api = { Instance = row }
	function api:Get() return value end
	function api:Set(v)
		value = v
		label.Text = tostring(v)
	end
	function api:SetOptions(next)
		items = next or {}
		for _, c in ipairs(list:GetChildren()) do
			if c:IsA("TextButton") then
				c:Destroy()
			end
		end
		list.Size = UDim2.new(0, 112, 0, math.min(#items * 26 + 8, 134))
		for i, item in ipairs(items) do
			local b = create("TextButton", {
				AutoButtonColor = false, BackgroundColor3 = theme.Surface,
				Text = tostring(item), TextColor3 = theme.Text, TextSize = 10,
				Font = theme.Font, Size = UDim2.new(1, 0, 0, 24), LayoutOrder = i, ZIndex = 21,
			}, list)
			corner(b, UDim.new(0, 5))
			local captured = item
			b.MouseButton1Click:Connect(function()
				value = captured
				label.Text = tostring(captured)
				setOpen(false)
				if callback then
					task.spawn(callback, captured)
				end
			end)
		end
	end
	if opts and opts.Flag then
		api._flag = opts.Flag
		if context._config then
			context._config:_registerFlag(opts.Flag, api)
		end
	end
	_ = layout
	return api
end

function Components.Textbox(context, parent, title, placeholder, defaultValue, callback, order)
	local theme = context.Theme
	local opts
	if type(parent) == "table" and title == nil then
		opts = parent
		parent = opts.Parent or nil
		title = opts.Name or opts.Title or "Input"
		placeholder = opts.Placeholder or ("Enter " .. string.lower(title))
		defaultValue = opts.Default or opts.Value or ""
		callback = opts.Callback
		order = opts.Order
	end
	local row = register(context, create("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 35),
		LayoutOrder = order or 0,
	}, parent))
	text(row, title or "Input", { Font = theme.FontBold, Size = 11, Height = 35, Size2 = UDim2.new(1, -130, 0, 35) }, theme)
	local box = create("TextBox", {
		BackgroundColor3 = theme.SurfaceMuted,
		Text = defaultValue or "",
		PlaceholderText = placeholder or "",
		TextColor3 = theme.Text,
		PlaceholderColor3 = theme.TextFaint,
		TextSize = 10,
		Font = theme.Font,
		ClearTextOnFocus = false,
		Size = UDim2.new(0, 122, 0, 26),
		Position = UDim2.new(1, -122, 0, 4),
	}, row)
	corner(box, theme.SmallCornerRadius)
	create("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) }, box)
	box.FocusLost:Connect(function(enter)
		if enter and callback then
			task.spawn(callback, box.Text)
		end
		if context._config and opts and opts.Flag then
			context._config._onFlag(opts.Flag, box.Text)
		end
	end)
	local api = { Instance = row, Box = box }
	function api:Get() return box.Text end
	function api:Set(v) box.Text = tostring(v or "") end
	if opts and opts.Flag then
		api._flag = opts.Flag
		if context._config then
			context._config:_registerFlag(opts.Flag, api)
		end
	end
	return api
end

function Components.Keybind(context, parent, label, defaultValue, callback, order)
	local theme = context.Theme
	if type(parent) == "table" and label == nil then
		local o = parent
		parent = o.Parent or nil
		label, defaultValue, callback, order = o.Name or o.Title, o.Default or o.Value, o.Callback, o.Order
	end
	local row = register(context, create("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 27),
		LayoutOrder = order or 0,
	}, parent))
	text(row, label or "Keybind", { Font = theme.FontBold, Size = 11, Height = 27 }, theme)
	local input = create("TextButton", {
		AutoButtonColor = false,
		BackgroundColor3 = theme.SurfaceMuted,
		Text = (type(defaultValue) == "string" and defaultValue) or (typeof(defaultValue) == "EnumItem" and defaultValue.Name) or "None",
		TextColor3 = theme.TextMuted,
		TextSize = 10,
		Font = theme.FontBold,
		Size = UDim2.fromOffset(58, 22),
		Position = UDim2.new(1, -58, 0, 2),
	}, row)
	corner(input, theme.SmallCornerRadius)
	local current = defaultValue
	input.MouseButton1Click:Connect(function()
		input.Text = "..."
		local connection
		connection = UserInputService.InputBegan:Connect(function(inputObject, processed)
			if processed then
				return
			end
			if inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
				return
			end
			if inputObject.KeyCode ~= Enum.KeyCode.Unknown then
				current = inputObject.KeyCode
				input.Text = inputObject.KeyCode.Name
				if callback then
					task.spawn(callback, inputObject.KeyCode)
				end
				connection:Disconnect()
			end
		end)
	end)
	local api = { Instance = row }
	function api:Get() return current end
	function api:Set(k)
		current = k
		input.Text = (typeof(k) == "EnumItem" and k.Name) or tostring(k)
	end
	return api
end

function Components.ColorPicker(context, parent, title, defaultValue, callback, order)
	local theme = context.Theme
	local opts
	if type(parent) == "table" and title == nil then
		opts = parent
		parent = opts.Parent or nil
		title = opts.Name or opts.Title or "Color"
		defaultValue = opts.Default or opts.Value or Color3.fromRGB(104, 67, 190)
		callback = opts.Callback
		order = opts.Order
	end
	defaultValue = typeof(defaultValue) == "Color3" and defaultValue or Color3.fromRGB(104, 67, 190)
	local row = register(context, create("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 35),
		LayoutOrder = order or 0,
	}, parent))
	text(row, title or "Color", { Font = theme.FontBold, Size = 11, Height = 35, Size2 = UDim2.new(1, -60, 0, 35) }, theme)
	local preview = create("TextButton", {
		AutoButtonColor = false,
		BackgroundColor3 = defaultValue,
		Text = "",
		Size = UDim2.fromOffset(52, 22),
		Position = UDim2.new(1, -52, 0, 6),
	}, row)
	corner(preview, UDim.new(0, 6))
	stroke(preview, theme.Border)
	local value = defaultValue
	local expanded, picker
	preview.MouseButton1Click:Connect(function()
		if expanded and picker then
			expanded = false
			picker:Destroy()
			picker = nil
			return
		end
		expanded = true
		picker = create("Frame", {
			BackgroundColor3 = theme.Surface,
			Size = UDim2.new(1, 0, 0, 96),
			LayoutOrder = 999,
		}, row.Parent)
		corner(picker, theme.SmallCornerRadius)
		stroke(picker, theme.Border)
		create("UIPadding", {
			PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10),
			PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8),
		}, picker)
		local channels = { { "R", value.R }, { "G", value.G }, { "B", value.B } }
		local rgb = { value.R, value.G, value.B }
		for i, ch in ipairs(channels) do
			local line = create("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 22) }, picker)
			create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 6) }, line)
			text(line, ch[1], { Font = theme.FontBold, Size = 10, Size2 = UDim2.fromOffset(12, 22) }, theme)
			local bar = create("TextButton", { AutoButtonColor = false, BackgroundColor3 = theme.SurfaceMuted, Text = "", Size = UDim2.new(1, -20, 0, 8) }, line)
			corner(bar, UDim.new(1, 0))
			local idx = i
			local dot = create("Frame", {
				BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Size = UDim2.fromOffset(12, 12), Position = UDim2.new(rgb[idx], 0, 0.5, 0),
			}, bar)
			corner(dot, UDim.new(1, 0))
			bar.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					local rel = math.clamp((input.Position.X - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1), 0, 1)
					rgb[idx] = rel
					dot.Position = UDim2.new(rel, 0, 0.5, 0)
					value = Color3.new(rgb[1], rgb[2], rgb[3])
					preview.BackgroundColor3 = value
					if callback then
						task.spawn(callback, value)
					end
				end
			end)
		end
	end)
	local api = { Instance = row }
	function api:Get() return value end
	function api:Set(c)
		value = c
		preview.BackgroundColor3 = c
	end
	if opts and opts.Flag then
		api._flag = opts.Flag
		if context._config then
			context._config:_registerFlag(opts.Flag, api)
		end
	end
	return api
end

function Components.FeatureCard(context, parent, title, description, keybind, defaultValue, callback, order)
	local theme = context.Theme
	if type(parent) == "table" and title == nil then
		local o = parent
		parent, title, description, keybind, defaultValue, callback, order =
			nil, o.Name or o.Title, o.Description, o.Keybind or o.Key, o.Default or o.Value, o.Callback, o.Order
	end
	local card = register(context, create("Frame", {
		BackgroundColor3 = theme.Surface,
		Size = UDim2.new(1, 0, 0, 57),
		LayoutOrder = order or 0,
	}, parent))
	corner(card, theme.SmallCornerRadius)
	stroke(card, theme.Border, 0.4)
	text(card, title or "Feature", { Font = theme.FontBold, Size = 11, Position = UDim2.fromOffset(10, 5), Height = 17, Size2 = UDim2.new(1, -90, 0, 17) }, theme)
	text(card, description or "", { Color = theme.TextMuted, Size = 9, Position = UDim2.fromOffset(10, 23), Height = 27, Wrapped = true, Size2 = UDim2.new(1, -90, 0, 27) }, theme)
	if keybind then
		local chip = create("TextLabel", { BackgroundColor3 = theme.SurfaceMuted, Text = tostring(keybind), TextColor3 = theme.TextMuted, TextSize = 9, Font = theme.FontBold, Size = UDim2.fromOffset(31, 16), Position = UDim2.new(1, -73, 0, 7) }, card)
		corner(chip, UDim.new(0, 5))
	end
	local toggle = Components.Toggle(context, card, "", nil, defaultValue, callback)
	toggle.Instance.Size = UDim2.fromOffset(34, 22)
	toggle.Instance.Position = UDim2.new(1, -44, 0, 28)
	return card
end

function Components.Column(context, parent, width, order)
	local column = register(context, create("ScrollingFrame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(width or (1 / 3), -8, 1, 0),
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = context.Theme.Border,
		LayoutOrder = order or 0,
	}, parent))
	create("UIPadding", { PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6), PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5) }, column)
	create("UIListLayout", { Padding = UDim.new(0, 7), SortOrder = Enum.SortOrder.LayoutOrder }, column)
	return column
end

_G.__DL_Components = Components
end
local Components = _G.__DL_Components
-- DevampedLib Library module
-- API:
--   local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/revampedbyvamp/devamped-Lib/main/Dist/DevampedLib.lua"))()
--   local Window = Library:CreateWindow({ Title = "My Hub", Theme = "Dark" })
--   local Tab = Window:CreateTab({ Name = "Main" })
--   Tab:CreateButton({ Name = "Click Me", Callback = function() end })

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")


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
			local raw = (type(instance) == "table" and instance.Instance) or instance
			tab._searchables[#tab._searchables + 1] = { Name = name, Instance = raw }
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
