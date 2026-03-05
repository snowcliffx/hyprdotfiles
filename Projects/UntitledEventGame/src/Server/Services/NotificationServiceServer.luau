--!strict

--[ SERVICES ]--
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--[ REQUIRES ]--
local NotificationServiceUtils = require(ReplicatedStorage.Shared.Services.NotificationService.NotificationServiceUtils)

--[ TYPES ]--
export type NotificationType = NotificationServiceUtils.NotificationType

export type CountdownNotif = NotificationServiceUtils.CountdownNotif
export type MessageNotif = NotificationServiceUtils.MessageNotif

--[ REMOTES ]--
local NotificationRemote: RemoteEvent = ReplicatedStorage.Remotes.Notification

--[ MODULE TYPES ]--
type NotificationServiceServer = {
	Send: (player: "All" | Player, notif_type: NotificationType, notif: CountdownNotif | MessageNotif) -> (),
}

local NotificationServiceServer = {} :: NotificationServiceServer

function NotificationServiceServer.Send(player: "All" | Player, notif_type: NotificationType, notif: any)
	if player == "All" then
		NotificationRemote:FireAllClients(notif, notif_type)
	else
		NotificationRemote:FireClient(player, notif, notif_type)
	end
end

return NotificationServiceServer
