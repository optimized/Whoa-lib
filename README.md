<div align="center">
  <img src="https://i.imgur.com/ZvI5TPT.png" width="700"/>
</div>

---

# WhoaUI
A clean, lightweight Roblox UI library for exploit scripts.

---

## Installation

Host `WhoaUI_lib.lua` on a raw URL (GitHub, Pastebin, etc.) and load it in your script:

```lua
local UI = loadstring(game:HttpGet("YOUR_RAW_URL"))()
```

---

## Setup

Call `UI.Setup()` before building any UI. All fields are optional.

```lua
UI.Setup({
    Name        = "My Script",
    Version     = "v1.0",
    Icon        = "rbxassetid://YOUR_ID",
    Snow        = false,
    Keys        = {"mykey123"},
    KeyURL      = "https://discord.gg/yourlink",
    KeyPersist  = true,
})
```

| Field | Type | Description |
|-------|------|-------------|
| `Name` | string | Window title and watermark name |
| `Version` | string | Shown in the watermark |
| `Icon` | string | Roblox asset ID for the title bar icon |
| `Snow` | bool | Enable snow particles and background overlay |
| `Keys` | table | List of valid keys. Remove this field entirely to skip the key system |
| `KeyURL` | string | Copied to clipboard when user clicks "Get Key". A "Copied link!" confirmation appears below the modal |
| `KeyPersist` | bool | `true` = key saved after first entry. `false` = required every run |

### Loader

When `UI.Setup()` is called, an animated letter-by-letter intro screen plays automatically before the UI appears. No extra configuration needed — it reads `Name` automatically.

### Keybind Tip

After the loader finishes, a notification automatically appears in the bottom-right corner telling the user which key opens/closes the UI. This updates automatically if the toggle key is changed.

---

## Building UI

### Tabs

```lua
local colL, colR, tabName, tabSwitch = UI.AddTab("Tab Name")
```

Each tab has a **left column** (`colL`) and **right column** (`colR`). Pass either into `MakeSection`.

---

### Sections

```lua
local sec = UI.MakeSection(colL, "Section Title")
sec._tabName(tabName, tabSwitch)  -- required for search to work
```

Pass `""` as the title for a section with no header. Sections are collapsible by clicking the header.

---

### Elements

#### Toggle
```lua
local tog = sec:AddToggle({
    Name     = "My Toggle",
    Flag     = "tog1",
    Default  = false,
    Keybind  = Enum.KeyCode.F,   -- optional
    Callback = function(v) end,
})
tog:Set(true)
tog:Get()
```

#### Checkbox
```lua
sec:AddCheckbox({
    Name     = "My Checkbox",
    Flag     = "chk1",
    Default  = false,
    Callback = function(v) end,
})
```

#### Slider
```lua
local sld = sec:AddSlider({
    Name     = "My Slider",
    Flag     = "sld1",
    Min      = 0,
    Max      = 100,
    Default  = 50,
    Decimals = 0,
    Callback = function(v) end,
})
sld:Set(75)
sld:Get()
```

#### Button
```lua
sec:AddButton({
    Name     = "My Button",
    Keybind  = Enum.KeyCode.E,   -- optional
    Callback = function() end,
})
```

#### Dropdown
```lua
local drp = sec:AddDropdown({
    Name     = "My Dropdown",
    Flag     = "drp1",
    Items    = {"Option A", "Option B", "Option C"},
    Default  = "Option A",
    Callback = function(v) end,
})
drp:Get()
drp:Rebuild({"New A", "New B"})  -- swap items at runtime
```

#### TextBox
```lua
local tb = sec:AddTextBox({
    Name        = "My TextBox",
    Flag        = "txt1",
    Placeholder = "Type here...",
    Default     = "",
    Callback    = function(v) end,
})
tb:Get()
```

#### Color Picker
```lua
sec:AddColorPicker({
    Name     = "My Color",
    Flag     = "col1",
    Default  = Color3.fromRGB(255, 182, 215),
    Callback = function(c) end,
})
```

#### Keybind
```lua
sec:AddKeybind({
    Name     = "My Keybind",
    Flag     = "kb1",
    Default  = Enum.KeyCode.F,
    Callback = function(k) end,
})
```

> **Tip:** Use `Flag = "tkey"` to automatically update the UI toggle key when the user rebinds it.

#### Label
```lua
sec:AddLabel({ Name = "Some text here." })
```

#### Divider
```lua
sec:AddDivider()
```

---

## Flags

Every element with a `Flag` writes its value to `UI.Flags`. Read it from anywhere:

```lua
if UI.Flags["tog1"] then
    -- toggle is on
end

print(UI.Flags["sld1"])  -- current slider value
```

---

## Notifications

```lua
UI.Notify("Title", "Body text", "Success", 3)
```

| Type | Color |
|------|-------|
| `"Success"` | Green |
| `"Error"` | Red |
| `"Warning"` | Orange |
| `"Info"` | Accent pink (default) |

Duration is in seconds. Omit it to use the default (3s).

---

## Accent Color

```lua
UI.SetAccent(Color3.fromRGB(100, 200, 255))
```

Updates every accent-colored element instantly.

---

## Snow & Overlay

```lua
UI.StartSnow()   -- shows snow particles + dark background overlay
UI.StopSnow()    -- hides snow particles AND the background overlay
```

> **Note:** `StopSnow()` also hides the dark background overlay. `StartSnow()` brings it back.

You can control the overlay independently:
```lua
UI.SetOverlay(true)   -- show overlay
UI.SetOverlay(false)  -- hide overlay
```

---

## Config System

Save and load flag states between sessions:

```lua
UI.SaveConfig("myconfig")       -- save current flags
UI.LoadConfig("myconfig")       -- load saved flags
UI.DeleteConfig("myconfig")     -- delete a saved config
UI.ListConfigs()                -- returns table of saved config names
UI.SetAutoLoad("myconfig")      -- auto-loads this config on next run
UI.GetAutoLoad()                -- returns the current auto-load name
```

---

## Cleanup

Destroys the entire UI and disconnects all connections:

```lua
UI.Destroy()
```

---

## Full Example

```lua
local UI = loadstring(game:HttpGet("YOUR_RAW_URL"))()

UI.Setup({
    Name       = "My Script",
    Version    = "v1.0",
    Keys       = {"mykey"},
    KeyURL     = "https://discord.gg/yourserver",
    KeyPersist = true,
    Snow       = true,
})

-- Tabs
local colL, colR, tabName, tabSwitch = UI.AddTab("Main")
local sL, sR, sTab, sSwitch = UI.AddTab("Settings")

-- Section
local sec = UI.MakeSection(colL, "Features")
sec._tabName(tabName, tabSwitch)

-- Elements
sec:AddToggle({
    Name = "Speed Hack", Flag = "spd", Default = false,
    Callback = function(v)
        -- your code here
    end,
})

sec:AddSlider({
    Name = "Speed", Flag = "spdval",
    Min = 16, Max = 500, Default = 60, Decimals = 0,
    Callback = function(v)
        -- your code here
    end,
})

sec:AddButton({
    Name = "Reset",
    Callback = function()
        -- your code here
    end,
})

-- Settings tab
local uiSec = UI.MakeSection(sL, "UI")
uiSec._tabName(sTab, sSwitch)

uiSec:AddKeybind({ Name = "Toggle UI",  Flag = "tkey", Default = Enum.KeyCode.RightShift })
uiSec:AddCheckbox({ Name = "Watermark", Flag = "wm",   Default = true, Callback = function(v) UI.wmFrame.Visible = v end })
uiSec:AddCheckbox({ Name = "Snow",      Flag = "snow", Default = true, Callback = function(v) if v then UI.StartSnow() else UI.StopSnow() end end })

local themeSec = UI.MakeSection(sR, "Theme")
themeSec._tabName(sTab, sSwitch)

themeSec:AddColorPicker({
    Name = "Accent Color", Flag = "accent",
    Default = Color3.fromRGB(255, 182, 215),
    Callback = function(c) UI.SetAccent(c) end,
})
themeSec:AddButton({
    Name = "Reset Accent",
    Callback = function() UI.SetAccent(Color3.fromRGB(255, 182, 215)) end,
})

UI.Notify("My Script", "Loaded successfully!", "Success", 3)
```
