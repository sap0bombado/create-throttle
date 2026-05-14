## Basic Usage
```luau
--!strict
local createThrottle = require("@pkg/createThrottle")

-- Create a throttle with a 2-second interval
local throttle = createThrottle(2, os.clock)

-- Example event loop
while true do
	task.wait(0.2)

	-- Call throttle like a function to check if it's allowed
	if throttle() == true then
		print("Action allowed at:", os.clock())
	else
		print("Blocked by throttle")
	end
end

-- Changing interval dynamically
task.delay(3, function()
	throttle(0.5) -- make it faster after 10 seconds
	print("Throttle interval changed to 0.5s")
end)
```

## Install
Add as a Wally dependency:
```toml
createThrottle = "sap0bombado/create-throttle@0.1.0"
```