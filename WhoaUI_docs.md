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

At the very top of the lib file, 4 lines control it:

```lua
local KEY_ENABLED  = true          -- false = no key prompt at all
local KEY_VALUE    = "woah67"      -- the correct key (always lowercase)
local KEY_URL      = "https://discord.gg/..."  -- copied to clipboard on "Get Key"
local KEY_FILE     = "WhoaKey.txt" -- saves valid key so user only types once
```

**To disable keys entirely** just set `KEY_ENABLED = false` — the prompt never shows.

**To use your own key system** (e.g. check against a webhook or external list), replace the `tryKey` function body inside the `if KEY_ENABLED then` block with your own logic. The only requirement is that you set `unlocked = true` when the check passes.

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

Second argument is the title shown in the header. Pass `""` for no header.

### 3 — Add elements

#### Checkbox
```lua
sec:AddCheckbox({
    Name     = "My Toggle",   -- label shown
    Flag     = "mytoggle",    -- save key (must be unique)
    Default  = false,         -- starting value
    Keybind  = "G",           -- optional keyboard shortcut
    Callback = function(v) end  -- v = true/false
})
```

#### Slider
```lua
sec:AddSlider({
    Name     = "Walk Speed",
    Flag     = "wspeed",
    Min      = 0,
    Max      = 500,
    Default  = 16,
    Decimals = 0,             -- 0 = integer, 1+ = decimal places
    Callback = function(v) end
})
-- returns {Get = fn, Set = fn}
local s = sec:AddSlider({...})
s:Set(100)   -- set value programmatically
s:Get()      -- read current value
```

#### Dropdown
```lua
sec:AddDropdown({
    Name     = "Mode",
    Flag     = "mode",
    Items    = { "Option A", "Option B", "Option C" },
    Default  = "Option A",
    Callback = function(v) end
})
-- returns {Get = fn, Rebuild = fn}
local d = sec:AddDropdown({...})
d:Rebuild({"New A", "New B"})  -- swap items at runtime
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
sec:AddTextBox({
    Name        = "Username",
    Flag        = "username",
    Placeholder = "Enter name...",
    Default     = "",
    Callback    = function(text) end  -- fires on focus lost
})
-- returns {Get = fn}
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
    Flag     = "tkey",
    Default  = Enum.KeyCode.RightShift,
    Callback = function(keyCode) end
})
```
> Flag `"tkey"` is special — it automatically updates the window toggle key.

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
-- Last arg is duration in seconds
```

---

## Accent color

```lua
UI.SetAccent(Color3.fromRGB(100, 200, 255))
-- Updates every accent-colored element live
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
local refs = UI  -- UI exposes pbNameLabel, avImg, wmFrame, wmNameLabel, realAvatar()

sec:AddCheckbox({ Name="Anonymous Mode", Flag="anon", Default=false,
    Callback = function(v)
        refs.pbNameLabel.Text = v and "Hidden" or game.Players.LocalPlayer.DisplayName
        refs.avImg.Image      = v and "rbxassetid://1353560252" or (refs.realAvatar() or "")
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
