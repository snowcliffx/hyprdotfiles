--[ SERVICES ]--
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Teams = game:GetService("Teams")

--[ LIBRARIES ]--
local SignalLib = require(ReplicatedStorage.Shared.Libraries.Signal)

--[ DATA ]--
local SessionState = require("../Data/SessionState")

--[ USER-DEFINED SERVICES ]--
local NotificationService = require("./NotificationServiceServer")

type GameServiceServer = {
	Settings: {
		IntermissionTime: number,
		RoundTime: number,
		VoteTime: number,
		SpecialRoleAmount: number,
		StartingTime: number,
		EndingTime: number,
	},

	isOngoing: boolean,
	GameState: "Starting" | "Intermission" | "Voting" | "Ending",
	GameName: string?,
	Host: Player?,

	StartGame: (self: GameServiceServer, player: Player, game_name: string, special_role_amount: number) -> (),
	EndGame: (self: GameServiceServer) -> (),

	GameStarted: SignalLib.Signal<()>,
	GameEnded: SignalLib.Signal<()>,
}

local GameServiceServer = {
	Settings = {
		IntermissionTime = 60,
		RoundTime = 30,
		VoteTime = 30,
		StartingTime = 10,
		EndingTime = 10,
		SpecialRoleAmount = 5,
	},

	isOngoing = false,

	GameStarted = SignalLib.new(),
	GameEnded = SignalLib.new(),
} :: GameServiceServer

function GameServiceServer:StartGame(player: Player, game_name: string, special_role_amount: number)
	if self.isOngoing == true then
		print("A game is already ongoing.")
	end

	self.GameState = "Starting"

	self.Host = player
	self.GameName = game_name
	self.Settings.SpecialRoleAmount = special_role_amount

	NotificationService.Send(
		"All",
		"Countdown",
		{
			message = `{player.Name} is hosting! The game starts in: `,
			end_message = "The game is starting!",
			countdown = self.Settings.StartingTime,
		} :: NotificationService.CountdownNotif
	)

	for index, player in Players:GetPlayers() do
		SessionState.Init(player)

		if player == self.Host then
			player.Team = Teams.Host
			continue
		end

		player.Team = Teams.Playing
	end

	task.wait(10)

	self.isOngoing = true
	self.GameStarted:Fire()
end

function GameServiceServer:EndGame(player: Player)
	if self.isOngoing == false then
		print("There is no game??")
	end

	self.GameState = "Ending"

	self.Host = nil
	self.GameName = nil

	self.isOngoing = false
	self.GameEnded:Fire()
end

function GameServiceServer:Eliminate(player: Player) end

return GameServiceServer
