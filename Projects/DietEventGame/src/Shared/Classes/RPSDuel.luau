--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Events = ReplicatedStorage.Events
local TriggerDuelChoice = Events.TriggerDuelChoice

local BASE_CHOICE_TIME = 10
local BASE_HEARTS = 3

local RPSDuel = {} :: DuelImpl
RPSDuel.__index = RPSDuel

type DuelChoice = "Rock" | "Paper" | "Scissors"
type PlayerInfo = { Hearts: number, Choice: DuelChoice? }

type DuelFields = {
	FirstPlayer: Player,
	SecondPlayer: Player,

	PlayerInfoDict: {
		[Player]: PlayerInfo,
	},

	ChoiceTime: number,
	TieCount: number,
}

type DuelImpl = {
	__index: DuelImpl,

	Throw: (self: Duel) -> Player | "Draw",
	StartDuel: (self: Duel) -> (Player, Player),
	DeductHeart: (self: Duel, player: Player, amount: number) -> (),
}

export type Duel = setmetatable<DuelFields, DuelImpl>

function RPSDuel:Throw(): Player | "Draw"
	local FirstPlayerInfo = self.PlayerInfoDict[self.FirstPlayer]
	local SecondPlayerInfo = self.PlayerInfoDict[self.SecondPlayer]

	FirstPlayerInfo.Choice = nil
	SecondPlayerInfo.Choice = nil

	TriggerDuelChoice:FireClient(self.FirstPlayer, self.ChoiceTime)
	TriggerDuelChoice:FireClient(self.SecondPlayer, self.ChoiceTime)

	task.wait(self.ChoiceTime + 1) -- +1 for hacky fix because i cba to make the timer synced with client side

	local choice1 = FirstPlayerInfo.Choice
	local choice2 = SecondPlayerInfo.Choice

	if choice1 == choice2 then
		return "Draw"
	end

	-- Careful! Returns the PlayerInfo of whomever LOSES!
	if
		(choice1 == "Paper" and choice2 == "Rock")
		or (choice1 == "Rock" and choice2 == "Scissors")
		or (choice1 == "Scissors" and choice2 == "Paper")
		or choice2 == nil
	then
		return self.SecondPlayer
	else
		return self.FirstPlayer
	end
end

function RPSDuel:StartDuel()
	local FirstPlayerInfo = self.PlayerInfoDict[self.FirstPlayer]
	local SecondPlayerInfo = self.PlayerInfoDict[self.SecondPlayer]

	repeat
		local throw_result = self:Throw()
		if throw_result == "Draw" then
			self.ChoiceTime -= 1
			self.TieCount += 1

			if self.TieCount == 3 then
				self:DeductHeart(self.FirstPlayer, 1)
				self:DeductHeart(self.SecondPlayer, 1)

				self.ChoiceTime = BASE_CHOICE_TIME
				self.TieCount = 0
			end
		else
			self:DeductHeart(throw_result, 1)
		end

		print(self.PlayerInfoDict)
	until FirstPlayerInfo.Hearts == 0 or SecondPlayerInfo.Hearts == 0

	local winner, loser

	if FirstPlayerInfo.Hearts == 0 then
		winner = self.SecondPlayer
		loser = self.FirstPlayer
	else
		winner = self.FirstPlayer
		loser = self.SecondPlayer
	end

	return winner, loser
end

function RPSDuel:DeductHeart(player: Player, amount: number)
	local PlayerInfo = self.PlayerInfoDict[player]

	if not PlayerInfo then
		print("Player not found in duel.")
		return
	end

	PlayerInfo.Hearts -= amount
end

return {
	new = function(player_1: Player, player_2: Player): Duel
		local fields: DuelFields = {
			FirstPlayer = player_1,
			SecondPlayer = player_2,

			PlayerInfoDict = {
				[player_1] = {
					Choice = nil,
					Hearts = BASE_HEARTS,
				},

				[player_2] = {
					Choice = nil,
					Hearts = BASE_HEARTS,
				},
			},

			ChoiceTime = BASE_CHOICE_TIME,
			TieCount = 0,
		}

		return setmetatable(fields, RPSDuel)
	end,
}
