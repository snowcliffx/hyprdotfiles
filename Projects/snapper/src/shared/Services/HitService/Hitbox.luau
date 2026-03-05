--!optimize 2
--!native
--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Evaluate = require(script.Parent.Evaluate)
local HitServiceCommon = require(script.Parent.HitServiceCommon)
local SnowSignal = require(ReplicatedStorage.Shared.Libraries.SnowSignal)

local Hitbox = {} :: HitServiceCommon.HitboxImpl
Hitbox.__index = Hitbox

function Hitbox:SetFrequency(resolution: number)
	self.Frequency = resolution
end

function Hitbox:GetSegment(instance: Instance): HitServiceCommon.Segment
	return self.Segments[instance]
end

function Hitbox:GetAllSegments(): { [Instance]: HitServiceCommon.Segment }
	return self.Segments
end

function Hitbox:AddSegment(descendant: Attachment): HitServiceCommon.Segment
	local Segment = {} :: HitServiceCommon.Segment

	if descendant:HasTag(HitServiceCommon.Settings.TAG) then
		local Evaluator = Evaluate.Attachment

		Segment.Distance = 0
		Segment.Instance = descendant
		Segment.Position = Evaluator.ToPosition(Segment)
		Segment.LastDirection = -Vector3.one
		Segment.CastInfo = {
			Size = descendant:GetAttribute("CastSize") :: Vector3 or self.CastInfo.Size,
			CFrame = descendant:GetAttribute("CastCFrame") :: CFrame or self.CastInfo.CFrame,
			Radius = descendant:GetAttribute("CastRadius") :: number or self.CastInfo.Radius,
		}

		Segment.Update = function()
			if Segment.Instance.Parent == nil then
				self.Segments[descendant] = nil
				return
			end

			local Result, Direction = Evaluate.Raycast.Cast(Segment, self.RaycastParams)
			local Magnitude = Direction.Magnitude

			if Result then
				self.RaycastResult = Result

				if self.FilterPartsHit == true then
					local CurrentFilter = self.RaycastParams.FilterDescendantsInstances
					table.insert(CurrentFilter, Result.Instance)

					self.FilterList[Result.Instance] = true
					self.RaycastParams.FilterDescendantsInstances = CurrentFilter
				end

				self.OnHit:Fire(Result, Segment)
			end

			if Magnitude > 0 then
				Segment.LastDirection = Direction
				Segment.Distance += Magnitude
			end

			Segment.Position = Segment.Instance.WorldPosition
		end

		self.Segments[descendant] = Segment
	end

	return Segment
end

function Hitbox:RemoveSegment(descendant: Instance)
	if self.Segments[descendant] then
		self.Segments[descendant] = nil
	end
end

function Hitbox:Init()
	table.clear(self.Segments)

	for _index, descendant in self.Instance:GetDescendants() do
		if descendant:IsA("Attachment") then
			self:AddSegment(descendant)
		end
	end
end

function Hitbox:Start(time: number?, override_params: RaycastParams?): ()
	if self.Active then
		print("hitbox already on bro")
		return
	end

	self.PostSimulation = RunService.PostSimulation:Connect(function(delta)
		if delta >= (1 / self.Frequency) then
			self.OnUpdate:Fire(delta)

			for _index, segment in self:GetAllSegments() do
				task.defer(segment.Update)
			end

			self.ActiveTimer -= delta
		end

		if self.ActiveTimer <= 0 then
			self:Stop()
		end
	end)

	for _, segment in self:GetAllSegments() do
		segment.Position = nil -- Reset its state
		segment.Position = Evaluate.Attachment.ToPosition(segment)
		segment.Distance = 0
	end

	self.BeforeStart:Fire()

	self.RaycastResult = nil
	self.RaycastParams = override_params or self.RaycastParams
	self.Active = true

	self.ActiveTimer = time or math.huge
end

function Hitbox:Stop()
	if self.Active then
		self.ActiveTimer = 0
		self.Active = false

		self.OnStopped:Fire()

		if self.PostSimulation then
			self.PostSimulation:Disconnect()
			self.PostSimulation = nil
		end

		if self.FilterPartsHit then
			local currentFilter = self.RaycastParams.FilterDescendantsInstances

			for instance in self.FilterList do
				local index = table.find(currentFilter, instance)

				if index then
					table.remove(currentFilter, index)
				end
			end

			table.clear(self.FilterList)
			self.RaycastParams.FilterDescendantsInstances = currentFilter
		end
	end
end

function Hitbox:Destroy()
	self:Stop()

	self.OnDestroying:Fire()

	self.OnDestroying:DisconnectAll()
	self.OnHit:DisconnectAll()
	self.OnStopped:DisconnectAll()
	self.OnUpdate:DisconnectAll()
	self.BeforeStart:DisconnectAll()

	table.clear(self)
end

return {
	new = function(instance: Instance, params: RaycastParams?)
		local HitboxFields: HitServiceCommon.HitboxFields = {
			Instance = instance,
			RaycastParams = params or RaycastParams.new(),

			CastInfo = {
				Size = Vector3.zero,
				CFrame = CFrame.identity,
				Radius = 0,
			},

			Segments = {},
			FilterList = {},

			Active = false,
			ActiveTimer = 0,
			Frequency = 60,
			FilterPartsHit = false,

			BeforeStart = SnowSignal.new(),
			OnDestroying = SnowSignal.new(),
			OnHit = SnowSignal.new(),
			OnUpdate = SnowSignal.new(),
			OnStopped = SnowSignal.new(),
		}

		local hitbox = setmetatable(HitboxFields, Hitbox)

		return hitbox
	end,
}
