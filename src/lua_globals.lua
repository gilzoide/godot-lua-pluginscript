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
_G.print = GD.print

--- Scalar types
-- @section scalar_types

--- Bool type `godot_bool`
bool = ffi_typeof('godot_bool')
--- Integer type `godot_int`
int = ffi_typeof('godot_int')
--- Float type `godot_real`
float = ffi_typeof('godot_real')


--- Extra math
-- @section extra_math

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
