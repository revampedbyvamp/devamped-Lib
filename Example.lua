-- DevampedLib Example
-- Studio: put src/ under ReplicatedStorage as "DevampedLib", then:
--   local Library = require(game.ReplicatedStorage.DevampedLib.Init)
-- Executor (after GitHub push):
--   local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/revampedbyvamp/devamped-Lib/main/Dist/DevampedLib.lua"))()

local Library = require(script.Parent.src.Init)

local Window = Library:CreateWindow({
	Title = "My Hub",
	Theme = "Dark", -- "Light" | "Dark" | custom table
	ToggleKey = Enum.KeyCode.RightShift,
})

local Main = Window:CreateTab({ Name = "Main" })

Main:CreateSection({ Title = "Getting started", Subtitle = "Every component works out of the box" })

Main:CreateButton({
	Name = "Click Me",
	Tooltip = "Ripple + callback",
	Callback = function()
		Window:Notify({ Title = "Clicked", Content = "Button works!", Duration = 3 })
	end,
})

local toggle = Main:CreateToggle({
	Name = "Enable feature",
	Description = "Animated switch with flag support",
	Default = false,
	Flag = "feature_enabled",
	Callback = function(v) print("toggle:", v) end,
})

Main:CreateSlider({
	Name = "WalkSpeed",
	Min = 16,
	Max = 200,
	Default = 16,
	Flag = "walkspeed",
	Callback = function(v) print("speed:", v) end,
})

Main:CreateDropdown({
	Name = "Weapon",
	Options = { "Sword", "Bow", "Staff" },
	Default = "Sword",
	Flag = "weapon",
	Callback = function(v) print("weapon:", v) end,
})

Main:CreateTextbox({
	Name = "Player name",
	Placeholder = "Enter name...",
	Callback = function(v) print("name:", v) end,
})

Main:CreateKeybind({
	Name = "Toggle UI",
	Default = Enum.KeyCode.RightShift,
	Callback = function(k) print("key:", k) end,
})

Main:CreateColorPicker({
	Name = "Accent preview",
	Default = Color3.fromRGB(139, 105, 240),
	Callback = function(c) print("color:", c) end,
})

-- Config persistence (writefile on executors, memory in Studio)
Window:SaveConfig("default")
Window:LoadConfig("default")
-- Window:EnableAutoSave("autosave")

Window:Notify({ Title = "DevampedLib", Content = "Loaded successfully!", Duration = 4 })
