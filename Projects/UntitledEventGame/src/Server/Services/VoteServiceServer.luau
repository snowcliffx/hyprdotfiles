local SessionState = require("../Data/SessionState")

local VoteServiceServer = {
	Votes = {},
	SpecialVotes = {},
}

function VoteServiceServer.CanVote(player: Player)
	return SessionState:Get(player).canVote
end
