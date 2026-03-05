--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlayerMouse = LocalPlayer:GetMouse()

local ClonedThing = ReplicatedStorage.Buildings.Example:Clone()
ClonedThing.CanCollide = false
ClonedThing.CanQuery = false
ClonedThing.CanTouch = false
ClonedThing.Parent = game.Workspace

local SnowGrid = {}
local Planes = {}

type GridPlane = {
	Origin: Vector3,
    GridSize: number,
    Width: number,
    WidthInStuds: number,
    Length: number,
    LengthInStuds: number,

    GridPoints: {[number]: {[number]: boolean}},

    GetClosestGridPosition: (self: GridPlane, given_vector: Vector3) -> Vector3
}

local function GetClosestGridPosition(self: GridPlane, given_vector: Vector3)
    local pos_x = math.round(given_vector.X / self.GridSize)
    local pos_z = math.round(given_vector.Z / self.GridSize)

    return Vector3.new(pos_x, 0, pos_z)
end

function SnowGrid.CreateGridPlane(origin: Vector3, width: number, length: number, grid_size: number): GridPlane
    local RealWidth = grid_size * width
    local RealLength = grid_size * length

    local VisualPlane = Instance.new("Part")
    VisualPlane.Size = Vector3.new(RealWidth, 0, grid_size * RealLength)
    VisualPlane.Position = origin
    VisualPlane.Parent = Workspace

    local OffsetAnchor = Vector3.new(origin.X - RealWidth / 2, 0, origin.Z - RealLength / 2)
    local Points = {}

    for i = 0, width do
        for j = 0, length do
            local NewPoint = Instance.new("Attachment")

            NewPoint.Position = OffsetAnchor + Vector3.new(grid_size * i, 0, grid_size * j)
            NewPoint.Parent = VisualPlane

            if i == 0 or j == 0 then
                continue
            end

            Points[i][j] = true
        end
    end

    local NewGridPlane: GridPlane = {
        Origin = origin,
        GridSize = grid_size,
        Width = width,
        WidthInStuds = RealWidth,
        Length = length,
        LengthInStuds = RealLength,

        GridPoints = Points,

        GetClosestGridPosition = GetClosestGridPosition
    }

    table.insert(Planes, NewGridPlane)

    return NewGridPlane
end

function SnowGrid.CreatePlaneFromPart(part: BasePart, width: number, length: number)
    if (part.Size.X / width) ~= (part.Size.Z / length) then
        print("Grid size can not be calculated,")
    end

    local origin_pos = Vector3.new(part.Position.X, 0, part.Position.Z)
    local grid_size = part.Size.X / width
end

return SnowGrid
