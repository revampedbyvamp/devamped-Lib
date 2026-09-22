# devamped-Lib

Dark "luminate"-style Roblox UI library: sidebar nav, gray panel cards, monochrome controls. Drop-in, fully functional components, scale-safe on every device, smooth tween animations, draggable + resizable window, Luminate/Light/Dark/custom themes, config save/load, opt-in search, tooltips, touch support, and stacking notifications.

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
	Title = "luminate",
	Footer = "luminate.pw",
	ToggleKey = Enum.KeyCode.RightShift,
	-- Search = true, -- opt-in filter box above the content
	-- Theme = "Light", -- "Luminate" (default) | "Light" | "Dark" | custom table
})

local Tab = Window:CreateTab({ Name = "rage" })
local Panel = Tab:CreatePanel() -- gray card, like the reference

Panel:CreateCheckbox({ Name = "Checkbox" })
Panel:CreateSlider({ Name = "Slider", Min = 0, Max = 100, Default = 0 })
Panel:CreateDropdown({ Name = "Combo", Options = { "Item1", "Item2", "Item3" }, Default = "Item1" })
Panel:CreateButton({ Name = "Button", Callback = function()
	Window:Notify({ Title = "Hi", Content = "Button works!" })
end })

Window:SaveConfig("default")
Window:LoadConfig("default")
```

See `Example.lua` for the full demo.

## Layout

- `src/Theme.lua` — Luminate (default) / Light / Dark + `Theme.Create(nameOrTable)`
- `src/Animation.lua` — Tween, hover, press, fade, slide, spring, ripple
- `src/Icons.lua` — Lucide image icons (crosshair, shield, eye, grid, gear, cart, search, chevron, check...). `Icon = "zap"` on any tab, or a raw `rbxassetid://` string
- `src/Components.lua` — groupbox panel, button, toggle, checkbox, slider, dropdown/combo, textbox, keybind, color picker, label, section, column, tooltip
- `src/Library.lua` — `CreateWindow`, sidebar tabs, panels, notifications, drag/resize, responsive scale, config store
- `src/Init.lua` — Studio entry point
- `Dist/DevampedLib.lua` — generated single-file bundle (edit `src/`, rebuild; do not hand-edit)

## Rebuild the bundle

```sh
python3 tools/build.py
```

(or the inline python snippet documented in the repo history).
