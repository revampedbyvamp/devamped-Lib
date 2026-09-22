-- DevampedLib Theme module
-- Default look: dark "luminate" style (near-black window, sidebar nav,
-- gray panels, monochrome controls). Light/Dark kept for compatibility.
-- Theme.Create accepts a theme name ("Luminate"|"Light"|"Dark") or a table.

local Theme = {}

local function pickFont(...)
	local byName = {}
	pcall(function()
		for _, e in ipairs(Enum.Font:GetEnumItems()) do
			byName[e.Name] = e
		end
	end)
	for _, name in ipairs({ ... }) do
		if byName[name] then
			return byName[name]
		end
	end
	return Enum.Font.Gotham
end

local BodyFont = pickFont("MontserratMedium", "GothamMedium", "Gotham")
local BoldFont = pickFont("MontserratBold", "GothamBold", "Gotham")

Theme.Luminate = {
	Name = "Luminate",
	Accent = Color3.fromRGB(255, 255, 255),
	AccentSoft = Color3.fromRGB(52, 52, 58),
	Background = Color3.fromRGB(13, 13, 15),
	Surface = Color3.fromRGB(28, 28, 31),
	SurfaceMuted = Color3.fromRGB(42, 42, 47),
	Sidebar = Color3.fromRGB(22, 22, 25),
	SidebarAlt = Color3.fromRGB(32, 32, 37),
	Border = Color3.fromRGB(46, 46, 52),
	Text = Color3.fromRGB(242, 242, 245),
	TextMuted = Color3.fromRGB(154, 154, 161),
	TextFaint = Color3.fromRGB(107, 107, 114),
	Success = Color3.fromRGB(74, 200, 128),
	Danger = Color3.fromRGB(240, 90, 105),
	Shadow = Color3.fromRGB(0, 0, 0),
	Font = BodyFont,
	FontBold = BoldFont,
	CornerRadius = UDim.new(0, 8),
	SmallCornerRadius = UDim.new(0, 6),
}

Theme.Light = {
	Name = "Lavender Light",
	Accent = Color3.fromRGB(104, 67, 190),
	AccentSoft = Color3.fromRGB(235, 228, 251),
	Background = Color3.fromRGB(249, 249, 251),
	Surface = Color3.fromRGB(255, 255, 255),
	SurfaceMuted = Color3.fromRGB(244, 244, 247),
	Sidebar = Color3.fromRGB(240, 240, 244),
	SidebarAlt = Color3.fromRGB(232, 232, 237),
	Border = Color3.fromRGB(229, 229, 234),
	Text = Color3.fromRGB(31, 31, 36),
	TextMuted = Color3.fromRGB(117, 117, 127),
	TextFaint = Color3.fromRGB(166, 166, 175),
	Success = Color3.fromRGB(57, 164, 103),
	Danger = Color3.fromRGB(214, 75, 91),
	Shadow = Color3.fromRGB(30, 22, 56),
	Font = BodyFont,
	FontBold = BoldFont,
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
	Sidebar = Color3.fromRGB(20, 20, 26),
	SidebarAlt = Color3.fromRGB(30, 30, 38),
	Border = Color3.fromRGB(52, 52, 66),
	Text = Color3.fromRGB(240, 240, 245),
	TextMuted = Color3.fromRGB(160, 160, 175),
	TextFaint = Color3.fromRGB(110, 110, 125),
	Success = Color3.fromRGB(74, 200, 128),
	Danger = Color3.fromRGB(240, 90, 105),
	Shadow = Color3.fromRGB(0, 0, 0),
	Font = BodyFont,
	FontBold = BoldFont,
	CornerRadius = UDim.new(0, 12),
	SmallCornerRadius = UDim.new(0, 8),
}

Theme.Default = Theme.Luminate
Theme.Themes = { Luminate = Theme.Luminate, Light = Theme.Light, Dark = Theme.Dark }

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
