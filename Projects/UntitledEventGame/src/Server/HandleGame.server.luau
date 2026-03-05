--!strict

--[ SERVICES ]--
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

--[ FOLDERS ]--
local Data = ServerScriptService.Data
local Services = ServerScriptService.Services

--[ USER-DEFINED SERVICES ]--
local GameServiceServer = require(Services.GameServiceServer)

--ble
local DataManager = require(Data.PlayerData)
local GameModule = require(Modules.GameModule)
local IntermissionHandler = require(Modules.IntermissionHandler)
local PlayersManager = require(Modules.PlayersManager)
local VoteManager = require(Modules.VoteManager)
local donationBoardManager = require(Modules.DonationBoardManager)
local RoleManager = require(Modules.RoleManager)

local PowersManager_Instance = Modules.PowersManager

local STARTING_TIME = 10
local ENDING_TIME = 10

local ActivePowers = {}

local currentGame = nil

--[ DATA LOADING ]--

for _, player in Players:GetPlayers() do
	task.spawn(DataManager.LoadProfile, player)
end

Players.PlayerAdded:Connect(function(player)
	DataManager.LoadProfile(player)
	DataManager.CreateNotSavedValue(player)
	donationBoardManager.CreateDonationsObjects(player)
end)

Players.PlayerRemoving:Connect(function(player)
	local profile = DataManager.Profiles[player]

	if profile ~= nil then
		profile:EndSession()
	end
end)

local function slog(...)
	print("[Server]", ...)
end

local function swarn(...)
	warn("[Server][WARN]", ...)
end

local function deactivatePowers(powers, player)
	for _, powerInstance in ipairs(powers) do
		if powerInstance.Deactivate then
			powerInstance:Deactivate(player)
		end
	end
end

GameServiceServer.GameStarted:Connect(function() end)

Remotes.HostAGame.OnServerEvent:Connect(function(player, game_Settings)
	if currentGame ~= nil then
		print("A game is already hosted by: " .. currentGame.Player.Name)
		return
	end

	local game_init = GameModule.new(player, game_Settings)
	currentGame = game_init

	game_init:Start(STARTING_TIME)

	task.wait(STARTING_TIME)

	while #PlayersManager.GetRemainingPlayers() >= 1 do -- remove the "=" to make the game fully work
		task.wait(1)
		game_init:StartRound()

		task.wait(game_init.RoundTime + 1)

		game_init:StopVoting()

		task.wait(15)

		game_init:StopRound()

		-- make so : powerUps that need to choose a player plays after the vode. Then 15 sec waiting time for players with roles + player thats activated Power
		-- Make so player with a role are not able to activate a power
		for player, powers in pairs(ActivePowers) do
			deactivatePowers(powers, player)

			ActivePowers[player] = {}
		end

		local mostVotedPlrUserId, score = VoteManager.GetMostVotedPlayer()

		if mostVotedPlrUserId then
			local mostVotedPlayer = Players:GetPlayerByUserId(mostVotedPlrUserId)
			if mostVotedPlayer then
				slog(mostVotedPlayer.Name .. " is now eliminated. Votes = " .. score)
				IntermissionHandler.CleanupFor(mostVotedPlayer)
				ReplicatedStorage.Remotes.Elimination:FireAllClients(mostVotedPlayer, score)
			else
				swarn("Most voted userId has no Player instance.")
			end
		else
			slog("No elimination (tie). Votes = " .. tostring(score))
			ReplicatedStorage.Remotes.Elimination:FireAllClients(nil, score)
		end

		task.wait(game_init.IntermissionTime)
	end

	task.wait(ENDING_TIME)

	game_init:Stop()
	DataManager:ResetStats()
	currentGame = nil
end)

Remotes.Minigame.OnServerEvent:Connect(function(playerWhoTriggered, choosenMinigame, targetPlayer)
	if not playerWhoTriggered or not targetPlayer or type(choosenMinigame) ~= "string" then
		swarn("Bad Minigame request payload.")
		return
	end

	local pdf = playerWhoTriggered:FindFirstChild("Data")
	local tdf = targetPlayer:FindFirstChild("Data")
	if
		(pdf and pdf:FindFirstChild("Eliminated") and pdf.Eliminated.Value)
		or (tdf and tdf:FindFirstChild("Eliminated") and tdf.Eliminated.Value)
	then
		swarn("Minigame request denied because one player is eliminated.")
		return
	end

	slog(playerWhoTriggered.Name .. " requested minigame '" .. choosenMinigame .. "' with " .. targetPlayer.Name)
	Remotes.Minigame_Response:FireClient(targetPlayer, choosenMinigame, playerWhoTriggered)
end)

Remotes.Minigame_Response.OnServerEvent:Connect(
	function(player, choosenMinigame, Minigame_Host: Player, response: boolean)
		if not response then
			slog(
				player.Name
					.. " declined minigame '"
					.. tostring(choosenMinigame)
					.. "' from "
					.. (Minigame_Host and Minigame_Host.Name or "nil")
			)
			return
		end

		if not Minigame_Host then
			swarn("Minigame response has no host.")
			return
		end

		local minigameModule = Modules.MinigamesModule:FindFirstChild(choosenMinigame)
		if not minigameModule then
			swarn("Minigame module '" .. tostring(choosenMinigame) .. "' not found.")
			return
		end

		slog(player.Name .. " accepted minigame '" .. choosenMinigame .. "' from " .. Minigame_Host.Name)
		local ok, module = pcall(require, minigameModule)
		if not ok or not module then
			swarn("Failed to require minigame '" .. tostring(choosenMinigame) .. "': " .. tostring(module))
			return
		end

		local minigameInstance = module.new(player, Minigame_Host)
		minigameInstance:Start()
	end
)

Remotes.VotePlayer_ShowList.OnServerEvent:Connect(function(player, votedPlayer)
	local votes = VoteManager.Vote(player, votedPlayer)
end)

Remotes.Vote2Player_ShowList.OnServerEvent:Connect(function(player, votedPlayer)
	if not player then
		return
	end
	if not votedPlayer or not votedPlayer:IsA("Player") then
		warn("[Vote2] invalid target")
		return
	end

	local ok, reason = VoteManager.Vote(player, votedPlayer, 2)
	if not ok then
		warn("[Vote2] vote rejected for", player.Name, reason or "unknown")
		return
	end

	local role = RoleManager.GetRole(player)
	if role and role.Activate then
		local success, err = pcall(function()
			role:Activate(votedPlayer)
		end)
		if not success then
			warn("[Vote2] role activation failed:", tostring(err))
		end
	end

	local powers = ActivePowers[player]
	if powers and type(powers) == "table" then
		for _, powerInstance in ipairs(powers) do
			if powerInstance and powerInstance.Activate then
				local succ = pcall(function()
					powerInstance:Activate(player, votedPlayer)
				end)
				if not succ then
					pcall(function()
						powerInstance:Activate(player)
					end)
				end
			end
		end
	end
end)

Remotes.Minigame_Finish.OnServerEvent:Connect(function(player, finalPick, minigame)
	local DataFolder = player.Data
	local pickInstance = DataFolder:FindFirstChild(minigame .. "_pickInstance")

	if not pickInstance then
		return "pickInstance not found"
	end

	if pickInstance ~= nil then
		pickInstance.Value = finalPick
	else
		pickInstance.Value = "nil"
	end
end)

Remotes.ActivatePower.OnServerInvoke = function(player, power)
	if not player.powerUps:FindFirstChild(power.Name) then
		warn("Power not found")
		return false
	end

	print("Power activation processing...")

	local powerModule = require(PowersManager_Instance:WaitForChild(power.Name))
	if not powerModule then
		warn("Power module not found for", power.Name)
		return false
	end

	if ActivePowers[player] and #ActivePowers[player] >= 1 then
		warn("Player has already activated a powerUp -> Return")
		return false
	end

	local powerInstance = powerModule.new(power.Name)
	powerInstance:Activate(player)

	print("Power activated")

	ActivePowers[player] = ActivePowers[player] or {}
	table.insert(ActivePowers[player], powerInstance)

	return true
end
