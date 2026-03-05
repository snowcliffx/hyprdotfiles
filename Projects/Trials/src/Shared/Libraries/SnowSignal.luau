--!native
--!optimize 2

export type Signal<T...> = {
	__index: Signal<T...>,

	Tail: Connection<T...>?,
	Head: Connection<T...>?,

	Connect: (self: Signal<T...>, callback: (T...) -> ()) -> Connection<T...>,
	Once: (self: Signal<T...>, callback: (T...) -> ()) -> Connection<T...>,
	Wait: (self: Signal<T...>) -> T...,
	Fire: (self: Signal<T...>, T...) -> T...,

	DisconnectAll: (self: Signal<T...>) -> (),
}

export type Connection<T...> = {
	Signal: Signal<T...>,
	Connected: boolean?,
	Next: Connection<T...>?,
	Previous: Connection<T...>?,

	Callback: (T...) -> (),
	Disconnect: (self: Connection<T...>) -> (),
}

local Threads = {}

local function ReusableThreadCall(callback, thread, ...)
	callback(...)
	table.insert(Threads, thread)
end

local function ReusableThread()
	while true do
		ReusableThreadCall(coroutine.yield())
	end
end

local function Disconnect<T...>(Connection: Connection<T...>)
	if not Connection.Connected then
		return
	end

	Connection.Connected = nil

	local Signal = Connection.Signal
	local Previous = Connection.Previous
	local Next = Connection.Next

	if Previous then
		Previous.Next = Next
	else
		Signal.Tail = Next
	end

	if Next then
		Next.Previous = Previous
	else
		Signal.Head = Previous
	end
end

local function Connect<T...>(signal: Signal<T...>, callback: (T...) -> ()): Connection<T...>
	local head = signal.Head

	local Connection: Connection<T...> = {
		Signal = signal,
		Connected = true,
		Previous = head,
		Next = nil,

		Callback = callback,
		Disconnect = Disconnect,
	}

	if head then
		head.Next = Connection
	else
		signal.Tail = Connection
	end

	signal.Head = Connection

	return Connection
end

local function Once<T...>(signal: Signal<T...>, callback: (T...) -> ()): Connection<T...>
	local head = signal.Head

	local Connection: Connection<T...>
	Connection = {
		Signal = signal,
		Connected = true,
		Previous = head,
		Next = nil,

		Callback = function(...)
			if not Connection.Connected then
				return
			end

			Connection.Connected = false

			local previous = Connection.Previous
			local next = Connection.Next

			if previous then
				previous.Next = next
			else
				signal.Tail = next
			end

			if next then
				next.Previous = previous
			else
				signal.Head = previous
			end

			callback(...)
		end,

		Disconnect = Disconnect,
	}

	if head then
		head.Next = Connection
	else
		signal.Tail = Connection
	end

	signal.Head = Connection

	return Connection
end

local function Wait<T...>(signal: Signal<T...>)
	local thread = coroutine.running()
	local head = signal.Head

	local Connection: Connection<T...>
	Connection = {
		Signal = signal,
		Connected = true,
		Previous = head,
		Next = nil,

		Callback = function(...)
			Connection.Connected = false

			local previous = Connection.Previous
			local next = Connection.Next
			if previous then
				previous.Next = next
			else
				signal.Tail = next
			end
			if next then
				next.Previous = previous
			else
				signal.Head = previous
			end

			-- Resume the thread.
			if coroutine.status(thread) == "suspended" then -- To avoid creating new threads.
				task.spawn(thread, ...)
			end
		end,

		Disconnect = Disconnect,
	}

	if head then
		head.Next = Connection
	else
		signal.Tail = Connection
	end

	signal.Head = Connection

	return coroutine.yield()
end

local function Fire<T...>(signal: Signal<T...>, ...: T...)
	local connection = signal.Tail

	while connection do
		local length = #Threads

		if length == 0 then
			local thread = coroutine.create(ReusableThread)
			coroutine.resume(thread) -- Initialize.
			task.defer(thread, connection.Callback, thread, ...)
		else
			local thread = Threads[length]
			Threads[length] = nil -- Remove from free threads list.
			task.defer(thread, connection.Callback, thread, ...)
		end

		connection = connection.Next
	end
end

local function DisconnectAll<T...>(signal: Signal<T...>)
	local connection = signal.Tail
	while connection do
		local nextConnection = connection.Next

		connection.Connected = nil
		connection.Next = nil
		connection.Previous = nil

		connection = nextConnection
	end

	signal.Tail = nil
	signal.Head = nil
end

return {
	new = function<T...>(): Signal<T...>
		return {
			Connect = Connect,
			Once = Once,
			Wait = Wait,
			Fire = Fire,
			DisconnectAll = DisconnectAll,
		}
	end,
}
