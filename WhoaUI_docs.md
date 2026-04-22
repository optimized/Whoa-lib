# WhoaUI — Developer Docs

---

## Loading the library

Upload `WhoaUI_lib.lua` to a raw URL (GitHub raw, Pastebin raw, etc.) then in your script:

```lua
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/YOU/REPO/main/WhoaUI_lib.lua"))()
```

---

## Key system

At the top of the lib file:

```lua
local KEY_ENABLED = true      -- false = no key prompt, loads instantly
local KEY_VALUES  = {
    "mykey1",                 -- add as many keys as you want
    "mykey2",
    -- "key3",
}
local KEY_URL  = "https://discord.gg/yourinvite"  -- copied to clipboard on "Get Key"
local KEY_FILE = "WhoaKey.txt"                    -- caches the valid key locally
```

Keys are case-insensitive and whitespace-trimmed. Once a user enters a valid key it is saved locally — they will not be prompted again on future runs.

---

## Icons

Two icon variables sit at the top of the defaults block:

```lua
-- Top-left window icon. Set to "" to show a letter fallback instead.
local ICON_IMAGE   = "rbxassetid://YOUR_ASSET_ID"

-- Icon shown on the right side of every section header.
-- Set to "" to hide it entirely.
local SECTION_ICON = "rbxassetid://YOUR_ASSET_ID"
```

Both accept any Roblox asset ID. You can set them to the same asset or different ones. Setting either to `""` disables that icon — `ICON_IMAGE` will fall back to a letter, `SECTION_ICON` will simply not render anything in the header.

---

## Script defaults

```lua
local SCRIPT_NAME    = "whoa"
local SCRIPT_VERSION = "v2.0"
local WM_SHOW        = true        -- show watermark on load
local WM_SUBTEXT     = ""          -- optional extra text in watermark
local WIN_WIDTH      = 700
local WIN_HEIGHT     = 500
local TOGGLE_KEY     = Enum.KeyCode.RightShift
local SNOW_ENABLED   = false
local NOTIF_DURATION = 3           -- default notification seconds
```

---

## Theme

Edit any color to retheme the entire UI:

```lua
local T = {
    A  = Color3.fromRGB(255, 182, 215),   -- primary accent
    A2 = Color3.fromRGB(255, 150, 195),   -- window border
    B0 = Color3.fromRGB(9,   9,  13),     -- darkest bg
    B1 = Color3.fromRGB(14,  14, 19),     -- window bg
    B2 = Color3.fromRGB(20,  20, 27),     -- element bg
    B3 = Color3.fromRGB(26,  26, 35),     -- section bg
    B4 = Color3.fromRGB(34,  34, 46),     -- hovered
    BD = Color3.fromRGB(52,  52, 70),     -- borders
    TX = Color3.fromRGB(255, 255, 255),   -- main text
    MT = Color3.fromRGB(115, 115, 145),   -- muted text
}
```

Change accent at runtime:

```lua
UI.SetAccent(Color3.fromRGB(100, 200, 255))
```

---

## Building your UI

### 1 — Create tabs

```lua
local leftCol, rightCol, tabName, switchFn = UI.AddTab("Home")
```

### 2 — Create sections

```lua
local sec = UI.MakeSection(leftCol, "Section Title")
sec._tabName(tabName, switchFn)   -- always include — powers search
```

Pass `""` as title for a section with no header.

### 3 — Elements

#### Checkbox
```lua
sec:AddCheckbox({
    Name = "My Toggle", Flag = "mytoggle", Default = false,
    Keybind = "G",           -- optional
    Callback = function(v) end
})
```

#### Slider
```lua
local s = sec:AddSlider({
    Name = "Walk Speed", Flag = "wspeed",
    Min = 0, Max = 500, Default = 16, Decimals = 0,
    Callback = function(v) end
})
s:Set(100)
s:Get()
```

#### Dropdown
```lua
local d = sec:AddDropdown({
    Name = "Mode", Flag = "mode",
    Items = { "A", "B", "C" }, Default = "A",
    Callback = function(v) end
})
d:Rebuild({"X", "Y"})
d:Get()
```

#### Button
```lua
sec:AddButton({ Name = "Click Me", Callback = function() end })
```

#### TextBox
```lua
local t = sec:AddTextBox({
    Name = "Username", Flag = "username",
    Placeholder = "Enter name...", Default = "",
    Callback = function(text) end
})
t:Get()
```

#### ColorPicker
```lua
sec:AddColorPicker({
    Name = "Color", Flag = "col",
    Default = Color3.fromRGB(255, 80, 80),
    Callback = function(color3) end
})
```

#### Keybind
```lua
sec:AddKeybind({
    Name = "Toggle UI", Flag = "tkey",   -- "tkey" auto-updates the window toggle
    Default = Enum.KeyCode.RightShift,
    Callback = function(keyCode) end
})
```

#### Label
```lua
sec:AddLabel({ Name = "Read-only text." })
```

#### Divider
```lua
sec:AddDivider()
```

---

## Notifications

```lua
UI.Notify("Title", "Body", "Success", 3)
-- Types: "Success"  "Error"  "Warning"
```

---

## Flags

```lua
if UI.Flags["mytoggle"] then
    -- feature is on
end
```

---

## Snow

```lua
UI.StartSnow()
UI.StopSnow()
```

---

## Anonymous mode example

```lua
sec:AddCheckbox({ Name="Anonymous Mode", Flag="anon", Default=false,
    Callback = function(v)
        UI.pbNameLabel.Text = v and "Hidden" or game.Players.LocalPlayer.DisplayName
        UI.avImg.Image      = v and "rbxassetid://1353560252" or (UI.realAvatar() or "")
    end
})
```

---

## Minimal example

```lua
local UI = loadstring(game:HttpGet("YOUR_URL"))()

local hL, hR, hTab, hSwitch = UI.AddTab("Main")
local sec = UI.MakeSection(hL, "Combat")
sec._tabName(hTab, hSwitch)

sec:AddCheckbox({ Name="Auto Parry", Flag="autoparry", Default=false,
    Callback = function(v) end
})

UI.Notify("Loaded", "Ready.", "Success", 3)
```

---

## Cleanup

```lua
UI.Destroy()
```
