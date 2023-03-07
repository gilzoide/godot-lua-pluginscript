-- @file late_globals.lua  GD table and _G metatable
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

--- Godot enumerations and functions, available globally as the `GD` table.
-- Godot global constants from `godot_get_global_constants` are also available,
-- like `OK`, `ERR_ALREADY_EXISTS`, `TYPE_NIL`, `KEY_A`, `BUTTON_LEFT`,
-- `JOY_START`, `HALIGN_CENTER` and `MIDI_MESSAGE_NOTE_OFF`.
-- @module GD

GD = {
	--- (`const godot_gdnative_core_api_struct *`) GDNative core API 1.0
	api = api,
	--- (`const godot_gdnative_core_1_1_api_struct *`) GDNative core API 1.1
	api_1_1 = api_1_1,
	--- (`const godot_gdnative_core_1_2_api_struct *`) GDNative core API 1.2
	api_1_2 = api_1_2,
	--- (`Object`) [GDNativeLibrary](https://docs.godotengine.org/en/stable/classes/class_gdnativelibrary.html) instance
	gdnativelibrary = gdnativelibrary,
	--- `Enumerations.Error`
	Error = Error,
	--- `Enumerations.VariantType`
	VariantType = VariantType,
	--- `Enumerations.CallError`
	CallError = CallError,
	--- `Enumerations.RPCMode`
	RPCMode = RPCMode,
	--- `Enumerations.PropertyHint`
	PropertyHint = PropertyHint,
	--- `Enumerations.PropertyUsage`
	PropertyUsage = PropertyUsage,
	--- Project version: 0.5.2
	_VERSION = '0.5.2',
}

local global_constants = api.godot_get_global_constants()
for k, v in pairs(global_constants) do
	GD[k:to_ascii()] = v
end
api.godot_dictionary_destroy(global_constants)

--- Convert any value to a `godot_string`.
-- If `value` is already a `godot_string`, return it unmodified.
-- Otherwise, constructs a Variant and calls `as_string` on it.
-- @function GD.str
-- @param value  Value to be stringified
-- @treturn String
GD.str = str

--- Returns the Lua script instance associated with an `Object`, if it
-- has a Lua Script attached.
-- @function GD.get_lua_instance
-- @tparam Object  object
-- @treturn[1] LuaScriptInstance
-- @treturn[2] nil  If Object has no Lua Script attached
GD.get_lua_instance = get_lua_instance

--- Print a message to Godot's Output panel, with values separated by tabs
function GD.print(...)
	local message = String(string_join('\t', ...))
	api.godot_print(message)
end
_G.print = GD.print

--- Print a warning to Godot's Output panel, with values separated by tabs
function GD.print_warning(...)
	local info = debug_getinfo(2, 'nSl')
	local message = string_join('\t', ...)
	api.godot_print_warning(message, info.name, info.short_src, info.currentline)
end

--- Print an error to Godot's Output panel, with values separated by tabs
function GD.print_error(...)
	local info = debug_getinfo(2, 'nSl')
	local message = string_join('\t', ...)
	api.godot_print_error(message, info.name, info.short_src, info.currentline)
end

local ResourceLoader = api.godot_global_get_singleton("ResourceLoader")
--- Loads a Resource by path, similar to GDScript's [load](https://docs.godotengine.org/en/stable/classes/class_%40gdscript.html#class-gdscript-method-load)
function GD.load(path)
	return ResourceLoader:load(path)
end


--- Yield the current running Lua thread, returning a wrapper Object with the `lps_coroutine.lua` script attached.
-- If an `object` and `signal_name` are passed, this coroutine will resume automatically when object emits the signal.
-- If the same coroutine yields more than once, the same object will be returned.
-- This is similar to GDScript's [yield](https://docs.godotengine.org/en/stable/classes/class_%40gdscript.html#class-gdscript-method-yield).
-- @usage
--     -- self is a Node
--     GD.yield(self:get_tree():create_timer(2), "timeout")
--     print('2 seconds have passed!')
-- @tparam[opt] Object object
-- @tparam[opt] string|String|StringName signal_name
-- @return Value passed to coroutine object's `resume` call, if any
-- @see lps_coroutine.lua
function GD.yield(object, signal_name)
	local co, is_main = coroutine_running()
	assert(co and not is_main, "GD.yield can be called only from script methods")
	local co_obj = get_script_instance_for_lua_object(co)
	if object and signal_name then
		object:connect(signal_name, co_obj, "resume", Array(), Object.CONNECT_ONESHOT)
	end
	return coroutine_yield(co_obj)
end

local Engine = api.godot_global_get_singleton("Engine")
setmetatable(_G, {
	__index = function(self, key)
		local gd_key = String(key)
		if Engine:has_singleton(gd_key) then
			local singleton = api.godot_global_get_singleton(key)
			rawset(self, key, singleton)
			return singleton
		end
		local cls = ClassWrapper_cache[key]
		if cls then
			rawset(self, key, cls)
			return cls
		end
	end,
})

-- References are already got, just register them globally
_G.Engine = Engine
_G.ClassDB = ClassDB
_G.ResourceLoader = ResourceLoader
-- These classes are registered with a prepending "_" in ClassDB
File = ClassWrapper_cache._File
Directory = ClassWrapper_cache._Directory
Thread = ClassWrapper_cache._Thread
Mutex = ClassWrapper_cache._Mutex
Semaphore = ClassWrapper_cache._Semaphore
