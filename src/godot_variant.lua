-- @file godot_variant.lua  Wrapper for GDNative's Variant
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

--- Variant metatype, wrapper for `godot_variant`.
-- Useful for interfacing directly with the GDNative API.
-- Construct using the idiom `Variant(value)`, which calls `__new`.
-- @classmod Variant

local methods = {
	fillvariant = api.godot_variant_new_copy,
	--- Alias for `GD.VariantType`
	-- @table Type
	Type = VariantType,

	--- Return the Variant as a boolean.
	-- @function as_bool
	-- @treturn bool
	as_bool = api.godot_variant_as_bool,
	--- Return the Variant as an unsigned integer.
	-- @function as_uint
	-- @treturn uint64_t
	as_uint = api.godot_variant_as_uint,
	--- Return the Variant as an integer.
	-- @function as_int
	-- @treturn int64_t
	as_int = api.godot_variant_as_int,
	--- Return the Variant as an number.
	-- @function as_real
	-- @treturn number
	as_real = api.godot_variant_as_real,
	--- Return the Variant as a `String`.
	-- @function as_string
	-- @treturn String
	as_string = function(self)
		return ffi_gc(api.godot_variant_as_string(self), api.godot_string_destroy)
	end,
	--- Return the Variant as a `Vector2`.
	-- @function as_vector2
	-- @treturn Vector2
	as_vector2 = api.godot_variant_as_vector2,
	--- Return the Variant as a `Rect2`.
	-- @function as_rect2
	-- @treturn Rect2
	as_rect2 = api.godot_variant_as_rect2,
	--- Return the Variant as a `Vector3`.
	-- @function as_vector3
	-- @treturn Vector3
	as_vector3 = api.godot_variant_as_vector3,
	--- Return the Variant as a `Transform2D`.
	-- @function as_transform2d
	-- @treturn Transform2D
	as_transform2d = api.godot_variant_as_transform2d,
	--- Return the Variant as a `Plane`.
	-- @function as_plane
	-- @treturn Plane
	as_plane = api.godot_variant_as_plane,
	--- Return the Variant as a `Quat`.
	-- @function as_quat
	-- @treturn Quat
	as_quat = api.godot_variant_as_quat,
	--- Return the Variant as an `AABB`.
	-- @function as_aabb
	-- @treturn AABB
	as_aabb = api.godot_variant_as_aabb,
	--- Return the Variant as a `Basis`.
	-- @function as_basis
	-- @treturn Basis
	as_basis = api.godot_variant_as_basis,
	--- Return the Variant as a `Transform`.
	-- @function as_transform
	-- @treturn Transform
	as_transform = api.godot_variant_as_transform,
	--- Return the Variant as a `Color`.
	-- @function as_color
	-- @treturn Color
	as_color = api.godot_variant_as_color,
	--- Return the Variant as a `NodePath`.
	-- @function as_node_path
	-- @treturn NodePath
	as_node_path = function(self)
		return ffi_gc(api.godot_variant_as_node_path(self), api.godot_node_path_destroy)
	end,
	--- Return the Variant as a `RID`.
	-- @function as_rid
	-- @treturn RID
	as_rid = api.godot_variant_as_rid,
	--- Return the Variant as an `Object`.
	-- If object is a Reference, it is automatically referenced and marked for unreferencing upon garbage-collection.
	-- @function as_object
	-- @treturn Object
	as_object = function(self)
		local obj = api.godot_variant_as_object(self)
		if obj ~= nil and Object_is_class(obj, 'Reference') and Reference_reference(obj) then
			ffi_gc(obj, Object_gc)
		end
		return obj
	end,
	--- Return the Variant as a `Dictionary`.
	-- @function as_dictionary
	-- @treturn Dictionary
	as_dictionary = function(self)
		return ffi_gc(api.godot_variant_as_dictionary(self), api.godot_dictionary_destroy)
	end,
	--- Return the Variant as a `Array`.
	-- @function as_array
	-- @treturn Array
	as_array = function(self)
		return ffi_gc(api.godot_variant_as_array(self), api.godot_array_destroy)
	end,
	--- Return the Variant as a `PoolByteArray`.
	-- @function as_pool_byte_array
	-- @treturn PoolByteArray
	as_pool_byte_array = function(self)
		return ffi_gc(api.godot_variant_as_pool_byte_array(self), api.godot_pool_byte_array_destroy)
	end,
	--- Return the Variant as a `PoolIntArray`.
	-- @function as_pool_int_array
	-- @treturn PoolIntArray
	as_pool_int_array = function(self)
		return ffi_gc(api.godot_variant_as_pool_int_array(self), api.godot_pool_int_array_destroy)
	end,
	--- Return the Variant as a `PoolRealArray`.
	-- @function as_pool_real_array
	-- @treturn PoolRealArray
	as_pool_real_array = function(self)
		return ffi_gc(api.godot_variant_as_pool_real_array(self), api.godot_pool_real_array_destroy)
	end,
	--- Return the Variant as a `PoolStringArray`.
	-- @function as_pool_string_array
	-- @treturn PoolStringArray
	as_pool_string_array = function(self)
		return ffi_gc(api.godot_variant_as_pool_string_array(self), api.godot_pool_string_array_destroy)
	end,
	--- Return the Variant as a `PoolVector2Array`.
	-- @function as_pool_vector2_array
	-- @treturn PoolVector2Array
	as_pool_vector2_array = function(self)
		return ffi_gc(api.godot_variant_as_pool_vector2_array(self), api.godot_pool_vector2_array_destroy)
	end,
	--- Return the Variant as a `PoolVector3Array`.
	-- @function as_pool_vector3_array
	-- @treturn PoolVector3Array
	as_pool_vector3_array = function(self)
		return ffi_gc(api.godot_variant_as_pool_vector3_array(self), api.godot_pool_vector3_array_destroy)
	end,
	--- Return the Variant as a `PoolColorArray`.
	-- @function as_pool_color_array
	-- @treturn PoolColorArray
	as_pool_color_array = function(self)
		return ffi_gc(api.godot_variant_as_pool_color_array(self), api.godot_pool_color_array_destroy)
	end,
	--- Returns the Variant type enum value (`enum godot_variant_type`).
	-- Use `get_type_name` or `Variant.Type` to get the type name.
	-- @function get_type
	-- @treturn int
	get_type = function(self)
		return tonumber(api.godot_variant_get_type(self))
	end,
	--- Returns the Variant type name.
	-- @function get_type_name
	-- @treturn string
	get_type_name = function(self)
		return VariantType[self:get_type()]
	end,
	--- Call method with the passed name and arguments.
	-- @function call
	-- @param method  Method name, stringified with `GD.str`
	-- @param ...  Arguments passed to method
	-- @return Method call result
	-- @see pcall
	call = function(self, method, ...)
		local argc = select('#', ...)
		local argv = ffi_new('godot_variant *[?]', argc)
		for i = 1, argc do
			local arg = select(i, ...)
			argv[i - 1] = Variant(arg)
		end
		local r_error = ffi_new('godot_variant_call_error')
		local value = ffi_gc(api.godot_variant_call(self, str(method), ffi_cast('const godot_variant **', argv), argc, r_error), api.godot_variant_destroy)
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
	--- Returns `true` if Variant has method `method`.
	-- @function has_method
	-- @param method  Method name, stringified with `GD.str`
	-- @treturn bool
	has_method = function(self, method)
		return api.godot_variant_has_method(self, str(method))
	end,
	--- Returns `true` if Variant's hash is equal to `other`'s.
	-- @function hash_compare
	-- @param other  Other value, boxed by `__new`
	-- @treturn bool
	hash_compare = function(self, other)
		return api.godot_variant_hash_compare(self, Variant(other))
	end,
	--- Unbox a Variant, returning the corresponding Lua object.
	-- @function unbox
	-- @treturn nil|bool|number|String|Vector2|Rect2|Vector3|Transform2D|Plane|Quat|AABB|Basis|Transform|Color|NodePath|RID|Object|Dictionary|Array|PoolByteArray|PoolIntArray|PoolRealArray|PoolStringArray|PoolVector2Array|PoolVector3Array|PoolColorArray
	unbox = function(self)
		local t = self:get_type()
		if t == VariantType.Nil then
			return nil
		elseif t == VariantType.Bool then
			return api.godot_variant_as_bool(self)
		elseif t == VariantType.Int then
			return tonumber(api.godot_variant_as_int(self))
		elseif t == VariantType.Real then
			return tonumber(api.godot_variant_as_real(self))
		elseif t == VariantType.String then
			return self:as_string()
		elseif t == VariantType.Vector2 then
			return api.godot_variant_as_vector2(self)
		elseif t == VariantType.Rect2 then
			return api.godot_variant_as_rect2(self)
		elseif t == VariantType.Vector3 then
			return api.godot_variant_as_vector3(self)
		elseif t == VariantType.Transform2D then
			return api.godot_variant_as_transform2d(self)
		elseif t == VariantType.Plane then
			return api.godot_variant_as_plane(self)
		elseif t == VariantType.Quat then
			return api.godot_variant_as_quat(self)
		elseif t == VariantType.AABB then
			return api.godot_variant_as_aabb(self)
		elseif t == VariantType.Basis then
			return api.godot_variant_as_basis(self)
		elseif t == VariantType.Transform then
			return api.godot_variant_as_transform(self)
		elseif t == VariantType.Color then
			return api.godot_variant_as_color(self)
		elseif t == VariantType.NodePath then
			return self:as_node_path()
		elseif t == VariantType.RID then
			return api.godot_variant_as_rid(self)
		elseif t == VariantType.Object then
			return self:as_object()
		elseif t == VariantType.Dictionary then
			return self:as_dictionary()
		elseif t == VariantType.Array then
			return self:as_array()
		elseif t == VariantType.PoolByteArray then
			return self:as_pool_byte_array()
		elseif t == VariantType.PoolIntArray then
			return self:as_pool_int_array()
		elseif t == VariantType.PoolRealArray then
			return self:as_pool_real_array()
		elseif t == VariantType.PoolStringArray then
			return self:as_pool_string_array()
		elseif t == VariantType.PoolVector2Array then
			return self:as_pool_vector2_array()
		elseif t == VariantType.PoolVector3Array then
			return self:as_pool_vector3_array()
		elseif t == VariantType.PoolColorArray then
			return self:as_pool_color_array()
		end
	end,
}

--- Make a protected call to method with the passed name and arguments.
-- @function pcall
-- @param method  Method name, stringified with `GD.str`
-- @param ...  Arguments passed to method
-- @treturn[1] bool  `true` if method was called successfully
-- @return[1] Method call result
-- @treturn[2] bool  `false` on errors
-- @return[2] Error message
-- @see call
methods.pcall = function(self, method, ...)
	return pcall(methods.call, self, method, ...)
end

Variant = ffi_metatype("godot_variant", {
	--- Variant constructor, called by the idiom `Variant(value)`.
	-- @function __new
	-- @param value  Value to be boxed
	-- @treturn Variant
	__new = function(mt, value)
		local self = ffi_new(mt)
		local t = type(value)
		if t == 'boolean' then
			api.godot_variant_new_bool(self, value)
		elseif t == 'string' or ffi_istype('char *', value) or ffi_istype('wchar_t *', value) then
			local s = String(value)
			api.godot_variant_new_string(self, s)
		elseif ffi_istype(int, value) then
			api.godot_variant_new_int(self, value)
		elseif t == 'number' or tonumber(value) then
			api.godot_variant_new_real(self, value)
		elseif t == 'table' then
			if value.fillvariant then
				value.fillvariant(self, value)
			else
				local d = Dictionary(value)
				api.godot_variant_new_dictionary(self, d)
			end
		elseif t == 'cdata' and value.fillvariant then
			value.fillvariant(self, value)
		else
			api.godot_variant_new_nil(self)
		end
		return self
	end,
	__gc = api.godot_variant_destroy,
	--- Returns a Lua `string` from the result of `as_string`.
	-- @function __tostring
	-- @treturn string
	__tostring = function(self)
		return tostring(self:as_string())
	end,
	--- Concatenates values.
	-- @function __concat
	-- @param a  First value, stringified with `GD.str`
	-- @param b  First value, stringified with `GD.str`
	-- @treturn String
	__concat = concat_gdvalues,
	__index = methods,
	--- Equality comparison (`a == b`).
	-- @function __eq
	-- @param a  First value, boxed with `__new`
	-- @param b  Second value, boxed with `__new`
	-- @treturn bool
	__eq = function(a, b)
		return api.godot_variant_operator_equal(Variant(a), Variant(b))
	end,
	--- Less than comparison (`a < b`).
	-- @function __eq
	-- @param a  First value, boxed with `__new`
	-- @param b  Second value, boxed with `__new`
	-- @treturn bool
	__lt = function(a, b)
		return api.godot_variant_operator_less(Variant(a), Variant(b))
	end,
})
