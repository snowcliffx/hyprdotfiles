--!strict

local RoundServiceClient = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Events = ReplicatedStorage.Events
local SendPairedPlayers = Events.SendPairedPlayers

local LocalPlayer = Players.LocalPlayer

local COLORS = {
	WHITE = Color3.new(1, 1, 1),
	BLACK = Color3.new(0, 0, 0),

	RED = Color3.fromRGB(255, 0, 0),
	GREEN = Color3.fromRGB(0, 255, 0),
	BLUE = Color3.fromRGB(0, 0, 255),

	DARK_RED = Color3.fromRGB(85, 0, 0),
	DARK_GREEN = Color3.fromRGB(0, 85, 0),
	DARK_BLUE = Color3.fromRGB(0, 0, 85),
}

local function HighlightPlayer(player: Player, color: Color3?, outline_color: Color3?)
	local character = player.Character or player.CharacterAdded:Wait()
	local new_highlight = Instance.new("Highlight")

	new_highlight.FillColor = color or new_highlight.FillColor
	new_highlight.FillTransparency = 0.7

	new_highlight.OutlineColor = outline_color or new_highlight.OutlineColor
	new_highlight.OutlineTransparency = 0.3

	new_highlight.Parent = character
end

SendPairedPlayers.OnClientEvent:Connect(function(ChosenPlayers: { Player })
	for index = 1, #ChosenPlayers, 2 do
		local player1 = ChosenPlayers[index]
		local player2 = ChosenPlayers[index + 1]
		
		if player1 == LocalPlayer then
			HighlightPlayer(player1, COLORS.GREEN, COLORS.DARK_GREEN)
			HighlightPlayer(player2, COLORS.RED, COLORS.DARK_RED)
		elseif player2 == LocalPlayer then
			HighlightPlayer(player2, COLORS.GREEN, COLORS.DARK_GREEN)
			HighlightPlayer(player1, COLORS.RED, COLORS.DARK_RED)
		else
			HighlightPlayer(player1, COLORS.WHITE, COLORS.BLACK)
			HighlightPlayer(player2, COLORS.WHITE, COLORS.BLACK)
		end
	end
end)

return RoundServiceClient
