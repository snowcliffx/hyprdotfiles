local module = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local LogicContainer = workspace.LogicContainer

-- Modules --

-- Logic Components --
local PlayerSeats = LogicContainer.PlayerSeats
local VotingBoxes = LogicContainer.VotingBoxes

-- Constants --
local AmountSeatRows = 0 -- Set at Initialization
local AmountSeatsPerRow = #PlayerSeats:FindFirstChildWhichIsA("Model"):GetChildren()
local TotalSeats = 0 -- Set at Initialization
local DefaultWalkSpeed = StarterPlayer.CharacterWalkSpeed
local DefaultJumpHeight = StarterPlayer.CharacterJumpHeight

-- State Variables --
local SeatObjects = {}
function module:GetNextFreeSeat() -- Get the seat object from the next available seat (takes lowest SeatNum from lowest RowNum)
	local Seat

	for Row = 1, AmountSeatRows, 1 do
		for SeatNum = 1, AmountSeatsPerRow, 1 do
			local Index = Row .. ":" .. SeatNum
			local SeatObj: Seat = SeatObjects[Index]

			if SeatObj.Occupant == nil then
				Seat = SeatObj
				break
			end
		end

		if Seat then
			break
		end
	end

	return Seat
end

function module:AssignSeatToPlayer(Player: Player, TargetSeat: Seat)
	task.spawn(function() -- Prevent yielding in main thread
		if Player:FindFirstChild("DataLoaded") == nil or Player.DataLoaded.Value == false then
			warn("Can't assign Seat to player: Player is not loaded")
			return
		end

		local Character = Player.Character or Player.CharacterAdded:Wait()
		local Humanoid: Humanoid = Character:WaitForChild("Humanoid")

		if TargetSeat == nil then
			TargetSeat = module:GetNextFreeSeat()
		end

		if TargetSeat == nil then
			warn("Can't assign Seat to player: No seats available")
			return
		end

		module:EnableSeats({ TargetSeat })

		TargetSeat:Sit(Humanoid)

		Humanoid.WalkSpeed = 0
		Humanoid.JumpHeight = 0
	end)
end

function module:GetSeatFromPlayer(Player)
	local Seat

	pcall(function()
		Seat = Player.State.AssignedSeat.Value
	end)

	return Seat
end

function module:DisableSeats(TargetSeats) -- make sure all players stand up
	if TargetSeats == nil then
		TargetSeats = SeatObjects
	end

	for _, Seat in TargetSeats do
		if Seat == nil then
			continue
		end

		Seat.Disabled = true
	end
end

function module:EnableSeats(TargetSeats)
	if TargetSeats == nil then
		TargetSeats = SeatObjects
	end

	for _, Seat in TargetSeats do
		if Seat == nil then
			continue
		end

		Seat.Disabled = false
	end
end

function module:GetSeatIndex(SeatObject: Seat) -- Seat object to index (RowNum:SeatNum)
	local SeatModel = SeatObject.Parent
	local Row = SeatModel.Parent

	return Row.Name .. ":" .. SeatModel.Name
end

function module:GetSeatFromIndex(Index) --    (RowNum:SeatNum) --> Seat Object
	return SeatObjects[Index]
end

function module:GetVotingBoxFromIndex(Index)
	local Split = string.split(Index, ":")
	local Row = Split[1]
	local Num = Split[2]

	if (not Row) or not Num then
		warn("Can't get voting box from index: Invalid index", Index)
		return
	end

	local RowModel = VotingBoxes:FindFirstChild(Row)

	if not RowModel then
		warn("Can't get voting box from index: Invalid Row", Row)
		return
	end

	local SeatObj = RowModel:FindFirstChild(Num)

	if not SeatObj then
		warn("Can't get voting box from index: Seat does not exist", Num)
		return
	end

	return SeatObj
end

function module:GetPlayerVotingBoxObj(Player)
	local AssignedSeatObj = module:GetSeatFromPlayer(Player)

	if AssignedSeatObj == nil then
		warn("Can't get voting box of player" .. Player.Name .. ": No assigned seat")
		return
	end

	local SeatIndex = module:GetSeatIndex(AssignedSeatObj)
end

function module:TeleportPlayersToLobby(playersToTp)
	if not playersToTp then
		playersToTp = Players:GetPlayers()
	end

	for _, Player in pairs(playersToTp) do
		local Seat = module:GetSeatFromPlayer(Player)
		module:DisableSeats({ Seat })
		Remotes.Client:FireClient(Player, { Type = "TeleportToLobby" })
	end
end

function module:SeatPlayers(playersToTp)
	if not playersToTp then
		playersToTp = Players:GetPlayers()
	end

	for _, Player in pairs(playersToTp) do
		local eliminatedFlag = Player:FindFirstChild("Data") and Player.Data:FindFirstChild("Eliminated")
		if eliminatedFlag and eliminatedFlag.Value == true then
			continue
		end

		if Player:FindFirstChild("DataLoaded") == nil or Player.DataLoaded.Value == false then
			print("Skipped seating " .. Player.Name .. ": Player not loaded")
			continue
		end

		module:AssignSeatToPlayer(Player)
		task.wait(0.05)
	end
end

function module:unseat(playersToTp)
	if not playersToTp then
		playersToTp = Players:GetPlayers()
	end

	for _, Player in pairs(playersToTp) do
		local eliminatedFlag = Player:FindFirstChild("Data") and Player.Data:FindFirstChild("Eliminated")
		if eliminatedFlag and eliminatedFlag.Value == true then
			continue
		end

		local Seat = module:GetSeatFromPlayer(Player)
		if Seat then
			module:DisableSeats({ Seat })
			print("Unseated survivor:", Player.Name)

			Player.Character.Humanoid.WalkSpeed = DefaultWalkSpeed
			Player.Character.Humanoid.JumpHeight = DefaultJumpHeight
		end
	end
end

-- Initialization -
for _, Row in PlayerSeats:GetChildren() do
	AmountSeatRows += 1

	for _, SeatModel in Row:GetChildren() do
		local SeatObject: Seat = SeatModel:FindFirstChildWhichIsA("Seat")
		local IndexName = module:GetSeatIndex(SeatObject)

		local OrigCFrame = SeatObjects.CFrame

		if SeatObject == nil then
			warn("No Seat found for Index:", IndexName)
		end

		SeatObjects[IndexName] = SeatObject

		TotalSeats += 1

		SeatObject:GetPropertyChangedSignal("CFrame"):Connect(function()
			SeatObjects.CFrame = OrigCFrame
		end)

		local LastOccupant

		SeatObject:GetPropertyChangedSignal("Occupant"):Connect(function()
			if SeatObject.Occupant == nil and LastOccupant then -- someone stood up
				LastOccupant.State.AssignedSeat.Value = nil
				return
			end

			local Character = SeatObject.Occupant.Parent
			local Player = Players:GetPlayerFromCharacter(Character)

			Player.State.AssignedSeat.Value = SeatObject
			LastOccupant = Player
		end)
	end
end

module:DisableSeats()

return module
