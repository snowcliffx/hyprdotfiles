--[ SERVICES ]--
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--[ REQUIRES ]--
local Tags = require(ReplicatedStorage.Shared.Modules.TagsList)

-- [ TYPES ]
type PlayerTagServiceServer = {
	ChangeRole: (player: Player, new_role: keyof<typeof(Tags)>) -> (),
	LoadTag: (player: Player) -> (),
}

--[ PRIVATE FUNCTIONS ]--
local function MakeTextLabel()
	local Label = Instance.new("TextLabel")
	Label.BackgroundTransparency = 1
	Label.FontFace = Font.new("Roboto", Enum.FontWeight.Bold)
	Label.TextScaled = true
	Label.TextColor3 = Color3.new(1, 1, 1)

	local Stroke = Instance.new("UIStroke")
	Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
	Stroke.Thickness = 2
	Stroke.Parent = Label

	return Label
end

local function MakeTagUI(player: Player)
	local PlayerTagUI = Instance.new("BillboardGui")
	PlayerTagUI.Name = "PlayerTagUI"
	PlayerTagUI.Size = UDim2.fromScale(5, 1)
	PlayerTagUI.LightInfluence = 0
	PlayerTagUI.Brightness = 1
	PlayerTagUI.StudsOffset = Vector3.yAxis * 2.5
	PlayerTagUI.MaxDistance = 100
	PlayerTagUI.ClipsDescendants = false

	local PlayerName = MakeTextLabel()
	PlayerName.Name = "PlayerName"
	PlayerName.Text = "@" .. player.Name
	PlayerName.AnchorPoint = Vector2.new(0.5, 0)
	PlayerName.Position = UDim2.fromScale(0.5, 0)
	PlayerName.Size = UDim2.fromScale(1, 0.6)

	local PlayerRole = MakeTextLabel()
	PlayerRole.Name = "PlayerRole"
	PlayerRole.Text = "No Role"
	PlayerRole.AnchorPoint = Vector2.new(0.5, 1)
	PlayerRole.Position = UDim2.fromScale(0.5, 1)
	PlayerRole.Size = UDim2.fromScale(1, 0.5)

	PlayerName.Parent = PlayerTagUI
	PlayerRole.Parent = PlayerTagUI

	return PlayerTagUI
end

--[ MODULE ]--
local PlayerTagServiceServer = {} :: PlayerTagServiceServer

function PlayerTagServiceServer.LoadTag(player: Player)
	local TagUI = MakeTagUI(player)
	local Character = player.Character or player.CharacterAdded:Wait()
	local Head = Character:WaitForChild("Head") :: Part

	TagUI.Parent = Head
end

function PlayerTagServiceServer.ChangeRole(player: Player, new_role: keyof<typeof(Tags)>)
	local Character = player.Character or player.CharacterAdded:Wait()
	local Head = Character:WaitForChild("Head") :: Part

	local PlayerTagUI = Head:WaitForChild("PlayerTagUI") :: BillboardGui
	local PlayerRole = PlayerTagUI:WaitForChild("PlayerRole") :: TextLabel
	local TextStroke = PlayerRole:WaitForChild("UIStroke") :: UIStroke

	PlayerRole.Text = new_role
	PlayerRole.TextColor3 = Tags[new_role]["PrimaryColor"]
	TextStroke.Color = Tags[new_role]["SecondaryColor"]
end

return PlayerTagServiceServer
