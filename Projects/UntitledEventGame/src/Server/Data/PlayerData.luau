--!strict

local Players = game:GetService("Players")

local ProfileStore = require("./ProfileStore")

local PROFILE_TEMPLATE = {
	Wins = 0,
}

local PlayerStore = ProfileStore.New("PlayerStore", PROFILE_TEMPLATE)
local Profiles: { [Player]: typeof(PlayerStore:StartSessionAsync(``, {})) } = {}

-- Player Joined --

local DataManager = {
	Profiles = Profiles,
}

function DataManager.OnProfileLoaded(player: Player, profile)
	-- Create Instances inside player --

	local DataLoaded = Instance.new("BoolValue")
	DataLoaded.Name = "DataLoaded"
	DataLoaded.Parent = player

	local BaseStructure = {
		{ Name = "Data", Type = "Folder" },
		{ Name = "State", Type = "Folder" },
		{ Name = "leaderstats", Type = "Folder" },
		{ Name = "powerUps", Type = "Folder" },
	}

	local ValuesToCreate = {
		{
			name = "AssignedSeat",
			obj = "ObjectValue",
			parent = "State",
			value = nil,
		},

		{
			name = "Eliminated",
			obj = "BoolValue",
			parent = "Data",
			value = false,
		},
	}

	for _, Info in BaseStructure do
		local Object = Instance.new(Info.Type)
		Object.Name = Info.Name
		Object.Parent = player
	end

	for _, info in ValuesToCreate do
		local Name = info.name
		local objType = info.obj
		local parent = if typeof(info.parent) == "string" then player:FindFirstChild(info.parent) else info.parent
		local value = info.value

		local Obj = Instance.new(objType)

		Obj.Name = Name

		pcall(function()
			Obj.Value = value
		end)

		Obj.Parent = parent
	end

	DataLoaded.Value = true
end

function DataManager.LoadProfile(player: Player)
	-- Start a profile session for this player's data:

	local profile = PlayerStore:StartSessionAsync(`{player.UserId}`, {
		Cancel = function()
			return player.Parent ~= Players
		end,
	})

	-- Handling new profile session or failure to start it:

	if profile ~= nil then
		profile:AddUserId(player.UserId) -- GDPR compliance
		profile:Reconcile() -- Fill in missing variables from PROFILE_TEMPLATE (optional)

		profile.OnSessionEnd:Connect(function()
			DataManager.Profiles[player] = nil
			player:Kick(`Profile session end - Please rejoin`)
		end)

		if player.Parent == Players then
			DataManager.Profiles[player] = profile
			DataManager.OnProfileLoaded(player, profile)
		else
			-- The player has left before the profile session started
			profile:EndSession()
		end
	else
		-- This condition should only happen when the Roblox server is shutting down
		player:Kick(`Profile load fail - Please rejoin`)
	end
end

function DataManager.CreateNotSavedValue(player: Player)
	local money = Instance.new("NumberValue")
	money.Parent = player.leaderstats
	money.Value = 5000
	money.Name = "Money"

	local hasVoted = Instance.new("BoolValue")
	hasVoted.Parent = player.Data
	hasVoted.Value = false
	hasVoted.Name = "hasVoted"
end

local function resetPowerUps(player)
	for _, powerUp in ipairs(player.PowerUps:GetChildren()) do
		powerUp:Destroy()
	end
end

function DataManager:ResetStats()
	for _, player in pairs(Players:GetPlayers()) do
		player.leaderstats.Money.Value = 100
		player.Data.Eliminated.Value = false
		player.Data.AssignedSeat.Value = nil
		player.Data.hasVoted.Value = false
		resetPowerUps(player)
	end
end

function DataManager.AddPowerUp(player, powerUp_Name)
	local powerUpsFolder = player.powerUps

	local powerUp = Instance.new("BoolValue")
	powerUp.Name = powerUp_Name
	powerUp.Value = true
	powerUp.Parent = powerUpsFolder
end

function DataManager.RemovePowerUp(player, powerUp_Name)
	local powerUpsFolder = player.powerUps

	local powerUp = powerUpsFolder:FindFirstChild(powerUp_Name)
	if powerUp then
		powerUp:Destroy()
	end
end

return DataManager
