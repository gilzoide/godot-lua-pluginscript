local filename, symbol = ...
assert(filename and symbol, "Usage: " .. arg[0] .. " FILENAME C_SYMBOL")

local is_debug = os.getenv("DEBUG") == "1"

local line_bytes = {}
for line in io.lines(filename ~= '-' and filename or nil) do
	if not is_debug then
		line = line:match("%s*(.*)"):gsub("%-%-.*", ""):gsub("//.*", "")
	end
	if #line > 0 then
		line = table.concat({ string.byte(line, 1, #line) }, ',') .. ','
	end
	if is_debug or #line > 0 then
		table.insert(line_bytes, line)
	end
end

local newline_byte = string.byte('\n') .. ',\n'
print(string.format("const char %s[] = {\n%s\n0\n};", symbol, table.concat(line_bytes, newline_byte)))
