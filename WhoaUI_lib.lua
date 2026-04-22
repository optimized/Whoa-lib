-- ══════════════════════════════════════════════════════════
--   WhoaUI v2.2 — Loadstring Library
--   Usage:  local UI = loadstring(game:HttpGet("YOUR_RAW_URL"))()
--           UI.Setup({ Keys={"mykey"}, KeyURL="...", ... })
-- ══════════════════════════════════════════════════════════

local SCRIPT_NAME    = "script"
local SCRIPT_VERSION = "v1.0"
local ICON_IMAGE     = ""
local SECTION_ICON   = ""
local WM_SHOW        = true
local WIN_WIDTH      = 700
local WIN_HEIGHT     = 500
local TOGGLE_KEY     = Enum.KeyCode.RightShift
local SNOW_ENABLED   = false
local NOTIF_DURATION = 3

local T = {
    A  = Color3.fromRGB(255,182,215), A2 = Color3.fromRGB(255,150,195),
    B0 = Color3.fromRGB(9,9,13),     B1 = Color3.fromRGB(14,14,19),
    B2 = Color3.fromRGB(20,20,27),   B3 = Color3.fromRGB(26,26,35),
    B4 = Color3.fromRGB(34,34,46),   BD = Color3.fromRGB(52,52,70),
    TX = Color3.fromRGB(255,255,255), MT = Color3.fromRGB(115,115,145),
}

local Players = game:GetService("Players")
local TS      = game:GetService("TweenService")
local UIS     = game:GetService("UserInputService")
local RS      = game:GetService("RunService")
local HS      = game:GetService("HttpService")
local LP      = Players.LocalPlayer

for _,v in ipairs({game:GetService("CoreGui"), LP.PlayerGui}) do
    pcall(function() if v:FindFirstChild("WhoaUI") then v.WhoaUI:Destroy() end end)
end

local AL = {}
local function setA(c) T.A=c; for _,fn in ipairs(AL) do pcall(fn,c) end end
local Flags           = {}
local toggleKey       = TOGGLE_KEY
local listeningForKey = false

-- ── CONFIG (no auto-save; call explicitly) ────────────────
local CFG_PREFIX = "WhoaUI_cfg_"
local CFG_INDEX  = "WhoaUI_cfglist.json"
local CFG_AUTO   = "WhoaUI_autoload.txt"
local function _encode()
    local out={}
    for k,v in pairs(Flags) do
        local t=typeof(v)
        if t=="boolean" or t=="number" or t=="string" then out[k]=v
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
        writefile(CFG_PREFIX..name..".json", HS:JSONEncode(_encode()))
        local list=cfgList(); local found=false
        for _,v in ipairs(list) do if v==name then found=true; break end end
        if not found then table.insert(list,name); writefile(CFG_INDEX, HS:JSONEncode(list)) end
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
        if writefile then writefile(CFG_INDEX, HS:JSONEncode(list)) end
    end)
end
local function cfgSetAuto(name) pcall(function() if writefile then writefile(CFG_AUTO, name or "") end end) end
local function cfgGetAuto()
    if not readfile or not isfile or not isfile(CFG_AUTO) then return nil end
    local n=readfile(CFG_AUTO):gsub("%s",""); return n~="" and n or nil
end
-- Load autoload on start
local _auto=cfgGetAuto(); if _auto then cfgLoad(_auto) end

-- ── HELPERS ───────────────────────────────────────────────
local function tw(o,p,t,s) TS:Create(o,TweenInfo.new(t or 0.15,s or Enum.EasingStyle.Quad,Enum.EasingDirection.Out),p):Play() end
local function new(cls,props,parent)
    local o=Instance.new(cls)
    if cls=="Frame" or cls=="ScrollingFrame" then pcall(function() o.BorderSizePixel=0 end) end
    for k,v in pairs(props or {}) do pcall(function() o[k]=v end) end
    if parent then o.Parent=parent end; return o
end
local function cr(r,p)   return new("UICorner",{CornerRadius=UDim.new(0,r)},p) end
local function st(c,t,p) return new("UIStroke",{Color=c,Thickness=t or 1},p) end
local function pad(t,b,l,r,p) return new("UIPadding",{PaddingTop=UDim.new(0,t),PaddingBottom=UDim.new(0,b),PaddingLeft=UDim.new(0,l),PaddingRight=UDim.new(0,r)},p) end
local function tl(props,parent)
    local o=new("TextLabel",props,parent)
    local s=Instance.new("UIStroke"); s.Color=Color3.new(0,0,0); s.Thickness=1; s.ApplyStrokeMode=Enum.ApplyStrokeMode.Contextual; s.Parent=o; return o
end
local function hexToColor(h)
    h=h:gsub("#",""); if #h~=6 then return nil end
    local r,g,b=tonumber(h:sub(1,2),16),tonumber(h:sub(3,4),16),tonumber(h:sub(5,6),16)
    return (r and g and b) and Color3.fromRGB(r,g,b) or nil
end
local function toHex(c) return string.format("%02X%02X%02X",math.round(c.R*255),math.round(c.G*255),math.round(c.B*255)) end

-- ── SCREENGUI ─────────────────────────────────────────────
local SG=new("ScreenGui",{Name="WhoaUI",ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,IgnoreGuiInset=true,DisplayOrder=99})
pcall(function() if syn and syn.protect_gui then syn.protect_gui(SG) end; SG.Parent=game:GetService("CoreGui") end)
if not SG.Parent then SG.Parent=LP.PlayerGui end

-- ── NOTIFICATIONS ─────────────────────────────────────────
local nh=new("Frame",{AnchorPoint=Vector2.new(1,1),Position=UDim2.new(1,-14,1,-14),Size=UDim2.new(0,270,1,-28),BackgroundTransparency=1,ZIndex=999},SG)
new("UIListLayout",{FillDirection=Enum.FillDirection.Vertical,VerticalAlignment=Enum.VerticalAlignment.Bottom,SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,6)},nh)
local nCol={Success=Color3.fromRGB(60,220,130),Error=Color3.fromRGB(255,75,75),Warning=Color3.fromRGB(255,160,40)}
local function Notify(title,body,ntype,dur)
    local col=nCol[ntype] or T.A
    local nf=new("Frame",{Size=UDim2.new(1,0,0,62),BackgroundColor3=T.B3,ZIndex=999},nh); cr(8,nf); st(T.BD,1,nf)
    new("Frame",{Size=UDim2.new(0,3,0.75,0),AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,0,0.5,0),BackgroundColor3=col,ZIndex=1000},nf)
    tl({Position=UDim2.new(0,12,0,9),Size=UDim2.new(1,-16,0,18),BackgroundTransparency=1,Text=title,TextColor3=T.A,Font=Enum.Font.FredokaOne,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=1000},nf)
    tl({Position=UDim2.new(0,12,0,29),Size=UDim2.new(1,-16,0,22),BackgroundTransparency=1,Text=body,TextColor3=T.TX,Font=Enum.Font.FredokaOne,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,ZIndex=1000},nf)
    nf.Position=UDim2.new(1.1,0,0,0); tw(nf,{Position=UDim2.new(0,0,0,0)},0.25,Enum.EasingStyle.Back)
    task.delay(dur or NOTIF_DURATION,function() tw(nf,{Position=UDim2.new(1.1,0,0,0)},0.2); task.delay(0.25,function() nf:Destroy() end) end)
end

-- ── WINDOW ────────────────────────────────────────────────
local WW,WH=WIN_WIDTH,WIN_HEIGHT; local winOpen=true; local winMin=false
local bgOverlay=new("Frame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=0.55,ZIndex=1},SG)
local snowCont=new("Frame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,ZIndex=5},SG)

-- Use absolute offset from the start — avoids scale→offset jump on first drag
local function initPos()
    local vp=workspace.CurrentCamera.ViewportSize
    return UDim2.new(0,math.floor(vp.X/2-WW/2),0,math.floor(vp.Y/2-WH/2))
end
local Win=new("Frame",{Name="Window",AnchorPoint=Vector2.new(0,0),Position=initPos(),Size=UDim2.new(0,WW,0,WH),BackgroundColor3=T.B1,ClipsDescendants=true,ZIndex=10},SG)
cr(12,Win); local winSt=st(T.A2,1.5,Win); table.insert(AL,function(c) winSt.Color=c end)

local TBar=new("Frame",{Size=UDim2.new(1,0,0,54),BackgroundColor3=T.B0},Win); cr(12,TBar)
new("Frame",{Position=UDim2.new(0,0,0.5,0),Size=UDim2.new(1,0,0.5,0),BackgroundColor3=T.B0},TBar)
new("Frame",{AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,0,1,0),Size=UDim2.new(1,0,0,1),BackgroundColor3=T.BD},TBar)
local iconBg=new("Frame",{AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,11,0.5,0),Size=UDim2.new(0,36,0,36),BackgroundColor3=T.B0,ZIndex=2},TBar); cr(8,iconBg)
local iconImg=new("ImageLabel",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,0,0.5,0),Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Image="",ScaleType=Enum.ScaleType.Fit,ZIndex=3,Visible=false},iconBg); cr(8,iconImg)
local iconLetter=tl({Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="W",TextColor3=Color3.new(1,1,1),Font=Enum.Font.GothamBold,TextSize=16,ZIndex=3,Visible=true},iconBg)
local titleLabel=tl({AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,56,0.5,0),Size=UDim2.new(0,200,1,0),BackgroundTransparency=1,Text=SCRIPT_NAME,TextColor3=T.TX,Font=Enum.Font.GothamBold,TextSize=19,TextXAlignment=Enum.TextXAlignment.Left},TBar)
local pb=new("Frame",{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-42,0.5,0),Size=UDim2.new(0,28,0,28),AutomaticSize=Enum.AutomaticSize.X,BackgroundColor3=T.B4},TBar); cr(6,pb); st(T.BD,1,pb); pad(0,0,3,10,pb)
local avImg=new("ImageLabel",{AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,3,0.5,0),Size=UDim2.new(0,22,0,22),BackgroundColor3=T.B2,Image=""},pb); cr(5,avImg)
local pbNameLabel=tl({AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,29,0.5,0),Size=UDim2.new(0,0,0,16),AutomaticSize=Enum.AutomaticSize.X,BackgroundTransparency=1,Text=LP.DisplayName,TextColor3=Color3.new(1,1,1),Font=Enum.Font.FredokaOne,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left},pb)
local realAvatar
task.spawn(function() pcall(function() realAvatar=Players:GetUserThumbnailAsync(LP.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size60x60); avImg.Image=realAvatar end) end)
local mb=new("TextButton",{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-6,0.5,0),Size=UDim2.new(0,28,0,20),BackgroundColor3=T.B4,Text="",ZIndex=3},TBar); cr(6,mb); st(T.BD,1,mb)
local mbBar=new("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,0,0.5,0),Size=UDim2.new(0,12,0,2),BackgroundColor3=T.MT,ZIndex=4},mb); cr(99,mbBar)
mb.MouseEnter:Connect(function() tw(mb,{BackgroundColor3=T.B3}); tw(mbBar,{BackgroundColor3=T.A}) end)
mb.MouseLeave:Connect(function() tw(mb,{BackgroundColor3=T.B4}); tw(mbBar,{BackgroundColor3=T.MT}) end)
mb.MouseButton1Click:Connect(function() winMin=not winMin; tw(Win,{Size=winMin and UDim2.new(0,WW,0,54) or UDim2.new(0,WW,0,WH)},0.22) end)

-- ── DRAG — pure offset, full viewport clamping ────────────
local drag,dragStart,winStart=false,nil,nil
TBar.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
        drag=true
        dragStart=i.Position
        -- Read offsets directly — AbsolutePosition includes GuiInset in CoreGui, causing a jump on drag start
        winStart=UDim2.new(0, Win.Position.X.Offset, 0, Win.Position.Y.Offset)
    end
end)
UIS.InputChanged:Connect(function(i)
    if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
        local d=i.Position-dragStart
        local vp=workspace.CurrentCamera.ViewportSize
        local ws=Win.AbsoluteSize
        Win.Position=UDim2.new(0,
            math.clamp(winStart.X.Offset+d.X, 0, math.max(0,vp.X-ws.X)),
            0,
            math.clamp(winStart.Y.Offset+d.Y, 0, math.max(0,vp.Y-ws.Y))
        )
    end
end)
UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=false end end)

local function setVisible(v) winOpen=v; Win.Visible=v; bgOverlay.Visible=v; snowCont.Visible=v end

-- ── TOGGLE — no gpe filter so every key works ─────────────
UIS.InputBegan:Connect(function(i)
    if not listeningForKey and i.KeyCode==toggleKey then setVisible(not winOpen) end
end)

-- ── RESPONSIVE SCALE ──────────────────────────────────────
local function scaleWindow()
    local vp=workspace.CurrentCamera.ViewportSize
    local s=math.min(vp.X/WW, vp.Y/WH)
    local sw,sh
    if s>=1 then sw=WW; sh=WH else s=math.max(s*0.93,0.45); sw=math.floor(WW*s); sh=math.floor(WH*s) end
    Win.Size=winMin and UDim2.new(0,sw,0,54) or UDim2.new(0,sw,0,sh)
end
scaleWindow()
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(scaleWindow)

-- ── TAB BAR ───────────────────────────────────────────────
local TopRow=new("Frame",{Position=UDim2.new(0,0,0,54),Size=UDim2.new(1,0,0,36),BackgroundColor3=T.B0},Win)
new("Frame",{Position=UDim2.new(0,0,0.5,0),Size=UDim2.new(1,0,0.5,0),BackgroundColor3=T.B0},TopRow)
new("Frame",{AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,0,1,0),Size=UDim2.new(1,0,0,1),BackgroundColor3=T.BD},TopRow)
local tabList=new("Frame",{Size=UDim2.new(1,-120,1,0),Position=UDim2.new(0,6,0,0),BackgroundTransparency=1},TopRow)
new("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,VerticalAlignment=Enum.VerticalAlignment.Center,SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,0)},tabList)
local searchBg=new("Frame",{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-8,0.5,0),Size=UDim2.new(0,108,0,24),BackgroundColor3=T.B2},TopRow); cr(6,searchBg); local searchSt=st(T.BD,1,searchBg)
local searchBox=new("TextBox",{Position=UDim2.new(0,8,0,0),Size=UDim2.new(1,-16,1,0),BackgroundTransparency=1,Text="",PlaceholderText="search...",PlaceholderColor3=T.MT,TextColor3=T.TX,Font=Enum.Font.Gotham,TextSize=12,ClearTextOnFocus=false},searchBg)
searchBox.Focused:Connect(function() tw(searchSt,{Color=T.A}) end); searchBox.FocusLost:Connect(function() tw(searchSt,{Color=T.BD}) end)
local ContentArea=new("Frame",{Position=UDim2.new(0,0,0,90),Size=UDim2.new(1,0,1,-90),BackgroundTransparency=1,ClipsDescendants=true},Win)
local searchOverlay=new("ScrollingFrame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=T.B1,BackgroundTransparency=0,BorderSizePixel=0,ScrollBarThickness=3,ScrollBarImageColor3=T.BD,CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,Visible=false,ZIndex=50},ContentArea)
new("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,4)},searchOverlay); pad(6,6,8,8,searchOverlay)
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
            local res=new("Frame",{Size=UDim2.new(1,0,0,36),BackgroundColor3=T.B3,LayoutOrder=found,ZIndex=51},searchOverlay); cr(6,res); st(T.BD,1,res)
            tl({Position=UDim2.new(0,12,0,0),Size=UDim2.new(0.52,0,1,0),BackgroundTransparency=1,Text=item.label,TextColor3=T.TX,Font=Enum.Font.FredokaOne,TextSize=14,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=52},res)
            tl({Position=UDim2.new(0.52,0,0,0),Size=UDim2.new(0.26,0,1,0),BackgroundTransparency=1,Text=item.tab,TextColor3=T.MT,Font=Enum.Font.Gotham,TextSize=11,TextXAlignment=Enum.TextXAlignment.Right,ZIndex=52},res)
            local goBtn=new("TextButton",{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-6,0.5,0),Size=UDim2.new(0,42,0,22),BackgroundColor3=T.B4,Text="go",TextColor3=T.A,Font=Enum.Font.GothamBold,TextSize=11,ZIndex=53},res); cr(4,goBtn); st(T.BD,1,goBtn)
            local rowBtn=new("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=54},res)
            rowBtn.MouseEnter:Connect(function() tw(res,{BackgroundColor3=T.B4},0.08) end); rowBtn.MouseLeave:Connect(function() tw(res,{BackgroundColor3=T.B3},0.08) end)
            local function doNav() if item.switch then item.switch() end; searchBox.Text="" end
            rowBtn.MouseButton1Click:Connect(doNav); goBtn.MouseButton1Click:Connect(doNav)
        end
    end
    if found==0 then tl({Size=UDim2.new(1,0,0,36),BackgroundTransparency=1,Text="No results found",TextColor3=T.MT,Font=Enum.Font.FredokaOne,TextSize=14,ZIndex=51},searchOverlay) end
end
searchBox:GetPropertyChangedSignal("Text"):Connect(function() rebuildSearch(searchBox.Text) end)

-- ── TABS ──────────────────────────────────────────────────
local tabFrames,tabBtns={},{}
local function addTab(name)
    local btn=new("TextButton",{Size=UDim2.new(0,0,1,0),AutomaticSize=Enum.AutomaticSize.X,BackgroundTransparency=1,Text=name,TextColor3=T.MT,Font=Enum.Font.GothamBold,TextSize=14},tabList)
    pad(0,0,16,16,btn)
    local s=Instance.new("UIStroke"); s.Color=Color3.new(0,0,0); s.Thickness=1; s.ApplyStrokeMode=Enum.ApplyStrokeMode.Contextual; s.Parent=btn
    local ul=new("Frame",{AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,0,1,0),Size=UDim2.new(1,0,0,2),BackgroundColor3=T.A,Visible=false},btn); cr(99,ul); table.insert(AL,function(c) ul.BackgroundColor3=c end)
    local frame=new("Frame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Visible=false},ContentArea)
    local function makeCol(xs,xo,wo)
        local col=new("ScrollingFrame",{Position=UDim2.new(xs,xo,0,6),Size=UDim2.new(0.5,wo,1,-12),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,ScrollBarImageColor3=T.BD,CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y},frame)
        new("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,6)},col); pad(2,4,0,0,col); return col
    end
    local colL=makeCol(0,6,-10); local colR=makeCol(0.5,4,-10)
    table.insert(tabFrames,frame); table.insert(tabBtns,{b=btn,u=ul})
    local function switchToTab()
        for _,f in ipairs(tabFrames) do f.Visible=false end
        for _,b in ipairs(tabBtns) do tw(b.b,{TextColor3=T.MT}); b.u.Visible=false end
        frame.Visible=true; btn.TextColor3=T.A; ul.Visible=true; searchBox.Text=""
    end
    btn.MouseButton1Click:Connect(switchToTab)
    if #tabFrames==1 then frame.Visible=true; btn.TextColor3=T.A; ul.Visible=true end
    return colL,colR,name,switchToTab
end

-- ── SECTIONS ──────────────────────────────────────────────
local function makeSection(parent,title)
    local sec=new("Frame",{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundColor3=T.B3,ClipsDescendants=true},parent)
    cr(8,sec); st(T.BD,1,sec)
    local body=new("Frame",{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1},sec)
    pad(4,6,0,0,body); new("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,0)},body)
    local lo=0; local function nl() lo+=1; return lo end
    local tabName=""; local tabSwitch=nil; local collapsed=false

    if title and title~="" then
        local hdr=new("TextButton",{Size=UDim2.new(1,0,0,28),BackgroundColor3=T.B2,LayoutOrder=0,Text="",ZIndex=2},body)
        local acBar=new("Frame",{Size=UDim2.new(0,3,1,0),BackgroundColor3=T.A},hdr); table.insert(AL,function(c) acBar.BackgroundColor3=c end)
        tl({Position=UDim2.new(0,12,0,0),Size=UDim2.new(1,-36,1,0),BackgroundTransparency=1,Text=title:upper(),TextColor3=Color3.fromRGB(200,160,230),Font=Enum.Font.GothamBold,TextSize=10,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=3},hdr)
        new("Frame",{AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,0,1,0),Size=UDim2.new(1,0,0,1),BackgroundColor3=T.BD},hdr)
        if SECTION_ICON~="" then
            local ib=new("Frame",{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-5,0.5,0),Size=UDim2.new(0,22,0,22),BackgroundTransparency=1,ZIndex=3},hdr)
            new("ImageLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Image=SECTION_ICON,ScaleType=Enum.ScaleType.Fit,ImageTransparency=0.15,ZIndex=4},ib)
        end
        -- Collapse on header click
        hdr.MouseButton1Click:Connect(function()
            collapsed=not collapsed
            if collapsed then
                sec.AutomaticSize=Enum.AutomaticSize.None
                tw(sec,{Size=UDim2.new(1,0,0,28)},0.18)
            else
                tw(sec,{Size=UDim2.new(1,0,0,28)},0.01)
                task.delay(0.05,function()
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

    local slideCBs={}; local slideActive=nil
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
        local row=new("Frame",{Size=UDim2.new(1,0,0,36),BackgroundTransparency=1,LayoutOrder=nl()},body)
        local hbg=new("Frame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=T.B4,BackgroundTransparency=1},row); cr(4,hbg)
        tl({Position=UDim2.new(0,12,0,0),Size=UDim2.new(1,-72,1,0),BackgroundTransparency=1,Text=cfg.Name,TextColor3=Color3.new(1,1,1),Font=Enum.Font.FredokaOne,TextSize=14,TextXAlignment=Enum.TextXAlignment.Left},row)
        local cbBG=new("Frame",{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-10,0.5,0),Size=UDim2.new(0,22,0,22),BackgroundColor3=T.B1},row); cr(6,cbBG); local cbSt=st(T.BD,1.5,cbBG)
        local cbFill=new("Frame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=T.A,Visible=false},cbBG); cr(5,cbFill)
        new("UIGradient",{Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(255,220,240)),ColorSequenceKeypoint.new(1,T.A)},Rotation=135},cbFill)
        local tick=new("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="✓",TextColor3=Color3.new(1,1,1),Font=Enum.Font.GothamBold,TextSize=16,Visible=false,ZIndex=3},cbBG)
        local function upd()
            if on then cbFill.Visible=true; tick.Visible=true; tw(cbSt,{Color=T.A,Thickness=1.5}); cbBG.Size=UDim2.new(0,16,0,16); tw(cbBG,{Size=UDim2.new(0,22,0,22)},0.14,Enum.EasingStyle.Back); cbFill.BackgroundColor3=T.A
            else cbFill.Visible=false; tick.Visible=false; tw(cbBG,{Size=UDim2.new(0,22,0,22)}); tw(cbSt,{Color=T.BD,Thickness=1.5}) end
        end
        table.insert(AL,function(c) if on then cbFill.BackgroundColor3=c; cbSt.Color=c end end)
        if cfg.Keybind then
            local kc=Enum.KeyCode[cfg.Keybind]
            if kc then UIS.InputBegan:Connect(function(i) if i.KeyCode==kc then on=not on; Flags[flg]=on; upd(); if cfg.Callback then cfg.Callback(on) end end end) end
        end
        local btn=new("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=2},row)
        btn.MouseEnter:Connect(function() tw(hbg,{BackgroundTransparency=0.82},0.1) end); btn.MouseLeave:Connect(function() tw(hbg,{BackgroundTransparency=1},0.1) end)
        btn.MouseButton1Click:Connect(function() on=not on; Flags[flg]=on; upd(); if cfg.Callback then cfg.Callback(on) end end)
        upd()
    end

    function api:AddSlider(cfg)
        local flg=cfg.Flag or cfg.Name
        local val=(Flags[flg]~=nil) and Flags[flg] or (cfg.Default or cfg.Min or 0); local dec=cfg.Decimals or 0; Flags[flg]=val
        table.insert(searchItems,{label=cfg.Name,keywords=cfg.Name..(cfg.Flag or ""),tab=tabName,switch=tabSwitch})
        local function fmt(v) return dec>0 and string.format("%."..dec.."f",v) or tostring(math.round(v)) end
        local wr=new("Frame",{Size=UDim2.new(1,0,0,52),BackgroundTransparency=1,LayoutOrder=nl()},body)
        local hbg=new("Frame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=T.B4,BackgroundTransparency=1},wr); cr(4,hbg)
        tl({Position=UDim2.new(0,12,0,8),Size=UDim2.new(0.55,0,0,18),BackgroundTransparency=1,Text=cfg.Name,TextColor3=Color3.new(1,1,1),Font=Enum.Font.FredokaOne,TextSize=14,TextXAlignment=Enum.TextXAlignment.Left},wr)
        local vl=new("TextButton",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-10,0,6),Size=UDim2.new(0,94,0,20),BackgroundColor3=T.B2,Text=fmt(val).." / "..fmt(cfg.Max),TextColor3=T.A,Font=Enum.Font.FredokaOne,TextSize=12},wr); cr(4,vl); st(T.BD,1,vl); table.insert(AL,function(c) vl.TextColor3=c end)
        local eb=new("TextBox",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",TextColor3=T.A,Font=Enum.Font.Gotham,TextSize=12,Visible=false,ClearTextOnFocus=true,ZIndex=2},vl)
        local track=new("Frame",{Position=UDim2.new(0,12,0,36),Size=UDim2.new(1,-24,0,5),BackgroundColor3=T.B0},wr); cr(99,track); st(T.BD,1,track)
        local p0=(val-cfg.Min)/(cfg.Max-cfg.Min)
        local fil=new("Frame",{Size=UDim2.new(p0,0,1,0),BackgroundColor3=T.A},track); cr(99,fil)
        local grad=new("UIGradient",{Color=ColorSequence.new{ColorSequenceKeypoint.new(0,T.A),ColorSequenceKeypoint.new(1,Color3.fromRGB(255,180,220))}},fil)
        table.insert(AL,function(c) fil.BackgroundColor3=c; grad.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,c),ColorSequenceKeypoint.new(1,Color3.fromRGB(255,180,220))} end)
        local thumb=new("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(p0,0,0.5,0),Size=UDim2.new(0,13,0,13),BackgroundColor3=Color3.new(1,1,1),ZIndex=2},track); cr(99,thumb); st(T.BD,1,thumb)
        local function setVal(v)
            v=math.clamp(v,cfg.Min,cfg.Max); v=dec==0 and math.round(v) or math.floor(v*10^dec+0.5)/10^dec; val=v; Flags[flg]=v
            local p=(v-cfg.Min)/(cfg.Max-cfg.Min); tw(fil,{Size=UDim2.new(p,0,1,0)},0.04); tw(thumb,{Position=UDim2.new(p,0,0.5,0)},0.04); vl.Text=fmt(v).." / "..fmt(cfg.Max); if cfg.Callback then cfg.Callback(v) end
        end
        vl.MouseButton1Click:Connect(function() eb.Text=fmt(val); eb.Visible=true; vl.Text=""; eb:CaptureFocus() end)
        eb.FocusLost:Connect(function() eb.Visible=false; local n=tonumber(eb.Text); if n then setVal(n) end; vl.Text=fmt(val).." / "..fmt(cfg.Max) end)
        local function fromX(x) setVal(cfg.Min+math.clamp((x-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)*(cfg.Max-cfg.Min)) end
        regSlide("sl_"..flg, fromX, function(x) fromX(x) end, track)
        wr.MouseEnter:Connect(function() tw(hbg,{BackgroundTransparency=0.88},0.1) end); wr.MouseLeave:Connect(function() tw(hbg,{BackgroundTransparency=1},0.1) end)
        return {Set=setVal, Get=function() return val end}
    end

    function api:AddDropdown(cfg)
        local flg=cfg.Flag or cfg.Name; local dv=Flags[flg] or cfg.Default or (cfg.Items and cfg.Items[1]) or ""; Flags[flg]=dv
        table.insert(searchItems,{label=cfg.Name,keywords=cfg.Name..(cfg.Flag or ""),tab=tabName,switch=tabSwitch})
        local wr=new("Frame",{Size=UDim2.new(1,0,0,56),BackgroundTransparency=1,LayoutOrder=nl(),ClipsDescendants=false,ZIndex=5},body)
        tl({Position=UDim2.new(0,12,0,6),Size=UDim2.new(1,-20,0,18),BackgroundTransparency=1,Text=cfg.Name,TextColor3=Color3.new(1,1,1),Font=Enum.Font.FredokaOne,TextSize=14,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=5},wr)
        local sb=new("TextButton",{Position=UDim2.new(0,10,0,27),Size=UDim2.new(1,-20,0,24),BackgroundColor3=T.B2,Text="",ZIndex=5},wr); cr(5,sb); st(T.BD,1,sb)
        local selLbl=new("TextLabel",{Position=UDim2.new(0,8,0,0),Size=UDim2.new(1,-24,1,0),BackgroundTransparency=1,Text=Flags[flg],TextColor3=T.TX,Font=Enum.Font.Gotham,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=6},sb)
        new("TextLabel",{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-6,0.5,0),Size=UDim2.new(0,16,1,0),BackgroundTransparency=1,Text="▾",TextColor3=T.MT,Font=Enum.Font.GothamBold,TextSize=12,ZIndex=6},sb)
        local open,lf,oc=false,nil,nil
        local function closeDd()
            if not open then return end; open=false
            if oc then oc:Disconnect(); oc=nil end
            if lf then tw(lf,{Size=UDim2.new(1,-20,0,0)},0.12); tw(wr,{Size=UDim2.new(1,0,0,56)},0.12); task.delay(0.12,function() if lf then lf:Destroy(); lf=nil end end) end
        end
        sb.MouseButton1Click:Connect(function()
            open=not open
            if open then
                lf=new("Frame",{Position=UDim2.new(0,10,0,55),Size=UDim2.new(1,-20,0,0),BackgroundColor3=T.B2,ClipsDescendants=true,ZIndex=20},wr); cr(5,lf); st(T.BD,1,lf)
                new("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder},lf)
                for _,item in ipairs(cfg.Items or {}) do
                    local op=new("TextButton",{Size=UDim2.new(1,0,0,26),BackgroundColor3=T.B2,Text="  "..item,TextColor3=item==Flags[flg] and T.A or T.TX,Font=Enum.Font.Gotham,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=21},lf)
                    op.MouseEnter:Connect(function() tw(op,{BackgroundColor3=T.B4},0.08) end); op.MouseLeave:Connect(function() tw(op,{BackgroundColor3=T.B2},0.08) end)
                    op.MouseButton1Click:Connect(function() Flags[flg]=item; selLbl.Text=item; closeDd(); if cfg.Callback then cfg.Callback(item) end end)
                end
                local h=#(cfg.Items or {})*26; tw(lf,{Size=UDim2.new(1,-20,0,h)},0.15); tw(wr,{Size=UDim2.new(1,0,0,56+h+2)},0.15)
                task.delay(0.05,function() if not open then return end; oc=UIS.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then closeDd() end end) end)
            else closeDd() end
        end)
        local obj={Get=function() return Flags[flg] end}; function obj:Rebuild(items) cfg.Items=items; Flags[flg]=items[1] or "(none)"; selLbl.Text=Flags[flg] end; return obj
    end

    function api:AddButton(cfg)
        table.insert(searchItems,{label=cfg.Name,keywords=cfg.Name,tab=tabName,switch=tabSwitch})
        local wr=new("Frame",{Size=UDim2.new(1,0,0,38),BackgroundTransparency=1,LayoutOrder=nl()},body)
        local btn=new("TextButton",{Position=UDim2.new(0,10,0.5,-13),Size=UDim2.new(1,-20,0,26),BackgroundColor3=T.B2,Text=cfg.Name,TextColor3=Color3.new(1,1,1),Font=Enum.Font.FredokaOne,TextSize=14},wr); cr(6,btn); local bSt=st(T.BD,1,btn)
        btn.MouseEnter:Connect(function() tw(btn,{BackgroundColor3=T.B4,TextColor3=T.A}); tw(bSt,{Color=T.A},0.1) end); btn.MouseLeave:Connect(function() tw(btn,{BackgroundColor3=T.B2,TextColor3=Color3.new(1,1,1)}); tw(bSt,{Color=T.BD},0.1) end)
        btn.MouseButton1Down:Connect(function() tw(btn,{BackgroundColor3=T.B0},0.07) end); btn.MouseButton1Click:Connect(function() tw(btn,{BackgroundColor3=T.B2},0.1); if cfg.Callback then cfg.Callback() end end)
    end

    function api:AddTextBox(cfg)
        local flg=cfg.Flag or cfg.Name; Flags[flg]=Flags[flg] or cfg.Default or ""
        table.insert(searchItems,{label=cfg.Name,keywords=cfg.Name..(cfg.Flag or ""),tab=tabName,switch=tabSwitch})
        local wr=new("Frame",{Size=UDim2.new(1,0,0,56),BackgroundTransparency=1,LayoutOrder=nl()},body)
        tl({Position=UDim2.new(0,12,0,6),Size=UDim2.new(1,-20,0,18),BackgroundTransparency=1,Text=cfg.Name,TextColor3=Color3.new(1,1,1),Font=Enum.Font.FredokaOne,TextSize=14,TextXAlignment=Enum.TextXAlignment.Left},wr)
        local bg=new("Frame",{Position=UDim2.new(0,10,0,27),Size=UDim2.new(1,-20,0,24),BackgroundColor3=T.B2},wr); cr(5,bg); local tSt=st(T.BD,1,bg)
        local tb=new("TextBox",{Position=UDim2.new(0,8,0,0),Size=UDim2.new(1,-16,1,0),BackgroundTransparency=1,Text=Flags[flg],PlaceholderText=cfg.Placeholder or "",PlaceholderColor3=T.MT,TextColor3=T.TX,Font=Enum.Font.Gotham,TextSize=12,ClearTextOnFocus=false},bg)
        tb.Focused:Connect(function() tw(tSt,{Color=T.A}) end); tb.FocusLost:Connect(function(e) tw(tSt,{Color=T.BD}); Flags[flg]=tb.Text; if e and cfg.Callback then cfg.Callback(tb.Text) end end)
        return {Get=function() return tb.Text end}
    end

    function api:AddColorPicker(cfg)
        local flg=cfg.Flag or cfg.Name; local sv=Flags[flg]; local cur=(typeof(sv)=="Color3" and sv) or cfg.Default or T.A; Flags[flg]=cur
        table.insert(searchItems,{label=cfg.Name,keywords=cfg.Name..(cfg.Flag or ""),tab=tabName,switch=tabSwitch})
        local cH,cS,cV=Color3.toHSV(cur)
        local function rebuild() cur=Color3.fromHSV(cH,cS,cV); Flags[flg]=cur; if cfg.Callback then cfg.Callback(cur) end end
        local row=new("Frame",{Size=UDim2.new(1,0,0,36),BackgroundTransparency=1,LayoutOrder=nl()},body)
        tl({Position=UDim2.new(0,12,0,0),Size=UDim2.new(1,-62,1,0),BackgroundTransparency=1,Text=cfg.Name,TextColor3=Color3.new(1,1,1),Font=Enum.Font.FredokaOne,TextSize=14,TextXAlignment=Enum.TextXAlignment.Left},row)
        local sw=new("Frame",{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-10,0.5,0),Size=UDim2.new(0,36,0,20),BackgroundColor3=cur},row); cr(4,sw); st(T.BD,1,sw)
        local svRow=new("Frame",{Size=UDim2.new(1,0,0,110),BackgroundTransparency=1,LayoutOrder=nl()},body)
        local svBox=new("Frame",{Position=UDim2.new(0,12,0,4),Size=UDim2.new(1,-24,0,100),BackgroundColor3=Color3.fromHSV(cH,1,1)},svRow); cr(5,svBox); st(T.BD,1,svBox)
        local sG=new("Frame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=Color3.new(1,1,1)},svBox); new("UIGradient",{Transparency=NumberSequence.new{NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,1)}},sG)
        local vG=new("Frame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=Color3.new(0,0,0)},svBox); new("UIGradient",{Transparency=NumberSequence.new{NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(1,0)},Rotation=90},vG)
        local svT=new("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(cS,0,1-cV,0),Size=UDim2.new(0,14,0,14),BackgroundColor3=Color3.new(1,1,1),ZIndex=3},svBox); cr(99,svT); st(Color3.new(0,0,0),1.5,svT)
        local function applySV(x,y) cS=math.clamp((x-svBox.AbsolutePosition.X)/svBox.AbsoluteSize.X,0,1); cV=1-math.clamp((y-svBox.AbsolutePosition.Y)/svBox.AbsoluteSize.Y,0,1); svT.Position=UDim2.new(cS,0,1-cV,0); rebuild(); sw.BackgroundColor3=cur end
        regSlide("sv_"..flg,applySV,applySV,svBox)
        local hRow=new("Frame",{Size=UDim2.new(1,0,0,26),BackgroundTransparency=1,LayoutOrder=nl()},body)
        local hTrk=new("Frame",{Position=UDim2.new(0,12,0.5,-4),Size=UDim2.new(1,-24,0,7),BackgroundColor3=Color3.new(1,1,1)},hRow); cr(99,hTrk)
        new("UIGradient",{Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromHSV(0,1,1)),ColorSequenceKeypoint.new(0.17,Color3.fromHSV(0.17,1,1)),ColorSequenceKeypoint.new(0.33,Color3.fromHSV(0.33,1,1)),ColorSequenceKeypoint.new(0.5,Color3.fromHSV(0.5,1,1)),ColorSequenceKeypoint.new(0.67,Color3.fromHSV(0.67,1,1)),ColorSequenceKeypoint.new(0.83,Color3.fromHSV(0.83,1,1)),ColorSequenceKeypoint.new(1,Color3.fromHSV(1,1,1))}},hTrk)
        local hT=new("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(cH,0,0.5,0),Size=UDim2.new(0,14,0,14),BackgroundColor3=Color3.new(1,1,1),ZIndex=2},hTrk); cr(99,hT); st(T.BD,1,hT)
        local function applyH(x) cH=math.clamp((x-hTrk.AbsolutePosition.X)/hTrk.AbsoluteSize.X,0,1); hT.Position=UDim2.new(cH,0,0.5,0); svBox.BackgroundColor3=Color3.fromHSV(cH,1,1); rebuild(); sw.BackgroundColor3=cur end
        regSlide("hue_"..flg,applyH,function(x) applyH(x) end,hTrk)
        local hexRow=new("Frame",{Size=UDim2.new(1,0,0,30),BackgroundTransparency=1,LayoutOrder=nl()},body)
        local hxBg=new("Frame",{Position=UDim2.new(0,12,0.5,-11),Size=UDim2.new(1,-24,0,22),BackgroundColor3=T.B2},hexRow); cr(4,hxBg); local hxSt=st(T.BD,1,hxBg)
        tl({Position=UDim2.new(0,6,0,0),Size=UDim2.new(0,18,1,0),BackgroundTransparency=1,Text="#",TextColor3=T.MT,Font=Enum.Font.GothamBold,TextSize=12},hxBg)
        local hxBox=new("TextBox",{Position=UDim2.new(0,18,0,0),Size=UDim2.new(1,-24,1,0),BackgroundTransparency=1,Text=toHex(cur),PlaceholderText="FF69B4",PlaceholderColor3=T.MT,TextColor3=T.TX,Font=Enum.Font.GothamBold,TextSize=12,ClearTextOnFocus=false},hxBg)
        hxBox.Focused:Connect(function() tw(hxSt,{Color=T.A}) end)
        hxBox.FocusLost:Connect(function() tw(hxSt,{Color=T.BD}); local c=hexToColor(hxBox.Text); if c then cur=c; cH,cS,cV=Color3.toHSV(c); sw.BackgroundColor3=c; svBox.BackgroundColor3=Color3.fromHSV(cH,1,1); svT.Position=UDim2.new(cS,0,1-cV,0); hT.Position=UDim2.new(cH,0,0.5,0); Flags[flg]=c; if cfg.Callback then cfg.Callback(c) end end; hxBox.Text=toHex(cur) end)
        local origReb=rebuild; rebuild=function() origReb(); hxBox.Text=toHex(cur) end
    end

    function api:AddLabel(cfg)
        local lbl=tl({Size=UDim2.new(1,0,0,22),BackgroundTransparency=1,Text=cfg.Name or "",TextColor3=T.MT,Font=Enum.Font.FredokaOne,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,LayoutOrder=nl()},body); pad(0,0,12,0,lbl)
    end

    function api:AddDivider()
        local wr=new("Frame",{Size=UDim2.new(1,0,0,10),BackgroundTransparency=1,LayoutOrder=nl()},body)
        new("Frame",{AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,10,0.5,0),Size=UDim2.new(1,-20,0,1),BackgroundColor3=T.BD},wr)
    end

    function api:AddKeybind(cfg)
        local flg=cfg.Flag or cfg.Name; local cur=Flags[flg] or cfg.Default or Enum.KeyCode.RightShift; Flags[flg]=cur; local listening=false
        table.insert(searchItems,{label=cfg.Name,keywords=cfg.Name..(cfg.Flag or ""),tab=tabName,switch=tabSwitch})
        local row=new("Frame",{Size=UDim2.new(1,0,0,36),BackgroundTransparency=1,LayoutOrder=nl()},body)
        local hbg=new("Frame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=T.B4,BackgroundTransparency=1},row); cr(4,hbg)
        tl({Position=UDim2.new(0,12,0,0),Size=UDim2.new(1,-100,1,0),BackgroundTransparency=1,Text=cfg.Name,TextColor3=Color3.new(1,1,1),Font=Enum.Font.FredokaOne,TextSize=14,TextXAlignment=Enum.TextXAlignment.Left},row)
        local badge=new("TextButton",{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-10,0.5,0),Size=UDim2.new(0,88,0,22),BackgroundColor3=T.B2,Text=cur.Name,TextColor3=T.A,Font=Enum.Font.GothamBold,TextSize=11},row); cr(4,badge); local bSt=st(T.BD,1,badge)
        table.insert(AL,function(c) if not listening then badge.TextColor3=c end end)
        badge.MouseEnter:Connect(function() tw(hbg,{BackgroundTransparency=0.82},0.1) end); badge.MouseLeave:Connect(function() tw(hbg,{BackgroundTransparency=1},0.1) end)
        badge.MouseButton1Click:Connect(function()
            if listening then return end; listening=true; listeningForKey=true; badge.Text="Press key..."; badge.TextColor3=T.MT; tw(badge,{BackgroundColor3=T.B4}); tw(bSt,{Color=T.A})
            local conn; conn=UIS.InputBegan:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.Keyboard then
                    listening=false; listeningForKey=false; cur=i.KeyCode; Flags[flg]=cur
                    if flg=="tkey" then toggleKey=cur end
                    badge.Text=cur.Name; badge.TextColor3=T.A; tw(badge,{BackgroundColor3=T.B2}); tw(bSt,{Color=T.BD})
                    if cfg.Callback then cfg.Callback(cur) end; conn:Disconnect()
                end
            end)
        end)
    end

    return api
end

-- ── SNOW ──────────────────────────────────────────────────
local flakes,snowConn={},nil
for i=1,30 do
    local sz=math.random(3,6); local f=new("Frame",{Size=UDim2.new(0,sz,0,sz),BackgroundColor3=Color3.fromRGB(255,182,217),BackgroundTransparency=0.2,ZIndex=6},snowCont); cr(99,f)
    flakes[i]={ui=f,x=math.random(0,100)/100,y=math.random(-10,110)/100,spd=math.random(4,10)/100,dx=math.random(-15,15)/10000}; f.Position=UDim2.new(flakes[i].x,0,flakes[i].y,0)
end
local function startSnow()
    if snowConn then return end
    snowConn=RS.Heartbeat:Connect(function(dt)
        for _,fl in ipairs(flakes) do
            fl.y+=fl.spd*dt; fl.x+=fl.dx
            if fl.y>1.05 then fl.y=-0.04; fl.x=math.random(0,100)/100 end
            fl.x=fl.x<0 and 1 or fl.x>1 and 0 or fl.x; fl.ui.Position=UDim2.new(fl.x,0,fl.y,0)
        end
    end)
end
local function stopSnow() if snowConn then snowConn:Disconnect(); snowConn=nil end end

-- ── WATERMARK ─────────────────────────────────────────────
local wmFrame=new("Frame",{AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,14,1,-14),Size=UDim2.new(0,0,0,36),AutomaticSize=Enum.AutomaticSize.X,BackgroundColor3=T.B1,BackgroundTransparency=0.08,ZIndex=100,Visible=WM_SHOW},SG)
cr(9,wmFrame); local wmSt=st(T.A,1.2,wmFrame); table.insert(AL,function(c) wmSt.Color=c end)
new("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,VerticalAlignment=Enum.VerticalAlignment.Center,SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,7)},wmFrame); pad(0,0,10,12,wmFrame)
local wmDot=new("Frame",{Size=UDim2.new(0,7,0,7),BackgroundColor3=T.A,LayoutOrder=1,ZIndex=101},wmFrame); cr(99,wmDot); table.insert(AL,function(c) wmDot.BackgroundColor3=c end)
local wmScript=tl({Size=UDim2.new(0,0,0,18),AutomaticSize=Enum.AutomaticSize.X,BackgroundTransparency=1,Text=SCRIPT_NAME,TextColor3=T.TX,Font=Enum.Font.GothamBold,TextSize=14,LayoutOrder=2,ZIndex=101},wmFrame)
local wvBg=new("Frame",{Size=UDim2.new(0,0,0,18),AutomaticSize=Enum.AutomaticSize.X,BackgroundColor3=T.B3,LayoutOrder=3,ZIndex=101},wmFrame); cr(4,wvBg); st(T.BD,1,wvBg); pad(0,0,5,5,wvBg)
local wmVer=tl({Size=UDim2.new(0,0,1,0),AutomaticSize=Enum.AutomaticSize.X,BackgroundTransparency=1,Text=SCRIPT_VERSION,TextColor3=T.A,Font=Enum.Font.GothamBold,TextSize=10,ZIndex=102},wvBg); table.insert(AL,function(c) wmVer.TextColor3=c end)
local wmNameLabel=new("TextLabel",{Visible=false,Size=UDim2.new(0,0,0,0),Text=LP.Name},SG)

-- ── SETUP ─────────────────────────────────────────────────
local function Setup(cfg)
    cfg=cfg or {}
    if cfg.Name    then SCRIPT_NAME=cfg.Name; titleLabel.Text=cfg.Name; wmScript.Text=cfg.Name; iconLetter.Text=cfg.Name:sub(1,1):upper() end
    if cfg.Version then SCRIPT_VERSION=cfg.Version; wmVer.Text=cfg.Version end
    if cfg.Icon~=nil then ICON_IMAGE=cfg.Icon; iconImg.Image=cfg.Icon; iconImg.Visible=cfg.Icon~=""; iconLetter.Visible=cfg.Icon=="" end
    if cfg.SectionIcon~=nil then SECTION_ICON=cfg.SectionIcon end
    if cfg.Snow==true then startSnow() elseif cfg.Snow==false then stopSnow() end
    local persist=cfg.KeyPersist~=false
    if cfg.WatermarkSubtext and cfg.WatermarkSubtext~="" then
        new("Frame",{Size=UDim2.new(0,1,0,16),BackgroundColor3=T.BD,LayoutOrder=4,ZIndex=101},wmFrame)
        tl({Size=UDim2.new(0,0,0,16),AutomaticSize=Enum.AutomaticSize.X,BackgroundTransparency=1,Text=cfg.WatermarkSubtext,TextColor3=Color3.fromRGB(130,100,120),Font=Enum.Font.Gotham,TextSize=10,LayoutOrder=5,ZIndex=101},wmFrame)
    end
    local keys=cfg.Keys or {}; local keyURL=cfg.KeyURL or ""; local keyFile=cfg.KeyFile or "WhoaKey.txt"
    if #keys==0 then return end
    local unlocked=false
    if persist and isfile and isfile(keyFile) then
        pcall(function()
            local k=readfile(keyFile):gsub("%s",""):lower()
            for _,v in ipairs(keys) do if k==v:lower() then unlocked=true; break end end
        end)
    end
    if unlocked then return end

    -- Hide all UI behind key prompt
    Win.Visible=false; bgOverlay.Visible=false; wmFrame.Visible=false; snowCont.Visible=false

    local ov=new("Frame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=0.6,ZIndex=200},SG)
    local md=new("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,0,0.5,0),Size=UDim2.new(0,360,0,persist and 270 or 250),BackgroundColor3=T.B3,ZIndex=201},ov); cr(12,md); st(T.BD,1,md)
    new("Frame",{Size=UDim2.new(1,0,0,3),BackgroundColor3=T.A,ZIndex=202},md)
    tl({Position=UDim2.new(0,0,0,18),Size=UDim2.new(1,0,0,28),BackgroundTransparency=1,Text=SCRIPT_NAME,TextColor3=T.TX,Font=Enum.Font.GothamBold,TextSize=22,ZIndex=202},md)
    tl({Position=UDim2.new(0,0,0,48),Size=UDim2.new(1,0,0,16),BackgroundTransparency=1,Text="Enter your key to continue",TextColor3=T.MT,Font=Enum.Font.FredokaOne,TextSize=15,ZIndex=202},md)
    tl({Position=UDim2.new(0,24,0,78),Size=UDim2.new(1,-48,0,14),BackgroundTransparency=1,Text="LICENSE KEY",TextColor3=T.MT,Font=Enum.Font.FredokaOne,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=202},md)
    local ib=new("Frame",{Position=UDim2.new(0,20,0,96),Size=UDim2.new(1,-40,0,36),BackgroundColor3=T.B4,ZIndex=202},md); cr(7,ib); local iSt=st(T.BD,1,ib)
    local ki=new("TextBox",{Position=UDim2.new(0,10,0,0),Size=UDim2.new(1,-20,1,0),BackgroundTransparency=1,Text="",PlaceholderText="Enter key...",PlaceholderColor3=T.MT,TextColor3=T.TX,Font=Enum.Font.FredokaOne,TextSize=13,ClearTextOnFocus=false,ZIndex=203},ib)
    local el=tl({Position=UDim2.new(0,24,0,138),Size=UDim2.new(1,-48,0,14),BackgroundTransparency=1,Text="",TextColor3=Color3.fromRGB(255,80,80),Font=Enum.Font.FredokaOne,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=202},md)
    if persist then tl({Position=UDim2.new(0,24,0,156),Size=UDim2.new(1,-48,0,12),BackgroundTransparency=1,Text="Key will be saved — you won't need to enter it again.",TextColor3=T.MT,Font=Enum.Font.FredokaOne,TextSize=10,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=202},md) end
    local btnY=persist and 176 or 158
    local authBtn=new("TextButton",{Position=UDim2.new(0,20,0,btnY),Size=UDim2.new(0.5,-24,0,38),BackgroundColor3=T.A,Text="Authenticate",TextColor3=Color3.new(1,1,1),Font=Enum.Font.FredokaOne,TextSize=14,ZIndex=202},md); cr(8,authBtn)
    local getBtn=new("TextButton",{Position=UDim2.new(0.5,4,0,btnY),Size=UDim2.new(0.5,-24,0,38),BackgroundColor3=T.B4,Text="Get Key",TextColor3=T.TX,Font=Enum.Font.FredokaOne,TextSize=14,ZIndex=202},md); cr(8,getBtn); st(T.BD,1,getBtn)
    tl({Position=UDim2.new(0,0,0,btnY+44),Size=UDim2.new(1,0,0,28),BackgroundTransparency=1,Text="Join the server to get your key",TextColor3=T.A,Font=Enum.Font.FredokaOne,TextSize=14,ZIndex=202},md)
    ki.Focused:Connect(function() tw(iSt,{Color=T.A}) end); ki.FocusLost:Connect(function() tw(iSt,{Color=T.BD}) end)
    getBtn.MouseButton1Click:Connect(function() pcall(function() if setclipboard then setclipboard(keyURL) end end) end)
    local function tryKey()
        local k=ki.Text:gsub("%s",""):lower(); local valid=false
        for _,v in ipairs(keys) do if k==v:lower() then valid=true; break end end
        if valid then
            if persist then pcall(function() if writefile then writefile(keyFile,k) end end) end
            tw(ov,{BackgroundTransparency=1},0.3); tw(md,{BackgroundTransparency=1},0.3)
            task.delay(0.3,function()
                ov:Destroy()
                -- Restore UI
                Win.Visible=winOpen; bgOverlay.Visible=winOpen; wmFrame.Visible=WM_SHOW; snowCont.Visible=winOpen
            end)
            unlocked=true
        else
            el.Text="Incorrect key. Please try again."; tw(iSt,{Color=Color3.fromRGB(200,60,60)},0.1)
            task.delay(2,function() el.Text=""; tw(iSt,{Color=T.BD},0.2) end)
        end
    end
    authBtn.MouseButton1Click:Connect(tryKey); ki.FocusLost:Connect(function(e) if e then tryKey() end end)
    repeat task.wait(0.05) until unlocked
end

return {
    Setup=Setup, AddTab=addTab, MakeSection=makeSection, Notify=Notify, SetAccent=setA,
    StartSnow=startSnow, StopSnow=stopSnow, Flags=Flags,
    pbNameLabel=pbNameLabel, avImg=avImg, wmFrame=wmFrame, wmNameLabel=wmNameLabel,
    realAvatar=function() return realAvatar end,
    -- Config API — no auto-save; call explicitly
    SaveConfig   = cfgSave,    -- UI.SaveConfig("myconfig")
    LoadConfig   = cfgLoad,    -- UI.LoadConfig("myconfig") → bool
    DeleteConfig = cfgDelete,  -- UI.DeleteConfig("myconfig")
    ListConfigs  = cfgList,    -- UI.ListConfigs() → {name,...}
    SetAutoLoad  = cfgSetAuto, -- UI.SetAutoLoad("myconfig") or UI.SetAutoLoad("")
    GetAutoLoad  = cfgGetAuto, -- UI.GetAutoLoad() → name or nil
    Destroy=function() pcall(stopSnow); pcall(function() SG:Destroy() end) end,
}
