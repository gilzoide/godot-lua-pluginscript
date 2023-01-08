-- @file lua_globals.lua  Extra global Lua functions and basic types
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

