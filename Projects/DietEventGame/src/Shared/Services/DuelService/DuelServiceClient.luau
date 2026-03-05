--!strict
--!native
--!optimize 2

type DuelChoice = "Rock" | "Paper" | "Scissors"

--[ SERVICES ]--
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local DuelServiceClient = {}

--[ CONSTANTS ]--
local BASE_BUTTON_SIZE = UDim2.fromScale(0.25, 0.8)
local BASE_BUTTON_COLOR = Color3.fromRGB(65, 65, 65)

local BASE_BUTTON_PROPERTIES = {
	BackgroundColor3 = BASE_BUTTON_COLOR,
	Size = BASE_BUTTON_SIZE
}

local SELECTED_BUTTON_PROPERTIES = {
	BackgroundColor3 = Color3.fromRGB(25, 25, 25),
	Size = UDim2.fromScale(0.35, 0.9),
}

local BUTTON_TWEEN_INFO = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

--[ GLOBAL INSTANCES ]--
local Events = ReplicatedStorage.Events
local TriggerDuelChoice = Events.TriggerDuelChoice

local LocalPlayer = Players.LocalPlayer

local DuelChoiceUI = LocalPlayer.PlayerGui:WaitForChild("DuelChoice")

local RockButton = DuelChoiceUI.Base.RockButton
local PaperButton = DuelChoiceUI.Base.PaperButton
local ScissorsButton = DuelChoiceUI.Base.ScissorsButton

--[ GLOBAL VARIABLES ]--
local PickedChoice: DuelChoice? = nil

local MapStringToButtons: { [DuelChoice]: TextButton } = {
	Rock = RockButton,
	Paper = PaperButton,
	Scissors = ScissorsButton,
}

--[ EVENTS ]--
TriggerDuelChoice.OnClientEvent:Connect(function(choice_time: number)
	for _, button in MapStringToButtons do
		button.Size = BASE_BUTTON_SIZE
		button.BackgroundColor3 = BASE_BUTTON_COLOR
	end

	DuelChoiceUI.Enabled = true

	task.wait(choice_time)

	DuelChoiceUI.Enabled = false
	TriggerDuelChoice:FireServer(PickedChoice)
	PickedChoice = nil
end)

--[ INITIALIZING ]--
for choice_name, button in MapStringToButtons do
	button.MouseButton1Click:Connect(function()
		PickedChoice = choice_name

		TweenService:Create(button, BUTTON_TWEEN_INFO, SELECTED_BUTTON_PROPERTIES):Play() -- TODO: Can be optimized by caching tweens

		for _, button_s in MapStringToButtons do
			if button_s == button then
				continue 
			end

			TweenService:Create(button_s, BUTTON_TWEEN_INFO, BASE_BUTTON_PROPERTIES):Play()
		end
	end)
end

return DuelServiceClient