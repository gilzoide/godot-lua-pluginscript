-- @file lua_string_extras.lua  Extra functionality for the `string` library
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

--- Extra functionality for Lua's `string` library.
-- @module string_extras

--- Returns a Lua string with all values joined by `separator`.
-- `tostring` is called to each of the passed values before joining.
-- @usage
--     assert(string.join(',', 1, 2, 'three', Array()) == '1,2,three,[]')
-- @function string.join
-- @tparam string sep
-- @param ...  Values to be joined, stringified by `tostring`.
-- @treturn string
local function string_join(sep, ...)
	local result = {}
	for i = 1, select('#', ...) do
		local s = select(i, ...)
		table_insert(result, tostring(s))
	end
	return table_concat(result, sep)
end
string.join = string_join

--- Quote a value, alias for `string.format("%q", tostring(value))`.
-- @function string.quote
-- @param value
-- @treturn string
local function string_quote(value)
	return string_format('%q', tostring(value))
end
string.quote = string_quote

--- Performs plain substring substitution, with no characters in `pattern` or `replacement` being considered magic.
-- @usage
--     assert(string.replace('Dot.percent.arent.magic', '.', '%') == 'Dot%percent%arent%magic')
-- @function string.replace
-- @tparam string str
-- @tparam string pattern
-- @tparam string replacement
-- @treturn string
-- @see string.gsub

