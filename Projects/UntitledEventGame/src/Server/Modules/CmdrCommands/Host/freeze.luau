local COMMAND_ARGUMENTS = {
	{
		Type = "players",
		Name = "Players",
		Description = "Player(s) to freeze/thaw.",
	},

	{
		Type = "freeze",
		Name = "Freeze Option",
		Description = "Whether to freeze or thaw the selected player(s).",
	},

	{
		Type = "boolean",
		Name = "Persist",
		Description = "This ensures that whatever option you chose persists even if the player(s) resets.",
	},
}

return {
	Name = "toggle-freeze",
	Aliases = { "tf" },
	Description = "Freezes or thaws player(s) based on the input.",
	Group = "Host",
	Args = COMMAND_ARGUMENTS,
}
