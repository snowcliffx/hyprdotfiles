--!strict

--[ MODULES ]--
local SessionState = require("../Data/SessionState")

--[ GLOBAL TYPES ]--
type PowerUp = SessionState.PowerUp

--[ MODULE TYPES ]--
type PowerServiceServer = {
	ActivePowerUps: { [Player]: { [PowerUp]: boolean } },

	AddPowerUp: (player: Player, power_up: PowerUp, amount: number?) -> (),
	RemovePowerUp: (player: Player, power_up: PowerUp, amount: number?) -> (),

	ActivatePowerUp: (self: PowerServiceServer, player: Player, power_up: PowerUp) -> (),
	DeactivatePowerUps: (self: PowerServiceServer, player: Player) -> (),
}

local PowerServiceServer: PowerServiceServer = {} :: PowerServiceServer
PowerServiceServer.ActivePowerUps = {}

function PowerServiceServer.AddPowerUp(player: Player, power_up: PowerUp, amount: number?)
	SessionState:Update(player, function(state)
		if not state.PowerUps[power_up] then
			state.PowerUps[power_up] = amount or 1
			return
		end

		state.PowerUps[power_up] += (amount or 1)
	end)
end

function PowerServiceServer.RemovePowerUp(player: Player, power_up: PowerUp, amount: number?)
	SessionState:Update(player, function(state)
		local current_amount = state.PowerUps[power_up]

		if not current_amount then
			return
		end

		if current_amount - (amount or 1) > 0 then
			state.PowerUps[power_up] -= (amount or 1)
		else
			state.PowerUps[power_up] = nil
		end
	end)
end

function PowerServiceServer:ActivatePowerUp(player: Player, power_up: PowerUp)
	if self.ActivePowerUps[player][power_up] then
		print("Already activated.")
		return
	end

	if SessionState:Get(player).PowerUps[power_up] then
		PowerServiceServer.RemovePowerUp(player, power_up)
		self.ActivePowerUps[player][power_up] = true
	end
end

function PowerServiceServer:DeactivatePowerUps(player: Player)
	for power_up, _val in self.ActivePowerUps[player] do
		self.ActivePowerUps[player] = nil
	end
end

return PowerServiceServer
