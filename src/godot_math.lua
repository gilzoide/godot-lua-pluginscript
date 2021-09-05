-- @file godot_math.lua  Wrapper for GDNative's math types
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
local aabb_methods = {
	fillvariant = api.godot_variant_new_aabb,
	varianttype = GD.TYPE_AABB,

	new = api.godot_aabb_new,
	as_string = function(self)
		return ffi_gc(api.godot_aabb_as_string(self), api.godot_string_destroy)
	end,
	get_area = api.godot_aabb_get_area,
	has_no_area = api.godot_aabb_has_no_area,
	has_no_surface = api.godot_aabb_has_no_surface,
	intersects = api.godot_aabb_intersects,
	encloses = api.godot_aabb_encloses,
	merge = api.godot_aabb_merge,
	intersection = api.godot_aabb_intersection,
	intersects_plane = api.godot_aabb_intersects_plane,
	intersects_segment = api.godot_aabb_intersects_segment,
	has_point = api.godot_aabb_has_point,
	get_support = api.godot_aabb_get_support,
	get_longest_axis = api.godot_aabb_get_longest_axis,
	get_longest_axis_index = api.godot_aabb_get_longest_axis_index,
	get_longest_axis_size = api.godot_aabb_get_longest_axis_size,
	get_shortest_axis = api.godot_aabb_get_shortest_axis,
	get_shortest_axis_index = api.godot_aabb_get_shortest_axis_index,
	get_shortest_axis_size = api.godot_aabb_get_shortest_axis_size,
	expand = api.godot_aabb_expand,
	grow = api.godot_aabb_grow,
	get_endpoint = api.godot_aabb_get_endpoint,
}

AABB = ffi_metatype('godot_aabb', {
	__tostring = gd_tostring,
	__index = aabb_methods,
	__concat = concat_gdvalues,
	__eq = function(a, b)
		return a.position == b.position and a.size == b.size
	end,
})

local transform2d_methods = {
	fillvariant = api.godot_variant_new_transform2d,
	varianttype = GD.TYPE_TRANSFORM2D,

	new = api.godot_transform2d_new,
	new_axis_origin = api.godot_transform2d_new_axis_origin,
	as_string = function(self)
		return ffi_gc(api.godot_transform2d_as_string(self), api.godot_string_destroy)
	end,
	inverse = api.godot_transform2d_inverse,
	affine_inverse = api.godot_transform2d_affine_inverse,
	get_rotation = api.godot_transform2d_get_rotation,
	get_origin = api.godot_transform2d_get_origin,
	get_scale = api.godot_transform2d_get_scale,
	orthonormalized = api.godot_transform2d_orthonormalized,
	rotated = api.godot_transform2d_rotated,
	scaled = api.godot_transform2d_scaled,
	translated = api.godot_transform2d_translated,
	xform_vector2 = api.godot_transform2d_xform_vector2,
	xform_inv_vector2 = api.godot_transform2d_xform_inv_vector2,
	basis_xform_vector2 = api.godot_transform2d_basis_xform_vector2,
	basis_xform_inv_vector2 = api.godot_transform2d_basis_xform_inv_vector2,
	interpolate_with = api.godot_transform2d_interpolate_with,
	new_identity = api.godot_transform2d_new_identity,
	xform_rect2 = api.godot_transform2d_xform_rect2,
	xform_inv_rect2 = api.godot_transform2d_xform_inv_rect2,
	xform = function(self, value)
		if ffi_istype(Vector2, value) then
			return self:xform_vector2(value)
		elseif ffi_istype(Rect2, value) then
			return self:xform_rect2(value)
		elseif ffi_istype(PoolVector2Array, value) then
			local array = PoolVector2Array()
			array:resize(#value)
			for i, v in ipairs(value) do
				array:set(i, self:xform_vector2(v))
			end
			return array
		end
	end,
	xform_inv = function(self, value)
		if ffi_istype(Vector2, value) then
			return self:xform_inv_vector2(value)
		elseif ffi_istype(Rect2, value) then
			return self:xform_inv_rect2(value)
		elseif ffi_istype(PoolVector2Array, value) then
			local array = PoolVector2Array()
			array:resize(#value)
			for i, v in ipairs(value) do
				array:set(i, self:xform_inv_vector2(v))
			end
			return array
		end
	end,
}

Transform2D = ffi_metatype('godot_transform2d', {
	__new = function(mt, x, y, origin)
		if ffi_istype(mt, x) then
			return ffi_new(mt, x)
		end
		local self = ffi_new(mt)
		if not x then
			self:new_identity()
		elseif tonumber(x) then
			self:new(x, y)
		else
			self:new_axis_origin(x, y, origin)
		end
		return self
	end,
	__tostring = gd_tostring,
	__index = transform2d_methods,
	__concat = concat_gdvalues,
	__eq = function(a, b)
		return a.elements[0] == b.elements[0] and a.elements[1] == b.elements[1] and a.elements[2] == b.elements[2]
	end,
	__mul = api.godot_transform2d_operator_multiply,
})

local transform_methods = {
	fillvariant = api.godot_variant_new_transform,
	varianttype = GD.TYPE_TRANSFORM,

	new_with_axis_origin = api.godot_transform_new_with_axis_origin,
	new = api.godot_transform_new,
	as_string = function(self)
		return ffi_gc(api.godot_transform_as_string(self), api.godot_string_destroy)
	end,
	inverse = api.godot_transform_inverse,
	affine_inverse = api.godot_transform_affine_inverse,
	orthonormalized = api.godot_transform_orthonormalized,
	rotated = api.godot_transform_rotated,
	scaled = api.godot_transform_scaled,
	translated = api.godot_transform_translated,
	looking_at = api.godot_transform_looking_at,
	xform_plane = api.godot_transform_xform_plane,
	xform_inv_plane = api.godot_transform_xform_inv_plane,
	new_identity = api.godot_transform_new_identity,
	operator_equal = api.godot_transform_operator_equal,
	operator_multiply = api.godot_transform_operator_multiply,
	xform_vector3 = api.godot_transform_xform_vector3,
	xform_inv_vector3 = api.godot_transform_xform_inv_vector3,
	xform_aabb = api.godot_transform_xform_aabb,
	xform_inv_aabb = api.godot_transform_xform_inv_aabb,
	xform = function(self, value)
		if ffi_istype(Vector3, value) then
			return self:xform_vector3(value)
		elseif ffi_istype(Plane, value) then
			return self:xform_plane(value)
		elseif ffi_istype(AABB, value) then
			return self:xform_aabb(value)
		elseif ffi_istype(PoolVector3Array, value) then
			local array = PoolVector3Array()
			array:resize(#value)
			for i, v in ipairs(value) do
				array:set(i, self:xform_vector3(v))
			end
			return array
		end
	end,
	xform_inv = function(self, value)
		if ffi_istype(Vector3, value) then
			return self:xform_inv_vector3(value)
		elseif ffi_istype(Plane, value) then
			return self:xform_inv_plane(value)
		elseif ffi_istype(AABB, value) then
			return self:xform_inv_aabb(value)
		elseif ffi_istype(PoolVector3Array, value) then
			local array = PoolVector3Array()
			array:resize(#value)
			for i, v in ipairs(value) do
				array:set(i, self:xform_inv_vector3(v))
			end
			return array
		end
	end,
}

if api_1_1 then
	transform_methods.new_with_quat = api_1_1.godot_transform_new_with_quat
end

Transform = ffi_metatype('godot_transform', {
	__new = function(mt, x, y, z, origin)
		if ffi_istype(mt, x) then
			return ffi_new(mt, x)
		end
		local self = ffi_new(mt)
		if not x then
			self:new_identity()
		elseif ffi_istype(Vector3, x) then
			self:new_with_axis_origin(x, y, z, origin)
		elseif ffi_istype(Basis, x) then
			self:new_with_basis(x, y or Vector3())
		elseif ffi_istype(Quat, x) then
			self:new_with_quat(x)
		end
		return self
	end,
	__tostring = gd_tostring,
	__index = transform_methods,
	__concat = concat_gdvalues,
	__eq = function(a, b)
		return a.basis == b.basis and a.origin == b.origin
	end,
	__mul = api.godot_transform_operator_multiply,
})
