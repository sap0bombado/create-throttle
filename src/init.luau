--!strict
--[[
	MIT License

	Copyright (c) 2026 Diego Bandeira
	
	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:
		
		The above copyright notice and this permission notice shall be included in all
		copies or substantial portions of the Software.
		
		THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
		IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.
--]]

type ConnectionLike = RBXScriptConnection & { Disconnect: (any) -> () } & { disconnect: (any) -> () }
type EventLike = RBXScriptSignal & { Connect: (any, any) -> ConnectionLike } & { connect: (any, any) -> ConnectionLike }

export type Throttle = (() -> boolean) & ((interval: number) -> ()) & (("destroy") -> ())

local function safeDisconnect(traceback: string, connection: ConnectionLike)
	local method = connection.Disconnect ~= nil and "Disconnect" or "disconnect"

	if connection[method] ~= nil and typeof(connection[method]) == "function" then
		connection[method :: any](connection)
		return
	end

	error(`Expected a connection with a Disconnect or disconnect method. \nThrottle created at:\n{traceback}`)
end

local function safeConnect(traceback: string, event: EventLike, callback: any): ConnectionLike
	local method = event.Connect ~= nil and "Connect" or "connect"

	if event[method] ~= nil and typeof(event[method]) == "function" then
		return event[method :: any](event, callback)
	end

	error(`Expected an event with a Connect or connect method. \nThrottle created at:\n{traceback}`)
end

local function createThrottle(interval: number, updateEventMaybe: EventLike?)
	local traceback = debug.traceback(nil, 2)
	local updateEvent = updateEventMaybe or game:GetService("RunService").Heartbeat

	local canUseThrottle = true
	local accumulatedTime = 0

	local updateConnection = safeConnect(traceback, updateEvent, function(deltaTime: number)
		if canUseThrottle == true then
			return
		end

		accumulatedTime += deltaTime

		if accumulatedTime >= interval then
			accumulatedTime = 0
			canUseThrottle = true
		end
	end)

	return function(arg: (number | "destroy")?)
		if arg == nil then
			local canUse = canUseThrottle

			if canUse == true then
				canUseThrottle = false
			end

			return canUse :: any
		end

		if arg == "destroy" then
			safeDisconnect(traceback, updateConnection)
			canUseThrottle = false
			return
		end

		assert(typeof(arg) == "number", "Expected a number or 'destroy' as an argument.")
		interval = arg
	end
end

return createThrottle :: (interval: number, updateEventMaybe: EventLike?) -> Throttle
