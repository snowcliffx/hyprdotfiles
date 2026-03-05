--!strict

local PersistFreeze = {} :: { [Player]: RBXScriptConnection }

local function AnchorCharacter(instance: Instance)
	for index, part in instance:GetChildren() do
		if part:IsA("BasePart") then
			part.Anchored = true
		end
	end
end

local function ToggleFreeze(player: Player, doAnchor: boolean, persist: boolean)
	local character = player.Character or player.CharacterAdded:Wait()

	for index, part in character:GetChildren() do
		if part:IsA("BasePart") then
			part.Anchored = doAnchor
		end
	end

	if persist == true then
		if doAnchor == true then
			if PersistFreeze[player] then
				return
			end

			local onCharacterRespawn = player.CharacterAdded:Connect(AnchorCharacter)
			PersistFreeze[player] = onCharacterRespawn
		else
			if PersistFreeze[player] then
				local Connection = PersistFreeze[player]
				Connection:Disconnect()
				Connection = nil
				PersistFreeze[player] = nil
			end
		end
	end
end

return function(context, playerArg: Player | { Player }, freezeOption: "Freeze" | "Thaw", persist: boolean)
	local doAnchor = freezeOption == "Freeze" and true or false

	if type(playerArg) == "table" then
		for index, player in playerArg do
			ToggleFreeze(player, doAnchor, persist)
		end
	else
		ToggleFreeze(playerArg, doAnchor, persist)
	end

	local freeze_text = freezeOption == "Freeze" and "frozen" or "thawed"
	local persist_text = persist == true and "persist" or "not persist"

	return `Selected player(s) have been {freeze_text} and this will {persist_text} when they respawn.`
end
