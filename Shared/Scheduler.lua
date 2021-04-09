-- Scheduler
-- MrAsync

--//Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

--//Classes
local MaidClass = require(ReplicatedStorage.Modules:WaitForChild("Maid"))

--//Locals
local _Maid = MaidClass.new()

local Scheduler = {}
Scheduler.__index = Scheduler

--Constructor
function Scheduler.new(targetTime)
	local self = setmetatable({
		Length = targetTime,
		Elapsed = 0,
		
		_Elapsed = 0,
		_Maid = MaidClass.new()
	}, Scheduler)
	
	--Construct Events
	self._Tick = Instance.new("BindableEvent")
	self.Tick = self._Tick.Event
	self._Maid:GiveTask(self._Tick)
	
	self._Ended = Instance.new("BindableEvent")
	self.Ended = self._Ended.Event
	self._Maid:GiveTask(self._Ended)
	
	return self
end


--//Begins counting for appointment
function Scheduler:Start()
	self._Maid:GiveTask(RunService.Stepped:Connect(function(_, step)
		self._Elapsed += step
		
		--Update Whole-Number, fire tick
		local elapsed = math.floor(self._Elapsed)
		if (elapsed > self.Elapsed) then
			self.Elapsed = elapsed
			self._Tick:Fire(elapsed)
		end
		
		--Check if timer should be over
		if (self._Elapsed >= self.Length) then
			self:Stop()
		end
	end))
end


--//Kills counter for appointment
function Scheduler:Stop()
	self._Ended:Fire()
	self._Maid:Destroy()
end


return Scheduler
