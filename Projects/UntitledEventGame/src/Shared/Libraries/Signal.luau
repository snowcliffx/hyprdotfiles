export type Signal<T...> = typeof(setmetatable({} :: SignalFields<T...>, {} :: SignalImpl<T...>))
export type Connection<T...> = typeof(setmetatable({} :: ConnectionFields<T...>, {} :: ConnectionImpl<T...>))

type SignalFields<T...> = {
	head: Connection<T...>?,
}

type SignalImpl<T...> = {
	__index: SignalImpl<T...>,

	Connect: (self: Signal<T...>, listener: (T...) -> ()) -> Connection<T...>,
	Fire: (self: Signal<T...>, T...) -> (),
	Wait: (self: Signal<T...>) -> (),
}

type ConnectionFields<T...> = {
	listener: (T...) -> (),
	next: Connection<T...>?,
	signal: Signal<T...>,
	is_connected: boolean,
}

type ConnectionImpl<T...> = {
	__index: ConnectionImpl<T...>,
	Disconnect: (self: Connection<T...>) -> (),
}

local Connection: ConnectionImpl<...any> = {} :: ConnectionImpl<...any>
Connection.__index = Connection

local Signal: SignalImpl<...any> = {} :: SignalImpl<...any>
Signal.__index = Signal

--[[
		Yield-safe coroutine reusing by stravant;
		Sources:
		https://devforum.roblox.com/t/lua-signal-class-comparison-optimal-goodsignal-class/1387063
		https://gist.github.com/stravant/b75a322e0919d60dde8a0316d1f09d2f
	--]]

local FreeRunnerThread: thread?

local function AcquireRunnerThreadAndCallEventHandler(fn, ...)
	local acquired_runner_thread = FreeRunnerThread
	FreeRunnerThread = nil
	fn(...)

	-- The handler finished running, this runner thread is free again.
	FreeRunnerThread = acquired_runner_thread
end

local function RunEventHandlerInFreeThread(...)
	AcquireRunnerThreadAndCallEventHandler(...)

	while true do
		AcquireRunnerThreadAndCallEventHandler(coroutine.yield())
	end
end

function Connection:Disconnect(): ()
	if self.is_connected == false then
		return
	end

	local signal = self.signal
	self.is_connected = false

	if signal.head == self then
		signal.head = self.next
	else
		local prev = signal.head

		while prev ~= nil and prev.next ~= self do
			prev = prev.next
		end

		if prev ~= nil then
			prev.next = self.next
		end
	end
end

function Signal:Connect<T...>(listener: (T...) -> ()): Connection<...any>
	if type(listener) ~= "function" then
		error(`[{script.Name}]: \"listener\" must be a function; Received {typeof(listener)}`)
	end

	local connection: ConnectionFields<...any> = {
		listener = listener,
		signal = self,
		next = self.head,
		is_connected = true,
	}

	setmetatable(connection, Connection)

	self.head = connection

	return connection
end

function Signal:Fire<T...>(...: T...): ()
	local item = self.head

	while item ~= nil do
		if item.is_connected == true then
			if not FreeRunnerThread then
				FreeRunnerThread = coroutine.create(RunEventHandlerInFreeThread)
			end

			if FreeRunnerThread then
				task.spawn(FreeRunnerThread, item.listener, ...)
			end
		end

		item = item.next
	end
end

function Signal:Wait(): ()
	local thread = coroutine.running()
	local connection

	connection = self:Connect(function(...)
		connection:Disconnect()
		task.spawn(thread, ...)
	end)

	return coroutine.yield()
end

return table.freeze({
	new = function<T...>(): Signal<T...>
		local signal: SignalFields<T...> = {
			head = nil,
		}

		setmetatable(signal, Signal)

		return signal
	end,
})
