--!strict
--!native
--!optimize 2

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Teams = game:GetService("Teams")

local SnowSignal = require(ReplicatedStorage.Shared.Libraries.SnowSignal)
local Utils = require(ReplicatedStorage.Shared.Services.RoundService.RoundServiceUtils)

type GameStatus = "Intermission" | "ChoosingPlayers" | "Ongoing" | "Ended"

local ROUND_MAX_PLAYERS = 8
local MINIMUM_PLAYERS = 2

local RoundServiceServer = {
	GameStatus = "Intermission" :: GameStatus,
	EnoughPlayers = true,

	PlayerPool = {} :: { Player },
	PreviousWinners = {} :: { Player },

	MinimumPlayersReached = SnowSignal.new(),
} 

function RoundServiceServer.Intermission()
	RoundServiceServer.GameStatus = "Intermission"

	for countdown = 10, 0, -1 do
		if RoundServiceServer.EnoughPlayers == false then
			print("waiting for more players")

			RoundServiceServer.MinimumPlayersReached:Wait()
			countdown = 10
		end

		print(countdown)
		task.wait(1)
	end
end

function RoundServiceServer.ChoosePlayers(): { Player }
	RoundServiceServer.GameStatus = "ChoosingPlayers"

	local AvailablePlayers = table.clone(RoundServiceServer.PlayerPool)
	local AvailablePlayerCount = #AvailablePlayers

	local PlayerAmountToChoose = math.clamp(AvailablePlayerCount, 1, ROUND_MAX_PLAYERS)

	if AvailablePlayerCount % 2 == 1 then
		PlayerAmountToChoose -= 1
	end

	local ChosenPlayers = {}

	for i = 1, PlayerAmountToChoose, 1 do
		local chosen_player_index = math.random(1, #AvailablePlayers)
		ChosenPlayers[i] = AvailablePlayers[chosen_player_index]
		table.remove(AvailablePlayers, chosen_player_index)

		if #AvailablePlayers == 0 then
			break
		end
	end

	return ChosenPlayers
end

function RoundServiceServer.EliminatePlayer(player: Player)
	player.Team = Teams.Eliminated

	local found_player = table.find(RoundServiceServer.PlayerPool, player)

	if found_player then
		table.remove(RoundServiceServer.PlayerPool, found_player)
	end

	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:FindFirstChild("Humanoid") :: Humanoid

	humanoid.Health = 0
end

function RoundServiceServer.StartGame()
	for index, player in Teams.Eliminated:GetPlayers() do
		player.Team = Teams.Participants
		table.insert(RoundServiceServer.PlayerPool, player)
		Utils.TeleportPlayer(player, game.Workspace.Baseplate.Position + Vector3.new(0, 3, 0))
	end
end

Players.PlayerAdded:Connect(function(player)
	if #Players:GetPlayers() >= MINIMUM_PLAYERS and RoundServiceServer.EnoughPlayers == false then
		RoundServiceServer.EnoughPlayers = true
		RoundServiceServer.MinimumPlayersReached:Fire()
	end
end)

Players.ChildRemoved:Connect(function(inst: Instance)
	if #Players:GetPlayers() < MINIMUM_PLAYERS then
		RoundServiceServer.EnoughPlayers = false
	end
end)

return RoundServiceServer
