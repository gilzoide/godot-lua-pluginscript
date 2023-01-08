-- @file pluginscript_instance.lua  Script instances struct and metatype
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

--- Script instance metatable, the Lua side of a Lua script instance.
-- These are created when a PluginScript is instanced and are only directly
-- accessible in the script's functions as the `self` parameter or gotten from
-- `Object`s using `GD.get_lua_instance`.
-- 
--     typedef struct {
--       godot_object *__owner;
--       lps_lua_script *__script;
--       lps_lua_object __data;
--     } lps_script_instance;
--
-- @module LuaScriptInstance

ffi_cdef[[
typedef struct {
	godot_object *__owner;
	lps_lua_script *__script;
	lps_lua_object __data;
} lps_script_instance;
]]

--- Allocs and returns a pointer to a `LuaScriptInstance`.
-- @tparam Object owner
-- @tparam table script
-- @param[opt={}] data
local function LuaScriptInstance_new(owner, script, data)
	local self = ffi_cast('lps_script_instance *', api.godot_alloc(ffi_sizeof('lps_script_instance')))
	self.__owner = owner
	self.__script = script
	self.__data = LuaObject(data or {})
	return self
end

--- Frees all memory associated with a `LuaScriptInstance`.
-- @tparam LuaScriptInstance self
local function LuaScriptInstance_destroy(self)
	LuaObject_destroy(self.__data)
	api.godot_free(self)
end

local methods = {
	fillvariant = function(var, self)
		api.godot_variant_new_object(var, self.__owner)
	end,
	varianttype = VariantType.Object,

	--- Get a value from `__data`, bypassing the check for getters.
	-- @function rawget
	-- @param index
	-- @return
	rawget = function(self, index)
		return self.__data[index]
	end,
	--- Sets a value on the `__data`, bypassing the check for setters.
	-- @function rawset
	-- @param index
	-- @param value
	rawset = function(self, index, value)
		self.__data[index] = value
	end,
}
LuaScriptInstance = ffi_metatype('lps_script_instance', {
	--- `Object` that this script instance is attached to.
	-- This is the Godot side of the instance.
	-- @tfield Object __owner
	
	--- `LuaScript` for instance, the one returned by the Lua script when
	-- loading it as a PluginScript. Note that calling `Object:get_script` will
	-- return an `Object` rather than this wrapper.
	-- @tfield LuaScript __script
	
	--- `LuaObject` that references an internal table for holding arbitrary data.
	-- @tfield LuaObject __data
	
	--- Try indexing `__owner`, then `__data`, then `__script`.
	-- @function __index
	-- @param key
	-- @return
	-- @see Object.__index
	__index = function(self, key)
		local value = methods[key]
		if is_not_nil(value) then return value end
		local script_value = self.__script[key]
		if type(script_value) == 'function' then return script_value end
		value = self.__owner[key]
		if is_not_nil(value) then return value end
		value = self.__data[key]
		if is_not_nil(value) then return value end
		return script_value
	end,
	--- Calls `Object:set` if `key` is the name of a property known to base class, `rawset` otherwise.
	-- @function __newindex
	-- @param key
	-- @param value
	__newindex = function(self, key, value)
		if self.__script:has_property(key) then
			Object_set(self.__owner, key, value)
		else
			self:rawset(key, value)
		end
	end,
	--- Returns a Lua string representation of `__owner`, as per `Object:to_string`.
	-- @function __tostring
	-- @treturn string
	__tostring = function(self)
		return tostring(self.__owner)
	end,
	--- Concatenates values.
	-- @function __concat
	-- @param a  First value, stringified with `GD.str`
	-- @param b  First value, stringified with `GD.str`
	-- @treturn String
	__concat = concat_gdvalues,
})
