-- @file in_editor_callbacks.lua  PluginScript Editor + Debug callbacks implementation
-- This file is part of Godot Lua PluginScript: https://github.com/gilzoide/godot-lua-pluginscript
--
-- Copyright (C) 2021 Gil Barbosa Reis.
-- 
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the “Software”), to
-- deal in the Software without restriction, including without limitation the
-- rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
-- sell copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
-- 
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
-- 
-- THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
-- FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
-- IN THE SOFTWARE.
local ffi = require 'ffi'

local pluginscript_callbacks = debug.getregistry().lps_callbacks
local wrap_callback = pluginscript_callbacks.wrap_callback

-- void (*)(const godot_string *class_name, const godot_string *base_class_name, godot_string *ret)
pluginscript_callbacks.get_template_source_code = wrap_callback(function(class_name, base_class_name, ret)
	class_name = ffi.cast('godot_string *', class_name):gsub("[^_%w]", "_")
	base_class_name = ffi.cast('godot_string *', base_class_name)
	ret = ffi.cast('godot_string *', ret)

	ret[0] = ffi.gc(String('local ' .. class_name .. ' = {\n\textends = "' .. base_class_name .. '",\n}\n\nreturn ' .. class_name), nil)
end)

-- godot_bool (*)(const godot_string *script, int *line_error, int *col_error, godot_string *test_error, const godot_string *path, godot_pool_string_array *functions)
pluginscript_callbacks.validate = wrap_callback(function(script, line_error, col_error, test_error, path, functions)
	script = ffi.cast('godot_string *', script)
	line_error = ffi.cast('int *', line_error)
	col_error = ffi.cast('int *', col_error)
	test_error = ffi.cast('godot_string *', test_error)
	path = ffi.cast('godot_string *', path)
	functions = ffi.cast('godot_pool_string_array *', functions)

	local f, err = loadstring(tostring(script), tostring(path))
	if not f then
		local line, msg = string.match(err, ':(%d+):%s*(.*)')
		line_error[0] = tonumber(line) or -1
		test_error[0] = ffi.gc(String(msg or err), nil)
	end
	return f ~= nil
end, true)

-- void (*)(const godot_string *class_name, const godot_string *name, const godot_pool_string_array *args, godot_string *ret)
pluginscript_callbacks.make_function = wrap_callback(function(class_name, name, args, ret)
	class_name = ffi.cast('godot_string *', class_name)
	name = ffi.cast('godot_string *', name)
	args = ffi.cast('godot_pool_string_array *', args)
	ret = ffi.cast('godot_string *', ret)

	local code = string.format('function %s:%s(%s)\n\t\nend', tostring(class_name), tostring(name), tostring(args:join(', ')))
	ret[0] = ffi.gc(String(code), nil)
end)
