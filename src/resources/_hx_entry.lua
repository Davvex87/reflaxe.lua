local function _hx_handle_error(obj)
	local message = tostring(obj)
	if debug and debug.traceback then
		message = debug.traceback(message, 2)
	end
	return setmetatable({}, { __tostring = function() return message end })
end

local success, err = xpcall(function()
	::moduleid::.main();
	EntryPoint.run();
end, _hx_handle_error)
if not success then error(err) end
