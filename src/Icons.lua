-- DevampedLib Icons module
-- Lucide glyphs served from public Roblox atlas sheets. Rects verified
-- against each sheet's thumbnail (glyph renders white on transparency,
-- tint it with ImageColor3). Rect data layout matches the public
-- Rayfield icons.lua atlas, which these sheets belong to.
-- Usage: Icons.Apply(imageLabel, "crosshair", theme.TextMuted)

local Icons = {}

-- name -> { imageAssetId, rectX, rectY, cellSize }
Icons.Map = {
	["crosshair"] = { 16898668482, 514, 257, 256 },
	["person-standing"] = { 16898731539, 257, 257 },
	["shield"] = { 16898734664, 257, 0 },
	["eye"] = { 16898669897, 0, 0 },
	["layout-grid"] = { 16898674182, 514, 0 },
	["settings"] = { 16898734421, 514, 0 },
	["shopping-cart"] = { 16898734664, 257, 514 },
	["cookie"] = { 16898619423, 0, 0 },
	["search"] = { 16898734242, 257, 0 },
	["chevron-down"] = { 16898617411, 257, 0 },
	["check"] = { 16898612819, 710, 869, 48 },
	["x"] = { 16898791349, 257, 0 },
	["minus"] = { 16898728878, 514, 0 },
	["circle"] = { 16898618049, 257, 514 },
	["zap"] = { 16898791349, 257, 257 },
	["target"] = { 16898788248, 257, 0 },
	["user"] = { 16898790259, 0, 0 },
	["wrench"] = { 16898791187, 514, 257 },
}

-- default sidebar glyph per tab name (lowercase lookup)
Icons.TabDefaults = {
	rage = "crosshair",
	antiaim = "person-standing",
	legit = "shield",
	visuals = "eye",
	misc = "layout-grid",
	settings = "settings",
}

function Icons.Resolve(name)
	local entry = Icons.Map[name]
	if not entry then
		return nil
	end
	local size = entry[4] or 256
	return ("rbxassetid://%d"):format(entry[1]),
		Vector2.new(entry[2], entry[3]),
		Vector2.new(size, size)
end

-- Applies a glyph to an ImageLabel. Accepts an Icons key or a raw
-- rbxassetid string (used as-is, full image, no rect).
function Icons.Apply(imageLabel, name, tint)
	if typeof(imageLabel) ~= "Instance" or not imageLabel:IsA("ImageLabel") then
		return false
	end
	if type(name) == "string" and string.sub(name, 1, 11) == "rbxassetid://" then
		imageLabel.Image = name
		imageLabel.ImageRectOffset = Vector2.new(0, 0)
		imageLabel.ImageRectSize = Vector2.new(0, 0)
		imageLabel.ScaleType = Enum.ScaleType.Fit
		imageLabel.BackgroundTransparency = 1
		if tint then
			imageLabel.ImageColor3 = tint
		end
		return true
	end
	local image, offset, size = Icons.Resolve(name)
	if not image then
		return false
	end
	imageLabel.Image = image
	imageLabel.ImageRectOffset = offset
	imageLabel.ImageRectSize = size
	imageLabel.ScaleType = Enum.ScaleType.Fit
	imageLabel.BackgroundTransparency = 1
	if tint then
		imageLabel.ImageColor3 = tint
	end
	return true
end

function Icons.ForTab(tabName, custom)
	if custom and (Icons.Map[custom] or string.sub(custom, 1, 11) == "rbxassetid://") then
		return custom
	end
	return Icons.TabDefaults[string.lower(tabName or "")] or "circle"
end

return Icons
