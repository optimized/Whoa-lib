local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/optimized/Whoa-lib/refs/heads/main/WhoaUI_lib.lua"))()

UI.Setup({
    Name       = "WhoaUI Demo",
    Version    = "v1.0",
    Icon       = "rbxassetid://134387754737125",
    Snow       = true,
    Keys       = {"demo"},
    KeyURL     = "https://discord.gg/yourlink",
    KeyPersist = true,
})

-- ── SERVICES ──────────────────────────────────────
local UIS        = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local lp         = game:GetService("Players").LocalPlayer
local function getHum() return lp.Character and lp.Character:FindFirstChildOfClass("Humanoid") end
local function getHRP() return lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") end

-- ── TABS ──────────────────────────────────────────
local aL, aR, aTab, aSwitch = UI.AddTab("Actions")
local mL, mR, mTab, mSwitch = UI.AddTab("Movement")
local sL, sR, sTab, sSwitch = UI.AddTab("Settings")

-- ══════════════════════════════════════════════════
--  ACTIONS TAB
-- ══════════════════════════════════════════════════

local featSec = UI.MakeSection(aL, "Features")
featSec._tabName(aTab, aSwitch)

featSec:AddToggle({
    Name = "Infinite Jump", Flag = "infjump", Default = false,
    Keybind = Enum.KeyCode.J,
    Callback = function(v)
        if v then
            _G.ijConn = UIS.JumpRequest:Connect(function()
                local hrp = getHRP(); local hum = getHum()
                if hrp and hum then hrp:ApplyImpulse(Vector3.new(0, hum.JumpPower * hrp.AssemblyMass, 0)) end
            end)
        elseif _G.ijConn then _G.ijConn:Disconnect(); _G.ijConn = nil end
    end,
})

featSec:AddToggle({
    Name = "Noclip", Flag = "noclip", Default = false,
    Keybind = Enum.KeyCode.N,
    Callback = function(v)
        if v then
            _G.ncConn = RunService.Stepped:Connect(function()
                if not UI.Flags["noclip"] then return end
                if lp.Character then
                    for _,p in ipairs(lp.Character:GetDescendants()) do
                        if p:IsA("BasePart") then p.CanCollide = false end
                    end
                end
            end)
        elseif _G.ncConn then _G.ncConn:Disconnect(); _G.ncConn = nil end
    end,
})

featSec:AddCheckbox({ Name = "Show Notifications", Flag = "notifs", Default = true })
featSec:AddDivider()

featSec:AddButton({
    Name = "Send Test Notifications",
    Callback = function()
        UI.Notify("WhoaUI", "This is a success notification!", "Success", 3)
        task.wait(1)
        UI.Notify("WhoaUI", "This is a warning!", "Warning", 3)
        task.wait(1)
        UI.Notify("WhoaUI", "This is an error!", "Error", 3)
    end,
})

featSec:AddButton({
    Name = "Print All Flags",
    Callback = function()
        for k, v in pairs(UI.Flags) do print(k, "=", v) end
    end,
})

-- Right: Dropdowns + textbox
local inputSec = UI.MakeSection(aR, "Inputs")
inputSec._tabName(aTab, aSwitch)

inputSec:AddDropdown({
    Name = "Render Quality", Flag = "rq",
    Items = {"Auto", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10"},
    Default = "Auto",
    Callback = function(v)
        pcall(function()
            settings().Rendering.QualityLevel = v == "Auto" and Enum.QualityLevel.Automatic or tonumber(v)
        end)
    end,
})

inputSec:AddDropdown({
    Name = "Time of Day", Flag = "tod",
    Items = {"Morning", "Noon", "Evening", "Night"},
    Default = "Noon",
    Callback = function(v)
        local t = {Morning=7, Noon=14, Evening=18, Night=0}
        pcall(function() game:GetService("Lighting").ClockTime = t[v] end)
    end,
})

inputSec:AddDivider()

local tb = inputSec:AddTextBox({
    Name = "Custom Text", Flag = "customtxt",
    Placeholder = "Type something...",
    Callback = function(v)
        if UI.Flags["notifs"] then UI.Notify("TextBox", v, "Success", 2) end
    end,
})

inputSec:AddButton({
    Name = "Read TextBox",
    Callback = function() UI.Notify("TextBox Value", tb:Get(), "Success", 3) end,
})

inputSec:AddColorPicker({
    Name = "Highlight Color", Flag = "hlcol",
    Default = Color3.fromRGB(255, 80, 80),
    Callback = function(c)
        -- use c here
    end,
})

-- ══════════════════════════════════════════════════
--  MOVEMENT TAB
-- ══════════════════════════════════════════════════

local spdSec = UI.MakeSection(mL, "Speed")
spdSec._tabName(mTab, mSwitch)

spdSec:AddToggle({
    Name = "Speed Hack", Flag = "spd", Default = false,
    Callback = function(v)
        if v then
            _G.spdConn = RunService.Heartbeat:Connect(function(dt)
                if not UI.Flags["spd"] then return end
                local hrp = getHRP(); if not hrp then return end
                local spd  = UI.Flags["spdval"] or 60
                local move = Vector3.zero
                local cam  = workspace.CurrentCamera
                if UIS:IsKeyDown(Enum.KeyCode.W) then move += Vector3.new(0,0,-1) end
                if UIS:IsKeyDown(Enum.KeyCode.S) then move += Vector3.new(0,0, 1) end
                if UIS:IsKeyDown(Enum.KeyCode.A) then move += Vector3.new(-1,0,0) end
                if UIS:IsKeyDown(Enum.KeyCode.D) then move += Vector3.new( 1,0,0) end
                if move == Vector3.zero then return end
                local flat = CFrame.new(Vector3.zero, Vector3.new(cam.CFrame.LookVector.X,0,cam.CFrame.LookVector.Z))
                hrp.CFrame = hrp.CFrame + flat:VectorToWorldSpace(move.Unit) * spd * dt
            end)
        elseif _G.spdConn then _G.spdConn:Disconnect(); _G.spdConn = nil end
    end,
})

spdSec:AddSlider({ Name = "Speed Value", Flag = "spdval", Min = 16, Max = 500, Default = 60, Decimals = 0 })

local statSec = UI.MakeSection(mL, "Character")
statSec._tabName(mTab, mSwitch)

statSec:AddSlider({
    Name = "WalkSpeed", Flag = "ws", Min = 0, Max = 500, Default = 16, Decimals = 0,
    Callback = function(v) pcall(function() local h = getHum(); if h then h.WalkSpeed = v end end) end,
})
statSec:AddSlider({
    Name = "JumpPower", Flag = "jp", Min = 0, Max = 500, Default = 50, Decimals = 0,
    Callback = function(v) pcall(function() local h = getHum(); if h then h.JumpPower = v end end) end,
})

local worldSec = UI.MakeSection(mR, "World")
worldSec._tabName(mTab, mSwitch)

worldSec:AddSlider({
    Name = "Gravity", Flag = "grav", Min = 0, Max = 300, Default = 196, Decimals = 0,
    Callback = function(v) pcall(function() workspace.Gravity = v end) end,
})
worldSec:AddSlider({
    Name = "Field of View", Flag = "fov", Min = 30, Max = 120, Default = 70, Decimals = 0,
    Callback = function(v) pcall(function() workspace.CurrentCamera.FieldOfView = v end) end,
})

worldSec:AddDivider()

worldSec:AddToggle({
    Name = "Fullbright", Flag = "fb", Default = false,
    Keybind = Enum.KeyCode.B,
    Callback = function(v)
        local L = game:GetService("Lighting")
        if v then L.Brightness = 2; L.FogEnd = 100000
        else L.Brightness = 1; L.FogEnd = 100000 end
    end,
})

-- ══════════════════════════════════════════════════
--  SETTINGS TAB
-- ══════════════════════════════════════════════════

local uiSec = UI.MakeSection(sL, "UI")
uiSec._tabName(sTab, sSwitch)

-- Flag "tkey" auto-updates the toggle keybind
uiSec:AddKeybind({ Name = "Toggle UI",  Flag = "RightShift", Default = Enum.KeyCode.RightShift })
uiSec:AddCheckbox({ Name = "Watermark", Flag = "wm",   Default = true,  Callback = function(v) UI.wmFrame.Visible = v end })
-- StopSnow hides both snow particles and the dark overlay; StartSnow brings both back
uiSec:AddCheckbox({ Name = "Snow",      Flag = "snow", Default = true,  Callback = function(v) if v then UI.StartSnow() else UI.StopSnow() end end })
uiSec:AddCheckbox({ Name = "Overlay",   Flag = "ov",   Default = true,  Callback = function(v) UI.SetOverlay(v) end })

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

local cfgSec = UI.MakeSection(sL, "Configs")
cfgSec._tabName(sTab, sSwitch)

local cfgBox = cfgSec:AddTextBox({ Name = "Config Name", Flag = "cfgname", Placeholder = "e.g. default" })
cfgSec:AddButton({ Name = "Save",        Callback = function() local n = cfgBox:Get(); if n ~= "" then UI.SaveConfig(n);    UI.Notify("Config", "Saved: "    .. n, "Success", 3) end end })
cfgSec:AddButton({ Name = "Load",        Callback = function() local n = cfgBox:Get(); if n ~= "" then UI.LoadConfig(n);    UI.Notify("Config", "Loaded: "   .. n, "Success", 3) end end })
cfgSec:AddButton({ Name = "Delete",      Callback = function() local n = cfgBox:Get(); if n ~= "" then UI.DeleteConfig(n); UI.Notify("Config", "Deleted: "  .. n, "Success", 3) end end })
cfgSec:AddButton({ Name = "Set Autoload",Callback = function() local n = cfgBox:Get(); if n ~= "" then UI.SetAutoLoad(n);  UI.Notify("Config", "Autoload → " .. n, "Success", 3) end end })

-- ── DONE ──────────────────────────────────────────
UI.Notify("WhoaUI Demo", "All features loaded!", "Success", 4)
