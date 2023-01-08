-- @file pluginscript_signal.lua  Signal declarations for scripts
-- This file is part of Godot Lua PluginScript: https://github.com/gilzoide/godot-lua-pluginscript
--
-- Copyright (C) 2021-2023 Gil Barbosa Reis.
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

--- Signal declarations for scripts.
-- @module signal

--- Signal metatable, used only to check if a value is a signal.
local Signal = {}

--- Checks if `value` is a signal.
local function is_signal(value)
	return getmetatable(value) == Signal
end

--- Transforms a `Signal` into a `Dictionary`, for populating scripts metadata.
local function signal_to_dictionary(sig)
	local args = Array()
	for i = 1, #sig do
		args:append(Dictionary{ name = String(sig[i]) })
	end
	local dict = Dictionary()
	dict.args = args
	return dict
end

--- Create a signal table, only useful for declaring scripts' signals.
-- @usage
--     MyClass.something_happened = signal()
--     MyClass.something_happened_with_args = signal('arg1', 'arg2', 'etc')
-- @param ...  Signal argument names
-- @treturn table
-- @see lps_coroutine.lua
function signal(...)
	return setmetatable({ ... }, Signal)
end
