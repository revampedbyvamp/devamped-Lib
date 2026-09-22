-- ============================================
-- DevampedLib Full Demo
-- Every component, multiple tabs, config, themes.
--
-- Executor:
--   local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/revampedbyvamp/devamped-Lib/main/Dist/DevampedLib.lua"))()
-- Studio (src/ under ReplicatedStorage as "DevampedLib"):
--   local Library = require(game.ReplicatedStorage.DevampedLib.Init)
-- ============================================

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/revampedbyvamp/devamped-Lib/main/Dist/DevampedLib.lua"))()
-- local Library = require(game.ReplicatedStorage.DevampedLib.Init)

-- 1. Window (draggable, resizable, RightShift toggles UI, scales 0.65-1x)
local Window = Library:CreateWindow({
	Title = "Devamped Demo",
	Theme = "Dark", -- "Light" | "Dark" | custom color table
	ToggleKey = Enum.KeyCode.RightShift,
})

-- 2. Tabs
local Main = Window:CreateTab({ Name = "Main" })
local Visuals = Window:CreateTab({ Name = "Visuals" })
local Settings = Window:CreateTab({ Name = "Settings" })

-- 3. MAIN TAB ---------------------------------------------

Main:CreateSection({ Title = "Welcome", Subtitle = "Search box above filters all of these live" })

Main:CreateButton({
	Name = "Say hello",
	Tooltip = "Hover me, then click for a ripple",
	Callback = function()
		Window:Notify({ Title = "Hello!", Content = "Button callback fired.", Duration = 3 })
	end,
})

local fly = Main:CreateToggle({
	Name = "Fly",
	Description = "Animated switch. Stored in Library.Flags['fly']",
	Default = false,
	Flag = "fly",
	Callback = function(v)
		print("fly:", v)
	end,
})

Main:CreateCheckbox({
	Name = "I agree",
	Default = true,
	Callback = function(v) print("agree:", v) end,
})

local speed = Main:CreateSlider({
	Name = "WalkSpeed",
	Min = 16,
	Max = 200,
	Default = 16,
	Flag = "walkspeed",
	Callback = function(v)
		local char = game.Players.LocalPlayer.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.WalkSpeed = v
		end
	end,
})
-- speed:Set(50) | speed:Get()

Main:CreateDropdown({
	Name = "Weapon",
	Options = { "Sword", "Bow", "Staff" },
	Default = "Sword",
	Flag = "weapon",
	Callback = function(v)
		Window:Notify({ Title = "Weapon", Content = "Equipped " .. tostring(v), Duration = 2 })
	end,
})

Main:CreateTextbox({
	Name = "Target player",
	Placeholder = "Enter name, press Enter...",
	Callback = function(v) print("target:", v) end,
})

Main:CreateKeybind({
	Name = "Panic key",
	Default = Enum.KeyCode.P,
	Callback = function(k) print("panic bound to:", k.Name) end,
})

Main:CreateColorPicker({
	Name = "Aura color",
	Default = Color3.fromRGB(139, 105, 240),
	Callback = function(c) print("color:", math.floor(c.R * 255), math.floor(c.G * 255), math.floor(c.B * 255)) end,
})

Main:CreateFeature({
	Name = "Auto parry",
	Description = "Card layout with mini-toggle",
	Keybind = "Q",
	Default = false,
	Callback = function(v) print("auto parry:", v) end,
})

Main:CreateLabel({ Title = "Status", Text = "All systems go" })

-- programmatic control demo
task.delay(1, function()
	print("fly is:", fly:Get())
	print("speed is:", speed:Get())
	print("all flags:", Library.Flags)
end)

-- 4. VISUALS TAB (multi-column layout) ---------------------

local left = Visuals:CreateColumn(1 / 2)
local right = Visuals:CreateColumn(1 / 2)

Visuals:CreateSection(left, "ESP", "Left column, explicit parent")
Visuals:CreateToggle(left, "Box ESP", "Draw boxes", false, function(v) print("box:", v) end)
Visuals:CreateToggle(left, "Name ESP", nil, true, function(v) print("name:", v) end)
Visuals:CreateSlider(left, "ESP range", 50, 2000, 500, function(v) print("range:", v) end)

Visuals:CreateSection(right, "World", "Right column")
Visuals:CreateSlider(right, "Brightness", 0, 5, 2, function(v)
	pcall(function() game.Lighting.Brightness = v end)
end)
Visuals:CreateDropdown(right, "Sky", { "Day", "Night" }, "Day", function(v)
	print("sky:", v)
end)
Visuals:CreateButton(right, "Fullbright", function()
	pcall(function()
		game.Lighting.Brightness = 3
		game.Lighting.ClockTime = 14
	end)
	Window:Notify({ Title = "Visuals", Content = "Fullbright on", Duration = 2 })
end)

-- 5. SETTINGS TAB (themes + config + window control) --------

Settings:CreateSection({ Title = "Theme", Subtitle = "Swaps instantly" })

Settings:CreateDropdown({
	Name = "Theme",
	Options = { "Dark", "Light" },
	Default = "Dark",
	Callback = function(v)
		Window:SetTheme(v)
		Window:Notify({ Title = "Theme", Content = v .. " applied", Duration = 2 })
	end,
})

Settings:CreateSection({ Title = "Config", Subtitle = "Saved to file on executors, memory in Studio" })

Settings:CreateButton({ Name = "Save config", Callback = function()
	Window:SaveConfig("demo")
	Window:Notify({ Title = "Config", Content = "Saved 'demo'", Duration = 2 })
end })

Settings:CreateButton({ Name = "Load config", Callback = function()
	if Window:LoadConfig("demo") then
		Window:Notify({ Title = "Config", Content = "Loaded 'demo'", Duration = 2 })
	else
		Window:Notify({ Title = "Config", Content = "No save found", Duration = 2 })
	end
end })

Settings:CreateToggle({
	Name = "Autosave",
	Description = "Saves on every flag change",
	Default = false,
	Callback = function(v)
		if v then
			Window:EnableAutoSave("demo")
		end
	end,
})

Settings:CreateSection({ Title = "Window" })

Settings:CreateButton({ Name = "Toggle UI (same as RightShift)", Callback = function()
	Window:Toggle()
end })

Settings:CreateButton({ Name = "Unload library", Callback = function()
	Window:Destroy()
end })

-- 6. Welcome notification (stack up to 4 by calling again)
Window:Notify({ Title = "DevampedLib", Content = "Full demo loaded. Try the search bar!", Duration = 4 })
