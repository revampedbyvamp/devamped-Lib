-- DevampedLib Components module
-- Monochrome "luminate" styling: square checkboxes, thin sliders,
-- combo fields with white-highlight dropdowns, full-width buttons.
-- Scale-based sizes, touch friendly.

local UserInputService = game:GetService("UserInputService")

local Components = {}

-- Icons is shared via _G in the single-file bundle, otherwise required.
local Icons = _G.__DL_Icons
if not Icons then
	pcall(function()
		Icons = require(script.Parent.Icons)
	end)
end

local function create(className, properties, parent)
	local object = Instance.new(className)
	for key, value in pairs(properties or {}) do
		pcall(function() object[key] = value end)
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

local function register(context, object)
	context._objects = context._objects or {}
	context._objects[#context._objects + 1] = object
	return object
end

local function normArgs(first, second)
	if type(first) == "table" and (second == nil or type(second) ~= "Instance") then
		return nil, first
	end
	return first, second
end

function Components.Tooltip(context, parent, tipText)
	local theme = context.Theme
	local tip = create("TextLabel", {
		Visible = false,
		BackgroundColor3 = Color3.fromRGB(10, 10, 12),
		TextColor3 = Color3.fromRGB(240, 240, 245),
		Text = tipText or "",
		TextSize = 10,
		Font = theme.Font,
		TextWrapped = true,
		AutomaticSize = Enum.AutomaticSize.XY,
		Size = UDim2.fromOffset(10, 10),
		ZIndex = 100,
	}, parent)
	corner(tip, UDim.new(0, 6))
	stroke(tip, theme.Border)
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
	local tip = Components.Tooltip(context, layer or hoverObject.Parent, tipText)
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

-- Panel card (the gray boxes in the reference). Optional small header.
function Components.Groupbox(context, parent, title, order)
	local theme = context.Theme
	local opts
	parent, opts = normArgs(parent, title)
	if opts then
		title = opts.Title or opts.Name
		order = opts.Order or order
		parent = opts.Parent or parent
	end
	local panel = register(context, create("Frame", {
		BackgroundColor3 = theme.Surface,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = order or 0,
		ClipsDescendants = false,
	}, parent))
	corner(panel, theme.CornerRadius)
	stroke(panel, theme.Border, 0.55)
	create("UIPadding", {
		PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12),
		PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10),
	}, panel)
	create("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }, panel)
	if title and title ~= "" then
		text(panel, title, { Font = theme.FontBold, Size = 11, Height = 18, LayoutOrder = -1 }, theme)
	end
	return panel
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
		Size = UDim2.new(1, 0, 0, subtitle and 38 or 24),
	}, parent))
	text(frame, title or "Section", { Font = theme.FontBold, Size = 12, Height = 18 }, theme)
	if subtitle then
		text(frame, subtitle, { Color = theme.TextMuted, Size = 10, Position = UDim2.fromOffset(0, 18), Height = 16 }, theme)
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
		Size = UDim2.new(1, 0, 0, value and 34 or 20),
		LayoutOrder = order or 0,
	}, parent))
	text(row, title or "", { Font = theme.FontBold, Size = 11, Height = 16 }, theme)
	if value then
		text(row, value, { Color = theme.TextMuted, Size = 10, Position = UDim2.fromOffset(0, 16), Height = 15 }, theme)
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
		BackgroundColor3 = theme.SurfaceMuted,
		Text = title or "Button",
		TextColor3 = theme.TextMuted,
		TextSize = 12,
		Font = theme.Font,
		Size = UDim2.new(1, 0, 0, 28),
		LayoutOrder = order or 0,
	}, parent))
	corner(buttonObject, theme.SmallCornerRadius)
	context.Animation.Ripple(buttonObject, Color3.new(1, 1, 1))
	context.Animation.BindHover(buttonObject, theme.SurfaceMuted, theme.AccentSoft, 0.12)
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
	local rowHeight = description and 44 or 32
	local row = register(context, create("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, rowHeight),
		LayoutOrder = order or 0,
	}, parent))
	text(row, title or "Toggle", { Font = theme.Font, Size = 11, Height = 17 }, theme)
	if description then
		text(row, description, { Color = theme.TextMuted, Size = 10, Position = UDim2.fromOffset(0, 16), Height = 24, Wrapped = true }, theme)
	end
	local switch = create("TextButton", {
		AutoButtonColor = false,
		BackgroundColor3 = theme.SurfaceMuted,
		Text = "",
		Size = UDim2.fromOffset(32, 18),
		Position = UDim2.new(1, -32, 0, 2),
	}, row)
	corner(switch, UDim.new(1, 0))
	local knob = create("Frame", {
		BackgroundColor3 = defaultValue and Color3.new(1, 1, 1) or theme.TextFaint,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(12, 12),
		Position = defaultValue and UDim2.new(1, -15, 0, 3) or UDim2.fromOffset(3, 3),
	}, switch)
	corner(knob, UDim.new(1, 0))
	local value = defaultValue == true
	local api = { Instance = row }
	switch.MouseButton1Click:Connect(function()
		value = not value
		context.Animation.Tween(knob, {
			Position = value and UDim2.new(1, -15, 0, 3) or UDim2.fromOffset(3, 3),
			BackgroundColor3 = value and Color3.new(1, 1, 1) or theme.TextFaint,
		}, 0.16, Enum.EasingStyle.Back)
		if callback then
			task.spawn(callback, value)
		end
		if context._config and context._config._onFlag then
			context._config._onFlag(api._flag, value)
		end
	end)
	function api:Set(nextValue)
		value = nextValue == true
		knob.BackgroundColor3 = value and Color3.new(1, 1, 1) or theme.TextFaint
		knob.Position = value and UDim2.new(1, -15, 0, 3) or UDim2.fromOffset(3, 3)
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
		Size = UDim2.new(1, 0, 0, 24),
		LayoutOrder = order or 0,
	}, parent))
	local box = create("Frame", {
		BackgroundColor3 = theme.SurfaceMuted,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(14, 14),
		Position = UDim2.fromOffset(0, 5),
	}, button)
	corner(box, UDim.new(0, 4))
	local mark = create("ImageLabel", {
		BackgroundTransparency = 1,
		Image = (Icons and Icons.Resolve("check")) or "",
		ImageColor3 = Color3.fromRGB(10, 10, 12),
		ScaleType = Enum.ScaleType.Fit,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromOffset(10, 10),
		Position = UDim2.fromScale(0.5, 0.5),
	}, box)
	if Icons then
		Icons.Apply(mark, "check", Color3.fromRGB(10, 10, 12))
	else
		mark:Destroy()
		mark = text(box, "✓", {
			Color = Color3.fromRGB(10, 10, 12), Font = theme.FontBold, Size = 11,
			XAlignment = Enum.TextXAlignment.Center, Size2 = UDim2.fromScale(1, 1),
		}, theme)
	end
	text(button, title or "Checkbox", {
		Color = theme.TextMuted, Size = 11,
		Position = UDim2.fromOffset(22, 0), Height = 24,
		Size2 = UDim2.new(1, -22, 0, 24),
	}, theme)
	local value = defaultValue == true
	local markIsImage = mark:IsA("ImageLabel")
	local function paint()
		box.BackgroundColor3 = value and Color3.new(1, 1, 1) or theme.SurfaceMuted
		if markIsImage then
			mark.ImageTransparency = value and 0 or 1
		else
			mark.TextTransparency = value and 0 or 1
		end
	end
	paint()
	button.MouseButton1Click:Connect(function()
		value = not value
		paint()
		if callback then
			task.spawn(callback, value)
		end
	end)
	local api = { Instance = button }
	function api:Get() return value end
	function api:Set(v) value = v == true paint() end
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
		Size = UDim2.new(1, 0, 0, 40),
		LayoutOrder = order or 0,
	}, parent))
	text(row, title or "Slider", { Color = theme.TextMuted, Font = theme.Font, Size = 11, Height = 16 }, theme)
	local valueLabel = text(row, tostring(math.floor(value * 100) / 100), {
		Color = theme.TextMuted, Size = 11, Height = 16,
		XAlignment = Enum.TextXAlignment.Right,
		Size2 = UDim2.new(1, 0, 0, 16),
	}, theme)
	local track = create("TextButton", {
		AutoButtonColor = false,
		BackgroundColor3 = theme.SurfaceMuted,
		Text = "",
		Size = UDim2.new(1, 0, 0, 5),
		Position = UDim2.fromOffset(0, 26),
	}, row)
	corner(track, UDim.new(1, 0))
	local fill = create("Frame", {
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
	}, track)
	corner(fill, UDim.new(1, 0))
	local knob = create("Frame", {
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromOffset(10, 14),
		Position = UDim2.new((value - min) / (max - min), 0, 0.5, 0),
		ZIndex = 2,
	}, track)
	corner(knob, UDim.new(0, 4))
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
		title = opts.Name or opts.Title or "Combo"
		items = opts.Options or opts.Items or {}
		defaultValue = opts.Default or opts.Value
		callback = opts.Callback
		order = opts.Order
	end
	items = items or {}
	local row = register(context, create("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 48),
		LayoutOrder = order or 0,
		ClipsDescendants = false,
	}, parent))
	row.ZIndex = 5
	text(row, title or "Combo", { Color = theme.TextMuted, Font = theme.Font, Size = 11, Height = 16 }, theme)
	local box = create("TextButton", {
		AutoButtonColor = false,
		BackgroundColor3 = theme.SurfaceMuted,
		Text = "",
		Size = UDim2.new(1, 0, 0, 26),
		Position = UDim2.fromOffset(0, 20),
	}, row)
	corner(box, theme.SmallCornerRadius)
	local label = text(box, tostring(defaultValue or items[1] or "Select"), {
		Color = theme.TextMuted, Size = 11, Font = theme.Font,
		Position = UDim2.fromOffset(10, 0), Height = 26,
		Size2 = UDim2.new(1, -38, 0, 26),
	}, theme)
	local chevron = create("ImageLabel", {
		BackgroundTransparency = 1,
		Image = (Icons and Icons.Resolve("chevron-down")) or "",
		ImageColor3 = theme.TextMuted,
		ScaleType = Enum.ScaleType.Fit,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromOffset(13, 13),
		Position = UDim2.new(1, -17, 0.5, 0),
	}, box)
	if Icons then
		Icons.Apply(chevron, "chevron-down", theme.TextMuted)
	else
		chevron:Destroy()
		chevron = text(box, "∨", {
			Color = theme.TextMuted, Size = 12,
			XAlignment = Enum.TextXAlignment.Right,
			Position = UDim2.new(1, -26, 0, 0), Height = 26,
			Size2 = UDim2.new(0, 16, 0, 26),
		}, theme)
	end
	local list = create("Frame", {
		Visible = false,
		BackgroundColor3 = theme.SurfaceMuted,
		Size = UDim2.new(1, 0, 0, math.min(#items * 28 + 10, 122)),
		Position = UDim2.fromOffset(0, 50),
		ZIndex = 20,
	}, row)
	corner(list, theme.SmallCornerRadius)
	stroke(list, theme.Border)
	create("UIPadding", {
		PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 5),
		PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5),
	}, list)
	create("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder }, list)
	local value = defaultValue or items[1]
	local open = false
	local itemButtons = {}
	local function paint()
		for itemName, b in pairs(itemButtons) do
			local selected = itemName == value
			b.BackgroundColor3 = selected and Color3.new(1, 1, 1) or theme.SurfaceMuted
			b.TextColor3 = selected and Color3.fromRGB(10, 10, 12) or theme.TextMuted
		end
	end
	local function setOpen(next)
		open = next
		list.Visible = next
		if chevron:IsA("ImageLabel") then
			chevron.Rotation = next and 180 or 0
		end
		if next then
			paint()
		end
	end
	local function buildList(nextItems)
		for _, c in ipairs(list:GetChildren()) do
			if c:IsA("TextButton") then
				c:Destroy()
			end
		end
		table.clear(itemButtons)
		list.Size = UDim2.new(1, 0, 0, math.min(#nextItems * 28 + 10, 122))
		for i, item in ipairs(nextItems) do
			local b = create("TextButton", {
				AutoButtonColor = false,
				BackgroundColor3 = theme.SurfaceMuted,
				Text = tostring(item),
				TextColor3 = theme.TextMuted,
				TextSize = 11,
				Font = theme.Font,
				TextXAlignment = Enum.TextXAlignment.Left,
				Size = UDim2.new(1, 0, 0, 26),
				LayoutOrder = i,
				ZIndex = 21,
			}, list)
			corner(b, UDim.new(0, 5))
			create("UIPadding", { PaddingLeft = UDim.new(0, 10) }, b)
			local captured = item
			b.MouseButton1Click:Connect(function()
				value = captured
				label.Text = tostring(captured)
				setOpen(false)
				paint()
				if callback then
					task.spawn(callback, captured)
				end
				if context._config and opts and opts.Flag then
					context._config._onFlag(opts.Flag, captured)
				end
			end)
			itemButtons[item] = b
		end
		paint()
	end
	box.MouseButton1Click:Connect(function() setOpen(not open) end)
	buildList(items)
	local api = { Instance = row }
	function api:Get() return value end
	function api:Set(v)
		value = v
		label.Text = tostring(v)
		paint()
	end
	function api:SetOptions(next)
		items = next or {}
		if not value or not table.find(items, value) then
			value = items[1]
			label.Text = tostring(value or "Select")
		end
		buildList(items)
	end
	if opts and opts.Flag then
		api._flag = opts.Flag
		if context._config then
			context._config:_registerFlag(opts.Flag, api)
		end
	end
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
		Size = UDim2.new(1, 0, 0, 48),
		LayoutOrder = order or 0,
	}, parent))
	text(row, title or "Input", { Color = theme.TextMuted, Font = theme.Font, Size = 11, Height = 16 }, theme)
	local box = create("TextBox", {
		BackgroundColor3 = theme.SurfaceMuted,
		Text = defaultValue or "",
		PlaceholderText = placeholder or "",
		TextColor3 = theme.Text,
		PlaceholderColor3 = theme.TextFaint,
		TextSize = 11,
		Font = theme.Font,
		ClearTextOnFocus = false,
		Size = UDim2.new(1, 0, 0, 26),
		Position = UDim2.fromOffset(0, 20),
	}, row)
	corner(box, theme.SmallCornerRadius)
	create("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) }, box)
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
		Size = UDim2.new(1, 0, 0, 26),
		LayoutOrder = order or 0,
	}, parent))
	text(row, label or "Keybind", { Color = theme.TextMuted, Font = theme.Font, Size = 11, Height = 26, Size2 = UDim2.new(1, -70, 0, 26) }, theme)
	local input = create("TextButton", {
		AutoButtonColor = false,
		BackgroundColor3 = theme.SurfaceMuted,
		Text = (type(defaultValue) == "string" and defaultValue) or (typeof(defaultValue) == "EnumItem" and defaultValue.Name) or "None",
		TextColor3 = theme.TextMuted,
		TextSize = 10,
		Font = theme.Font,
		Size = UDim2.fromOffset(58, 20),
		Position = UDim2.new(1, -58, 0, 3),
	}, row)
	corner(input, UDim.new(0, 5))
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
		defaultValue = opts.Default or opts.Value or Color3.fromRGB(255, 255, 255)
		callback = opts.Callback
		order = opts.Order
	end
	defaultValue = typeof(defaultValue) == "Color3" and defaultValue or Color3.fromRGB(255, 255, 255)
	local row = register(context, create("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 26),
		LayoutOrder = order or 0,
	}, parent))
	text(row, title or "Color", { Color = theme.TextMuted, Font = theme.Font, Size = 11, Height = 26, Size2 = UDim2.new(1, -40, 0, 26) }, theme)
	local preview = create("TextButton", {
		AutoButtonColor = false,
		BackgroundColor3 = defaultValue,
		Text = "",
		Size = UDim2.fromOffset(22, 16),
		Position = UDim2.new(1, -22, 0, 5),
	}, row)
	corner(preview, UDim.new(0, 4))
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
			BackgroundColor3 = theme.SurfaceMuted,
			Size = UDim2.new(1, 0, 0, 92),
			LayoutOrder = 999,
			ZIndex = 15,
		}, row.Parent)
		corner(picker, theme.SmallCornerRadius)
		stroke(picker, theme.Border)
		create("UIPadding", {
			PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10),
			PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8),
		}, picker)
		create("UIListLayout", { Padding = UDim.new(0, 4) }, picker)
		local rgb = { value.R, value.G, value.B }
		for i, name in ipairs({ "R", "G", "B" }) do
			local line = create("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20) }, picker)
			create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 6) }, line)
			text(line, name, { Color = theme.TextMuted, Font = theme.Font, Size = 10, Size2 = UDim2.fromOffset(12, 20) }, theme)
			local bar = create("TextButton", { AutoButtonColor = false, BackgroundColor3 = theme.Background, Text = "", Size = UDim2.new(1, -18, 0, 8) }, line)
			corner(bar, UDim.new(1, 0))
			local idx = i
			local dot = create("Frame", {
				BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Size = UDim2.fromOffset(10, 12), Position = UDim2.new(rgb[idx], 0, 0.5, 0),
			}, bar)
			corner(dot, UDim.new(0, 4))
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
		parent = o.Parent or nil
		title, description, keybind, defaultValue, callback, order =
			o.Name or o.Title, o.Description, o.Keybind or o.Key, o.Default or o.Value, o.Callback, o.Order
	end
	local card = register(context, create("Frame", {
		BackgroundColor3 = theme.SurfaceMuted,
		Size = UDim2.new(1, 0, 0, 54),
		LayoutOrder = order or 0,
	}, parent))
	corner(card, theme.SmallCornerRadius)
	text(card, title or "Feature", { Font = theme.Font, Size = 11, Position = UDim2.fromOffset(10, 5), Height = 16, Size2 = UDim2.new(1, -80, 0, 16) }, theme)
	text(card, description or "", { Color = theme.TextMuted, Size = 9, Position = UDim2.fromOffset(10, 22), Height = 25, Wrapped = true, Size2 = UDim2.new(1, -80, 0, 25) }, theme)
	if keybind then
		local chip = create("TextLabel", { BackgroundColor3 = theme.Background, Text = tostring(keybind), TextColor3 = theme.TextMuted, TextSize = 9, Font = theme.Font, Size = UDim2.fromOffset(30, 15), Position = UDim2.new(1, -68, 0, 6) }, card)
		corner(chip, UDim.new(0, 4))
	end
	local toggle = Components.Toggle(context, card, "", nil, defaultValue, callback)
	toggle.Instance.Size = UDim2.fromOffset(32, 20)
	toggle.Instance.Position = UDim2.new(1, -40, 0, 26)
	toggle.Instance.BackgroundTransparency = 1
	return card
end

function Components.Column(context, parent, width, order)
	local column = register(context, create("ScrollingFrame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(width or (1 / 3), -8, 1, 0),
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 0,
		LayoutOrder = order or 0,
	}, parent))
	create("UIPadding", { PaddingLeft = UDim.new(0, 2), PaddingRight = UDim.new(0, 2), PaddingTop = UDim.new(0, 2), PaddingBottom = UDim.new(0, 2) }, column)
	create("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }, column)
	return column
end

return Components
