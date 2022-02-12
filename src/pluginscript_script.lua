-- @file pluginscript_script.lua  Script metadata struct and metatype
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

--- Internal struct that wrap scripts with metadata.
--
--     typedef struct {
--       godot_string_name __path;
--       lps_lua_object __properties;
--       lps_lua_object __implementation;
--     } lps_lua_script;
--
-- @module LuaScriptWrapper
-- @local

ffi_cdef[[
typedef struct {
	godot_string_name __path;
	lps_lua_object __properties;
	lps_lua_object __implementation;
} lps_lua_script;
]]

--- Allocs and returns a pointer to a `LuaScriptWrapper`.
-- @param path  Script path
-- @tparam table properties  Known properties from script
-- @tparam table implementation  Script implementation
-- @treturn LuaScriptWrapper
local function LuaScriptWrapper_new(path, properties, implementation)
	local self = ffi_cast('lps_lua_script *', api.godot_alloc(ffi_sizeof('lps_lua_script')))
	self.__path = ffi_gc(StringName(path), nil)
	self.__properties = LuaObject(properties)
	self.__implementation = LuaObject(implementation)
	return self
end

--- Frees all memory associated with a `LuaScriptWrapper`.
-- @tparam LuaScriptWrapper script_wrapper 
local function LuaScriptWrapper_destroy(self)
	api.godot_string_name_destroy(self.__path)
	LuaObject_destroy(self.__properties)
	LuaObject_destroy(self.__implementation)
	api.godot_free(self)
end

--- @type LuaScriptWrapper
local LuaScriptWrapper = ffi_metatype('lps_lua_script', {
	--- Forwards indexing to script implementation
	-- @function __index
	-- @param index
	-- @return Value
	__index = function(self, index)
		return self.__implementation[index]
	end,
})
