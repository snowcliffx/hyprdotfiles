local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Modules = ReplicatedStorage.Modules
local Remotes = ReplicatedStorage.Remotes

local GAME_SETTINGS = {
	INTERMISSION_TIME = 60,
	ROUND_TIME = 30,
	SPECIAL_ROLE_COUNT = 5,
}

local Game_Settings = require(Modules.GameModule.Game_Settings)
local IntermissionModule = require(Modules.IntermissionHandler)
local RoundModule = require(Modules.RoundHandler)
local VoteManager = require(Modules.VoteManager)

local GameModule = {}
GameModule.__index = GameModule

function GameModule.new(player, round_Settings)
	local self = setmetatable({}, GameModule)

	self.GameName = round_Settings.game_Name or player.Name .. "'s Game"
	self.IntermissionTime = Game_Settings.IntermissionTime or 50
	self.RoundTime = Game_Settings.RoundTime or 60
	self.SpecialRolesAmount = round_Settings.SpecialRolesAmount or 5
	self.Player = player

	return self
end

function GameModule:Start(waitingTime: number)
	print("[GameModule] Host:", self.Player.Name, "wait:", waitingTime)
	Remotes.Notification:FireAllClients(
		self,
		self.Player.Name .. " Hosted a game. The game will start in...",
		waitingTime
	)
end

function GameModule:StartRound()
	print("[GameModule] StartRound")
	IntermissionModule.Stop()
	RoundModule.Start()
	Remotes.Notification:FireAllClients(self, "Round is in progress... end of the round in ", self.RoundTime)
	Remotes.DisplayShop:FireAllClients(true)
	Remotes.DisplayInventory:FireAllClients(true)
	Remotes.VotePlayer_ShowList:FireAllClients(true)
end

function GameModule:StopVoting()
	print("[GameModule] StopVoting")
	RoundModule.StopVoting()
	Remotes.Notification:FireAllClients(self, "Players will roles/powerUps will now choose their target Player. ", 15)
	Remotes.DisplayShop:FireAllClients(false)
	Remotes.DisplayInventory:FireAllClients(false)
	Remotes.VotePlayer_ShowList:FireAllClients(false)
end

function GameModule:StopRound()
	print("[GameModule] StopRound")
	RoundModule.Stop()
	IntermissionModule.Start()
	Remotes.Notification:FireAllClients(
		self,
		"Intermission is in progress... end of the intermission in ",
		self.IntermissionTime
	)
	Remotes.DisplayShop:FireAllClients(false)
	Remotes.DisplayInventory:FireAllClients(false)
	Remotes.VotePlayer_ShowList:FireAllClients(false)
	VoteManager:ResetVotes()
end

function GameModule:StartSpecialVote()
	print("[GameModule] StartSpecialVote")
	Remotes.Notification:FireAllClients(self, "Special vote phase for roles and active powerUps!", 15)
	Remotes.DisplayShop:FireAllClients(false)
	Remotes.DisplayInventory:FireAllClients(false)
	Remotes.VotePlayer_ShowList:FireAllClients(false)

	task.delay(15, function()
		self:ResolveSpecialVote()
	end)
end

function GameModule:ResolveSpecialVote()
	print("[GameModule] ResolveSpecialVote")

	for _, role in pairs(require(Modules.RoleManager).ActiveRoles) do
		role:Start()
	end

	for _, player in pairs(Players:GetPlayers()) do
		local powersFolder = player:FindFirstChild("powerUps")
		if powersFolder then
			for _, power in pairs(powersFolder:GetChildren()) do
				if power.Active and power.Start then
					power:Start(player)
				end
			end
		end
	end

	local eliminatedUserId, votes = require(Modules.VoteManager).GetMostVotedPlayer()
	if eliminatedUserId then
		local eliminatedPlayer = Players:GetPlayerByUserId(eliminatedUserId)
		if eliminatedPlayer then
			print(eliminatedPlayer.Name .. " has been eliminated with " .. votes .. " votes.")
		end
	end
end

function GameModule:Stop()
	RoundModule.Stop()
	Remotes.Notification:FireAllClients(self, "The game is now finished. Thanks for participating.")
end

return GameModule
