local module = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer

module.meta = {
    name = "Vehicle Fly",
    tab = "Movement",
    side = "Left",
    priority = 0
}

module.Speed = 200
module.Boost = 600
module.Accel = 0.15
module.Enabled = false

local BV
local BG
local Root
local Loop

local Move = {}
local vel = Vector3.zero

function module.setSpeed(v) module.Speed = v end
function module.setBoost(v) module.Boost = v end
function module.setAccel(v) module.Accel = v end

local function cleanup()

    if BV then BV:Destroy() BV = nil end
    if BG then BG:Destroy() BG = nil end

    Root = nil
    vel = Vector3.zero

end

local function getVehicleRoot()

    local char = player.Character
    if not char then return end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    if not hum.SeatPart then return end

    return hum.SeatPart.AssemblyRootPart

end

function module.enable()

    if module.Enabled then return end
    module.Enabled = true

    Loop = RunService.Heartbeat:Connect(function()

        if not module.Enabled then return end

        local root = getVehicleRoot()
        if not root then return end

        if root ~= Root then

            cleanup()

            Root = root

            BV = Instance.new("BodyVelocity")
            BV.MaxForce = Vector3.new(1e9,1e9,1e9)
            BV.Parent = root

            BG = Instance.new("BodyGyro")
            BG.MaxTorque = Vector3.new(1e9,1e9,1e9)
            BG.P = 25000
            BG.D = 1200
            BG.Parent = root

        end

        local cam = workspace.CurrentCamera

        local dir = Vector3.zero

        if Move.W then dir += cam.CFrame.LookVector end
        if Move.S then dir -= cam.CFrame.LookVector end
        if Move.A then dir -= cam.CFrame.RightVector end
        if Move.D then dir += cam.CFrame.RightVector end
        if Move.Space then dir += Vector3.yAxis end
        if Move.Ctrl then dir -= Vector3.yAxis end

        if dir.Magnitude > 1 then
            dir = dir.Unit
        end

        local spd = Move.Shift and module.Boost or module.Speed

        vel = vel:Lerp(dir * spd, module.Accel)

        if BV then
            BV.Velocity = vel
        end

        if BG then
            BG.CFrame = cam.CFrame
        end

    end)

end

function module.disable()

    module.Enabled = false

    if Loop then
        Loop:Disconnect()
        Loop = nil
    end

    cleanup()

end

UIS.InputBegan:Connect(function(i,g)
    if g then return end

    if i.KeyCode == Enum.KeyCode.W then Move.W = true end
    if i.KeyCode == Enum.KeyCode.S then Move.S = true end
    if i.KeyCode == Enum.KeyCode.A then Move.A = true end
    if i.KeyCode == Enum.KeyCode.D then Move.D = true end
    if i.KeyCode == Enum.KeyCode.Space then Move.Space = true end
    if i.KeyCode == Enum.KeyCode.LeftControl then Move.Ctrl = true end
    if i.KeyCode == Enum.KeyCode.LeftShift then Move.Shift = true end
end)

UIS.InputEnded:Connect(function(i)
    if i.KeyCode == Enum.KeyCode.W then Move.W = false end
    if i.KeyCode == Enum.KeyCode.S then Move.S = false end
    if i.KeyCode == Enum.KeyCode.A then Move.A = false end
    if i.KeyCode == Enum.KeyCode.D then Move.D = false end
    if i.KeyCode == Enum.KeyCode.Space then Move.Space = false end
    if i.KeyCode == Enum.KeyCode.LeftControl then Move.Ctrl = false end
    if i.KeyCode == Enum.KeyCode.LeftShift then Move.Shift = false end
end)

function module.init(ctx)

    local box = ctx.box

    box:AddToggle("VFlyToggle",{Text="Enable Vehicle Fly"})
    Toggles.VFlyToggle:OnChanged(function(v)
        if v then module.enable() else module.disable() end
    end)

    box:AddSlider("VFlySpeed",{
        Text="Speed",
        Default=200,
        Min=50,
        Max=2000,
        Rounding=0
    })

    Options.VFlySpeed:OnChanged(function()
        module.setSpeed(Options.VFlySpeed.Value)
    end)

    box:AddSlider("VFlyBoost",{
        Text="Boost",
        Default=600,
        Min=100,
        Max=4000,
        Rounding=0
    })

    Options.VFlyBoost:OnChanged(function()
        module.setBoost(Options.VFlyBoost.Value)
    end)

    box:AddSlider("VFlyAccel",{
        Text="Acceleration",
        Default=0.15,
        Min=0.01,
        Max=0.5,
        Rounding=2
    })

    Options.VFlyAccel:OnChanged(function()
        module.setAccel(Options.VFlyAccel.Value)
    end)

    box:AddLabel("Vehicle Fly Key")
    :AddKeyPicker("VFlyBind",{
        Default="F",
        Mode="Toggle",
        Text="Toggle Vehicle Fly"
    })

    Options.VFlyBind:OnClick(function()
        Toggles.VFlyToggle:SetValue(
            not Toggles.VFlyToggle.Value
        )
    end)

end

return module
