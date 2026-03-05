--!strict

export type NotificationType = "Countdown" | "Message"

export type CountdownNotif = {
	message: string,
	end_message: string,
	countdown: number,
}

export type MessageNotif = {
	message: string,
	duration: number,
}

return {}
