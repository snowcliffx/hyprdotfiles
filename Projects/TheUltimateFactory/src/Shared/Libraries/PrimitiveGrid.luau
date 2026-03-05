local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerMouse = LocalPlayer:GetMouse()

local ClonedThing = ReplicatedStorage.Buildings.Example:Clone()
ClonedThing.CanCollide = false
ClonedThing.CanQuery = false
ClonedThing.CanTouch = false
ClonedThing.Parent = game.Workspace

local DEFAULT_GRID_SIZE = 8
local DEFAULT_GRID_HALF_SIZE = DEFAULT_GRID_SIZE / 2
local GRID_PLACEMENT_TWEEN_INFO = TweenInfo.new(0.2)

local SnowGrid = {}

local function GetClosestGridPosition(Vector: Vector3)
	local factor_x, _ = math.modf(Vector.X / DEFAULT_GRID_SIZE)
	local factor_z, _ = math.modf(Vector.Z / DEFAULT_GRID_SIZE)

	local idk_x = math.abs(Vector.X) % DEFAULT_GRID_SIZE < DEFAULT_GRID_HALF_SIZE and 0 or 1
	local idk_z = math.abs(Vector.Z) % DEFAULT_GRID_SIZE < DEFAULT_GRID_HALF_SIZE and 0 or 1

	factor_x = (factor_x + math.sign(Vector.X) * idk_x) * DEFAULT_GRID_SIZE
	factor_z = (factor_z + math.sign(Vector.Z) * idk_z) * DEFAULT_GRID_SIZE

	return Vector3.new(factor_x, 0, factor_z)
end

local function ToCoordinates(Vector: Vector3)
	return Vector / 8
end

local PreviousCoordinates = Vector3.new()

PlayerMouse.Move:Connect(function()
	local ClosestPosition = GetClosestGridPosition(PlayerMouse.Hit.Position)
	print(ClosestPosition)
	local GridCoordidnates = ToCoordinates(ClosestPosition)

	if GridCoordidnates == PreviousCoordinates then
		return
	end

	TweenService:Create(ClonedThing, GRID_PLACEMENT_TWEEN_INFO, { Position = ClosestPosition }):Play()
	PreviousCoordinates = GridCoordidnates
end)

return SnowGrid
