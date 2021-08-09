local symbol, filename = ...
assert(symbol and filename, "Usage: " .. arg[0] .. " C_SYMBOL FILENAME")

local is_debug = os.getenv("DEBUG") == "1"

local line_bytes = {}
for line in io.lines(filename ~= '-' and filename or nil) do
	if not is_debug then
		line = line:match("%s*(.*)"):gsub("%-%-.*", ""):gsub("//.*", "")
	end
	if #line > 0 then
		table.insert(line_bytes, table.concat({ string.byte(line, 1, #line) }, ','))
	end
end

local newline_byte = ',' .. string.byte('\n') .. ',\n'
print(string.format("const char %s[] = {\n%s,\n0\n};", symbol, table.concat(line_bytes, newline_byte)))
