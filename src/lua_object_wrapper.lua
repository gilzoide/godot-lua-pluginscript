-- @file lua_object_wrapper.lua  Script instances for lua objects
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

--- Helper functions for wrapping a Lua Object in a Godot Object.
-- Currently only coroutines are supported.
-- @module lua_object_wrapper
-- @local

local library_resource_dir = gdnativelibrary.resource_path:get_base_dir()

--- Global cache of Lua object wrappers
local lps_lua_object_references = setmetatable({}, weak_kv)

--- Get or create a Godot Object that wraps `lua_obj`.
-- Currently only coroutines are supported.
local function get_script_instance_for_lua_object(lua_obj)
	local ref = lps_lua_object_references[lua_obj]
	if ref ~= nil then
		return ref
	end

	local t = type(lua_obj)
	if t == 'thread' then
		lps_next_instance_data = lua_obj
		local godot_obj = GD.load(library_resource_dir:plus_file('lps_coroutine.lua')):new()
		lps_lua_object_references[lua_obj] = godot_obj
		return godot_obj
	else
		error(string_format('Lua object of type %q is not supported yet', t))
	end
end
