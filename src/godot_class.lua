-- @file godot_class.lua  Method Binds and generic Godot Class definitions
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

local Object_call = api.godot_method_bind_get_method('Object', 'call')
local Object_get = api.godot_method_bind_get_method('Object', 'get')
local Object_set = api.godot_method_bind_get_method('Object', 'set')
local Object_has_method = api.godot_method_bind_get_method('Object', 'has_method')
local Object_is_class = api.godot_method_bind_get_method('Object', 'is_class')
local Reference_init_ref = api.godot_method_bind_get_method('Reference', 'init_ref')
local Reference_reference = api.godot_method_bind_get_method('Reference', 'reference')
local Reference_unreference = api.godot_method_bind_get_method('Reference', 'unreference')

local function Object_gc(obj)
	if Reference_unreference(obj) then
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
		if Object_is_class(obj, 'Reference') and Reference_init_ref(obj) then
			ffi_gc(obj, Object_gc)
		end
		obj:pcall('_init', ...)
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
	--- Returns whether class has a property named `name`.
	-- Only properties from `ClassDB:class_get_property_list()` return true.
	-- @function has_property
	-- @tparam string name  Property name
	-- @treturn bool
	has_property = function(self, name)
		local cache = self.known_properties
		if not cache then
			cache = {}
			for _, prop in ipairs(ClassDB:class_get_property_list(self.class_name)) do
				cache[tostring(prop.name)] = true
			end
			self.known_properties = cache
		end
		return cache[name] ~= nil
	end,
}
local ClassWrapper = {
	new = function(self, class_name)
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

local function is_class_wrapper(v)
	return getmetatable(v) == ClassWrapper
end


local ClassWrapper_cache = setmetatable({}, {
	__index = function(self, class_name)
		if not ClassDB:class_exists(class_name) then
			return nil
		end
		class_name = tostring(class_name)
		local cls = ClassWrapper:new(class_name)
		rawset(self, class_name, cls)
		return cls
	end,
})


--- MethodBind metatype, wrapper for `godot_method_bind`.
-- These are returned by `ClassWrapper:__index` and GDNative's `godot_method_bind_get_method`.
-- @type MethodBind
local MethodBind = ffi_metatype('godot_method_bind', {
	--- Calls the method in `object`.
	-- @function __call
	-- @tparam Object object
	-- @param ...
	-- @return  Method return value
	__call = function(self, obj, ...)
		local argc = select('#', ...)
		local argv = ffi_new('godot_variant *[?]', argc)
		for i = 1, argc do
			local arg = select(i, ...)
			argv[i - 1] = Variant(arg)
		end
		local r_error = ffi_new('godot_variant_call_error')
		local value = ffi_gc(api.godot_method_bind_call(self, _Object(obj), ffi_cast('const godot_variant **', argv), argc, r_error), api.godot_variant_destroy)
		if r_error.error == CallError.OK then
			return value:unbox()
		elseif r_error.error == CallError.ERROR_INVALID_METHOD then
			error("Invalid method")
		elseif r_error.error == CallError.ERROR_INVALID_ARGUMENT then
			error(string_format("Invalid argument #%d, expected %s",
				r_error.argument + 1,
				VariantType[tonumber(r_error.expected)]
			))
		elseif r_error.error == CallError.ERROR_TOO_MANY_ARGUMENTS then
			error("Too many arguments")
		elseif r_error.error == CallError.ERROR_TOO_FEW_ARGUMENTS then
			error("Too few arguments")
		elseif r_error.error == CallError.ERROR_INSTANCE_IS_NULL then
			error("Instance is null")
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

