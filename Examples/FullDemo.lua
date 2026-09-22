-- ============================================
-- DevampedLib Demo ("luminate" look)
-- Sidebar nav + gray panels, like the reference.
--
-- Executor:
--   local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/revampedbyvamp/devamped-Lib/main/Dist/DevampedLib.lua"))()
-- Studio (src/ under ReplicatedStorage as "DevampedLib"):
--   local Library = require(game.ReplicatedStorage.DevampedLib.Init)
-- ============================================

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/revampedbyvamp/devamped-Lib/main/Dist/DevampedLib.lua"))()
-- local Library = require(game.ReplicatedStorage.DevampedLib.Init)

local Window = Library:CreateWindow({
	Title = "luminate",
	Footer = "luminate.pw",
	ToggleKey = Enum.KeyCode.RightShift,
	-- Search = true, -- opt-in filter box at the top of the content area
})

-- Sidebar tabs with real Lucide image icons.
-- rage/antiaim/legit/visuals/misc/settings map automatically;
-- pass any Icons key (or raw rbxassetid) via Icon = "..." to override.
local rage = Window:CreateTab({ Name = "rage" })
local antiaim = Window:CreateTab({ Name = "antiaim" })
local legit = Window:CreateTab({ Name = "legit" })
local visuals = Window:CreateTab({ Name = "visuals" })
local misc = Window:CreateTab({ Name = "misc", Icon = "zap" })
local settings = Window:CreateTab({ Name = "settings" })

-- RAGE: mirrors the reference panel (checkboxes, slider, combo, button)
local left = rage:CreatePanel({ Parent = rage:CreateColumn(0.5) })
rage:CreatePanel({ Parent = rage:CreateColumn(0.5) }) -- empty right card, like the reference

left:CreateCheckbox({ Name = "Checkbox", Default = false, Callback = function(v) print("checkbox:", v) end })
left:CreateCheckbox({ Name = "Checkboxx", Default = false, Callback = function(v) print("checkboxx:", v) end })

left:CreateSlider({
	Name = "Slider",
	Min = 0,
	Max = 100,
	Default = 0,
	Flag = "slider",
	Callback = function(v) print("slider:", v) end,
})

left:CreateDropdown({
	Name = "Combo",
	Options = { "Item1", "Item2", "Item3" },
	Default = "Item1",
	Flag = "combo",
	Callback = function(v)
		Window:Notify({ Title = "Combo", Content = "Picked " .. tostring(v), Duration = 2 })
	end,
})

left:CreateButton({
	Name = "Button",
	Callback = function()
		Window:Notify({ Title = "luminate", Content = "Button pressed", Duration = 2 })
	end,
})

-- Other tabs: a couple of controls each so every page has content
antiaim:CreatePanel():CreateToggle({
	Name = "Enabled",
	Description = "Master switch",
	Default = false,
	Flag = "aa_enabled",
	Callback = function(v) print("antiaim:", v) end,
})

legit:CreatePanel():CreateSlider({
	Name = "Smoothing",
	Min = 1,
	Max = 20,
	Default = 5,
	Flag = "smooth",
	Callback = function(v) print("smooth:", v) end,
})

visuals:CreatePanel():CreateColorPicker({
	Name = "Accent",
	Default = Color3.fromRGB(255, 255, 255),
	Callback = function(c) print("accent:", c) end,
})

misc:CreatePanel():CreateTextbox({
	Name = "Config name",
	Placeholder = "default",
	Callback = function(v) print("configname:", v) end,
})

misc:CreatePanel():CreateKeybind({
	Name = "Panic key",
	Default = Enum.KeyCode.P,
	Callback = function(k) print("panic:", k.Name) end,
})

-- SETTINGS: config + window control
local cfg = settings:CreatePanel()
cfg:CreateButton({ Name = "Save config", Callback = function()
	Window:SaveConfig("demo")
	Window:Notify({ Title = "Config", Content = "Saved 'demo'", Duration = 2 })
end })
cfg:CreateButton({ Name = "Load config", Callback = function()
	if Window:LoadConfig("demo") then
		Window:Notify({ Title = "Config", Content = "Loaded 'demo'", Duration = 2 })
	else
		Window:Notify({ Title = "Config", Content = "No save found", Duration = 2 })
	end
end })

local win = settings:CreatePanel()
win:CreateButton({ Name = "Toggle UI (RightShift)", Callback = function() Window:Toggle() end })
win:CreateButton({ Name = "Unload", Callback = function() Window:Destroy() end })

Window:Notify({ Title = "luminate", Content = "Loaded. Press RightShift to hide.", Duration = 4 })
