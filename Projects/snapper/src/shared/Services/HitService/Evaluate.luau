--!strict
--!native
--!optimize 2

local HitServiceCommon = require(script.Parent.HitServiceCommon)

type Segment = HitServiceCommon.Segment

local Evaluate = {}

type EvaluateDelta = {
    ToPosition: (segment: Segment) -> Vector3,
    ToDirection: (segment: Segment) -> Vector3,
    Visualize: (segment: Segment) -> CFrame
}

Evaluate.Attachment = {
    ToPosition = function(segment: Segment): Vector3
        return segment.Position or segment.Instance.WorldPosition
    end,

    ToDirection = function(segment: Segment): Vector3
        local direction = segment.Instance.WorldPosition - Evaluate.Attachment.ToPosition(segment)

        if direction.Magnitude == 0 then
            direction = segment.LastDirection.Unit * HitServiceCommon.Settings.MINIMUM_STATIONARY_TIME
        end

        return direction
    end,

    Visualize = function(segment: Segment): CFrame
        return CFrame.lookAt(Evaluate.Attachment.ToPosition(segment), segment.Instance.WorldPosition)
    end
}

Evaluate.Raycast = {
    Solvers = {
        Attachment = Evaluate.Attachment
    } :: {[string]: EvaluateDelta},

    Cast = function(segment: Segment, params: RaycastParams?): (RaycastResult?, Vector3)
        local solver = Evaluate.Raycast.Solvers[segment.Instance.ClassName]
        local origin = solver.ToPosition(segment)
        local direction = solver.ToDirection(segment)

        return workspace:Raycast(origin, direction, params), direction
    end
}

return Evaluate