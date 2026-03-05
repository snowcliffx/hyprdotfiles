--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SnowSignal = require(ReplicatedStorage.Shared.Libraries.SnowSignal)
local RoundSettings = require(ReplicatedStorage.Shared.Modules.RoundSettings)

type RoundServiceServer = {
    EnoughPlayers: boolean,
    Round: number,
    CurrentOperator: Player?,
    Participants: {Player},
    MinimumPlayersReached: SnowSignal.Signal<()>
}

local RoundServiceServer = {
	EnoughPlayers = false,

    Round = 1,
    CurrentOperator = nil,
    Participants = {},

    MinimumPlayersReached = SnowSignal.new()
}

Players.PlayerAdded:Connect(function(player)
	if #Players:GetPlayers() >= RoundSettings.MinimumPlayers and RoundServiceServer.EnoughPlayers == false then
        RoundServiceServer.EnoughPlayers = true
        RoundServiceServer.MinimumPlayersReached:Fire()
	end
end)

Players.PlayerRemoving:Connect(function(player, leave_reason)
    if #Players:GetPlayers() >= RoundSettings.MinimumPlayers and RoundServiceServer.EnoughPlayers == true then
        RoundServiceServer.EnoughPlayers = false
    end
end)

return RoundServiceServer
