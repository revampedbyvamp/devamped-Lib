-- DevampedLib Components module
-- Buttons, toggles, sliders, dropdowns, textboxes, keybinds, color pickers,
-- labels, sections, columns, tooltips. All scale-based and touch friendly.

local UserInputService = game:GetService("UserInputService")

local Components = {}

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

return Components
