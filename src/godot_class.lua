-- @file godot_class.lua  Method Binds and generic Godot Class definitions
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

--- Helper metatables for interfacing with Godot's OOP.
-- None of them are available directly for creation, but are rather returned by
-- the API.
-- @module OOP

-- Stringification helpers
local function str(value)
	if ffi_istype(String, value) then
		return value
	else
		return Variant(value):as_string()
	end
end

local function gd_tostring(value)
	return tostring(str(value))
end

local function concat_gdvalues(a, b)
	return ffi_gc(api.godot_string_operator_plus(str(a), str(b)), api.godot_string_destroy)
end

-- Class/Object definitions
local ClassDB = api.godot_global_get_singleton("ClassDB")

local Variant_p_array = ffi_typeof('godot_variant *[?]')
local const_Variant_pp = ffi_typeof('const godot_variant **')
local VariantCallError = ffi_typeof('godot_variant_call_error')

local _Object  -- forward local declaration
local Object_call = api.godot_method_bind_get_method('Object', 'call')
local Object_get = api.godot_method_bind_get_method('Object', 'get')
local Object_has_method = api.godot_method_bind_get_method('Object', 'has_method')
local Object_is_class = api.godot_method_bind_get_method('Object', 'is_class')

local function Object_gc(obj)
	if Object_call(obj, 'unreference') then
		api.godot_object_destroy(obj)
	end
end

--- Wrapper for Godot Classes, used to create instances or index constants.
-- These are constructed by `_G:__index` when indexing a known class name, e.g.: `KinematicBody`.
-- @type ClassWrapper
local class_methods = {
	--- Creates a new instance of a Class, initializing with the given values.
	-- If Class inherits from Reference, the reference is initialized with
	-- `init_ref` and object is marked for `unreference`ing at garbage-collection.
	-- @function new
	-- @param ...  Parameters forwarded to a call to `_init`
	-- @treturn Object
	new = function(self, ...)
		local obj = self.constructor()
		if Object_call(obj, 'init_ref') then
			ffi_gc(obj, Object_gc)
		end
		Object_call(obj, '_init', ...)
		return obj
	end,
	--- Returns whether this Class inherits a `parent` Class.
	-- @function inherits
	-- @param other  Other class name
	-- @treturn bool
	inherits = function(self, parent)
		return ClassDB:is_parent_class(self.class_name, parent)
	end,
	--- Returns the parent class.
	-- @function get_parent_class
	-- @treturn String
	get_parent_class = function(self)
		return ClassDB:get_parent_class(self.class_name)
	end,
}
local ClassWrapper = {
	new = function(self, class_name)
		class_name = tostring(class_name)
		return setmetatable({
			--- (`string`) Class name
			class_name = class_name,
			--- (`Object (*)()`) Raw constructor function as returned by GDNative's `godot_get_class_constructor`.
			-- This is used by `new` and should probably not be used directly.
			-- @see new
			constructor = api.godot_get_class_constructor(class_name),
		}, self)
	end,
	--- Returns a `MethodBind` if class has a method with that name, or an integer
	-- constant if there is any.
	-- @function __index
	-- @param key
	-- @treturn[1] MethodBind  If `ClassDB:class_has_method(self.class_name, key)`
	-- @treturn[2] int  If `ClassDB:class_has_integer_constant(self.class_name, key)`
	-- @treturn[3] nil
	__index = function(self, key)
		local method = class_methods[key]
		if method then return method end
		local method_bind = api.godot_method_bind_get_method(self.class_name, key)
		if method_bind ~= nil then
			rawset(self, key, method_bind)
			return method_bind
		end
		local varkey = Variant(key)
		if ClassDB:class_has_integer_constant(self.class_name, varkey) then
			local constant = ClassDB:class_get_integer_constant(self.class_name, varkey)
			rawset(self, key, constant)
			return constant
		end
	end,
	--- Returns `class_name`
	-- @function __tostring
	-- @treturn string
	__tostring = function(self)
		return self.class_name
	end,
}

local function wrapper_for_class(class_name)
	if ClassDB:class_exists(class_name) then
		return ClassWrapper:new(class_name)
	end
end

local function is_class_wrapper(v)
	return getmetatable(v) == ClassWrapper
end

--- MethodBind metatype, wrapper for `godot_method_bind`.
-- These are returned by `ClassWrapper:__index` and GDNative's `godot_method_bind_get_method`.
-- @type MethodBind
local MethodBind = ffi.metatype('godot_method_bind', {
	--- Calls the method in `object`.
	-- @function __call
	-- @tparam Object object
	-- @param ...
	-- @return[1]  Method return value
	-- @treturn[2] nil  If call errored
	__call = function(self, obj, ...)
		local argc = select('#', ...)
		local argv = ffi_new(Variant_p_array, argc)
		for i = 1, argc do
			local arg = select(i, ...)
			argv[i - 1] = Variant(arg)
		end
		local r_error = ffi_new(VariantCallError)
		local value = ffi_gc(api.godot_method_bind_call(self, _Object(obj), ffi_cast(const_Variant_pp, argv), argc, r_error), api.godot_variant_destroy)
		if r_error.error == CallError.OK then
			return value:unbox()
		else
			return nil
		end
	end,
})


--- A method binding object that calls a method by name, as `object:call(method_name, ...)`.
-- These are returned by `Object.__index` if `object:has_method(method_name)` is true.
-- @type MethodBindByName
local MethodBindByName = {
	--- Create a new method binding by name.
	-- @usage
	--     local method_bind = MethodBindByName:new(method_name)
	--     method_bind(object, ...)
	-- @function new
	-- @tparam string method_name
	-- @treturn MethodBindByName
	new = function(self, method_name)
		return setmetatable({
			--- (`string`) Method name.
			method_name = method_name
		}, self)
	end,
	--- Returns the result of `object:call(self.method_name, ...)`.
	-- @function __call
	-- @tparam Object|ScriptInstance|Variant object
	-- @param ...
	__call = function(self, obj, ...)
		return obj:call(self.method_name, ...)
	end,
}


--- Script instance metatable, the Lua side of a Lua script instance.
-- These are created when a PluginScript is instanced and are only directly
-- accessible in the script's functions as the `self` parameter.
-- @type ScriptInstance
local instance_methods = {
	fillvariant = function(var, self)
		api.godot_variant_new_object(var, rawget(self, '__owner'))
	end,
	--- Forwards a call to `__owner` using `Object:pcall`.
	-- @function pcall
	-- @param method  Method name
	-- @param ...
	-- @treturn[1] bool `true` if method exists
	-- @return[1] Method result
	-- @treturn[2] bool `false` if method does not exist
	-- @see Object.pcall
	pcall = function(self, ...)
		return rawget(self, '__owner'):pcall(...)
	end,
	--- Forwards a call to `__owner` using `Object:call`.
	-- @function call
	-- @param method  Method name
	-- @param ...
	-- @return[1] Method result
	-- @treturn[2] nil  If method does not exist or errors
	-- @see Object.call
	call = function(self, ...)
		return rawget(self, '__owner'):call(...)
	end,
}
local ScriptInstance = {
	--- `Object` that this script instance is attached to.
	-- This is the Godot side of the instance.
	-- @field __owner
	
	--- Lua script table, the one returned by the Lua script when loading it as a PluginScript.
	-- Note that calling `Object:get_script` will return an `Object` rather
	-- than this table.
	-- @field __script
	
	--- Try indexing `__script`, then `__owner`.
	-- @function __index
	-- @param key
	-- @return
	-- @see Object.__index
	__index = function(self, key)
		local script_value = instance_methods[key] or rawget(self, '__script')[key]
		if script_value ~= nil then return script_value end
		return rawget(self, '__owner')[key]
	end,
	--- Returns a Lua string representation of `__owner`, as per `Object:to_string`.
	-- @function __tostring
	-- @treturn string
	__tostring = function(self)
		return tostring(rawget(self, '__owner'))
	end,
	--- Concatenates values.
	-- @function __concat
	-- @param a  First value, stringified with `GD.str`
	-- @param b  First value, stringified with `GD.str`
	-- @treturn String
	__concat = concat_gdvalues,
}

