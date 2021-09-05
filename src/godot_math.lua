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
local plane_methods = {
	fillvariant = api.godot_variant_new_plane,
	varianttype = GD.TYPE_PLANE,

	new_with_reals = api.godot_plane_new_with_reals,
	new_with_vectors = api.godot_plane_new_with_vectors,
	new_with_normal = api.godot_plane_new_with_normal,
	as_string = function(self)
		return ffi_gc(api.godot_plane_as_string(self), api.godot_string_destroy)
	end,
	normalized = api.godot_plane_normalized,
	center = api.godot_plane_center,
	get_any_point = api.godot_plane_get_any_point,
	is_point_over = api.godot_plane_is_point_over,
	distance_to = api.godot_plane_distance_to,
	has_point = api.godot_plane_has_point,
	project = api.godot_plane_project,
	intersect_3 = function(self, b, c)
		local dest = Vector3()
		if api.godot_plane_intersect_3(self, dest, b, c) then
			return dest
		else
			return nil
		end
	end,
	intersects_ray = function(self, from, dir)
		local dest = Vector3()
		if api.godot_plane_intersects_ray(self, dest, from, dir) then
			return dest
		else
			return nil
		end
	end,
	intersects_segment = function(self, begin, end_)
		local dest = Vector3()
		if api.godot_plane_intersects_segment(self, dest, begin, end_) then
			return dest
		else
			return nil
		end
	end,
}

Plane = ffi_metatype('godot_plane', {
	__new = function(mt, a, b, c, d)
		if ffi_istype(mt, a) then
			return ffi_new(mt, a)
		end
		local self = ffi_new(mt)
		if ffi_istype(Vector3, a) then
			if ffi.istype(Vector3, b) then
				self:new_with_vectors(self, a, b, c)
			else
				self:new_with_normal(a, b)
			end
		else
			self:new_with_reals(a, b, c, d)
		end
		return self
	end,
	__tostring = gd_tostring,
	__index = plane_methods,
	__concat = concat_gdvalues,
	__unm = function(self)
		return api.godot_plane_operator_neg(self)
	end,
	__eq = function(a, b)
		return a.d == b.d and a.normal == b.normal
	end,
})

local quat_methods = {
	fillvariant = api.godot_variant_new_quat,
	varianttype = GD.TYPE_QUAT,

	new = api.godot_quat_new,
	new_with_axis_angle = api.godot_quat_new_with_axis_angle,
	as_string = function(self)
		return ffi_gc(api.godot_quat_as_string(self), api.godot_string_destroy)
	end,
	length = api.godot_quat_length,
	length_squared = api.godot_quat_length_squared,
	normalized = api.godot_quat_normalized,
	is_normalized = api.godot_quat_is_normalized,
	inverse = api.godot_quat_inverse,
	dot = api.godot_quat_dot,
	xform = api.godot_quat_xform,
	slerp = api.godot_quat_slerp,
	slerpni = api.godot_quat_slerpni,
	cubic_slerp = api.godot_quat_cubic_slerp,
}

if api_1_1 then
	quat_methods.new_with_basis = api_1_1.godot_quat_new_with_basis
	quat_methods.new_with_euler = api_1_1.godot_quat_new_with_euler
	quat_methods.set_axis_angle = api_1_1.godot_quat_set_axis_angle
end

Quat = ffi.metatype('godot_quat', {
	__new = function(mt, x, y, z, w)
		if ffi_istype(mt, x) then
			return ffi_new(mt, x)
		end
		local self = ffi_new(mt)
		if ffi_istype(Vector3, x) then
			if y then
				self:new_with_axis_angle(x, y)
			else
				self:new_with_euler(x)
			end
		elseif ffi_istype(Basis, x) then
			self:new_with_basis(self, x)
		else
			self:new(x, y, z, w or 1)
		end
		return self
	end,
	__tostring = gd_tostring,
	__index = quat_methods,
	__concat = concat_gdvalues,
	__eq = function(a, b)
		return a.x == b.x and a.y == b.y and a.z == b.z and a.w == b.w
	end,
	__add = function(a, b)
		return Quat(a.x + b.x, a.y + b.y, a.z + b.z, a.w + b.w)
	end,
	__sub = function(a, b)
		return Quat(a.x - b.x, a.y - b.y, a.z - b.z, a.w - b.w)
	end,
	__mul = function(self, s)
		return Quat(self.x * s, self.y * s, self.z * s, self.w * s)
	end,
	__div = function(self, s)
		return self * (1.0 / s)
	end,
	__unm = function(self)
		return Quat(-self.x, -self.y, -self.z, -self.w)
	end,
})

local basis_methods = {
	fillvariant = api.godot_variant_new_basis,
	varianttype = GD.TYPE_BASIS,

	new = api.godot_basis_new,
	new_with_rows = api.godot_basis_new_with_rows,
	new_with_axis_and_angle = api.godot_basis_new_with_axis_and_angle,
	new_with_euler = api.godot_basis_new_with_euler,
	new_with_euler_quat = api.godot_basis_new_with_euler_quat,
	as_string = function(self)
		return ffi_gc(api.godot_basis_as_string(self), api.godot_string_destroy)
	end,
	inverse = api.godot_basis_inverse,
	transposed = api.godot_basis_transposed,
	orthonormalized = api.godot_basis_orthonormalized,
	determinant = api.godot_basis_determinant,
	rotated = api.godot_basis_rotated,
	scaled = api.godot_basis_scaled,
	get_scale = api.godot_basis_get_scale,
	get_euler = api.godot_basis_get_euler,
	tdotx = api.godot_basis_tdotx,
	tdoty = api.godot_basis_tdoty,
	tdotz = api.godot_basis_tdotz,
	xform = api.godot_basis_xform,
	xform_inv = api.godot_basis_xform_inv,
	get_orthogonal_index = api.godot_basis_get_orthogonal_index,
	get_axis = api.godot_basis_get_axis,
	set_axis = api.godot_basis_set_axis,
	get_row = api.godot_basis_get_row,
	set_row = api.godot_basis_set_row,
}

if api_1_1 then
	basis_methods.slerp = api_1_1.godot_basis_slerp
	basis_methods.get_quat = api_1_1.godot_basis_get_quat
	basis_methods.set_quat = api_1_1.godot_basis_set_quat
	basis_methods.set_axis_angle_scale = api_1_1.godot_basis_set_axis_angle_scale
	basis_methods.set_euler_scale = api_1_1.godot_basis_set_euler_scale
	basis_methods.set_quat_scale = api_1_1.godot_basis_set_quat_scale
end

Basis = ffi.metatype('godot_basis', {
	__new = function(mt, x, y, z)
		if ffi_istype(mt, x) then
			return ffi_new(mt, x)
		end
		local self = ffi_new(mt)
		if ffi_istype(Vector3, x) then
			if ffi_istype(Vector3, y) then
				self:new_with_rows(x, y, z)
			elseif y then
				self:new_with_axis_and_angle(x, y)
			else
				self:new_with_euler(x)
			end
		elseif ffi_istype(Quat, x) then
			self:new_with_euler_quat(x)
		else
			self:new()
		end
		return self
	end,
	__tostring = gd_tostring,
	__index = basis_methods,
	__concat = concat_gdvalues,
	__eq = function(a, b)
		return a.elements[0] == b.elements[0] and a.elements[1] == b.elements[1] and a.elements[2] == b.elements[2]
	end,
	__add = function(a, b)
		return Basis(a.elements[0] + b.elements[0], a.elements[1] + b.elements[1], a.elements[2] + b.elements[2])
	end,
	__sub = function(a, b)
		return Basis(a.elements[0] - b.elements[0], a.elements[1] - b.elements[1], a.elements[2] - b.elements[2])
	end,
	__mul = function(a, b)
		if ffi_istype(Basis, a) then
			if ffi_istype(Basis, b) then
				return api.godot_basis_operator_multiply_vector(a, b)
			else
				return Basis(a.elements[0] * b, a.elements[1] * b, a.elements[2] * b)
			end
		else
			return Basis(a * b.elements[0], a * b.elements[1], a * b.elements[2])
		end
	end,
})

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
