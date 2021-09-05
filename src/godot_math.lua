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
