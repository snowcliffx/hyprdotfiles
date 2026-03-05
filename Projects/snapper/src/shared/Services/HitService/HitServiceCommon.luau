--!strict
--!native
--!optimize 2

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SnowSignal = require(ReplicatedStorage.Shared.Libraries.SnowSignal)

export type CastType = "Raycast" | "BlockCast" | "SphereCast"

export type Segment = {
    Instance: Attachment,
    Distance: number,
    Position: Vector3?,
    LastDirection: Vector3,
    RaycastResult: RaycastResult?,
	CastInfo: CastInfo,

	Update: () -> (),
}

export type CastInfo = {
	CFrame: CFrame,
	Size: Vector3,
	Radius: number,
}

export type HitboxFields = {
	Instance: Instance,
	RaycastParams: RaycastParams,
    RaycastResult: RaycastResult?,

	CastInfo: CastInfo,
	Segments: {[Instance]: Segment},
	FilterList: {[Instance]: boolean},

	Active: boolean,
	ActiveTimer: number,
	Frequency: number,
	FilterPartsHit: boolean,

    OnDestroying: SnowSignal.Signal<()>,
    BeforeStart: SnowSignal.Signal<()>,
    OnUpdate: SnowSignal.Signal<number>, -- 1: Delta
    OnHit: SnowSignal.Signal<RaycastResult, Segment>,
	OnStopped: SnowSignal.Signal<()>,

	PostSimulation: RBXScriptConnection?
}

export type HitboxImpl = {
    __index: HitboxImpl,

	GetAllSegments: (self: Hitbox) -> { [Instance]: Segment },
	GetSegment: (self: Hitbox, instance: Instance) -> Segment,
	AddSegment: (self: Hitbox, descendant: Attachment) -> Segment,
	RemoveSegment: (self: Hitbox, descendant: Instance) -> (),
	Init: (self: Hitbox) -> (),
	Start: (self: Hitbox, time: number?, override_params: RaycastParams?) -> (),
	Stop: (self: Hitbox) -> (),
	Destroy: (self: Hitbox) -> (),
	SetFrequency: (self: Hitbox, resolution: number) -> (),
	SetCastData: (self: Hitbox, cast_info: CastInfo) -> (),
}

export type Hitbox = setmetatable<HitboxFields, HitboxImpl>

return {
	Settings = {
		TAG = "HitPoint",
		MINIMUM_STATIONARY_TIME = 1
	}
}