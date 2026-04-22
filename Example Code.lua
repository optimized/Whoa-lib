local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/optimized/Whoa-lib/refs/heads/main/WhoaUI_lib.lua"))()

UI.Setup({
    Keys        = {"test"},
    KeyURL      = "https://discord.gg/Q9xJ5s5RFg",
    KeyPersist  = false,
    Name        = "whoa",
    Version     = "v2.2",
    Icon        = "rbxassetid://134387754737125",
    SectionIcon = "rbxassetid://134387754737125",
    Snow        = true,
})

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS        = game:GetService("UserInputService")
local lp         = Players.LocalPlayer

-- ── ESP ───────────────────────────────────────────────────
local espObjs = {}
local function removeESP(p) if espObjs[p] then espObjs[p]:Destroy(); espObjs[p]=nil end end
local function addESP(p)
    if p==lp or not p.Character then return end
    removeESP(p)
    local h = Instance.new("Highlight")
    h.Adornee = p.Character; h.FillTransparency=1
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop; h.OutlineTransparency=0
    local teamCheck = UI.Flags["espteam"] and p.Team and lp.Team
    h.OutlineColor = teamCheck and (p.Team==lp.Team and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,60,60)) or (UI.Flags["espcol"] or Color3.fromRGB(255,80,80))
    h.Parent = p.Character; espObjs[p]=h
end
local function refreshESP()
    for p in pairs(espObjs) do removeESP(p) end
    if not UI.Flags["esp"] then return end
    for _,p in ipairs(Players:GetPlayers()) do addESP(p) end
end
RunService.Heartbeat:Connect(function()
    if not UI.Flags["esp"] then return end
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=lp and p.Character and (not espObjs[p] or espObjs[p].Adornee~=p.Character) then addESP(p) end
    end
end)
Players.PlayerAdded:Connect(function(p) p.CharacterAdded:Connect(function() task.wait(0.5); if UI.Flags["esp"] then addESP(p) end end) end)
Players.PlayerRemoving:Connect(removeESP)

-- ── CFRAME SPEED ──────────────────────────────────────────
local speedConn = nil
local function startSpeed()
    if speedConn then return end
    speedConn = RunService.Heartbeat:Connect(function(dt)
        if not UI.Flags["speed"] then return end
        local char = lp.Character; if not char then return end
        local hrp  = char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
        local spd  = UI.Flags["speedval"] or 50
        local move = Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then move += Vector3.new(0,0,-1) end
        if UIS:IsKeyDown(Enum.KeyCode.S) then move += Vector3.new(0,0, 1) end
        if UIS:IsKeyDown(Enum.KeyCode.A) then move += Vector3.new(-1,0,0) end
        if UIS:IsKeyDown(Enum.KeyCode.D) then move += Vector3.new( 1,0,0) end
        if move == Vector3.zero then return end
        move = move.Unit
        local cam  = workspace.CurrentCamera
        local flat = CFrame.new(Vector3.zero, Vector3.new(cam.CFrame.LookVector.X, 0, cam.CFrame.LookVector.Z))
        hrp.CFrame = hrp.CFrame + flat:VectorToWorldSpace(move) * spd * dt
    end)
end
local function stopSpeed()
    if speedConn then speedConn:Disconnect(); speedConn=nil end
end

-- Bind speed toggle keybind to the flag
UIS.InputBegan:Connect(function(i)
    local kb = UI.Flags["speedkey"]
    if kb and i.KeyCode == kb then
        UI.Flags["speed"] = not UI.Flags["speed"]
        if UI.Flags["speed"] then startSpeed() else stopSpeed() end
    end
end)

-- ── TABS ──────────────────────────────────────────────────
local mL, mR, mTab, mSwitch = UI.AddTab("Main")
local sL, sR, sTab, sSwitch = UI.AddTab("Settings")
local cL, cR, cTab, cSwitch = UI.AddTab("Character")

-- ── MAIN — ESP ────────────────────────────────────────────
local espSec = UI.MakeSection(mL, "ESP")
espSec._tabName(mTab, mSwitch)
espSec:AddCheckbox({Name="ESP",        Flag="esp",     Default=false, Callback=function() refreshESP() end})
espSec:AddCheckbox({Name="Team Check", Flag="espteam", Default=true,  Callback=function() refreshESP() end})
espSec:AddColorPicker({Name="ESP Color", Flag="espcol", Default=Color3.fromRGB(255,80,80), Callback=function() refreshESP() end})

local infoSec = UI.MakeSection(mR, "Info")
infoSec._tabName(mTab, mSwitch)
infoSec:AddLabel({Name="Highlights enemies in red,"})
infoSec:AddLabel({Name="teammates in green (team check)."})
infoSec:AddLabel({Name="Custom color when team check off."})
infoSec:AddDivider()
infoSec:AddLabel({Name="Speed bypasses server WalkSpeed"})
infoSec:AddLabel({Name="via CFrame — camera-relative."})

-- ── MAIN — SPEED ──────────────────────────────────────────
local spdSec = UI.MakeSection(mL, "Speed")
spdSec._tabName(mTab, mSwitch)
spdSec:AddCheckbox({Name="Speed", Flag="speed", Default=false, Callback=function(v)
    if v then startSpeed() else stopSpeed() end
end})
spdSec:AddSlider({Name="Speed Value", Flag="speedval", Min=10, Max=500, Default=50, Decimals=0, Callback=function() end})
spdSec:AddKeybind({Name="Speed Toggle Key", Flag="speedkey", Default=Enum.KeyCode.Q, Callback=function() end})

-- ── SETTINGS — GENERAL ────────────────────────────────────
local genSec = UI.MakeSection(sL, "General")
genSec._tabName(sTab, sSwitch)
genSec:AddCheckbox({Name="Snowfall",       Flag="snow", Default=true,  Callback=function(v) if v then UI.StartSnow() else UI.StopSnow() end end})
genSec:AddCheckbox({Name="Anonymous Mode", Flag="anon", Default=false, Callback=function(v)
    UI.pbNameLabel.Text = v and "Hidden" or lp.DisplayName
    UI.avImg.Image = v and "rbxassetid://1353560252" or (UI.realAvatar() or "")
end})
genSec:AddCheckbox({Name="Watermark", Flag="wm", Default=true, Callback=function(v) UI.wmFrame.Visible=v end})
genSec:AddKeybind({Name="Toggle UI", Flag="tkey", Default=Enum.KeyCode.RightShift, Callback=function() end})

-- ── SETTINGS — THEME ──────────────────────────────────────
local themeSec = UI.MakeSection(sR, "Theme")
themeSec._tabName(sTab, sSwitch)
themeSec:AddColorPicker({Name="Accent Color", Flag="accent", Default=Color3.fromRGB(255,182,215), Callback=function(c) UI.SetAccent(c) end})

-- ── SETTINGS — CONFIGS ────────────────────────────────────
-- Note: configs do NOT auto-save. Use the buttons below.
local cfgSec = UI.MakeSection(sL, "Configs")
cfgSec._tabName(sTab, sSwitch)

local cfgNameBox = cfgSec:AddTextBox({Name="Config Name", Flag="cfgname", Placeholder="e.g. default", Default=""})

cfgSec:AddButton({Name="Save Config", Callback=function()
    local name = cfgNameBox:Get()
    if name=="" then UI.Notify("Config","Enter a config name first.","Warning",3); return end
    UI.SaveConfig(name)
    UI.Notify("Config","Saved: "..name,"Success",3)
end})

cfgSec:AddButton({Name="Load Config", Callback=function()
    local name = cfgNameBox:Get()
    if name=="" then UI.Notify("Config","Enter a config name first.","Warning",3); return end
    local ok = UI.LoadConfig(name)
    UI.Notify("Config", ok and ("Loaded: "..name) or "Config not found.", ok and "Success" or "Error", 3)
end})

cfgSec:AddButton({Name="Set as Autoload", Callback=function()
    local name = cfgNameBox:Get()
    if name=="" then UI.Notify("Config","Enter a config name first.","Warning",3); return end
    UI.SetAutoLoad(name)
    UI.Notify("Config","Autoload set to: "..name,"Success",3)
end})

cfgSec:AddButton({Name="Clear Autoload", Callback=function()
    UI.SetAutoLoad("")
    UI.Notify("Config","Autoload cleared.","Success",3)
end})

cfgSec:AddButton({Name="Delete Config", Callback=function()
    local name = cfgNameBox:Get()
    if name=="" then UI.Notify("Config","Enter a config name first.","Warning",3); return end
    UI.DeleteConfig(name)
    UI.Notify("Config","Deleted: "..name,"Success",3)
end})

cfgSec:AddDivider()
cfgSec:AddLabel({Name="Autoload: "..(UI.GetAutoLoad() or "none")})

-- ── CHARACTER — KORBLOX ───────────────────────────────────
local function setLegVis(char, t)
    local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then return end
    local parts = hum.RigType==Enum.HumanoidRigType.R15 and {"RightUpperLeg","RightLowerLeg","RightFoot"} or {"Right Leg"}
    for _,n in ipairs(parts) do local p=char:FindFirstChild(n); if p then p.Transparency=t end end
end
local function applyKorblox(char)
    local hum = char:WaitForChild("Humanoid",5); if not hum then return end
    task.wait(0.5); setLegVis(char,1)
    local ok,obj = pcall(function() return game:GetObjects("rbxassetid://139607718")[1] end)
    if not ok or not obj then return end
    local legPart = obj:IsA("Accessory") and obj:FindFirstChild("Handle") or obj:FindFirstChildWhichIsA("MeshPart",true)
    if not legPart then return end
    local clone = legPart:Clone(); clone.Anchored=false; clone.CanCollide=false; clone.Massless=true; clone.Name="KorbloxLeg"
    local rl = char:FindFirstChild(hum.RigType==Enum.HumanoidRigType.R15 and "RightUpperLeg" or "Right Leg")
    if not rl then return end
    clone.Parent = char
    local w = Instance.new("Weld"); w.Part0=rl; w.Part1=clone; w.Parent=clone
end
local function removeKorblox(char)
    if not char then return end
    local k=char:FindFirstChild("KorbloxLeg"); if k then k:Destroy() end
    setLegVis(char, 0)
end

local kSec = UI.MakeSection(cL, "Korblox")
kSec._tabName(cTab, cSwitch)
kSec:AddCheckbox({Name="Korblox Leg", Flag="korblox", Default=false, Callback=function(v)
    local char=lp.Character; if not char then return end
    if v then task.spawn(applyKorblox,char) else removeKorblox(char) end
end})

-- ── CHARACTER — HATS ─────────────────────────────────────
local hatCount  = 0
local activeHats = {}

local function applyWeld(hd)
    if not hd.weld or not hd.weld.Parent then return end
    hd.weld.C0 = (hd.baseC0 or CFrame.new()) * CFrame.new(hd.ox, hd.oy, hd.oz)
end
local function spawnHat(hd)
    local char = lp.Character; if not char then return end
    local head = char:WaitForChild("Head",5); if not head then return end
    local ok,acc = pcall(function() return game:GetObjects("rbxassetid://"..hd.id)[1] end)
    if not ok or not acc or not acc:IsA("Accessory") then UI.Notify("Hat","Failed to load ID "..hd.id,"Error",3); return end
    local handle = acc:FindFirstChild("Handle"); if not handle then return end
    handle.CanCollide=false; handle.Massless=true; acc.Parent=char
    local weld = Instance.new("Weld"); weld.Part0=head; weld.Part1=handle
    local att = handle:FindFirstChildOfClass("Attachment")
    local headAtt = head:FindFirstChild("HatAttachment")
    if att and headAtt then hd.baseC0=headAtt.CFrame; weld.C1=att.CFrame
    else hd.baseC0=CFrame.new(); weld.C1=CFrame.new() end
    weld.Parent=handle; hd.accessory=acc; hd.weld=weld
    applyWeld(hd)
end
local function addHatUI(id)
    hatCount += 1; local n = hatCount
    local hd = {id=id, ox=0, oy=0, oz=0, accessory=nil, weld=nil, baseC0=nil}
    table.insert(activeHats, hd)
    task.spawn(function() spawnHat(hd) end)
    local sec = UI.MakeSection(cR, "Hat "..id)
    sec._tabName(cTab, cSwitch)
    sec:AddSlider({Name="X  Left / Right", Flag="hx"..n, Min=-3, Max=3, Default=0, Decimals=2, Callback=function(v) hd.ox=v; applyWeld(hd) end})
    sec:AddSlider({Name="Y  Up / Down",    Flag="hy"..n, Min=-3, Max=3, Default=0, Decimals=2, Callback=function(v) hd.oy=v; applyWeld(hd) end})
    sec:AddSlider({Name="Z  Fwd / Back",   Flag="hz"..n, Min=-3, Max=3, Default=0, Decimals=2, Callback=function(v) hd.oz=v; applyWeld(hd) end})
    sec:AddButton({Name="Remove Hat", Callback=function()
        if hd.accessory and hd.accessory.Parent then hd.accessory:Destroy() end
        for i,v in ipairs(activeHats) do if v==hd then table.remove(activeHats,i); break end end
        sec.Destroy()
    end})
end

local hatAdd = UI.MakeSection(cL, "Add Hat")
hatAdd._tabName(cTab, cSwitch)
local hatIdBox = hatAdd:AddTextBox({Name="Asset ID", Flag="hatid", Placeholder="e.g. 1235488", Default=""})
hatAdd:AddButton({Name="Add Hat", Callback=function()
    local id = tonumber(hatIdBox:Get())
    if not id then UI.Notify("Error","Invalid asset ID","Error",3); return end
    addHatUI(id)
    UI.Notify("Hat","Hat "..id.." added!","Success",3)
end})

-- ── RESPAWN ───────────────────────────────────────────────
lp.CharacterAdded:Connect(function(char)
    if UI.Flags["korblox"] then task.spawn(applyKorblox,char) end
    for _,hd in ipairs(activeHats) do
        hd.accessory=nil; hd.weld=nil; task.spawn(function() spawnHat(hd) end)
    end
    if UI.Flags["esp"] then task.wait(1); refreshESP() end
    if UI.Flags["speed"] then stopSpeed(); startSpeed() end
end)

UI.Notify("whoa", "Loaded successfully!", "Success", 3)
