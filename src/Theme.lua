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

return Theme
