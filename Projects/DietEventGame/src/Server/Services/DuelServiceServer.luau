--!strict
--!native
--!optimize 2

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RPSDuel = require(ReplicatedStorage.Shared.Classes.RPSDuel)

local Events = ReplicatedStorage.Events
local TriggerDuelChoice = Events.TriggerDuelChoice

type DuelChoice = "Rock" | "Paper" | "Scissors"

type DuelServiceServer = {
	CurrentDuels: { RPSDuel.Duel },

	GroupPlayersInDuel: (self: DuelServiceServer, players: { Player }) -> (),
    FindDuelOfPlayer: (self: DuelServiceServer, player: Player) -> RPSDuel.Duel?,
}

local DuelServiceServer = {
	CurrentDuels = {},
	PlayerReferenceToDuels = {},
} :: DuelServiceServer

function DuelServiceServer:GroupPlayersInDuel(players: { Player })
	local PlayerCount = #players

	if PlayerCount % 2 == 1 then
		error("Can't group an odd number of players! Something went very wrong here.")
	end

	for index = 1, PlayerCount, 2 do
		local duel = RPSDuel.new(players[index], players[index + 1])

		table.insert(self.CurrentDuels, duel)
	end
end

function DuelServiceServer:FindDuelOfPlayer(player: Player)
    for index, duel in self.CurrentDuels do
        if player == duel.FirstPlayer or player == duel.SecondPlayer then
            return duel
        end
    end

    return nil
end

TriggerDuelChoice.OnServerEvent:Connect(function(player: Player, choice: DuelChoice)
    local Duel = DuelServiceServer:FindDuelOfPlayer(player)

    if Duel then
        Duel.PlayerInfoDict[player].Choice = choice
    end
end)

return DuelServiceServer
