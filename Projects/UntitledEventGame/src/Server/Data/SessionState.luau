--!strict

--[ SERVICES ]--

local Players = game:GetService("Players")

--[ GLOBAL TYPES ]--
export type PowerUp = "ExtraVote" | "ImmunityPass" | "King" | "RevealCash" | "Unmute"
export type Role = "King" | "Enforcer" | "Judge" | "Landlord"

--[ CONSTANTS ]--

local STATE_TEMPLATE = {
	AssignedSeat = nil :: Seat?,
	Role = nil :: Role?,

	Money = 100,

	dataLoaded = false,
	isEliminated = false,
	canVote = false,
	hasVoted = false,

	PowerUps = {} :: { [PowerUp]: number },
}

--[ MODULE TYPES ]--

type State = typeof(STATE_TEMPLATE)

type SessionState = {
	States: { [Player]: State },

	Get: (self: SessionState, player: Player) -> State,
	Update: (self: SessionState, player: Player, func: (old_state: State) -> ()) -> (),

	Init: (player: Player) -> (),
}

--[ MODULE ]--

local SessionState: SessionState = {} :: SessionState
SessionState.States = {}

--[ PRIVATE FUNCTIONS ]--

local function DeepCopy<T>(tbl: T): T
	local t_copy = table.clone(tbl) :: any

	for key, value in t_copy do
		if type(value) == "table" then
			t_copy[key] = DeepCopy(value)
		end
	end

	return t_copy
end

--[ METHODS ]--

--[[
Only use this function to VIEW the state, not change it.
]]
function SessionState:Get(player: Player): State
	return self.States[player]
end

--[[
Only use this function IF THE OTHER modules don't have their own methods to change values.
Example: "Role" can be changed with RoleServiceServer, but "Money" can't be changed with any other module.
]]
function SessionState:Update(player: Player, func: (old_state: State) -> ()): ()
	local old_state = self.States[player]
	func(old_state)
end

--[ LOGIC ]--

function SessionState.Init(player: Player)
	SessionState.States[player] = DeepCopy(STATE_TEMPLATE)
end

Players.PlayerRemoving:Connect(function(player)
	SessionState.States[player] = nil
end)

--[ RETURN ]--

return SessionState
