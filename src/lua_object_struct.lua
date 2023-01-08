-- @file lua_object_struct.lua  Helper struct for storing Lua references
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

--- Internal struct to store references to Lua objects, like tables and coroutines.
-- 
-- References are stored in a global cache table, indexed by their own address,
-- and are only unreferenced when `LuaObject_destroy` is called.
-- Thus this struct must used with care.
--
-- This is used internally for having `LuaScript` and `LuaScriptInstance`
-- be structs that reference tables.
--
--     typedef struct {
--       void *__address;
--     } lps_lua_object;
--
-- @module LuaObject

ffi_cdef[[
typedef struct {
	void *__address;
} lps_lua_object;
]]

local lps_lua_objects = {}

--- Helper function to convert a `void *` to a table index.
local function pointer_to_index(ptr)
	return tonumber(ffi_cast('uintptr_t', ptr))
end

--- Gets the Lua object referenced by a LuaObject
local function LuaObject_get(self)
	return lps_lua_objects[pointer_to_index(self.__address)]
end

--- Sets the Lua object referenced by a LuaObject
-- @tparam LuaObject self 
-- @param value
local function LuaObject_set(self, value)
	lps_lua_objects[pointer_to_index(self.__address)] = value
end

--- Unreference the Lua object, removing it from cache.
-- @see lps_lua_objects
local function LuaObject_destroy(self)
	LuaObject_set(self, nil)
end

--- @type LuaObject
local LuaObject = ffi_metatype('lps_lua_object', {
	--- Wrapped reference memory address
	-- @tfield void* __address

	--- LuaObject constructor, called by the idiom `LuaObject(obj)`.
	--
	-- This registers the object in the global cache table, indexed by its
	-- own address.
	-- @function __new
	-- @param obj  Lua object
	-- @local
	__new = function(mt, obj)
		local self = ffi_new(mt, touserdata(obj))
		LuaObject_set(self, obj)
		return self
	end,
	--- Forwards indexing to referenced Lua object
	-- @function __index
	-- @param index
	-- @return value
	__index = function(self, index)
		return LuaObject_get(self)[index]
	end,
	--- Forwards indexing to referenced Lua object
	-- @function __newindex
	-- @param index
	-- @param value
	__newindex = function(self, index, value)
		LuaObject_get(self)[index] = value
	end,
	--- Forwards length operator to referenced Lua object
	-- @function __len
	-- @return Object length, if supported
	__len = function(self)
		return #LuaObject_get(self)
	end,
	--- Forwards `pairs` to referenced Lua object
	-- @function __pairs
	__pairs = function(self)
		return pairs(LuaObject_get(self))
	end,
	--- Forwards `ipairs` to referenced Lua object
	-- @function __ipairs
	__ipairs = function(self)
		return ipairs(LuaObject_get(self))
	end,
	--- Forwards call to referenced Lua object
	-- @function __call
	-- @param ...
	__call = function(self, ...)
		return LuaObject_get(self)(...)
	end,
})
