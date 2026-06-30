-- Features.lua
local Features = {}
local UIS = game:GetService("UserInputService")
local RS  = game:GetService("RunService")
local LP  = game:GetService("Players").LocalPlayer

Features.TABS = {
    {name="Main", icon="⚡", items={
        {label="Infinite Jump", desc="Jump while in air", state=false, conn=nil,
         enable=function(it)
             it.conn=UIS.JumpRequest:Connect(function()
                 pcall(function()
                     local h=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
                     if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
                 end)
             end)
         end,
         disable=function(it) if it.conn then it.conn:Disconnect();it.conn=nil end end},

        {label="Speed Boost", desc="Multiply walk speed", state=false,
         param={label="Speed Multiplier",min=1,max=10,step=0.5,val=2.5,
          fmt=function(v) return string.format("%.1fx",v) end,
          apply=function(v)
              pcall(function()
                  local h=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
                  if h then h.WalkSpeed=16*v end
              end)
          end},
         enable=function(it)
             pcall(function()
                 local h=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
                 if h then h.WalkSpeed=16*it.param.val end
             end)
         end,
         disable=function()
             pcall(function()
                 local h=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
                 if h then h.WalkSpeed=16 end
             end)
         end},

        {label="Anti-AFK", desc="Prevent idle kick", state=false, conn=nil,
         enable=function(it)
             it.conn=LP.Idled:Connect(function()
                 pcall(function()
                     local v=game:GetService("VirtualUser")
                     v:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
                     task.wait()
                     v:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
                 end)
             end)
         end,
         disable=function(it) if it.conn then it.conn:Disconnect();it.conn=nil end end},

        {label="Fly", desc="WASD + Space", state=false, conn=nil, _bv=nil, _bg=nil, _spd=60,
         param={label="Fly Speed",min=10,max=300,step=5,val=60,
          fmt=function(v) return math.floor(v).." u/s" end,
          apply=function(v,it) if it then it._spd=v end end},
         enable=function(it)
             it._spd=it.param.val
             pcall(function()
                 local ch=LP.Character; if not ch then return end
                 local root=ch:FindFirstChild("HumanoidRootPart"); if not root then return end
                 local hum=ch:FindFirstChildOfClass("Humanoid"); if hum then hum.PlatformStand=true end
                 local bv=Instance.new("BodyVelocity")
                 bv.Velocity=Vector3.new(0,0,0); bv.MaxForce=Vector3.new(1e5,1e5,1e5); bv.Parent=root; it._bv=bv
                 local bg=Instance.new("BodyGyro")
                 bg.MaxTorque=Vector3.new(1e5,1e5,1e5); bg.D=100; bg.Parent=root; it._bg=bg
                 it.conn=RS.RenderStepped:Connect(function()
                     pcall(function()
                         local cam=workspace.CurrentCamera
                         local lv=cam.CFrame.LookVector; local rv=cam.CFrame.RightVector
                         local d=Vector3.new(0,0,0)
                         if UIS:IsKeyDown(Enum.KeyCode.W) then d=Vector3.new(d.X+lv.X,d.Y+lv.Y,d.Z+lv.Z) end
                         if UIS:IsKeyDown(Enum.KeyCode.S) then d=Vector3.new(d.X-lv.X,d.Y-lv.Y,d.Z-lv.Z) end
                         if UIS:IsKeyDown(Enum.KeyCode.A) then d=Vector3.new(d.X-rv.X,d.Y-rv.Y,d.Z-rv.Z) end
                         if UIS:IsKeyDown(Enum.KeyCode.D) then d=Vector3.new(d.X+rv.X,d.Y+rv.Y,d.Z+rv.Z) end
                         if UIS:IsKeyDown(Enum.KeyCode.Space) then d=Vector3.new(d.X,d.Y+1,d.Z) end
                         if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then d=Vector3.new(d.X,d.Y-1,d.Z) end
                         if d.Magnitude>0 then d=d.Unit end
                         bv.Velocity=d*(it._spd or 60); bg.CFrame=cam.CFrame
                     end)
                 end)
             end)
         end,
         disable=function(it)
             if it.conn then it.conn:Disconnect();it.conn=nil end
             pcall(function()
                 if it._bv then it._bv:Destroy();it._bv=nil end
                 if it._bg then it._bg:Destroy();it._bg=nil end
                 local h=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
                 if h then h.PlatformStand=false end
             end)
         end},

        {label="No Clip", desc="Walk through walls", state=false, conn=nil,
         enable=function(it)
             it.conn=RS.Stepped:Connect(function()
                 pcall(function()
                     if LP.Character then
                         for _,p in ipairs(LP.Character:GetDescendants()) do
                             if p:IsA("BasePart") then p.CanCollide=false end
                         end
                     end
                 end)
             end)
         end,
         disable=function(it)
             if it.conn then it.conn:Disconnect();it.conn=nil end
             pcall(function()
                 if LP.Character then
                     for _,p in ipairs(LP.Character:GetDescendants()) do
                         if p:IsA("BasePart") then p.CanCollide=true end
                     end
                 end
             end)
         end},

        {label="TEST-6",desc="Empty slot",state=false,enable=function()end,disable=function()end},
        {label="TEST-7",desc="Empty slot",state=false,enable=function()end,disable=function()end},
        {label="TEST-8",desc="Empty slot",state=false,enable=function()end,disable=function()end},
        {label="TEST-9",desc="Empty slot",state=false,enable=function()end,disable=function()end},
    }},

    {name="Player", icon="👤", items={
        {label="God Mode",desc="Max health loop",state=false,conn=nil,
         enable=function(it) it.conn=RS.Heartbeat:Connect(function()
             pcall(function() local h=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
                 if h then h.Health=h.MaxHealth end end) end) end,
         disable=function(it) if it.conn then it.conn:Disconnect();it.conn=nil end end},

        {label="High Jump",desc="Custom jump power",state=false,
         param={label="Jump Power",min=50,max=500,step=10,val=150,
          fmt=function(v) return math.floor(v) end,
          apply=function(v)
              pcall(function()
                  local h=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
                  if h then h.JumpPower=v end end) end},
         enable=function(it)
             pcall(function()
                 local h=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
                 if h then h.JumpPower=it.param.val end end) end,
         disable=function()
             pcall(function()
                 local h=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
                 if h then h.JumpPower=50 end end) end},

        {label="Invisible",desc="Hide character",state=false,
         enable=function() pcall(function()
             for _,p in ipairs(LP.Character:GetDescendants()) do
                 if p:IsA("BasePart") or p:IsA("Decal") then p.Transparency=1 end end end) end,
         disable=function() pcall(function()
             for _,p in ipairs(LP.Character:GetDescendants()) do
                 if p:IsA("BasePart") then p.Transparency=0
                 elseif p:IsA("Decal") then p.Transparency=0 end end end) end},

        {label="Freeze",desc="Anchor in place",state=false,
         enable=function() pcall(function()
             local r=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
             if r then r.Anchored=true end end) end,
         disable=function() pcall(function()
             local r=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
             if r then r.Anchored=false end end) end},

        {label="Low Gravity",desc="Custom gravity",state=false,
         param={label="Gravity",min=2,max=196,step=5,val=20,
          fmt=function(v) return math.floor(v) end,
          apply=function(v) pcall(function() workspace.Gravity=v end) end},
         enable=function(it) pcall(function() workspace.Gravity=it.param.val end) end,
         disable=function() pcall(function() workspace.Gravity=196.2 end) end},

        {label="TEST-6",desc="Empty slot",state=false,enable=function()end,disable=function()end},
        {label="TEST-7",desc="Empty slot",state=false,enable=function()end,disable=function()end},
        {label="TEST-8",desc="Empty slot",state=false,enable=function()end,disable=function()end},
        {label="TEST-9",desc="Empty slot",state=false,enable=function()end,disable=function()end},
    }},

    {name="Visual", icon="👁", items={
        {label="Full Bright",desc="Max ambient",state=false,_old=nil,
         param={label="Brightness",min=1,max=10,step=0.5,val=2,
          fmt=function(v) return string.format("%.1f",v) end,
          apply=function(v) pcall(function()
              game.Lighting.Ambient=Color3.fromRGB(255,255,255)
              game.Lighting.OutdoorAmbient=Color3.fromRGB(255,255,255)
              game.Lighting.Brightness=v end) end},
         enable=function(it) pcall(function()
             it._old={a=game.Lighting.Ambient,o=game.Lighting.OutdoorAmbient,b=game.Lighting.Brightness}
             game.Lighting.Ambient=Color3.fromRGB(255,255,255)
             game.Lighting.OutdoorAmbient=Color3.fromRGB(255,255,255)
             game.Lighting.Brightness=it.param.val end) end,
         disable=function(it) pcall(function()
             if it._old then game.Lighting.Ambient=it._old.a
                 game.Lighting.OutdoorAmbient=it._old.o
                 game.Lighting.Brightness=it._old.b end end) end},

        {label="Time of Day",desc="Set clock hour",state=false,
         param={label="Clock Hour",min=0,max=24,step=0.5,val=12,
          fmt=function(v) local h=math.floor(v)
              return string.format("%02d:%02d",h,math.floor((v-h)*60)) end,
          apply=function(v) pcall(function() game.Lighting.ClockTime=v end) end},
         enable=function(it) pcall(function() game.Lighting.ClockTime=it.param.val end) end,
         disable=function() end},

        {label="No Fog",desc="Remove world fog",state=false,_old=nil,
         enable=function(it) pcall(function()
             it._old={s=game.Lighting.FogStart,e=game.Lighting.FogEnd}
             game.Lighting.FogStart=0; game.Lighting.FogEnd=1e6 end) end,
         disable=function(it) pcall(function()
             if it._old then game.Lighting.FogStart=it._old.s
                 game.Lighting.FogEnd=it._old.e end end) end},

        {label="ESP Players",desc="Names over heads",state=false,_bills={},
         enable=function(it) pcall(function()
             for _,pl in ipairs(game:GetService("Players"):GetPlayers()) do
                 if pl~=LP and pl.Character then
                     local root=pl.Character:FindFirstChild("HumanoidRootPart")
                     if root then
                         local bb=Instance.new("BillboardGui",root)
                         bb.Size=UDim2.new(0,120,0,36); bb.StudsOffset=Vector3.new(0,4,0)
                         bb.AlwaysOnTop=true
                         local lb=Instance.new("TextLabel",bb); lb.Size=UDim2.new(1,0,1,0)
                         lb.BackgroundTransparency=1; lb.TextColor3=Color3.fromRGB(255,255,255)
                         lb.TextStrokeTransparency=0; lb.Text=pl.Name
                         lb.Font=Enum.Font.GothamBold; lb.TextSize=15
                         table.insert(it._bills,bb) end end end end) end,
         disable=function(it)
             for _,b in ipairs(it._bills) do pcall(function() b:Destroy() end) end
             it._bills={} end},

        {label="TEST-5",desc="Empty slot",state=false,enable=function()end,disable=function()end},
        {label="TEST-6",desc="Empty slot",state=false,enable=function()end,disable=function()end},
        {label="TEST-7",desc="Empty slot",state=false,enable=function()end,disable=function()end},
        {label="TEST-8",desc="Empty slot",state=false,enable=function()end,disable=function()end},
        {label="TEST-9",desc="Empty slot",state=false,enable=function()end,disable=function()end},
    }},
}

return Features
