# devamped-Lib

Production-ready Roblox UI library. Drop-in, fully functional components, scale-safe on every device, smooth tween animations, draggable + resizable window, Light/Dark/custom themes, config save/load, search, tooltips, touch support, and stacking notifications.

## Install (executor, one line)

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/revampedbyvamp/devamped-Lib/main/Dist/DevampedLib.lua"))()
```

## Install (Studio / Rojo)

1. Copy `src/` into ReplicatedStorage as `DevampedLib`.
2. `local Library = require(game.ReplicatedStorage.DevampedLib.Init)`

## Quick start

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/revampedbyvamp/devamped-Lib/main/Dist/DevampedLib.lua"))()

local Window = Library:CreateWindow({
	Title = "My Hub",
	Theme = "Dark", -- "Light" | "Dark" | custom table
	ToggleKey = Enum.KeyCode.RightShift,
})

local Tab = Window:CreateTab({ Name = "Main" })

Tab:CreateButton({ Name = "Click Me", Callback = function()
	Window:Notify({ Title = "Hi", Content = "Button works!" })
end })

Tab:CreateToggle({ Name = "Enabled", Default = false, Flag = "enabled" })
Tab:CreateSlider({ Name = "Speed", Min = 16, Max = 200, Default = 16, Flag = "speed" })
Tab:CreateDropdown({ Name = "Weapon", Options = { "Sword", "Bow" }, Default = "Sword" })
Tab:CreateTextbox({ Name = "Name", Placeholder = "Enter name..." })
Tab:CreateKeybind({ Name = "Toggle", Default = Enum.KeyCode.RightShift })
Tab:CreateColorPicker({ Name = "Color" })

Window:SaveConfig("default")
Window:LoadConfig("default")
```

See `Example.lua` for the full demo.

## Layout

- `src/Theme.lua` — Light/Dark themes + `Theme.Create(nameOrTable)`
- `src/Animation.lua` — Tween, hover, press, fade, slide, spring, ripple
- `src/Components.lua` — button, toggle, checkbox, slider, dropdown, textbox, keybind, color picker, label, section, column, tooltip
- `src/Library.lua` — `CreateWindow`, tabs, notifications, search, drag/resize, responsive scale, config store
- `src/Init.lua` — Studio entry point
- `Dist/DevampedLib.lua` — generated single-file bundle (edit `src/`, rebuild; do not hand-edit)

## Rebuild the bundle

```sh
python3 tools/build.py
```

(or the inline python snippet documented in the repo history).
