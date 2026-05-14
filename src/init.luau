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

export type Throttle = (() -> boolean) & ((interval: number) -> ())

local function createThrottle(interval: number, timeFunctionMaybe: (() -> number)?)
	local traceback = debug.traceback(nil, 2)
	local timeFunction = timeFunctionMaybe or os.clock
	local lastUsedTime = 0

	return function(arg: number?)
		if arg == nil then
			local now = timeFunction()

			if now < lastUsedTime then
				error(
					`Time function returned a value smaller than the last used time. This can cause the throttle to never be usable again. \nThrottle created at:\n{traceback}`
				)
			end

			local canUse = now - lastUsedTime >= interval

			if canUse then
				lastUsedTime = now
			end

			return canUse :: any
		end

		assert(
			typeof(arg) == "number",
			`Expected a number or 'destroy' as an argument. \nThrottle created at:\n{traceback}`
		)

		interval = arg

		return
	end
end

return createThrottle :: (interval: number) -> Throttle
