--!strict

--[ SERVICES ]--
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--[ REQUIRES ]--
local NotificationServiceUtils = require(ReplicatedStorage.Shared.Services.NotificationService.NotificationServiceUtils)

--[ TYPES ]--
type NotificationType = NotificationServiceUtils.NotificationType

type CountdownNotif = NotificationServiceUtils.CountdownNotif
type MessageNotif = NotificationServiceUtils.MessageNotif

--[ OBJECTS ]--
local NotificationRemote = ReplicatedStorage.Remotes.Notification

local LocalPlayer = Players.LocalPlayer
local NotificationsUI = LocalPlayer.PlayerGui.Notifications
local NotificationTemplate = NotificationsUI.Container.Notification

--[ MODULE ]--
local NotificationServiceClient = {}

function NotificationServiceClient.Countdown(notif: CountdownNotif, notif_label: TextLabel)
	for count = notif.countdown, 0, -1 do
		notif_label.Text = notif.message .. `{notif.message} seconds.`
		task.wait(1)
	end

	notif_label.Text = notif.end_message
	task.wait(3)
end

function NotificationServiceClient.Message(notif: MessageNotif, notif_label: TextLabel)
	notif_label.Text = notif.message
	task.wait(notif.duration)
end

function NotificationServiceClient.Init()
	print("Loaded notification service on the client.")
end

NotificationRemote.OnClientEvent:Connect(function(notif: any, type: NotificationType)
	local NewNotification = NotificationTemplate:Clone()
	NewNotification.Visible = true
	NewNotification.Parent = NotificationsUI.Container

	NotificationServiceClient[type](notif, NewNotification)

	NewNotification:Destroy() -- SO SCUFFED BUT IT GIVES ME HAPPY HORMONE
end)

return NotificationServiceClient
