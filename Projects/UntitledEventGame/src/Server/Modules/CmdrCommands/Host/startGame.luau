local COMMAND_ARGUMENTS = {
	{
		Type = "string",
		Name = "Game Name",
		Description = "The name to display the game as.",
	},

	{
		Type = "number",
		Name = "Special Role Amount",
		Description = "The amount of special roles to allow in the game.",
	},
}

return {
	Name = "start-game",
	Aliases = { "sg" },
	Description = "Starts the game.",
	Group = "Host",
	Args = COMMAND_ARGUMENTS,
}
