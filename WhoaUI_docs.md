# WhoaUI — Developer Docs

---

## Loading the library

Upload `WhoaUI_lib.lua` to a raw URL (GitHub raw, Pastebin raw, etc.) then in your script:

```lua
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/YOU/REPO/main/WhoaUI_lib.lua"))()
```

`UI` is now your handle to everything.

---

## Key system

At the very top of the lib file you will find a clearly marked config block. Everything you need to touch is in there — nothing else needs to be edited.

```lua
-- ── KEY SYSTEM CONFIG ────────────────────────────
local KEY_ENABLED = true      -- false = no key prompt at all, loads instantly
local KEY_VALUES  = {
    "mykey1",                 -- add as many keys as you want
    "mykey2",
    -- "key3",               -- uncomment to add more
}
local KEY_URL  = "https://discord.gg/yourinvite"  -- copied to clipboard on "Get Key"
local KEY_FILE = "WhoaKey.txt"                    -- caches the valid key locally
```

### No keys at all

Set `KEY_ENABLED = false` — the prompt never shows and the UI loads instantly.

### Single key

```lua
local KEY_ENABLED = true
local KEY_VALUES  = { "mysecretkey" }
```

### Multiple keys (e.g. one per user)

```lua
local KEY_ENABLED = true
local KEY_VALUES  = {
    "alpha001",
    "beta002",
    "vip999",
}
```

Keys are **case-insensitive** and **whitespace-trimmed**, so `" MyKey1 "` and `"mykey1"` both work.

Once a user enters a valid key it is saved to `KEY_FILE` locally — they will not be prompted again on future runs.

---

## Script defaults

Also at the top of the lib, easily editable:

```lua
local SCRIPT_NAME    = "whoa"                      -- name shown in titlebar + watermark
local SCRIPT_VERSION = "v2.0"                      -- version badge in watermark
local ICON_IMAGE     = "rbxassetid://..."          -- set "" for letter icon fallback
local WM_SHOW        = true                        -- show watermark on load
local WM_SUBTEXT     = ""                          -- extra text in watermark (optional)
local WIN_WIDTH      = 700                         -- window width in pixels
local WIN_HEIGHT     = 500                         -- window height in pixels
local TOGGLE_KEY     = Enum.KeyCode.RightShift     -- default key to show/hide UI
local SNOW_ENABLED   = false                       -- snow particles on by default
local NOTIF_DURATION = 3                           -- default notification duration (seconds)
```

---

## Theme

Directly below the script defaults is the theme table. Edit any color to retheme the entire UI — all elements update automatically.

```lua
local T = {
    A  = Color3.fromRGB(255, 182, 215),   -- primary accent (buttons, sliders, etc.)
    A2 = Color3.fromRGB(255, 150, 195),   -- window border
    B0 = Color3.fromRGB(9,   9,  13),     -- darkest background
    B1 = Color3.fromRGB(14,  14, 19),     -- window background
    B2 = Color3.fromRGB(20,  20, 27),     -- element background
    B3 = Color3.fromRGB(26,  26, 35),     -- section background
    B4 = Color3.fromRGB(34,  34, 46),     -- hovered state
    BD = Color3.fromRGB(52,  52, 70),     -- borders
    TX = Color3.fromRGB(255, 255, 255),   -- main text
    MT = Color3.fromRGB(115, 115, 145),   -- muted text
}
```

You can also change the accent color at runtime from your script:

```lua
UI.SetAccent(Color3.fromRGB(100, 200, 255))
```

---

## Building your UI

### 1 — Create tabs

```lua
local leftCol, rightCol, tabName, switchFn = UI.AddTab("Home")
```

Returns two scroll columns (left/right), the tab name string, and a function to switch to it programmatically.

### 2 — Create sections

```lua
local sec = UI.MakeSection(leftCol, "Section Title")
sec._tabName(tabName, switchFn)   -- always include — powers search navigation
```

Pass `""` as the second argument for a section with no header.

### 3 — Add elements

#### Checkbox
```lua
sec:AddCheckbox({
    Name     = "My Toggle",
    Flag     = "mytoggle",    -- unique save key
    Default  = false,
    Keybind  = "G",           -- optional keyboard shortcut
    Callback = function(v) end
})
```

#### Slider
```lua
local s = sec:AddSlider({
    Name     = "Walk Speed",
    Flag     = "wspeed",
    Min      = 0,
    Max      = 500,
    Default  = 16,
    Decimals = 0,             -- 0 = integer, 1+ = decimal places
    Callback = function(v) end
})
s:Set(100)   -- set value programmatically
s:Get()      -- read current value
```

#### Dropdown
```lua
local d = sec:AddDropdown({
    Name     = "Mode",
    Flag     = "mode",
    Items    = { "Option A", "Option B", "Option C" },
    Default  = "Option A",
    Callback = function(v) end
})
d:Rebuild({"New A", "New B"})  -- swap items at runtime
d:Get()                        -- read current value
```

#### Button
```lua
sec:AddButton({
    Name     = "Click Me",
    Callback = function() end
})
```

#### TextBox
```lua
local t = sec:AddTextBox({
    Name        = "Username",
    Flag        = "username",
    Placeholder = "Enter name...",
    Default     = "",
    Callback    = function(text) end  -- fires on focus lost
})
t:Get()  -- read current value
```

#### ColorPicker
```lua
sec:AddColorPicker({
    Name     = "ESP Color",
    Flag     = "espcol",
    Default  = Color3.fromRGB(255, 80, 80),
    Callback = function(color3) end
})
```

#### Keybind
```lua
sec:AddKeybind({
    Name     = "Toggle UI",
    Flag     = "tkey",        -- "tkey" is special: automatically updates the window toggle key
    Default  = Enum.KeyCode.RightShift,
    Callback = function(keyCode) end
})
```

#### Label
```lua
sec:AddLabel({ Name = "This is a read-only text line." })
```

#### Divider
```lua
sec:AddDivider()
```

---

## Notifications

```lua
UI.Notify("Title", "Body message", "Success", 3)
-- Types: "Success"  "Error"  "Warning"
-- Last arg is duration in seconds (optional, defaults to NOTIF_DURATION)
```

---

## Flags

All toggle/slider/textbox values are stored in `UI.Flags`:

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

## Anonymous mode (example)

```lua
sec:AddCheckbox({ Name="Anonymous Mode", Flag="anon", Default=false,
    Callback = function(v)
        UI.pbNameLabel.Text = v and "Hidden" or game.Players.LocalPlayer.DisplayName
        UI.avImg.Image      = v and "rbxassetid://1353560252" or (UI.realAvatar() or "")
    end
})
```

---

## Full minimal example

```lua
local UI = loadstring(game:HttpGet("YOUR_URL"))()

local hL, hR, hTab, hSwitch = UI.AddTab("Main")

local sec = UI.MakeSection(hL, "Combat")
sec._tabName(hTab, hSwitch)

sec:AddCheckbox({ Name="Auto Parry", Flag="autoparry", Default=false,
    Callback = function(v)
        -- your logic here
    end
})

sec:AddSlider({ Name="Speed", Flag="spd", Min=16, Max=300, Default=16,
    Callback = function(v)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v
    end
})

UI.Notify("Loaded", "Script ready!", "Success", 3)
```

---

## Cleanup

```lua
UI.Destroy()  -- removes the entire GUI
```
