return {
	Name = "rank",
	Aliases = {},
	Description = "Ranks a player.",
	Group = "Owner",
	Args = {
		{
			Type = "player",
			Name = "Player",
			Description = "Player to rank.",
		},

		{
			Type = "ranks",
			Name = "Rank Name",
			Description = "Which rank to hand out.",
		},

		{
			Type = "boolean",
			Name = "Permanent",
			Description = "If true, the player gets to keep the role even if they leave or rejoin.",
		},
	},
}
