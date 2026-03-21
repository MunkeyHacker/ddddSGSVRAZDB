local module = {}

module.Speed = 200
module.Boost = 600
module.Accel = 0.15
module.Enabled = false

module.BV = nil
module.BG = nil
module.Root = nil
module.Move = {}

local vel = Vector3.new()

local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

function module.setSpeed(v)
	module.Speed = v
end

function module.setBoost(v)
	module.Boost = v
end

local function getRoot()

	local char = player.Character
	if not char then return end
	
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum then return end
	
	if not hum.SeatPart then return end
	
	return hum.SeatPart.AssemblyRootPart

end

RunService.Heartbeat:Connect(function()

	if not module.Enabled then return end
	
	local root = getRoot()
	if not root then return end
	
	if root ~= module.Root then
		
		module.Root = root
		
		module.BV = Instance.new("BodyVelocity")
		module.BV.MaxForce = Vector3.new(1e9,1e9,1e9)
		module.BV.Parent = root
		
		module.BG = Instance.new("BodyGyro")
		module.BG.MaxTorque = Vector3.new(1e9,1e9,1e9)
		module.BG.P = 25000
		module.BG.D = 1200
		module.BG.Parent = root
		
	end
	
	local cam = workspace.CurrentCamera
	
	local dir = Vector3.new()

	if module.Move.W then dir += cam.CFrame.LookVector end
	if module.Move.S then dir -= cam.CFrame.LookVector end
	if module.Move.A then dir -= cam.CFrame.RightVector end
	if module.Move.D then dir += cam.CFrame.RightVector end
	if module.Move.Space then dir += Vector3.new(0,1,0) end
	if module.Move.Ctrl then dir -= Vector3.new(0,1,0) end
	
	if dir.Magnitude > 1 then
		dir = dir.Unit
	end
	
	local spd = module.Move.Shift and module.Boost or module.Speed
	
	vel = vel:Lerp(dir * spd, module.Accel)
	
	module.BV.Velocity = vel
	module.BG.CFrame = cam.CFrame
	
end)

function module.start()
	module.Enabled = true
end

function module.stop()
	module.Enabled = false
	
	if module.BV then module.BV:Destroy() end
	if module.BG then module.BG:Destroy() end
	
	module.Root = nil
	vel = Vector3.new()
end

UIS.InputBegan:Connect(function(i,g)
	if g then return end
	
	if i.KeyCode == Enum.KeyCode.W then module.Move.W = true end
	if i.KeyCode == Enum.KeyCode.S then module.Move.S = true end
	if i.KeyCode == Enum.KeyCode.A then module.Move.A = true end
	if i.KeyCode == Enum.KeyCode.D then module.Move.D = true end
	if i.KeyCode == Enum.KeyCode.Space then module.Move.Space = true end
	if i.KeyCode == Enum.KeyCode.LeftControl then module.Move.Ctrl = true end
	if i.KeyCode == Enum.KeyCode.LeftShift then module.Move.Shift = true end
end)

UIS.InputEnded:Connect(function(i)
	if i.KeyCode == Enum.KeyCode.W then module.Move.W = false end
	if i.KeyCode == Enum.KeyCode.S then module.Move.S = false end
	if i.KeyCode == Enum.KeyCode.A then module.Move.A = false end
	if i.KeyCode == Enum.KeyCode.D then module.Move.D = false end
	if i.KeyCode == Enum.KeyCode.Space then module.Move.Space = false end
	if i.KeyCode == Enum.KeyCode.LeftControl then module.Move.Ctrl = false end
	if i.KeyCode == Enum.KeyCode.LeftShift then module.Move.Shift = false end
end)

return module
