--!strict

local Players = game:GetService("Players")

--[ MODULES ]--
local SessionState = require("../Data/SessionState")

--[ GLOBAL TYPES ]--
type Role = SessionState.Role

--[ MODULE TYPES ]--
type RoleServiceServer = {
	SetRole: (player: Player, role: Role) -> (),
	GetRole: (player: Player) -> Role,

	AssignRoles: () -> (),
	ClearRoles: () -> (),
}

--[ MODULE ]--

local RoleServiceServer = {} :: RoleServiceServer
local ActiveRoles = {} :: { [Player]: Role }

function RoleServiceServer.SetRole(player: Player, role: Role): ()
	SessionState:Update(player, function(state)
		state.Role = role
	end)

	ActiveRoles[player] = role
end

function RoleServiceServer.GetRole(player: Player): Role?
	return SessionState:Get(player).Role
end

function RoleServiceServer.AssignRoles(): () end

function RoleServiceServer.ClearRoles(): ()
	for player, _role in ActiveRoles do
		SessionState:Update(player, function(state)
			state.Role = nil
		end)
	end

	ActiveRoles = {}
end

--[ RETURN ]--

return RoleServiceServer
