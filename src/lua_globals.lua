-- @file lua_globals.lua  Extra global Lua functions and basic types
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

--- Extra global Lua functions and basic types
-- @module Globals

--- Return `value` converted to light userdata with the return of `lua_topointer` 
-- @function touserdata
-- @param value  Value to be converted
-- @return Light userdata

--- Create or reuse a Lua thread (coroutine) with the given function/callable object
-- @warning Errorred threads cannot be reused
-- @function setthreadfunc
-- @tparam thread|nil thread  Thread to be reused. Pass `nil` to create a new one
-- @tparam function|table|userdata f  Function or other callable
-- @treturn thread  Reused or created thread

--- Alias for `GD.print`
-- @function print
-- @param ...

--- Search for singleton objects with `Engine:has_singleton(key)` and classes with
-- `ClassDB:class_exists(key)`.
-- Cache any values found, to avoid future calls.
-- Called when indexing the global table `_G` with a currently unknown key.
-- @function _G:__index
-- @param key
-- @treturn[1] Object  Singleton object, if `Engine:has_singleton(key)`
-- @treturn[2] OOP.ClassWrapper  Class wrapper, if `ClassDB:class_exists(key)`
-- @treturn[3] nil


--- Scalar types
-- @section scalar_types

--- Boolean type `godot_bool`
bool = ffi_typeof('godot_bool')
--- Integer type `godot_int`
int = ffi_typeof('godot_int')
--- Float type `godot_real`
float = ffi_typeof('godot_real')


--- package extras
-- @section package_extras

--- Searches for the given `name` in the given `path`. 
-- Similar to Lua's [package.searchpath](https://www.lua.org/manual/5.2/manual.html#pdf-package.searchpath),
-- but using Godot Files instead, so that paths like `res://` and `user://` are
-- supported.
--
-- `!` characters in `path` templates are replaced by the directory of the game/app
-- executable when running a standalone build (when `OS:has_feature("standalone")`)
-- or by the project's resource path otherwise (`ProjectSettings:globalize_path("res://")`).
-- @function package.searchpath
-- @param name
-- @param path
-- @param[opt="."] separator
-- @param[opt="/"] replacement


--- string extras
-- @section string_extras

local function string_join(sep, ...)
	local result = {}
	for i = 1, select('#', ...) do
		local s = select(i, ...)
		table_insert(result, tostring(s))
	end
	return table_concat(result, sep)
end

--- Returns a Lua string with all values joined by `separator`.
-- `tostring` is called to each of the passed values before joining.
-- @function string.join
-- @tparam string sep
-- @param ...  Values to be joined, stringified by `tostring`.
-- @treturn string
string.join = string_join

--- Performs plain substring substitution, with no characters in `pattern` or `replacement` being considered magic.
-- @function string.replace
-- @tparam string str
-- @tparam string pattern
-- @tparam string replacement
-- @treturn string


--- math extras
-- @section math_extras

--- Returns the value `x` clamped between an upper (`max`) and lower bounds (`min`).
-- Any values comparable by order, that is, with a less than operator, can be passed in.
-- @tparam Vector2|Vector3|Color|number x
-- @tparam Vector2|Vector3|Color|number min
-- @tparam Vector2|Vector3|Color|number max
-- @treturn Vector2|Vector3|Color|number
function math.clamp(x, min, max)
	if x < min then
		return min
	elseif x > max then
		return max
	else
		return x
	end
end

--- Linearly interpolates values `from` and `to` by `amount`.
-- Equivalent to `from + (amount * (to - from))`.
-- @tparam Vector2|Vector3|Color|Quat|number from
-- @tparam Vector2|Vector3|Color|Quat|number to
-- @tparam number amount
-- @treturn Vector2|Vector3|Color|Quat|number
function math.lerp(from, to, amount)
	return from + (amount * (to - from))
end
