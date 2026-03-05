--!strict
--!native
--!optimize 2

local RoundServiceUtils = {}

RoundServiceUtils.Settings = {
    BASE_HEARTS = 3,
    BASE_DUEL_CHOICE_TIME = 10
}

type TeleportDestination = Player | Vector3 | CFrame

function RoundServiceUtils.TeleportPlayer(player: Player, dest: TeleportDestination)
	local dest_cframe: CFrame?

	if typeof(dest) == "Player" and dest.Character then
		local found_hrp = dest:FindFirstChild("HumanoidRootPart") :: Part

		if found_hrp then
			dest_cframe = found_hrp.CFrame
		end
	elseif typeof(dest) == "Vector3" then
		dest_cframe = CFrame.new(dest)
	elseif typeof(dest) == "CFrame" then
		dest_cframe = dest
	end

	if player.Character and dest_cframe then
		local found_hrp = player.Character:FindFirstChild("HumanoidRootPart") :: Part
		local humanoid = player.Character:FindFirstChild("Humanoid") :: Humanoid

		if humanoid.Sit then
			humanoid.Jump = true
		end

		found_hrp.CFrame = dest_cframe
	end
end

return RoundServiceUtils