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

ffi.cdef[[
void (*lps_get_template_source_code_cb)(const godot_string *class_name, const godot_string *base_class_name, godot_string *ret);
godot_bool (*lps_validate_cb)(const godot_string *script, int *line_error, int *col_error, godot_string *test_error, const godot_string *path, godot_pool_string_array *functions);
void (*lps_make_function_cb)(const godot_string *class_name, const godot_string *name, const godot_pool_string_array *args, godot_string *ret);
]]

local wrap_callback = debug.getregistry().lps_wrap_callback
local clib = ffi.C

-- void (*lps_get_template_source_code_cb)(const godot_string *class_name, const godot_string *base_class_name, godot_string *ret)
clib.lps_get_template_source_code_cb = wrap_callback(function(class_name, base_class_name, ret)
	class_name = class_name:gsub("[^_%w]", "_")
	ret[0] = ffi.gc(String('local ' .. class_name .. ' = {\n\textends = "' .. base_class_name .. '",\n}\n\nreturn ' .. class_name), nil)
end)

-- godot_bool (*lps_validate_cb)(const godot_string *script, int *line_error, int *col_error, godot_string *test_error, const godot_string *path, godot_pool_string_array *functions)
clib.lps_validate_cb = wrap_callback(function(script, line_error, col_error, test_error, path, functions)
	script = tostring(script)
	local f, err = loadstring(script, tostring(path))
	if not f then
		local line, msg = string.match(err, ':(%d+):%s*(.*)')
		line_error[0] = tonumber(line) or -1
		test_error[0] = ffi.gc(String(msg or err), nil)
	end
	return f ~= nil
end, true)

-- void (*lps_make_function_cb)(const godot_string *class_name, const godot_string *name, const godot_pool_string_array *args, godot_string *ret)
clib.lps_make_function_cb = wrap_callback(function(class_name, name, args, ret)
	local code = string.format('function %s:%s(%s)\n\t\nend', tostring(class_name), tostring(name), tostring(args:join(', ')))
	ret[0] = ffi.gc(String(code), nil)
end)
