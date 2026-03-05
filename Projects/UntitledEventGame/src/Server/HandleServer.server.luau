local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local PlayerTagService = require(ServerScriptService.Services.PlayerTagServiceServer)
local Cmdr = require(ReplicatedStorage.Shared.Libraries.Cmdr)

Players.PlayerAdded:Connect(function(player)
	-- Stuff

	player.CharacterAdded:Connect(function(character)
		for index, part in character:GetChildren() do
			if part:IsA("BasePart") then
				part.CollisionGroup = "Player"
			end
		end

		PlayerTagService.LoadTag(player)
	end)
end)

Cmdr.Registry:RegisterTypesIn(ReplicatedStorage.Shared.Modules.CmdrTypes)
Cmdr.Registry:RegisterDefaultCommands()
Cmdr.Registry:RegisterCommandsIn(ServerScriptService.Modules.CmdrCommands)

Remotes.BuyPowerup.OnServerEvent:Connect(function(player, powerup)
	local playerMoney = player.leaderstats.Money
	if playerMoney.Value >= powerup.Info.Price then
		playerMoney.Value -= powerup.Info.Price
		DataManager.AddPowerUp(player, powerup.Name)
	end
end)

MarketPlaceService.PromptProductPurchaseFinished:Connect(function(userId, productId, isPurchased)
	if not isPurchased then
		return
	end

	print(Players:GetPlayerByUserId(userId).Name .. " Bought a	Donation, Thanks!")
end)
