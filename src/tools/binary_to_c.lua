local symbol, filename = ...
assert(symbol and filename, "Usage: " .. arg[0] .. " C_SYMBOL FILENAME")

local function table_extend(t, ...)
	for i = 1, select('#', ...) do
		local v = select(i, ...)
		table.insert(t, v)
	end
end

local f = io.input(filename ~= '-' and filename or nil)
local bytes = {}
repeat
	local chunk = f:read(1024)
	if chunk then
		table_extend(bytes, string.byte(chunk, 1, #chunk))
	end
until not chunk

print(string.format("const char %s[] = { %s };", symbol, table.concat(bytes, ',')))
