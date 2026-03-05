--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptServices = game:GetService("ServerScriptService")

local Services = ServerScriptServices.Services

local Events = ReplicatedStorage.Events
local SendPairedPlayers = Events.SendPairedPlayers

local DuelService = require(Services.DuelServiceServer)
local RoundService = require(Services.RoundServiceServer)

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		for _, child in pairs(character:GetDescendants()) do
			if child:IsA("BasePart") then
				child.CollisionGroup = "PlayerPart"
			end
		end
	end)
end)

local function GameLoop()
	RoundService.Intermission()
	RoundService.StartGame()

	local ChosenPlayers = RoundService.ChoosePlayers()
	DuelService:GroupPlayersInDuel(ChosenPlayers)
	SendPairedPlayers:FireAllClients(ChosenPlayers)

	for index, duel in DuelService.CurrentDuels do
		task.defer(duel.StartDuel, duel)
	end
	-- GameLoop()
end

GameLoop()
