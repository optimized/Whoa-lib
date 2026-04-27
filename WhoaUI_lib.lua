local SCRIPT_NAME,SCRIPT_VERSION = "script","v1.0"
local WIN_WIDTH,WIN_HEIGHT = 700,500
local TOGGLE_KEY = Enum.KeyCode.RightShift
local NOTIF_DURATION,WM_SHOW = 3,true

--[[
QUICK START FOR DEVS:
─────────────────────────────────────────────
local UI = loadstring(game:HttpGet("YOUR_RAW_URL"))()

UI.Setup({
    Name        = "My Script",   -- window title + watermark
    Version     = "v1.0",        -- shown in watermark
    Icon        = "rbxassetid://YOUR_ID",  -- optional icon
    Snow        = false,         -- snow particles
    Keys        = {"mykey123"},  -- key system (remove line if no key)
    KeyURL      = "https://discord.gg/yourlink",
    KeyPersist  = true,          -- saves key so user only enters once
})

-- Adding tabs:
local colL, colR, tabName, tabSwitch = UI.AddTab("Tab Name")

-- Adding a section to left column:
local sec = UI.MakeSection(colL, "Section Title")
sec._tabName(tabName, tabSwitch)

-- Elements:
sec:AddToggle({  Name="My Toggle",  Flag="tog1",  Default=false,  Callback=function(v) end })
sec:AddCheckbox({Name="My Check",   Flag="chk1",  Default=false,  Callback=function(v) end })
sec:AddSlider({  Name="My Slider",  Flag="sld1",  Min=0, Max=100, Default=50, Decimals=0, Callback=function(v) end })
sec:AddButton({  Name="My Button",  Callback=function() end })
sec:AddDropdown({Name="My Dropdown",Flag="drp1",  Items={"A","B","C"}, Callback=function(v) end })
sec:AddTextBox({ Name="My Textbox", Flag="txt1",  Placeholder="type here...", Callback=function(v) end })
sec:AddColorPicker({Name="My Color",Flag="col1",  Default=Color3.fromRGB(255,182,215), Callback=function(c) end })
sec:AddKeybind({ Name="My Keybind", Flag="kb1",   Default=Enum.KeyCode.F, Callback=function(k) end })
sec:AddLabel({   Name="My Label" })
sec:AddDivider()

-- Notifications:
UI.Notify("Title", "Body text", "Success", 3)  -- types: Success, Error, Warning
UI.Notify("Title", "Body text", "Info",    3)

-- Accent color:
UI.SetAccent(Color3.fromRGB(255,182,215))

-- Read any flag value anywhere:
print(UI.Flags["tog1"])

-- Config system:
UI.SaveConfig("myconfig")
UI.LoadConfig("myconfig")
UI.ListConfigs()
UI.DeleteConfig("myconfig")
UI.SetAutoLoad("myconfig")  -- auto-loads this config on next run
─────────────────────────────────────────────
--]]

local T = {
    A=Color3.fromRGB(255,182,215), BG=Color3.fromRGB(11,11,16),
    B1=Color3.fromRGB(17,17,24),  B2=Color3.fromRGB(23,23,32),
    B3=Color3.fromRGB(30,30,42),  B4=Color3.fromRGB(40,40,56),
    BD=Color3.fromRGB(52,52,72),  TX=Color3.fromRGB(242,242,255),
    MT=Color3.fromRGB(110,110,145),SUB=Color3.fromRGB(65,65,90),
}

local Players=game:GetService("Players")
local TS=game:GetService("TweenService")
local UIS=game:GetService("UserInputService")
local RS=game:GetService("RunService")
local HS=game:GetService("HttpService")
local LP=Players.LocalPlayer

for _,v in ipairs({game:GetService("CoreGui"),LP.PlayerGui}) do
    pcall(function() if v:FindFirstChild("WhoaUI") then v.WhoaUI:Destroy() end end)
end

local AL,Flags,togByFlag={},{},{}
local toggleKey,listeningForKey,ICON_ID=TOGGLE_KEY,false,""
local function setA(c) T.A=c; for _,fn in ipairs(AL) do pcall(fn,c) end end

-- CONFIG
local CFG_PREFIX,CFG_INDEX,CFG_AUTO="WhoaUI_cfg_","WhoaUI_cfglist.json","WhoaUI_autoload.txt"
local function _encode()
    local out={}
    for k,v in pairs(Flags) do
        local t=typeof(v)
        if t=="boolean"or t=="number"or t=="string" then out[k]=v
        elseif t=="Color3" then out[k]={r=v.R,g=v.G,b=v.B,__type="Color3"}
        elseif t=="EnumItem" then out[k]={name=v.Name,__type="EnumItem",enumType=tostring(v.EnumType)} end
    end; return out
end
local function _apply(data)
    if type(data)~="table" then return end
    for k,v in pairs(data) do
        if type(v)=="table" then
            if v.__type=="Color3" then Flags[k]=Color3.new(v.r,v.g,v.b)
            elseif v.__type=="EnumItem" then pcall(function() Flags[k]=Enum[v.enumType][v.name] end) end
        else Flags[k]=v end
    end
end
local function cfgList()
    if not readfile or not isfile or not isfile(CFG_INDEX) then return {} end
    local ok,d=pcall(function() return HS:JSONDecode(readfile(CFG_INDEX)) end)
    return (ok and type(d)=="table") and d or {}
end
local function cfgSave(name)
    if not writefile or not name or name=="" then return false end
    pcall(function()
        writefile(CFG_PREFIX..name..".json",HS:JSONEncode(_encode()))
        local list=cfgList(); local found=false
        for _,v in ipairs(list) do if v==name then found=true; break end end
        if not found then table.insert(list,name); writefile(CFG_INDEX,HS:JSONEncode(list)) end
    end); return true
end
local function cfgLoad(name)
    if not readfile or not isfile then return false end
    local f=CFG_PREFIX..name..".json"
    if not isfile(f) then return false end
    local ok,d=pcall(function() return HS:JSONDecode(readfile(f)) end)
    if ok then _apply(d) end; return ok
end
local function cfgDelete(name)
    pcall(function()
        local f=CFG_PREFIX..name..".json"
        if isfile and isfile(f) and delfile then delfile(f) end
        local list=cfgList()
        for i,v in ipairs(list) do if v==name then table.remove(list,i); break end end
        if writefile then writefile(CFG_INDEX,HS:JSONEncode(list)) end
    end)
end
local function cfgSetAuto(name) pcall(function() if writefile then writefile(CFG_AUTO,name or "") end end) end
local function cfgGetAuto()
    if not readfile or not isfile or not isfile(CFG_AUTO) then return nil end
    local n=readfile(CFG_AUTO):gsub("%s",""); return n~="" and n or nil
end
local _auto=cfgGetAuto(); if _auto then cfgLoad(_auto) end

-- HELPERS
local function tw(o,p,t,s) TS:Create(o,TweenInfo.new(t or 0.15,s or Enum.EasingStyle.Quad,Enum.EasingDirection.Out),p):Play() end
local FONT=Enum.Font.FredokaOne
local _TC={TextLabel=true,TextButton=true,TextBox=true}
local function new(cls,props,parent)
    local o=Instance.new(cls)
    if cls=="Frame"or cls=="ScrollingFrame" then pcall(function() o.BorderSizePixel=0 end) end
    if _TC[cls] then pcall(function() o.Font=FONT end) end
    for k,v in pairs(props or {}) do pcall(function() o[k]=v end) end
    if parent then o.Parent=parent end; return o
end
local function cr(r,p) return new("UICorner",{CornerRadius=UDim.new(0,r)},p) end
local function st(c,t,p) return new("UIStroke",{Color=c,Thickness=t or 1},p) end
local function pad(t,b,l,r,p) return new("UIPadding",{PaddingTop=UDim.new(0,t),PaddingBottom=UDim.new(0,b),PaddingLeft=UDim.new(0,l),PaddingRight=UDim.new(0,r)},p) end
local function tl(props,parent) return new("TextLabel",props,parent) end
local function hexToColor(h)
    h=h:gsub("#",""); if #h~=6 then return nil end
    local r,g,b=tonumber(h:sub(1,2),16),tonumber(h:sub(3,4),16),tonumber(h:sub(5,6),16)
    return (r and g and b) and Color3.fromRGB(r,g,b) or nil
end
local function toHex(c) return string.format("%02X%02X%02X",math.round(c.R*255),math.round(c.G*255),math.round(c.B*255)) end

-- SCREENGUI
local SG=new("ScreenGui",{Name="WhoaUI",ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,IgnoreGuiInset=true,DisplayOrder=99})
pcall(function()
    if gethui then SG.Parent=gethui()
    elseif syn and syn.protect_gui then syn.protect_gui(SG); SG.Parent=game:GetService("CoreGui")
    elseif protect_gui then protect_gui(SG); SG.Parent=game:GetService("CoreGui")
    else SG.Parent=game:GetService("CoreGui") end
end)
if not SG.Parent then SG.Parent=LP.PlayerGui end
pcall(function() SG.Name="RbxGui" end)

-- NOTIFICATIONS
local nh=new("Frame",{AnchorPoint=Vector2.new(1,1),Position=UDim2.new(1,-14,1,-14),Size=UDim2.new(0,270,1,-28),BackgroundTransparency=1,ZIndex=999},SG)
new("UIListLayout",{FillDirection=Enum.FillDirection.Vertical,VerticalAlignment=Enum.VerticalAlignment.Bottom,SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,6)},nh)
local nCol={Success=Color3.fromRGB(80,220,140),Error=Color3.fromRGB(255,80,80),Warning=Color3.fromRGB(255,170,50)}
local function Notify(title,body,ntype,dur)
    local col=nCol[ntype] or T.A
    local nf=new("Frame",{Size=UDim2.new(1,0,0,58),BackgroundColor3=T.B2,ZIndex=999,BackgroundTransparency=1},nh); cr(6,nf)
    nf.Position=UDim2.new(1.1,0,0,0)
    tw(nf,{BackgroundTransparency=0,Position=UDim2.new(0,0,0,0)},0.28,Enum.EasingStyle.Back)
    new("Frame",{Size=UDim2.new(0,2,0.7,0),AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,0,0.5,0),BackgroundColor3=col,ZIndex=1000},nf); cr(99,nf:FindFirstChildWhichIsA("Frame"))
    new("Frame",{Size=UDim2.new(1,0,0,1),BackgroundColor3=col,BackgroundTransparency=0.6,ZIndex=1000},nf)
    tl({Position=UDim2.new(0,14,0,10),Size=UDim2.new(1,-18,0,16),BackgroundTransparency=1,Text=title,TextColor3=col,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=1000},nf)
    tl({Position=UDim2.new(0,14,0,27),Size=UDim2.new(1,-18,0,22),BackgroundTransparency=1,Text=body,TextColor3=T.TX,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,ZIndex=1000},nf)
    new("Frame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=col,BackgroundTransparency=0.94,ZIndex=999},nf); cr(6,nf:FindFirstChildOfClass("Frame"))
    task.delay(dur or NOTIF_DURATION,function()
        tw(nf,{Position=UDim2.new(1.1,0,0,0),BackgroundTransparency=1},0.2)
        task.delay(0.22,function() nf:Destroy() end)
    end)
end

-- OVERLAY + SNOW
local bgOverlay=new("Frame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=0.55,ZIndex=1,Visible=false},SG)
local overlayEnabled=true
local function setOverlay(v) overlayEnabled=v; bgOverlay.Visible=v end
local snowCont=new("Frame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,ZIndex=5,Visible=false},SG)
local flakes,snowConn={},nil
for i=1,28 do
    local sz=math.random(2,5)
    local f=new("Frame",{Size=UDim2.new(0,sz,0,sz),BackgroundColor3=Color3.fromRGB(255,182,217),BackgroundTransparency=0.25,ZIndex=6},snowCont); cr(99,f)
    flakes[i]={ui=f,x=math.random(0,100)/100,y=math.random(-10,110)/100,spd=math.random(3,9)/100,dx=math.random(-12,12)/10000}
    f.Position=UDim2.new(flakes[i].x,0,flakes[i].y,0)
end
local function startSnow()
    if snowConn then return end
    snowCont.Visible=true
    if overlayEnabled then bgOverlay.Visible=true end
    snowConn=RS.Heartbeat:Connect(function(dt)
        for _,fl in ipairs(flakes) do
            fl.y+=fl.spd*dt; fl.x+=fl.dx
            if fl.y>1.05 then fl.y=-0.04; fl.x=math.random(0,100)/100 end
            fl.x=fl.x<0 and 1 or fl.x>1 and 0 or fl.x
            fl.ui.Position=UDim2.new(fl.x,0,fl.y,0)
        end
    end)
end
local function stopSnow()
    if snowConn then snowConn:Disconnect(); snowConn=nil end
    snowCont.Visible=false
    bgOverlay.Visible=false
    for _,fl in ipairs(flakes) do fl.ui.Position=UDim2.new(2,0,2,0) end
end

-- WINDOW
local WW,WH=WIN_WIDTH,WIN_HEIGHT
local winOpen,winMin=true,false
local baseW,baseH=WW,WH

local function getCenterPos(w,h)
    local vp=workspace.CurrentCamera.ViewportSize
    return UDim2.new(0,math.floor(vp.X/2-w/2),0,math.floor(vp.Y/2-h/2))
end

-- Outer window with full corner rounding
local Win=new("Frame",{
    Name="Window",AnchorPoint=Vector2.new(0,0),
    Position=getCenterPos(WW,WH),Size=UDim2.new(0,WW,0,WH),
    BackgroundColor3=T.BG,ClipsDescendants=false,ZIndex=10,
    Visible=false,BackgroundTransparency=1,
},SG)
cr(10,Win)

local WinInner=new("Frame",{
    Size=UDim2.new(1,0,1,0),BackgroundColor3=T.BG,
    ClipsDescendants=true,ZIndex=10,
},Win)
cr(10,WinInner)
st(Color3.fromRGB(38,38,54),1.2,Win)

-- TITLE BAR
local TBar=new("Frame",{Position=UDim2.new(0,0,0,0),Size=UDim2.new(1,0,0,56),BackgroundColor3=T.B1,ZIndex=11},WinInner)
cr(10,TBar) -- matches window corner radius so top-left/right corners are rounded
-- Separator under title bar - thicker, more pastel
local titleSep=new("Frame",{
    AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,0,1,0),
    Size=UDim2.new(1,0,0,2),BackgroundColor3=Color3.fromRGB(255,205,228),
    BackgroundTransparency=0.3,ZIndex=12,
    Visible=false,
},TBar)
table.insert(AL,function(c)
    local h,s,v=Color3.toHSV(c)
    titleSep.BackgroundColor3=Color3.fromHSV(h,s*0.45,math.min(v+0.35,1))
end)

local titleIcon=new("ImageLabel",{AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,12,0.5,0),Size=UDim2.new(0,26,0,26),BackgroundTransparency=1,Image="",ZIndex=12},TBar)
local titleLabel=tl({AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,44,0.5,0),Size=UDim2.new(0,220,0,22),BackgroundTransparency=1,Text=SCRIPT_NAME,TextColor3=T.TX,TextSize=17,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=12},TBar)

-- Player badge
local pb=new("Frame",{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-44,0.5,0),Size=UDim2.new(0,28,0,26),AutomaticSize=Enum.AutomaticSize.X,BackgroundColor3=T.B2,ZIndex=12},TBar); cr(5,pb); pad(0,0,5,8,pb)
local avImg=new("ImageLabel",{AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,3,0.5,0),Size=UDim2.new(0,18,0,18),BackgroundColor3=T.B3,Image="",ZIndex=13},pb); cr(4,avImg)
local pbNameLabel=tl({AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,25,0.5,0),Size=UDim2.new(0,0,0,14),AutomaticSize=Enum.AutomaticSize.X,BackgroundTransparency=1,Text=LP.DisplayName,TextColor3=T.TX,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=13},pb)
task.spawn(function()
    pcall(function()
        avImg.Image=Players:GetUserThumbnailAsync(LP.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size60x60)
    end)
end)

-- Minimize button
local mb=new("TextButton",{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-10,0.5,0),Size=UDim2.new(0,26,0,18),BackgroundColor3=T.B3,Text="",ZIndex=13},TBar); cr(4,mb)
local mbBar=new("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,0,0.5,0),Size=UDim2.new(0,10,0,2),BackgroundColor3=T.MT,ZIndex=14},mb); cr(99,mbBar)
mb.MouseEnter:Connect(function() tw(mb,{BackgroundColor3=T.B4}); tw(mbBar,{BackgroundColor3=T.A}) end)
mb.MouseLeave:Connect(function() tw(mb,{BackgroundColor3=T.B3}); tw(mbBar,{BackgroundColor3=T.MT}) end)
mb.MouseButton1Click:Connect(function()
    winMin=not winMin
    tw(Win,{Size=winMin and UDim2.new(0,WW,0,56) or UDim2.new(0,WW,0,WH)},0.22,Enum.EasingStyle.Quint)
end)

-- DRAG
local drag,dragStart,winStart=false,nil,nil
TBar.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
        drag=true; dragStart=i.Position
        winStart=UDim2.new(0,Win.Position.X.Offset,0,Win.Position.Y.Offset)
    end
end)
UIS.InputChanged:Connect(function(i)
    if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
        local d=i.Position-dragStart
        local vp=workspace.CurrentCamera.ViewportSize; local ws=Win.AbsoluteSize
        Win.Position=UDim2.new(0,math.clamp(winStart.X.Offset+d.X,0,math.max(0,vp.X-ws.X)),0,math.clamp(winStart.Y.Offset+d.Y,0,math.max(0,vp.Y-ws.Y)))
    end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=false end
end)

-- TOGGLE / VISIBILITY - instant close
local uiReady=false
local function setVisible(v)
    if not uiReady then return end
    winOpen=v
    if v then
        Win.Visible=true; Win.BackgroundTransparency=1
        tw(Win,{BackgroundTransparency=0},0.2,Enum.EasingStyle.Quad)
        if overlayEnabled then bgOverlay.Visible=true; bgOverlay.BackgroundTransparency=0.9; tw(bgOverlay,{BackgroundTransparency=0.55},0.2) end
        snowCont.Visible=true
    else
        -- Instant hide
        Win.Visible=false; bgOverlay.Visible=false; snowCont.Visible=false
    end
end
UIS.InputBegan:Connect(function(i) if not listeningForKey and i.KeyCode==toggleKey then setVisible(not winOpen) end end)

-- SCALING - always re-center
local function scaleWindow()
    local vp=workspace.CurrentCamera.ViewportSize
    local s=math.clamp(math.min(vp.X/1280,vp.Y/720),0.45,1.0)
    local sw,sh=math.floor(baseW*s),math.floor(baseH*s)
    WW=sw; WH=sh
    Win.Size=winMin and UDim2.new(0,sw,0,56) or UDim2.new(0,sw,0,sh)
    Win.Position=getCenterPos(sw,winMin and 56 or sh)
end
scaleWindow()
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(scaleWindow)

-- TAB BAR
local TabBar=new("Frame",{Position=UDim2.new(0,0,0,56),Size=UDim2.new(1,0,0,36),BackgroundColor3=T.B1,ZIndex=11},WinInner)
new("Frame",{AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,0,1,0),Size=UDim2.new(1,0,0,1),BackgroundColor3=Color3.fromRGB(28,28,40),ZIndex=12},TabBar)
local tabList=new("Frame",{Size=UDim2.new(1,-120,1,0),Position=UDim2.new(0,8,0,0),BackgroundTransparency=1},TabBar)
new("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,VerticalAlignment=Enum.VerticalAlignment.Center,SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,2)},tabList)

-- Search box
local searchBg=new("Frame",{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-8,0.5,0),Size=UDim2.new(0,108,0,22),BackgroundColor3=T.B2,ZIndex=12},TabBar); cr(5,searchBg)
local searchSt=st(T.BD,1,searchBg)
local searchBox=new("TextBox",{Position=UDim2.new(0,8,0,0),Size=UDim2.new(1,-12,1,0),BackgroundTransparency=1,Text="",PlaceholderText="search...",PlaceholderColor3=T.MT,TextColor3=T.TX,TextSize=13,ClearTextOnFocus=false,ZIndex=13},searchBg)
searchBox.Focused:Connect(function() tw(searchSt,{Color=T.A,Thickness=1.5}) end)
searchBox.FocusLost:Connect(function() tw(searchSt,{Color=T.BD,Thickness=1}) end)

-- Content area
local ContentArea=new("Frame",{Position=UDim2.new(0,0,0,93),Size=UDim2.new(1,0,1,-93),BackgroundTransparency=1,ClipsDescendants=true},WinInner)
local searchOverlay=new("ScrollingFrame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=T.BG,BorderSizePixel=0,ScrollBarThickness=3,ScrollBarImageColor3=T.BD,CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,Visible=false,ZIndex=50},ContentArea)
new("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,3)},searchOverlay)
pad(6,6,8,8,searchOverlay)

local searchItems={}
local function rebuildSearch(q)
    q=q:lower():gsub("%s","")
    if q=="" then searchOverlay.Visible=false; return end
    searchOverlay.Visible=true
    for _,c in ipairs(searchOverlay:GetChildren()) do if c:IsA("GuiObject") then c:Destroy() end end
    local found=0
    for _,item in ipairs(searchItems) do
        if item.keywords:lower():gsub("%s",""):find(q,1,true) then
            found+=1
            local res=new("Frame",{Size=UDim2.new(1,0,0,32),BackgroundColor3=T.B2,LayoutOrder=found,ZIndex=51},searchOverlay); cr(4,res)
            tl({Position=UDim2.new(0,12,0,0),Size=UDim2.new(0.55,0,1,0),BackgroundTransparency=1,Text=item.label,TextColor3=T.TX,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=52},res)
            tl({Position=UDim2.new(0.55,0,0,0),Size=UDim2.new(0.28,0,1,0),BackgroundTransparency=1,Text=item.tab,TextColor3=T.MT,TextSize=11,TextXAlignment=Enum.TextXAlignment.Right,ZIndex=52},res)
            local goBtn=new("TextButton",{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-6,0.5,0),Size=UDim2.new(0,32,0,18),BackgroundColor3=T.B3,Text="go",TextColor3=T.A,TextSize=11,ZIndex=53},res); cr(3,goBtn)
            table.insert(AL,function(c2) goBtn.TextColor3=c2 end)
            local rowBtn=new("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=54},res)
            rowBtn.MouseEnter:Connect(function() tw(res,{BackgroundColor3=T.B3},0.08) end)
            rowBtn.MouseLeave:Connect(function() tw(res,{BackgroundColor3=T.B2},0.08) end)
            local function doNav() if item.switch then item.switch() end; searchBox.Text="" end
            rowBtn.MouseButton1Click:Connect(doNav); goBtn.MouseButton1Click:Connect(doNav)
        end
    end
    if found==0 then tl({Size=UDim2.new(1,0,0,32),BackgroundTransparency=1,Text="no results",TextColor3=T.MT,TextSize=13,ZIndex=51},searchOverlay) end
end
searchBox:GetPropertyChangedSignal("Text"):Connect(function() rebuildSearch(searchBox.Text) end)

-- TABS
local tabFrames,tabBtns={},{}
local activeTabIndex=0
local function addTab(name)
    local idx=#tabFrames+1
    local btn=new("TextButton",{Size=UDim2.new(0,0,1,0),AutomaticSize=Enum.AutomaticSize.X,BackgroundTransparency=1,Text=name,TextColor3=T.MT,TextSize=14,ZIndex=12},tabList)
    pad(0,0,14,14,btn)
    local ul=new("Frame",{AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,14,1,0),Size=UDim2.new(1,-28,0,2),BackgroundColor3=T.A,Visible=false,ZIndex=13},btn); cr(99,ul)
    table.insert(AL,function(c) ul.BackgroundColor3=c end)
    local frame=new("Frame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Visible=false},ContentArea)
    local function makeCol(xs,xo,wo)
        local col=new("ScrollingFrame",{Position=UDim2.new(xs,xo,0,6),Size=UDim2.new(0.5,wo,1,-12),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=4,ScrollBarImageColor3=T.BD,CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y},frame)
        new("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,5)},col)
        pad(2,4,0,0,col); return col
    end
    local colL=makeCol(0,8,-14); local colR=makeCol(0.5,6,-14)
    table.insert(tabFrames,frame); table.insert(tabBtns,{b=btn,u=ul,idx=idx})
    local function switchToTab()
        for i,f in ipairs(tabFrames) do
            if i==activeTabIndex and i~=idx then f.Visible=false end
        end
        frame.Visible=true
        for _,bd in ipairs(tabBtns) do
            if bd.idx==idx then tw(bd.b,{TextColor3=T.TX},0.12); bd.u.Visible=true; tw(bd.u,{BackgroundColor3=T.A},0.12)
            else tw(bd.b,{TextColor3=T.MT},0.12); bd.u.Visible=false end
        end
        activeTabIndex=idx; searchBox.Text=""
    end
    btn.MouseEnter:Connect(function() if activeTabIndex~=idx then tw(btn,{TextColor3=T.TX},0.1) end end)
    btn.MouseLeave:Connect(function() if activeTabIndex~=idx then tw(btn,{TextColor3=T.MT},0.1) end end)
    btn.MouseButton1Click:Connect(switchToTab)
    if idx==1 then task.defer(switchToTab) end
    return colL,colR,name,switchToTab
end

-- SECTIONS
local function makeSection(parent,title)
    local sec=new("Frame",{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundColor3=T.B2,ClipsDescendants=true},parent)
    cr(6,sec)
    local body=new("Frame",{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1},sec)
    pad(4,6,0,0,body)
    new("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,0)},body)
    local lo=0; local function nl() lo+=1; return lo end
    local tabName,tabSwitch,collapsed="",nil,false

    if title and title~="" then
        local hdr=new("TextButton",{Size=UDim2.new(1,0,0,28),BackgroundColor3=T.B3,LayoutOrder=0,Text="",ZIndex=2},body)
        local pip=new("Frame",{AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,8,0.5,0),Size=UDim2.new(0,3,0.55,0),BackgroundColor3=T.A,ZIndex=3},hdr); cr(99,pip)
        table.insert(AL,function(c) pip.BackgroundColor3=c end)
        tl({Position=UDim2.new(0,18,0,0),Size=UDim2.new(0.7,-22,1,0),BackgroundTransparency=1,Text=title:upper(),TextColor3=T.MT,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=3},hdr)
        local arrowBg=new("Frame",{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-10,0.5,0),Size=UDim2.new(0,16,0,16),BackgroundColor3=T.B4,ZIndex=3},hdr); cr(4,arrowBg)
        local barH=new("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,0,0.5,0),Size=UDim2.new(0,8,0,2),BackgroundColor3=T.MT,ZIndex=4},arrowBg); cr(99,barH)
        local barV=new("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,0,0.5,0),Size=UDim2.new(0,2,0,8),BackgroundColor3=T.MT,ZIndex=4,Visible=false},arrowBg); cr(99,barV)
        new("Frame",{AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,0,1,0),Size=UDim2.new(1,0,0,1),BackgroundColor3=T.BD,BackgroundTransparency=0.6},hdr)
        hdr.MouseEnter:Connect(function() tw(hdr,{BackgroundColor3=T.B4},0.1) end)
        hdr.MouseLeave:Connect(function() tw(hdr,{BackgroundColor3=T.B3},0.1) end)
        hdr.MouseButton1Click:Connect(function()
            collapsed=not collapsed
            barV.Visible=collapsed
            tw(barH,{BackgroundColor3=collapsed and T.A or T.MT},0.12)
            tw(barV,{BackgroundColor3=collapsed and T.A or T.MT},0.12)
            if collapsed then
                -- Measure actual content height first
                local contentH=body.AbsoluteSize.Y
                sec.AutomaticSize=Enum.AutomaticSize.None
                sec.Size=UDim2.new(1,0,0,contentH)
                tw(sec,{Size=UDim2.new(1,0,0,28)},0.2,Enum.EasingStyle.Quint)
            else
                local targetH=body.AbsoluteSize.Y
                sec.AutomaticSize=Enum.AutomaticSize.None
                sec.Size=UDim2.new(1,0,0,28)
                tw(sec,{Size=UDim2.new(1,0,0,math.max(targetH,29))},0.2,Enum.EasingStyle.Quint)
                task.delay(0.22,function()
                    if not collapsed then
                        sec.AutomaticSize=Enum.AutomaticSize.Y
                        sec.Size=UDim2.new(1,0,0,0)
                    end
                end)
            end
        end)
    end

    local api={}
    api._tabName=function(n,fn) tabName=n; tabSwitch=fn end
    api.Destroy=function() sec:Destroy() end
    local slideCBs,slideActive={},nil
    UIS.InputChanged:Connect(function(i) if slideActive and i.UserInputType==Enum.UserInputType.MouseMovement then local cb=slideCBs[slideActive]; if cb then cb(i.Position.X,i.Position.Y) end end end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then slideActive=nil end end)
    local function regSlide(id,startFn,moveFn,obj)
        slideCBs[id]=moveFn
        obj.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then slideActive=id; startFn(i.Position.X,i.Position.Y) end end)
    end

    function api:AddCheckbox(cfg)
        local flg=cfg.Flag or cfg.Name
        local on=(Flags[flg]~=nil) and Flags[flg] or (cfg.Default==true); Flags[flg]=on
        table.insert(searchItems,{label=cfg.Name,keywords=cfg.Name..(cfg.Flag or ""),tab=tabName,switch=tabSwitch})
        local row=new("Frame",{Size=UDim2.new(1,0,0,34),BackgroundTransparency=1,LayoutOrder=nl()},body)
        local hbg=new("Frame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=T.B4,BackgroundTransparency=1},row); cr(4,hbg)
        tl({Position=UDim2.new(0,12,0,0),Size=UDim2.new(1,-46,1,0),BackgroundTransparency=1,Text=cfg.Name,TextColor3=T.TX,TextSize=14,TextXAlignment=Enum.TextXAlignment.Left},row)
        local cbBG=new("Frame",{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-10,0.5,0),Size=UDim2.new(0,18,0,18),BackgroundColor3=T.B1},row); cr(4,cbBG)
        local cbSt=st(T.BD,1.5,cbBG)
        local cbFill=new("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,0,0.5,0),Size=UDim2.new(0.7,0,0.7,0),BackgroundColor3=T.A,Visible=false},cbBG); cr(3,cbFill)
        local function upd()
            if on then cbFill.Visible=true; tw(cbSt,{Color=T.A,Thickness=1.5}); tw(cbFill,{BackgroundColor3=T.A})
            else cbFill.Visible=false; tw(cbSt,{Color=T.BD,Thickness=1.5}) end
        end
        table.insert(AL,function(c) if on then cbFill.BackgroundColor3=c; cbSt.Color=c end end)
        if cfg.Keybind then
            local kc=Enum.KeyCode[cfg.Keybind]
            if kc then UIS.InputBegan:Connect(function(i) if i.KeyCode==kc then on=not on; Flags[flg]=on; upd(); if cfg.Callback then cfg.Callback(on) end end end) end
        end
        local btn=new("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=2},row)
        btn.MouseEnter:Connect(function() tw(hbg,{BackgroundTransparency=0.84},0.08) end)
        btn.MouseLeave:Connect(function() tw(hbg,{BackgroundTransparency=1},0.08) end)
        btn.MouseButton1Click:Connect(function() on=not on; Flags[flg]=on; upd(); if cfg.Callback then cfg.Callback(on) end end)
        upd()
    end

    function api:AddToggle(cfg)
        local flg=cfg.Flag or cfg.Name
        local on=(Flags[flg]~=nil) and Flags[flg] or (cfg.Default==true); Flags[flg]=on
        table.insert(searchItems,{label=cfg.Name,keywords=cfg.Name..(cfg.Flag or ""),tab=tabName,switch=tabSwitch})
        local row=new("Frame",{Size=UDim2.new(1,0,0,34),BackgroundTransparency=1,LayoutOrder=nl()},body)
        local hbg=new("Frame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=T.B4,BackgroundTransparency=1},row); cr(4,hbg)
        tl({Position=UDim2.new(0,12,0,0),Size=UDim2.new(1,-66,1,0),BackgroundTransparency=1,Text=cfg.Name,TextColor3=T.TX,TextSize=14,TextXAlignment=Enum.TextXAlignment.Left},row)
        local track=new("Frame",{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-10,0.5,0),Size=UDim2.new(0,38,0,20),BackgroundColor3=T.B1},row); cr(99,track)
        local trkSt=st(T.BD,1.5,track)
        local knob=new("Frame",{AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,3,0.5,0),Size=UDim2.new(0,14,0,14),BackgroundColor3=T.MT,ZIndex=2},track); cr(99,knob)
        local function upd(anim)
            local t=anim and 0.18 or 0; local es=anim and Enum.EasingStyle.Back or Enum.EasingStyle.Quad
            if on then tw(track,{BackgroundColor3=T.A},t); tw(trkSt,{Color=T.A},t); tw(knob,{Position=UDim2.new(1,-17,0.5,0),BackgroundColor3=Color3.new(1,1,1)},t,es)
            else tw(track,{BackgroundColor3=T.B1},t); tw(trkSt,{Color=T.BD},t); tw(knob,{Position=UDim2.new(0,3,0.5,0),BackgroundColor3=T.MT},t,es) end
        end
        table.insert(AL,function(c) if on then track.BackgroundColor3=c; trkSt.Color=c end end)
        if not togByFlag[flg] then togByFlag[flg]={} end
        local function _setOn(v,anim) on=v; upd(anim) end
        table.insert(togByFlag[flg],_setOn)
        local function _syncSiblings(v) for _,fn in ipairs(togByFlag[flg]) do pcall(fn,v,true) end end
        if cfg.Keybind then
            local kc=typeof(cfg.Keybind)=="EnumItem" and cfg.Keybind or Enum.KeyCode[tostring(cfg.Keybind)]
            if kc then UIS.InputBegan:Connect(function(i) if not listeningForKey and i.KeyCode==kc then on=not on; Flags[flg]=on; _syncSiblings(on); if cfg.Callback then cfg.Callback(on) end end end) end
        end
        local btn=new("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=2},row)
        btn.MouseEnter:Connect(function() tw(hbg,{BackgroundTransparency=0.84},0.08) end)
        btn.MouseLeave:Connect(function() tw(hbg,{BackgroundTransparency=1},0.08) end)
        btn.MouseButton1Click:Connect(function() on=not on; Flags[flg]=on; _syncSiblings(on); if cfg.Callback then cfg.Callback(on) end end)
        upd(false)
        return {Set=function(v) Flags[flg]=v; _syncSiblings(v) end,Get=function() return on end}
    end

    function api:AddSlider(cfg)
        local flg=cfg.Flag or cfg.Name
        local val=(Flags[flg]~=nil) and Flags[flg] or (cfg.Default or cfg.Min or 0)
        local dec=cfg.Decimals or 0; Flags[flg]=val
        table.insert(searchItems,{label=cfg.Name,keywords=cfg.Name..(cfg.Flag or ""),tab=tabName,switch=tabSwitch})
        local function fmt(v) return dec>0 and string.format("%."..dec.."f",v) or tostring(math.round(v)) end
        local wr=new("Frame",{Size=UDim2.new(1,0,0,50),BackgroundTransparency=1,LayoutOrder=nl()},body)
        local hbg=new("Frame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=T.B4,BackgroundTransparency=1},wr); cr(4,hbg)
        tl({Position=UDim2.new(0,12,0,6),Size=UDim2.new(0.6,-16,0,16),BackgroundTransparency=1,Text=cfg.Name,TextColor3=T.TX,TextSize=14,TextXAlignment=Enum.TextXAlignment.Left},wr)
        local vl=new("TextButton",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-10,0,5),Size=UDim2.new(0,72,0,16),BackgroundColor3=T.B1,Text=fmt(val),TextColor3=T.A,TextSize=12,ZIndex=2},wr); cr(3,vl)
        table.insert(AL,function(c) vl.TextColor3=c end)
        local eb=new("TextBox",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",TextColor3=T.A,TextSize=12,Visible=false,ClearTextOnFocus=true,ZIndex=3},vl)
        local trackHit=new("Frame",{Position=UDim2.new(0,12,0,32),Size=UDim2.new(1,-24,0,12),BackgroundTransparency=1},wr)
        local track=new("Frame",{AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,0,0.5,0),Size=UDim2.new(1,0,0,4),BackgroundColor3=T.B1},trackHit); cr(99,track)
        local p0=(val-cfg.Min)/(cfg.Max-cfg.Min)
        local fil=new("Frame",{Size=UDim2.new(p0,0,1,0),BackgroundColor3=T.A},track); cr(99,fil)
        table.insert(AL,function(c) fil.BackgroundColor3=c end)
        local thumb=new("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(p0,0,0.5,0),Size=UDim2.new(0,12,0,12),BackgroundColor3=T.A,ZIndex=2},track); cr(99,thumb)
        table.insert(AL,function(c) thumb.BackgroundColor3=c end)
        new("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,0,0.5,0),Size=UDim2.new(0,5,0,5),BackgroundColor3=Color3.new(1,1,1),ZIndex=3},thumb); cr(99,thumb:FindFirstChildOfClass("Frame"))
        local function setVal(v)
            v=math.clamp(v,cfg.Min,cfg.Max)
            v=dec==0 and math.round(v) or math.floor(v*10^dec+0.5)/10^dec
            val=v; Flags[flg]=v
            local p=(v-cfg.Min)/(cfg.Max-cfg.Min)
            tw(fil,{Size=UDim2.new(p,0,1,0)},0.05); tw(thumb,{Position=UDim2.new(p,0,0.5,0)},0.05)
            vl.Text=fmt(v); if cfg.Callback then cfg.Callback(v) end
        end
        vl.MouseButton1Click:Connect(function() eb.Text=fmt(val); eb.Visible=true; vl.Text=""; eb:CaptureFocus() end)
        eb.FocusLost:Connect(function() eb.Visible=false; local n=tonumber(eb.Text); if n then setVal(n) end; vl.Text=fmt(val) end)
        local function fromX(x) setVal(cfg.Min+math.clamp((x-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)*(cfg.Max-cfg.Min)) end
        regSlide("sl_"..flg,fromX,function(x) fromX(x) end,trackHit)
        wr.MouseEnter:Connect(function() tw(hbg,{BackgroundTransparency=0.88},0.08) end)
        wr.MouseLeave:Connect(function() tw(hbg,{BackgroundTransparency=1},0.08) end)
        return {Set=setVal,Get=function() return val end}
    end

    function api:AddDropdown(cfg)
        local flg=cfg.Flag or cfg.Name
        local dv=Flags[flg] or cfg.Default or (cfg.Items and cfg.Items[1]) or ""; Flags[flg]=dv
        table.insert(searchItems,{label=cfg.Name,keywords=cfg.Name..(cfg.Flag or ""),tab=tabName,switch=tabSwitch})
        local wr=new("Frame",{Size=UDim2.new(1,0,0,50),BackgroundTransparency=1,LayoutOrder=nl(),ClipsDescendants=false,ZIndex=5},body)
        tl({Position=UDim2.new(0,12,0,4),Size=UDim2.new(1,-20,0,15),BackgroundTransparency=1,Text=cfg.Name,TextColor3=T.TX,TextSize=14,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=5},wr)
        local sb=new("TextButton",{Position=UDim2.new(0,10,0,22),Size=UDim2.new(1,-20,0,22),BackgroundColor3=T.B1,Text="",ZIndex=5},wr); cr(4,sb)
        local sbSt=st(T.BD,1,sb)
        local selLbl=new("TextLabel",{Position=UDim2.new(0,8,0,0),Size=UDim2.new(1,-22,1,0),BackgroundTransparency=1,Text=Flags[flg],TextColor3=T.TX,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=6},sb)
        new("TextLabel",{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-6,0.5,0),Size=UDim2.new(0,12,1,0),BackgroundTransparency=1,Text="v",TextColor3=T.MT,TextSize=11,ZIndex=6},sb)
        sb.MouseEnter:Connect(function() tw(sbSt,{Color=T.A}) end)
        sb.MouseLeave:Connect(function() tw(sbSt,{Color=T.BD}) end)
        local open,lf,oc=false,nil,nil
        local function closeDd()
            if not open then return end; open=false
            body.Parent.ClipsDescendants=true
            if oc then oc:Disconnect(); oc=nil end
            if lf then tw(lf,{Size=UDim2.new(1,-20,0,0)},0.12); tw(wr,{Size=UDim2.new(1,0,0,50)},0.12); task.delay(0.13,function() if lf then lf:Destroy(); lf=nil end end) end
        end
        sb.MouseButton1Click:Connect(function()
            open=not open
            if open then
                body.Parent.ClipsDescendants=false
                lf=new("Frame",{Position=UDim2.new(0,10,0,48),Size=UDim2.new(1,-20,0,0),BackgroundColor3=T.B1,ClipsDescendants=true,ZIndex=20},wr); cr(4,lf); st(T.BD,1,lf)
                new("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder},lf)
                for _,item in ipairs(cfg.Items or {}) do
                    local op=new("TextButton",{Size=UDim2.new(1,0,0,22),BackgroundColor3=T.B1,Text="  "..item,TextColor3=item==Flags[flg] and T.A or T.TX,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=21},lf)
                    op.MouseEnter:Connect(function() tw(op,{BackgroundColor3=T.B3},0.07) end)
                    op.MouseLeave:Connect(function() tw(op,{BackgroundColor3=T.B1},0.07) end)
                    op.MouseButton1Click:Connect(function() Flags[flg]=item; selLbl.Text=item; closeDd(); if cfg.Callback then cfg.Callback(item) end end)
                end
                local h=#(cfg.Items or {})*22
                tw(lf,{Size=UDim2.new(1,-20,0,h)},0.14); tw(wr,{Size=UDim2.new(1,0,0,50+h+2)},0.14)
                task.delay(0.05,function()
                    if not open then return end
                    oc=UIS.InputBegan:Connect(function(i)
                        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                            task.delay(0.05,function() closeDd() end)
                        end
                    end)
                end)
            else closeDd() end
        end)
        local obj={Get=function() return Flags[flg] end}
        function obj:Rebuild(items) cfg.Items=items; Flags[flg]=items[1] or "(none)"; selLbl.Text=Flags[flg] end
        return obj
    end

    function api:AddButton(cfg)
        table.insert(searchItems,{label=cfg.Name,keywords=cfg.Name,tab=tabName,switch=tabSwitch})
        local wr=new("Frame",{Size=UDim2.new(1,0,0,36),BackgroundTransparency=1,LayoutOrder=nl()},body)
        local btn=new("TextButton",{Position=UDim2.new(0,10,0.5,-12),Size=UDim2.new(1,-20,0,24),BackgroundColor3=T.B1,Text=cfg.Name,TextColor3=T.MT,TextSize=14},wr); cr(4,btn)
        local bSt=st(T.BD,1,btn)
        if cfg.Keybind then
            local kc=typeof(cfg.Keybind)=="EnumItem" and cfg.Keybind or Enum.KeyCode[tostring(cfg.Keybind)]
            if kc then
                new("TextLabel",{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-5,0.5,0),Size=UDim2.new(0,0,0,12),AutomaticSize=Enum.AutomaticSize.X,BackgroundColor3=T.B3,Text=" "..kc.Name.." ",TextColor3=T.MT,TextSize=9,ZIndex=4},btn); cr(3,btn:FindFirstChildOfClass("TextLabel"))
                UIS.InputBegan:Connect(function(i)
                    if not listeningForKey and i.KeyCode==kc then
                        tw(btn,{BackgroundColor3=T.BG,TextColor3=T.A},0.05)
                        task.delay(0.12,function() tw(btn,{BackgroundColor3=T.B1,TextColor3=T.MT},0.12) end)
                        if cfg.Callback then cfg.Callback() end
                    end
                end)
            end
        end
        btn.MouseEnter:Connect(function() tw(btn,{BackgroundColor3=T.B3,TextColor3=T.TX}); tw(bSt,{Color=T.A},0.1) end)
        btn.MouseLeave:Connect(function() tw(btn,{BackgroundColor3=T.B1,TextColor3=T.MT}); tw(bSt,{Color=T.BD},0.1) end)
        btn.MouseButton1Down:Connect(function() tw(btn,{BackgroundColor3=T.BG,TextColor3=T.A},0.06) end)
        btn.MouseButton1Click:Connect(function()
            tw(btn,{BackgroundColor3=T.B3,TextColor3=T.TX},0.08)
            task.delay(0.1,function() tw(btn,{BackgroundColor3=T.B1,TextColor3=T.MT},0.12) end)
            if cfg.Callback then cfg.Callback() end
        end)
    end

    function api:AddTextBox(cfg)
        local flg=cfg.Flag or cfg.Name; Flags[flg]=Flags[flg] or cfg.Default or ""
        table.insert(searchItems,{label=cfg.Name,keywords=cfg.Name..(cfg.Flag or ""),tab=tabName,switch=tabSwitch})
        local wr=new("Frame",{Size=UDim2.new(1,0,0,50),BackgroundTransparency=1,LayoutOrder=nl()},body)
        tl({Position=UDim2.new(0,12,0,4),Size=UDim2.new(1,-20,0,15),BackgroundTransparency=1,Text=cfg.Name,TextColor3=T.TX,TextSize=14,TextXAlignment=Enum.TextXAlignment.Left},wr)
        local bg=new("Frame",{Position=UDim2.new(0,10,0,22),Size=UDim2.new(1,-20,0,22),BackgroundColor3=T.B1},wr); cr(4,bg)
        local tSt=st(T.BD,1,bg)
        local tb=new("TextBox",{Position=UDim2.new(0,8,0,0),Size=UDim2.new(1,-16,1,0),BackgroundTransparency=1,Text=Flags[flg],PlaceholderText=cfg.Placeholder or "",PlaceholderColor3=T.MT,TextColor3=T.TX,TextSize=13,ClearTextOnFocus=false},bg)
        tb.Focused:Connect(function() tw(tSt,{Color=T.A,Thickness=1.5}) end)
        tb.FocusLost:Connect(function(e) tw(tSt,{Color=T.BD,Thickness=1}); Flags[flg]=tb.Text; if e and cfg.Callback then cfg.Callback(tb.Text) end end)
        return {Get=function() return tb.Text end}
    end

    function api:AddColorPicker(cfg)
        local flg=cfg.Flag or cfg.Name
        local sv=Flags[flg]; local cur=(typeof(sv)=="Color3" and sv) or cfg.Default or T.A; Flags[flg]=cur
        table.insert(searchItems,{label=cfg.Name,keywords=cfg.Name..(cfg.Flag or ""),tab=tabName,switch=tabSwitch})
        local cH,cS,cV=Color3.toHSV(cur)
        local function rebuild() cur=Color3.fromHSV(cH,cS,cV); Flags[flg]=cur; if cfg.Callback then cfg.Callback(cur) end end
        local row=new("Frame",{Size=UDim2.new(1,0,0,34),BackgroundTransparency=1,LayoutOrder=nl()},body)
        tl({Position=UDim2.new(0,12,0,0),Size=UDim2.new(1,-56,1,0),BackgroundTransparency=1,Text=cfg.Name,TextColor3=T.TX,TextSize=14,TextXAlignment=Enum.TextXAlignment.Left},row)
        local sw=new("Frame",{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-10,0.5,0),Size=UDim2.new(0,28,0,16),BackgroundColor3=cur},row); cr(3,sw); st(T.BD,1,sw)
        local svRow=new("Frame",{Size=UDim2.new(1,0,0,100),BackgroundTransparency=1,LayoutOrder=nl()},body)
        local svBox=new("Frame",{Position=UDim2.new(0,12,0,4),Size=UDim2.new(1,-24,0,92),BackgroundColor3=Color3.fromHSV(cH,1,1)},svRow); cr(4,svBox); st(T.BD,1,svBox)
        local sG=new("Frame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=Color3.new(1,1,1)},svBox)
        new("UIGradient",{Transparency=NumberSequence.new{NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,1)}},sG)
        local vG=new("Frame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=Color3.new(0,0,0)},svBox)
        new("UIGradient",{Transparency=NumberSequence.new{NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(1,0)},Rotation=90},vG)
        local svT=new("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(cS,0,1-cV,0),Size=UDim2.new(0,11,0,11),BackgroundColor3=Color3.new(1,1,1),ZIndex=3},svBox); cr(99,svT); st(Color3.new(0,0,0),1.5,svT)
        local function applySV(x,y)
            cS=math.clamp((x-svBox.AbsolutePosition.X)/svBox.AbsoluteSize.X,0,1)
            cV=1-math.clamp((y-svBox.AbsolutePosition.Y)/svBox.AbsoluteSize.Y,0,1)
            svT.Position=UDim2.new(cS,0,1-cV,0); rebuild(); sw.BackgroundColor3=cur
        end
        regSlide("sv_"..flg,applySV,applySV,svBox)
        local hRow=new("Frame",{Size=UDim2.new(1,0,0,20),BackgroundTransparency=1,LayoutOrder=nl()},body)
        local hTrk=new("Frame",{Position=UDim2.new(0,12,0.5,-3),Size=UDim2.new(1,-24,0,6),BackgroundColor3=Color3.new(1,1,1)},hRow); cr(99,hTrk)
        new("UIGradient",{Color=ColorSequence.new{
            ColorSequenceKeypoint.new(0,Color3.fromHSV(0,1,1)),ColorSequenceKeypoint.new(0.17,Color3.fromHSV(0.17,1,1)),
            ColorSequenceKeypoint.new(0.33,Color3.fromHSV(0.33,1,1)),ColorSequenceKeypoint.new(0.5,Color3.fromHSV(0.5,1,1)),
            ColorSequenceKeypoint.new(0.67,Color3.fromHSV(0.67,1,1)),ColorSequenceKeypoint.new(0.83,Color3.fromHSV(0.83,1,1)),
            ColorSequenceKeypoint.new(1,Color3.fromHSV(1,1,1)),
        }},hTrk)
        local hT=new("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(cH,0,0.5,0),Size=UDim2.new(0,11,0,11),BackgroundColor3=Color3.new(1,1,1),ZIndex=2},hTrk); cr(99,hT); st(T.BD,1,hT)
        local function applyH(x)
            cH=math.clamp((x-hTrk.AbsolutePosition.X)/hTrk.AbsoluteSize.X,0,1)
            hT.Position=UDim2.new(cH,0,0.5,0); svBox.BackgroundColor3=Color3.fromHSV(cH,1,1); rebuild(); sw.BackgroundColor3=cur
        end
        regSlide("hue_"..flg,applyH,function(x) applyH(x) end,hTrk)
        local hexRow=new("Frame",{Size=UDim2.new(1,0,0,26),BackgroundTransparency=1,LayoutOrder=nl()},body)
        local hxBg=new("Frame",{Position=UDim2.new(0,12,0.5,-9),Size=UDim2.new(1,-24,0,18),BackgroundColor3=T.B1},hexRow); cr(3,hxBg)
        local hxSt=st(T.BD,1,hxBg)
        tl({Position=UDim2.new(0,6,0,0),Size=UDim2.new(0,12,1,0),BackgroundTransparency=1,Text="#",TextColor3=T.MT,TextSize=12},hxBg)
        local hxBox=new("TextBox",{Position=UDim2.new(0,16,0,0),Size=UDim2.new(1,-20,1,0),BackgroundTransparency=1,Text=toHex(cur),PlaceholderText="FF69B4",PlaceholderColor3=T.MT,TextColor3=T.TX,TextSize=12,ClearTextOnFocus=false},hxBg)
        hxBox.Focused:Connect(function() tw(hxSt,{Color=T.A}) end)
        hxBox.FocusLost:Connect(function()
            tw(hxSt,{Color=T.BD})
            local c=hexToColor(hxBox.Text)
            if c then
                cur=c; cH,cS,cV=Color3.toHSV(c)
                sw.BackgroundColor3=c; svBox.BackgroundColor3=Color3.fromHSV(cH,1,1)
                svT.Position=UDim2.new(cS,0,1-cV,0); hT.Position=UDim2.new(cH,0,0.5,0)
                Flags[flg]=c; if cfg.Callback then cfg.Callback(c) end
            end
            hxBox.Text=toHex(cur)
        end)
        local origReb=rebuild
        rebuild=function() origReb(); hxBox.Text=toHex(cur) end
    end

    function api:AddLabel(cfg)
        local lbl=tl({Size=UDim2.new(1,0,0,20),BackgroundTransparency=1,Text=cfg.Name or "",TextColor3=T.MT,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,LayoutOrder=nl()},body)
        pad(0,0,12,0,lbl)
    end
    function api:AddLabel2(cfg)
        local lbl=tl({Size=UDim2.new(1,0,0,20),BackgroundTransparency=1,Text=cfg.Name or "",TextColor3=T.A,TextSize=14,TextXAlignment=Enum.TextXAlignment.Left,LayoutOrder=nl()},body)
        pad(0,0,12,0,lbl); table.insert(AL,function(c) lbl.TextColor3=c end)
    end
    function api:AddDivider()
        local wr=new("Frame",{Size=UDim2.new(1,0,0,10),BackgroundTransparency=1,LayoutOrder=nl()},body)
        new("Frame",{AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,10,0.5,0),Size=UDim2.new(1,-20,0,1),BackgroundColor3=T.BD,BackgroundTransparency=0.5},wr)
    end
    function api:AddKeybind(cfg)
        local flg=cfg.Flag or cfg.Name
        local cur=Flags[flg] or cfg.Default or Enum.KeyCode.RightShift; Flags[flg]=cur
        local listening=false
        table.insert(searchItems,{label=cfg.Name,keywords=cfg.Name..(cfg.Flag or ""),tab=tabName,switch=tabSwitch})
        local row=new("Frame",{Size=UDim2.new(1,0,0,34),BackgroundTransparency=1,LayoutOrder=nl()},body)
        local hbg=new("Frame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=T.B4,BackgroundTransparency=1},row); cr(4,hbg)
        tl({Position=UDim2.new(0,12,0,0),Size=UDim2.new(1,-100,1,0),BackgroundTransparency=1,Text=cfg.Name,TextColor3=T.TX,TextSize=14,TextXAlignment=Enum.TextXAlignment.Left},row)
        local badge=new("TextButton",{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-10,0.5,0),Size=UDim2.new(0,80,0,20),BackgroundColor3=T.B1,Text=cur.Name,TextColor3=T.A,TextSize=12},row)
        cr(4,badge); local bSt=st(T.BD,1,badge)
        table.insert(AL,function(c) if not listening then badge.TextColor3=c end end)
        badge.MouseEnter:Connect(function() tw(hbg,{BackgroundTransparency=0.84},0.08) end)
        badge.MouseLeave:Connect(function() tw(hbg,{BackgroundTransparency=1},0.08) end)
        badge.MouseButton1Click:Connect(function()
            if listening then return end
            listening=true; listeningForKey=true
            badge.Text="..."; badge.TextColor3=T.MT
            tw(badge,{BackgroundColor3=T.B3}); tw(bSt,{Color=T.A})
            local conn; conn=UIS.InputBegan:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.Keyboard then
                    listening=false; listeningForKey=false; cur=i.KeyCode; Flags[flg]=cur
                    if flg=="tkey" then toggleKey=cur end
                    badge.Text=cur.Name; badge.TextColor3=T.A
                    tw(badge,{BackgroundColor3=T.B1}); tw(bSt,{Color=T.BD})
                    if cfg.Callback then cfg.Callback(cur) end; conn:Disconnect()
                end
            end)
        end)
    end
    return api
end

-- WATERMARK
local wmFrame=new("Frame",{AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,12,1,-12),Size=UDim2.new(0,0,0,34),AutomaticSize=Enum.AutomaticSize.X,BackgroundColor3=T.B1,BackgroundTransparency=0.08,ZIndex=100,Visible=false},SG)
cr(6,wmFrame)
new("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,VerticalAlignment=Enum.VerticalAlignment.Center,SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,6)},wmFrame)
pad(0,0,7,10,wmFrame)
local wmIconImg=new("ImageLabel",{Size=UDim2.new(0,24,0,24),BackgroundTransparency=1,Image="",ZIndex=101,LayoutOrder=1,Visible=false},wmFrame)
local wmIconDot=new("Frame",{Size=UDim2.new(0,8,0,8),BackgroundColor3=T.A,LayoutOrder=1,ZIndex=101},wmFrame); cr(99,wmIconDot)
table.insert(AL,function(c) wmIconDot.BackgroundColor3=c end)
local wmScript=tl({Size=UDim2.new(0,0,0,16),AutomaticSize=Enum.AutomaticSize.X,BackgroundTransparency=1,Text=SCRIPT_NAME,TextColor3=T.TX,TextSize=14,LayoutOrder=2,ZIndex=101},wmFrame)
local wvBg=new("Frame",{Size=UDim2.new(0,0,0,15),AutomaticSize=Enum.AutomaticSize.X,BackgroundColor3=T.B3,LayoutOrder=3,ZIndex=101},wmFrame); cr(3,wvBg); pad(0,0,4,4,wvBg)
local wmVer=tl({Size=UDim2.new(0,0,1,0),AutomaticSize=Enum.AutomaticSize.X,BackgroundTransparency=1,Text=SCRIPT_VERSION,TextColor3=T.A,TextSize=10,ZIndex=102},wvBg)
table.insert(AL,function(c) wmVer.TextColor3=c end)
local wmNameLabel=new("TextLabel",{Visible=false,Size=UDim2.new(0,0,0,0),Text=LP.Name},SG)

-- LOADING SCREEN
local function showLoadingScreen()
    Win.Visible=false; bgOverlay.Visible=false
    local loadBg=new("Frame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=Color3.fromRGB(8,8,12),BackgroundTransparency=0.1,ZIndex=200},SG)
    local card=new("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,0,0.6,0),Size=UDim2.new(0,210,0,175),BackgroundColor3=T.B1,BackgroundTransparency=1,ZIndex=202},loadBg); cr(14,card)
    tw(card,{BackgroundTransparency=0.04,Position=UDim2.new(0.5,0,0.5,0)},0.4,Enum.EasingStyle.Back)
    local cardLine=new("Frame",{Size=UDim2.new(1,0,0,2),BackgroundColor3=T.A,ZIndex=203},card)
    table.insert(AL,function(c) cardLine.BackgroundColor3=c end)
    new("ImageLabel",{AnchorPoint=Vector2.new(0.5,0),Position=UDim2.new(0.5,0,0,18),Size=UDim2.new(0,58,0,58),BackgroundTransparency=1,Image=ICON_ID,ZIndex=203},card)
    tl({AnchorPoint=Vector2.new(0.5,0),Position=UDim2.new(0.5,0,0,88),Size=UDim2.new(1,-16,0,28),BackgroundTransparency=1,Text=SCRIPT_NAME,TextColor3=T.TX,TextSize=22,ZIndex=203},card)
    tl({AnchorPoint=Vector2.new(0.5,0),Position=UDim2.new(0.5,0,0,118),Size=UDim2.new(1,-16,0,16),BackgroundTransparency=1,Text=SCRIPT_VERSION,TextColor3=T.MT,TextSize=13,ZIndex=203},card)
    local progBg=new("Frame",{AnchorPoint=Vector2.new(0.5,1),Position=UDim2.new(0.5,0,1,-14),Size=UDim2.new(0.72,0,0,3),BackgroundColor3=T.B3,ZIndex=203},card); cr(99,progBg)
    local progFil=new("Frame",{Size=UDim2.new(0,0,1,0),BackgroundColor3=T.A,ZIndex=204},progBg); cr(99,progFil)
    table.insert(AL,function(c) progFil.BackgroundColor3=c end)
    task.spawn(function()
        tw(progFil,{Size=UDim2.new(0.65,0,1,0)},0.9)
        task.wait(0.95); tw(progFil,{Size=UDim2.new(1,0,1,0)},0.35)
    end)
    task.delay(1.5,function()
        tw(loadBg,{BackgroundTransparency=1},0.4)
        tw(card,{BackgroundTransparency=1,Position=UDim2.new(0.5,0,0.4,0)},0.35)
        for _,c in ipairs(card:GetDescendants()) do
            if c:IsA("GuiObject") then
                pcall(function() tw(c,{ImageTransparency=1},0.3) end)
                pcall(function() tw(c,{TextTransparency=1},0.3) end)
                pcall(function() tw(c,{BackgroundTransparency=1},0.3) end)
            end
        end
        task.delay(0.42,function()
            loadBg:Destroy(); uiReady=true
            Win.Visible=true; Win.BackgroundTransparency=1
            tw(Win,{BackgroundTransparency=0},0.3)
            if overlayEnabled then bgOverlay.Visible=true; bgOverlay.BackgroundTransparency=0.9; tw(bgOverlay,{BackgroundTransparency=0.55},0.3) end
            if WM_SHOW then wmFrame.Visible=true; wmFrame.BackgroundTransparency=1; tw(wmFrame,{BackgroundTransparency=0.08},0.3) end
            snowCont.Visible=true
        end)
    end)
end

-- SETUP
-- LOADER
local function showLoader(name, onDone)
    local TS2 = game:GetService("TweenService")
    local function tw2(o,p,t,s) TS2:Create(o,TweenInfo.new(t or 0.45,s or Enum.EasingStyle.Quint,Enum.EasingDirection.Out),p):Play() end

    local loaderGui = Instance.new("ScreenGui",SG.Parent or LP.PlayerGui)
    loaderGui.Name = "WhoaLoader"; loaderGui.ResetOnSpawn = false; loaderGui.IgnoreGuiInset = true; loaderGui.ZIndexBehavior = Enum.ZIndexBehavior.Global; loaderGui.DisplayOrder = 999

    local blur = Instance.new("BlurEffect", game:GetService("Lighting")); blur.Size = 0
    tw2(blur, {Size=48}, 0.8)

    local black = Instance.new("Frame", loaderGui)
    black.Size = UDim2.new(1,0,1,0); black.BackgroundColor3 = Color3.new(0,0,0); black.BackgroundTransparency = 1; black.BorderSizePixel = 0
    tw2(black, {BackgroundTransparency=0.65}, 0.5)

    local textHolder = Instance.new("Frame", loaderGui)
    textHolder.AnchorPoint = Vector2.new(0.5,0.5); textHolder.Position = UDim2.new(0.5,0,0.5,0)
    textHolder.Size = UDim2.new(1,0,0,200); textHolder.BackgroundTransparency = 1; textHolder.BorderSizePixel = 0
    local layout = Instance.new("UIListLayout", textHolder)
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.Padding = UDim.new(0, 2)
    layout.SortOrder = Enum.SortOrder.LayoutOrder

    local letters = {}
    for char in name:gmatch(".") do
        local frame = Instance.new("Frame", textHolder)
        frame.BackgroundTransparency = 1; frame.BorderSizePixel = 0
        frame.Size = UDim2.new(0, 60, 0, 120)

        local lbl = Instance.new("TextLabel", frame)
        lbl.AnchorPoint = Vector2.new(0.5,0.5); lbl.Position = UDim2.new(0.5,0,0.5,0)
        lbl.Size = UDim2.new(2,0,1,0); lbl.BackgroundTransparency = 1; lbl.BorderSizePixel = 0
        lbl.Text = char; lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 72
        lbl.TextColor3 = Color3.new(1,1,1); lbl.TextTransparency = 1
        local grad = Instance.new("UIGradient", lbl)
        grad.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, T.A),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(200,100,180))
        }
        grad.Rotation = 88
        local scale = Instance.new("UIScale", lbl); scale.Scale = 1
        table.insert(letters, {lbl=lbl, scale=scale, frame=frame})
    end

    task.wait(0.3)

    -- Animate first letter big then shrink into position
    local first = letters[1]
    if first then
        first.lbl.TextTransparency = 0
        first.scale.Scale = 4
        tw2(first.scale, {Scale=1}, 0.55, Enum.EasingStyle.Back)
        task.wait(0.4)
    end

    -- Pop in remaining letters
    for i = 2, #letters do
        local l = letters[i]
        l.lbl.Position = UDim2.new(0.5,0,0.5,80)
        tw2(l.lbl, {TextTransparency=0, Position=UDim2.new(0.5,0,0.5,0)}, 0.4, Enum.EasingStyle.Back)
        task.wait(0.06)
    end

    task.wait(1.2)

    -- Fade out
    for _, l in ipairs(letters) do
        tw2(l.lbl, {TextTransparency=1}, 0.5)
    end
    tw2(blur, {Size=0}, 0.8)
    tw2(black, {BackgroundTransparency=1}, 0.7)
    task.wait(0.8)

    loaderGui:Destroy()
    blur:Destroy()
    if onDone then onDone() end
end

-- SETUP
local function Setup(cfg)
    cfg=cfg or {}
    if cfg.Name then SCRIPT_NAME=cfg.Name; titleLabel.Text=cfg.Name; wmScript.Text=cfg.Name end
    if cfg.Version then SCRIPT_VERSION=cfg.Version; wmVer.Text=cfg.Version end
    if cfg.Icon and cfg.Icon~="" then
        ICON_ID=cfg.Icon; titleIcon.Image=cfg.Icon
        wmIconImg.Image=cfg.Icon; wmIconImg.Visible=true; wmIconDot.Visible=false
    end
    if cfg.Snow==true then startSnow() elseif cfg.Snow==false then stopSnow() end
    if cfg.WatermarkSubtext and cfg.WatermarkSubtext~="" then
        new("Frame",{Size=UDim2.new(0,1,0,12),BackgroundColor3=T.BD,LayoutOrder=4,ZIndex=101},wmFrame)
        tl({Size=UDim2.new(0,0,0,12),AutomaticSize=Enum.AutomaticSize.X,BackgroundTransparency=1,Text=cfg.WatermarkSubtext,TextColor3=T.MT,TextSize=10,LayoutOrder=5,ZIndex=101},wmFrame)
    end
    local keys=cfg.Keys or {}; local keyURL=cfg.KeyURL or ""; local keyFile=cfg.KeyFile or "WhoaKey.txt"; local persist=cfg.KeyPersist~=false
    local function revealUI()
        task.spawn(function()
            showLoader(SCRIPT_NAME, function()
                uiReady=true
                Win.Visible=true
                if overlayEnabled then bgOverlay.Visible=true end
                if WM_SHOW then wmFrame.Visible=true end
                snowCont.Visible=true
                task.delay(0.5,function()
                    Notify("Tip", "Press "..toggleKey.Name.." to open / close the UI", "Info", 5)
                end)
            end)
        end)
    end
    if #keys==0 then revealUI(); return end
    local unlocked=false
    if persist and isfile and isfile(keyFile) then
        pcall(function()
            local k=readfile(keyFile):gsub("%s",""):lower()
            for _,v in ipairs(keys) do if k==v:lower() then unlocked=true; break end end
        end)
    end
    if unlocked then revealUI(); return end
    bgOverlay.Visible=true
    local ov=new("Frame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=0.55,ZIndex=200},SG)
    local mdH=persist and 250 or 234
    local md=new("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,0,0.5,0),Size=UDim2.new(0,320,0,mdH),BackgroundColor3=T.B2,ZIndex=201,BackgroundTransparency=1},ov); cr(10,md)
    tw(md,{BackgroundTransparency=0},0.25,Enum.EasingStyle.Back)
    local topBar=new("Frame",{Size=UDim2.new(1,0,0,2),BackgroundColor3=T.A,ZIndex=202},md)
    table.insert(AL,function(c) topBar.BackgroundColor3=c end)
    if ICON_ID~="" then
        new("ImageLabel",{AnchorPoint=Vector2.new(0.5,0),Position=UDim2.new(0.5,0,0,16),Size=UDim2.new(0,44,0,44),BackgroundTransparency=1,Image=ICON_ID,ZIndex=202},md)
    else
        local ad=new("Frame",{AnchorPoint=Vector2.new(0.5,0),Position=UDim2.new(0.5,0,0,16),Size=UDim2.new(0,30,0,30),BackgroundColor3=T.B3,ZIndex=202},md); cr(99,ad)
        new("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,0,0.5,0),Size=UDim2.new(0.4,0,0.4,0),BackgroundColor3=T.A,ZIndex=203},ad); cr(99,ad:FindFirstChildOfClass("Frame"))
    end
    tl({AnchorPoint=Vector2.new(0.5,0),Position=UDim2.new(0.5,0,0,68),Size=UDim2.new(1,0,0,24),BackgroundTransparency=1,Text=SCRIPT_NAME,TextColor3=T.TX,TextSize=19,ZIndex=202},md)
    tl({AnchorPoint=Vector2.new(0.5,0),Position=UDim2.new(0.5,0,0,94),Size=UDim2.new(1,0,0,15),BackgroundTransparency=1,Text="enter your key to continue",TextColor3=T.MT,TextSize=12,ZIndex=202},md)
    tl({Position=UDim2.new(0,20,0,118),Size=UDim2.new(1,-40,0,12),BackgroundTransparency=1,Text="LICENSE KEY",TextColor3=T.MT,TextSize=10,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=202},md)
    local ib=new("Frame",{Position=UDim2.new(0,16,0,133),Size=UDim2.new(1,-32,0,30),BackgroundColor3=T.B1,ZIndex=202},md); cr(5,ib)
    local iSt=st(T.BD,1,ib)
    local ki=new("TextBox",{Position=UDim2.new(0,10,0,0),Size=UDim2.new(1,-20,1,0),BackgroundTransparency=1,Text="",PlaceholderText="enter key...",PlaceholderColor3=T.MT,TextColor3=T.TX,TextSize=13,ClearTextOnFocus=false,ZIndex=203},ib)
    local el=tl({Position=UDim2.new(0,20,0,167),Size=UDim2.new(1,-40,0,13),BackgroundTransparency=1,Text="",TextColor3=Color3.fromRGB(255,80,80),TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=202},md)
    if persist then tl({Position=UDim2.new(0,20,0,182),Size=UDim2.new(1,-40,0,11),BackgroundTransparency=1,Text="key saved for next session",TextColor3=T.SUB,TextSize=10,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=202},md) end
    local btnY=persist and 198 or 182
    local authBtn=new("TextButton",{Position=UDim2.new(0,16,0,btnY),Size=UDim2.new(0.5,-20,0,34),BackgroundColor3=T.A,Text="Authenticate",TextColor3=Color3.fromRGB(10,10,14),TextSize=14,ZIndex=202},md); cr(6,authBtn)
    table.insert(AL,function(c) authBtn.BackgroundColor3=c end)
    local getBtn=new("TextButton",{Position=UDim2.new(0.5,4,0,btnY),Size=UDim2.new(0.5,-20,0,34),BackgroundColor3=T.B3,Text="Get Key",TextColor3=T.TX,TextSize=14,ZIndex=202},md); cr(6,getBtn)
    local gSt=st(T.BD,1,getBtn)
    getBtn.MouseEnter:Connect(function() tw(gSt,{Color=T.A}) end)
    getBtn.MouseLeave:Connect(function() tw(gSt,{Color=T.BD}) end)
    ki.Focused:Connect(function() tw(iSt,{Color=T.A,Thickness=1.5}) end)
    ki.FocusLost:Connect(function() tw(iSt,{Color=T.BD,Thickness=1}) end)
    local copiedLbl=tl({AnchorPoint=Vector2.new(0.5,0),Position=UDim2.new(0.5,0,1,8),Size=UDim2.new(1,0,0,30),BackgroundTransparency=1,Text="Copied link!",TextColor3=T.A,TextSize=22,TextTransparency=1,ZIndex=203},md)
table.insert(AL,function(c) copiedLbl.TextColor3=c end)
getBtn.MouseButton1Click:Connect(function()
    pcall(function() if setclipboard then setclipboard(keyURL) end end)
    copiedLbl.TextTransparency=0
    tw(copiedLbl,{TextTransparency=1},1.5)
end)
    authBtn.MouseEnter:Connect(function() tw(authBtn,{BackgroundTransparency=0.15}) end)
    authBtn.MouseLeave:Connect(function() tw(authBtn,{BackgroundTransparency=0}) end)
    local function tryKey()
        local k=ki.Text:gsub("%s",""):lower(); local valid=false
        for _,v in ipairs(keys) do if k==v:lower() then valid=true; break end end
        if valid then
            if persist then pcall(function() if writefile then writefile(keyFile,k) end end) end
            tw(ov,{BackgroundTransparency=1},0.3); tw(md,{BackgroundTransparency=1},0.3)
            task.delay(0.3,function()
                ov:Destroy(); bgOverlay.Visible=false
                revealUI()
            end)
        else
            el.Text="incorrect key, try again"; tw(iSt,{Color=Color3.fromRGB(200,60,60),Thickness=1.5},0.1)
            task.delay(2,function() el.Text=""; tw(iSt,{Color=T.BD,Thickness=1},0.2) end)
        end
    end
    authBtn.MouseButton1Click:Connect(tryKey)
    ki.FocusLost:Connect(function(e) if e then tryKey() end end)
end

return {
    Setup=Setup, AddTab=addTab, MakeSection=makeSection, Notify=Notify,
    SetAccent=setA, StartSnow=startSnow, StopSnow=stopSnow, SetOverlay=setOverlay,
    Flags=Flags, pbNameLabel=pbNameLabel, avImg=avImg, wmFrame=wmFrame, wmNameLabel=wmNameLabel,
    SaveConfig=cfgSave, LoadConfig=cfgLoad, DeleteConfig=cfgDelete, ListConfigs=cfgList,
    SetAutoLoad=cfgSetAuto, GetAutoLoad=cfgGetAuto,
    Destroy=function() pcall(stopSnow); pcall(function() SG:Destroy() end) end,
}
