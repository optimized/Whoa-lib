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

-- ══════════════════════════════════════════════════
--  ESP
-- ══════════════════════════════════════════════════
local espObjs = {}
local function removeESP(p) if espObjs[p] then espObjs[p]:Destroy(); espObjs[p]=nil end end
local function addESP(p)
    if p==lp or not p.Character then return end
    removeESP(p)
    local h = Instance.new("Highlight")
    h.Adornee = p.Character; h.FillTransparency=1
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop; h.OutlineTransparency=0
    local tc = UI.Flags["espteam"] and p.Team and lp.Team
    h.OutlineColor = tc and (p.Team==lp.Team and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,60,60)) or (UI.Flags["espcol"] or Color3.fromRGB(255,80,80))
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

-- ══════════════════════════════════════════════════
--  SPEED (CFrame — bypasses server WalkSpeed)
-- ══════════════════════════════════════════════════
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
        local cam  = workspace.CurrentCamera
        local flat = CFrame.new(Vector3.zero, Vector3.new(cam.CFrame.LookVector.X, 0, cam.CFrame.LookVector.Z))
        hrp.CFrame = hrp.CFrame + flat:VectorToWorldSpace(move.Unit) * spd * dt
    end)
end
local function stopSpeed()
    if speedConn then speedConn:Disconnect(); speedConn=nil end
end

-- ══════════════════════════════════════════════════
--  FLY
-- ══════════════════════════════════════════════════
local flyConn = nil
local function startFly()
    if flyConn then return end
    pcall(function()
        local char = lp.Character; if not char then return end
        local hum  = char:FindFirstChildOfClass("Humanoid"); if not hum then return end
        hum.PlatformStand = true
    end)
    flyConn = RunService.Heartbeat:Connect(function(dt)
        if not UI.Flags["fly"] then return end
        local char = lp.Character; if not char then return end
        local hrp  = char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
        local spd  = UI.Flags["flyspeed"] or 40
        local move = Vector3.zero
        local cam  = workspace.CurrentCamera
        if UIS:IsKeyDown(Enum.KeyCode.W)           then move += cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S)           then move -= cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A)           then move -= cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D)           then move += cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space)       then move += Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.new(0,1,0) end
        hrp.AssemblyLinearVelocity = (move.Magnitude>0 and move.Unit or move) * spd
    end)
end
local function stopFly()
    if flyConn then flyConn:Disconnect(); flyConn=nil end
    pcall(function()
        local char = lp.Character; if not char then return end
        local hum  = char:FindFirstChildOfClass("Humanoid"); if not hum then return end
        hum.PlatformStand = false
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.AssemblyLinearVelocity = Vector3.zero end
    end)
end

-- ══════════════════════════════════════════════════
--  NOCLIP
-- ══════════════════════════════════════════════════
local noclipConn = nil
local function startNoClip()
    if noclipConn then return end
    noclipConn = RunService.Stepped:Connect(function()
        if not UI.Flags["noclip"] then return end
        local char = lp.Character; if not char then return end
        for _,p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end)
end
local function stopNoClip()
    if noclipConn then noclipConn:Disconnect(); noclipConn=nil end
    pcall(function()
        local char = lp.Character; if not char then return end
        for _,p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = true end
        end
    end)
end

-- ══════════════════════════════════════════════════
--  INFINITE JUMP
-- ══════════════════════════════════════════════════
local infJumpConn = nil
local function startInfJump()
    if infJumpConn then return end
    infJumpConn = UIS.JumpRequest:Connect(function()
        if not UI.Flags["infjump"] then return end
        local char = lp.Character; if not char then return end
        local hum  = char:FindFirstChildOfClass("Humanoid"); if not hum then return end
        local hrp  = char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
        hrp:ApplyImpulse(Vector3.new(0, hum.JumpPower * hrp.AssemblyMass, 0))
    end)
end
local function stopInfJump()
    if infJumpConn then infJumpConn:Disconnect(); infJumpConn=nil end
end

-- ══════════════════════════════════════════════════
--  FULLBRIGHT
-- ══════════════════════════════════════════════════
local origLighting = {}
local function applyFullbright(on)
    local L = game:GetService("Lighting")
    if on then
        origLighting = {Brightness=L.Brightness, ClockTime=L.ClockTime, FogEnd=L.FogEnd,
            Ambient=L.Ambient, OutdoorAmbient=L.OutdoorAmbient}
        L.Brightness=2; L.ClockTime=14; L.FogEnd=100000
        L.Ambient=Color3.fromRGB(180,180,180); L.OutdoorAmbient=Color3.fromRGB(180,180,180)
    else
        for k,v in pairs(origLighting) do pcall(function() L[k]=v end) end
    end
end

-- ══════════════════════════════════════════════════
--  KORBLOX
-- ══════════════════════════════════════════════════
local function setLegVis(char, t)
    local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then return end
    local parts = hum.RigType==Enum.HumanoidRigType.R15
        and {"RightUpperLeg","RightLowerLeg","RightFoot"} or {"Right Leg"}
    for _,n in ipairs(parts) do local p=char:FindFirstChild(n); if p then p.Transparency=t end end
end
local function applyKorblox(char)
    local hum = char:WaitForChild("Humanoid",5); if not hum then return end
    task.wait(0.5); setLegVis(char,1)
    local ok,obj = pcall(function() return game:GetObjects("rbxassetid://139607718")[1] end)
    if not ok or not obj then return end
    local legPart = obj:IsA("Accessory") and obj:FindFirstChild("Handle") or obj:FindFirstChildWhichIsA("MeshPart",true)
    if not legPart then return end
    local clone = legPart:Clone()
    clone.Anchored=false; clone.CanCollide=false; clone.Massless=true; clone.Name="KorbloxLeg"
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

-- ══════════════════════════════════════════════════
--  HATS
-- ══════════════════════════════════════════════════
local hatCount   = 0
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
    local att     = handle:FindFirstChildOfClass("Attachment")
    local headAtt = head:FindFirstChild("HatAttachment")
    if att and headAtt then hd.baseC0=headAtt.CFrame; weld.C1=att.CFrame
    else hd.baseC0=CFrame.new(); weld.C1=CFrame.new() end
    weld.Parent=handle; hd.accessory=acc; hd.weld=weld
    applyWeld(hd)
end

-- ══════════════════════════════════════════════════
--  TABS
-- ══════════════════════════════════════════════════
local mL,  mR,  mTab,  mSwitch  = UI.AddTab("Main")
local mvL, mvR, mvTab, mvSwitch = UI.AddTab("Movement")
local sL,  sR,  sTab,  sSwitch  = UI.AddTab("Settings")
local cL,  cR,  cTab,  cSwitch  = UI.AddTab("Character")
local wL,  wR,  wTab,  wSwitch  = UI.AddTab("World")

-- ══════════════════════════════════════════════════
--  MAIN — ESP
-- ══════════════════════════════════════════════════
local espSec = UI.MakeSection(mL, "ESP")
espSec._tabName(mTab, mSwitch)
espSec:AddToggle({Name="ESP",        Flag="esp",     Default=false, Keybind=Enum.KeyCode.E, Callback=function() refreshESP() end})
espSec:AddToggle({Name="Team Check", Flag="espteam", Default=true,                          Callback=function() refreshESP() end})
espSec:AddColorPicker({Name="ESP Color", Flag="espcol", Default=Color3.fromRGB(255,80,80),  Callback=function() refreshESP() end})

local infoSec = UI.MakeSection(mR, "Info")
infoSec._tabName(mTab, mSwitch)
infoSec:AddLabel({Name="Highlights enemies in red,"})
infoSec:AddLabel({Name="teammates in green (team check)."})
infoSec:AddDivider()
infoSec:AddLabel({Name="Speed: CFrame-based, bypasses"})
infoSec:AddLabel({Name="server WalkSpeed limits."})
infoSec:AddDivider()
infoSec:AddLabel({Name="Fly: WASD + Space/LCtrl."})

-- ══════════════════════════════════════════════════
--  MOVEMENT — SPEED
-- ══════════════════════════════════════════════════
local spdSec = UI.MakeSection(mvL, "CFrame Speed")
spdSec._tabName(mvTab, mvSwitch)
local speedToggle = spdSec:AddToggle({Name="Speed", Flag="speed", Default=false, Callback=function(v)
    if v then startSpeed() else stopSpeed() end
end})
spdSec:AddSlider({Name="Speed Value", Flag="speedval", Min=10, Max=500, Default=50, Decimals=0})
spdSec:AddKeybind({Name="Speed Key", Flag="speedkey", Default=Enum.KeyCode.Q})

-- ══════════════════════════════════════════════════
--  MOVEMENT — FLY
-- ══════════════════════════════════════════════════
local flySec = UI.MakeSection(mvL, "Fly")
flySec._tabName(mvTab, mvSwitch)
local flyToggle = flySec:AddToggle({Name="Fly", Flag="fly", Default=false, Callback=function(v)
    if v then startFly() else stopFly() end
end})
flySec:AddSlider({Name="Fly Speed", Flag="flyspeed", Min=5, Max=300, Default=40, Decimals=0})
flySec:AddKeybind({Name="Fly Key", Flag="flykey", Default=Enum.KeyCode.F})

-- ══════════════════════════════════════════════════
--  MOVEMENT — MODIFIERS
-- ══════════════════════════════════════════════════
local moveSec = UI.MakeSection(mvR, "Modifiers")
moveSec._tabName(mvTab, mvSwitch)
local ncToggle = moveSec:AddToggle({Name="NoClip",        Flag="noclip",  Default=false, Keybind=Enum.KeyCode.N, Callback=function(v)
    if v then startNoClip() else stopNoClip() end
end})
local ijToggle = moveSec:AddToggle({Name="Infinite Jump", Flag="infjump", Default=false, Keybind=Enum.KeyCode.J, Callback=function(v)
    if v then startInfJump() else stopInfJump() end
end})
moveSec:AddDivider()
moveSec:AddSlider({Name="Walk Speed", Flag="walkspeed", Min=8, Max=500, Default=16, Decimals=0, Callback=function(v)
    pcall(function()
        local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = v end
    end)
end})
moveSec:AddSlider({Name="Jump Power", Flag="jumppower", Min=7, Max=500, Default=50, Decimals=0, Callback=function(v)
    pcall(function()
        local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.JumpPower = v end
    end)
end})

-- Sync external keybinds (Speed Key / Fly Key) to their toggle UI elements
UIS.InputBegan:Connect(function(i)
    if i.UserInputType ~= Enum.UserInputType.Keyboard then return end
    local sk = UI.Flags["speedkey"]
    if sk and i.KeyCode == sk then
        local v = not UI.Flags["speed"]
        speedToggle.Set(v)
        if v then startSpeed() else stopSpeed() end
    end
    local fk = UI.Flags["flykey"]
    if fk and i.KeyCode == fk then
        local v = not UI.Flags["fly"]
        flyToggle.Set(v)
        if v then startFly() else stopFly() end
    end
end)

-- ══════════════════════════════════════════════════
--  SETTINGS — GENERAL
-- ══════════════════════════════════════════════════
local genSec = UI.MakeSection(sL, "General")
genSec._tabName(sTab, sSwitch)
genSec:AddToggle({Name="Snowfall",       Flag="snow", Default=true,  Callback=function(v) if v then UI.StartSnow() else UI.StopSnow() end end})
genSec:AddToggle({Name="Anonymous Mode", Flag="anon", Default=false, Callback=function(v)
    UI.pbNameLabel.Text = v and "Hidden" or lp.DisplayName
    UI.avImg.Image      = v and "rbxassetid://1353560252" or (UI.realAvatar() or "")
end})
genSec:AddToggle({Name="Watermark", Flag="wm", Default=true, Callback=function(v) UI.wmFrame.Visible=v end})
genSec:AddKeybind({Name="Toggle UI", Flag="tkey", Default=Enum.KeyCode.RightShift})

-- ══════════════════════════════════════════════════
--  SETTINGS — THEME
-- ══════════════════════════════════════════════════
local themeSec = UI.MakeSection(sR, "Theme")
themeSec._tabName(sTab, sSwitch)
themeSec:AddColorPicker({Name="Accent Color", Flag="accent", Default=Color3.fromRGB(255,182,215), Callback=function(c) UI.SetAccent(c) end})

-- ══════════════════════════════════════════════════
--  SETTINGS — CONFIGS
-- ══════════════════════════════════════════════════
-- Re-apply all stateful features after a config is loaded
local function reapplyAllFlags()
    if UI.Flags["speed"]      then startSpeed()      else stopSpeed()      end
    if UI.Flags["fly"]        then startFly()         else stopFly()        end
    if UI.Flags["noclip"]     then startNoClip()      else stopNoClip()     end
    if UI.Flags["infjump"]    then startInfJump()     else stopInfJump()    end
    applyFullbright(UI.Flags["fullbright"] or false)
    refreshESP()
    pcall(function()
        local char = lp.Character; if not char then return end
        local hum  = char:FindFirstChildOfClass("Humanoid"); if not hum then return end
        if UI.Flags["walkspeed"] then hum.WalkSpeed = UI.Flags["walkspeed"] end
        if UI.Flags["jumppower"] then hum.JumpPower  = UI.Flags["jumppower"] end
        if UI.Flags["fov"]     then workspace.CurrentCamera.FieldOfView = UI.Flags["fov"]     end
        if UI.Flags["gravity"] then workspace.Gravity                   = UI.Flags["gravity"] end
    end)
end

local cfgSec = UI.MakeSection(sL, "Configs")
cfgSec._tabName(sTab, sSwitch)
local cfgNameBox = cfgSec:AddTextBox({Name="Config Name", Flag="cfgname", Placeholder="e.g. default", Default=""})
cfgSec:AddButton({Name="Save Config", Callback=function()
    local name = cfgNameBox:Get()
    if name=="" then UI.Notify("Config","Enter a name first.","Warning",3); return end
    UI.SaveConfig(name); UI.Notify("Config","Saved: "..name,"Success",3)
end})
cfgSec:AddButton({Name="Load Config", Callback=function()
    local name = cfgNameBox:Get()
    if name=="" then UI.Notify("Config","Enter a name first.","Warning",3); return end
    local ok = UI.LoadConfig(name)
    UI.Notify("Config", ok and "Loaded: "..name or "Config not found.", ok and "Success" or "Error", 3)
    -- Re-apply features so you don't have to toggle off/on again
    if ok then task.defer(reapplyAllFlags) end
end})
cfgSec:AddButton({Name="Set as Autoload", Callback=function()
    local name = cfgNameBox:Get()
    if name=="" then UI.Notify("Config","Enter a name first.","Warning",3); return end
    UI.SetAutoLoad(name); UI.Notify("Config","Autoload → "..name,"Success",3)
end})
cfgSec:AddButton({Name="Clear Autoload", Callback=function()
    UI.SetAutoLoad(""); UI.Notify("Config","Autoload cleared.","Success",3)
end})
cfgSec:AddButton({Name="Delete Config", Callback=function()
    local name = cfgNameBox:Get()
    if name=="" then UI.Notify("Config","Enter a name first.","Warning",3); return end
    UI.DeleteConfig(name); UI.Notify("Config","Deleted: "..name,"Success",3)
end})
cfgSec:AddDivider()
cfgSec:AddLabel({Name="Autoload: "..(UI.GetAutoLoad() or "none")})

-- ══════════════════════════════════════════════════
--  CHARACTER — KORBLOX
-- ══════════════════════════════════════════════════
local kSec = UI.MakeSection(cL, "Korblox")
kSec._tabName(cTab, cSwitch)
kSec:AddToggle({Name="Korblox Leg", Flag="korblox", Default=false, Callback=function(v)
    local char=lp.Character; if not char then return end
    if v then task.spawn(applyKorblox,char) else removeKorblox(char) end
end})

-- ══════════════════════════════════════════════════
--  CHARACTER — HATS
-- ══════════════════════════════════════════════════
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
    addHatUI(id); UI.Notify("Hat","Hat "..id.." added!","Success",3)
end})

-- ══════════════════════════════════════════════════
--  WORLD — VISUALS
-- ══════════════════════════════════════════════════
local fbSec = UI.MakeSection(wL, "Visuals")
fbSec._tabName(wTab, wSwitch)
fbSec:AddToggle({Name="Fullbright", Flag="fullbright", Default=false, Keybind=Enum.KeyCode.B, Callback=function(v)
    applyFullbright(v)
end})
fbSec:AddSlider({Name="Field of View", Flag="fov",     Min=30, Max=120, Default=70,  Decimals=0, Callback=function(v)
    pcall(function() workspace.CurrentCamera.FieldOfView = v end)
end})
fbSec:AddSlider({Name="Gravity",       Flag="gravity", Min=0,  Max=300, Default=196, Decimals=0, Callback=function(v)
    pcall(function() workspace.Gravity = v end)
end})

-- ══════════════════════════════════════════════════
--  WORLD — RENDER QUALITY
-- ══════════════════════════════════════════════════
local renderSec = UI.MakeSection(wR, "Render Quality")
renderSec._tabName(wTab, wSwitch)
renderSec:AddDropdown({
    Name="Quality Level", Flag="renderq",
    Items={"Automatic","1","2","3","4","5","6","7","8","9","10"},
    Default="Automatic",
    Callback=function(v)
        pcall(function()
            if v=="Automatic" then settings().Rendering.QualityLevel=Enum.QualityLevel.Automatic
            else settings().Rendering.QualityLevel=tonumber(v) end
        end)
    end
})

-- ══════════════════════════════════════════════════
--  RESPAWN — re-apply everything on death/rejoin
-- ══════════════════════════════════════════════════
lp.CharacterAdded:Connect(function(char)
    -- Korblox auto-applies — no need to toggle off/on
    if UI.Flags["korblox"] then task.spawn(applyKorblox, char) end
    for _,hd in ipairs(activeHats) do
        hd.accessory=nil; hd.weld=nil; task.spawn(function() spawnHat(hd) end)
    end
    if UI.Flags["esp"]     then task.wait(1); refreshESP() end
    if UI.Flags["speed"]   then stopSpeed();   startSpeed()   end
    if UI.Flags["fly"]     then stopFly();     startFly()     end
    if UI.Flags["noclip"]  then stopNoClip();  startNoClip()  end
    if UI.Flags["infjump"] then stopInfJump(); startInfJump() end
    -- Re-apply humanoid stats after character loads
    task.wait(0.5)
    pcall(function()
        local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then return end
        if UI.Flags["walkspeed"] then hum.WalkSpeed = UI.Flags["walkspeed"] end
        if UI.Flags["jumppower"] then hum.JumpPower  = UI.Flags["jumppower"] end
    end)
end)

-- ══════════════════════════════════════════════════
--  INITIAL STATE — run once on load so autoloaded
--  configs and defaults take effect immediately,
--  without needing to toggle anything off and on
-- ══════════════════════════════════════════════════
task.defer(function()
    local char = lp.Character
    if char then
        if UI.Flags["korblox"] then task.spawn(applyKorblox, char) end
        pcall(function()
            local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then return end
            if UI.Flags["walkspeed"] and UI.Flags["walkspeed"]~=16  then hum.WalkSpeed=UI.Flags["walkspeed"] end
            if UI.Flags["jumppower"] and UI.Flags["jumppower"]~=50  then hum.JumpPower =UI.Flags["jumppower"] end
        end)
    end
    if UI.Flags["speed"]      then startSpeed()   end
    if UI.Flags["fly"]        then startFly()      end
    if UI.Flags["noclip"]     then startNoClip()   end
    if UI.Flags["infjump"]    then startInfJump()  end
    if UI.Flags["fullbright"] then applyFullbright(true) end
    pcall(function()
        if UI.Flags["fov"]     then workspace.CurrentCamera.FieldOfView = UI.Flags["fov"]     end
        if UI.Flags["gravity"] then workspace.Gravity                   = UI.Flags["gravity"] end
    end)
end)

UI.Notify("whoa", "Loaded successfully!", "Success", 3)
