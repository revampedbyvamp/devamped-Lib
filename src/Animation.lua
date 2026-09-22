-- DevampedLib Animation module
-- Tween helpers, hover, press, fade, slide, ripple. Never errors when instance is destroyed.

local TweenService = game:GetService("TweenService")

local Animation = {}

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

return Animation
