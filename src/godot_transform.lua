-- @file godot_transform.lua  Wrapper for GDNative's Transform
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

--- Transform metatype, wrapper for `godot_transform`.
-- Constructed using the idiom `Transform(...)`, which calls `__new`.
--     typedef union godot_transform {
--         uint8_t data[48];
--         float elements[12];
--         struct { Basis basis; Vector3 origin; };
--     } godot_transform;
-- @classmod Transform

local methods = {
	fillvariant = api.godot_variant_new_transform,
	varianttype = VariantType.Transform,

	--- Returns the inverse of the transform, under the assumption that the transformation is composed of rotation and translation (no scaling, use `affine_inverse` for transforms with scaling).
	-- @function inverse
	-- @treturn Transform
	inverse = api.godot_transform_inverse,
	--- Returns the inverse of the transform, under the assumption that the transformation is composed of rotation, scaling and translation.
	-- @function affine_inverse
	-- @treturn Transform
	affine_inverse = api.godot_transform_affine_inverse,
	--- Returns the transform with the basis orthogonal (90 degrees), and normalized axis vectors.
	-- @function orthonormalized
	-- @treturn Transform
	orthonormalized = api.godot_transform_orthonormalized,
	--- Rotates the transform around the given `axis` by the given `angle` (in radians), using matrix multiplication.
	-- The axis must be a normalized vector.
	-- @function rotated
	-- @tparam Vector3 axis
	-- @tparam number angle
	-- @treturn Transform
	rotated = api.godot_transform_rotated,
	--- Scales basis and origin of the transform by the given `scale` factor, using matrix multiplication.
	-- @function scaled
	-- @tparam Vector3 scale
	-- @treturn Transform
	scaled = api.godot_transform_scaled,
	--- Translates the transform by the given `offset`, relative to the transform's basis vectors.
	-- Unlike rotated and scaled, this does not use matrix multiplication.
	-- @function treturn
	-- @tparam Vector3 offset
	-- @treturn Transform
	translated = api.godot_transform_translated,
	--- Returns a copy of the transform rotated such that its -Z axis points towards the `target` position.
	-- The transform will first be rotated around the given up vector, and then fully aligned to the `target` by a further rotation around an axis perpendicular to both the `target` and `up` vectors.
	-- Operations take place in global space.
	-- @function looking_at
	-- @tparam Vector3 target
	-- @tparam Vector3 up
	-- @treturn Transform
	looking_at = api.godot_transform_looking_at,
	--- Transforms the given Plane
	-- @function xform_plane
	-- @tparam Plane plane
	-- @treturn Plane
	-- @see xform
	xform_plane = api.godot_transform_xform_plane,
	--- Inverse-transforms the given Plane
	-- @function xform_inv_plane
	-- @tparam Plane plane
	-- @treturn Plane
	-- @see xform
	xform_inv_plane = api.godot_transform_xform_inv_plane,
	--- Transforms the given Vector3
	-- @function xform_vector3
	-- @tparam Vector3 vector
	-- @treturn Vector3
	-- @see xform
	xform_vector3 = api.godot_transform_xform_vector3,
	--- Inverse-transforms the given Vector3
	-- @function xform_inv_vector3
	-- @tparam Vector3 vector
	-- @treturn Vector3
	-- @see xform
	xform_inv_vector3 = api.godot_transform_xform_inv_vector3,
	--- Transforms the given AABB
	-- @function xform_aabb
	-- @tparam AABB aabb
	-- @treturn AABB
	-- @see xform
	xform_aabb = api.godot_transform_xform_aabb,
	--- Inverse-transforms the given AABB
	-- @function xform_inv_aabb
	-- @tparam AABB aabb
	-- @treturn AABB
	-- @see xform
	xform_inv_aabb = api.godot_transform_xform_inv_aabb,
	--- Transforms the given `Vector3`, `Plane`, `AABB`, or `PoolVector3Array` by this transform.
	-- @function xform
	-- @tparam Vector3|Plane|AABB|PoolVector3Array value
	-- @treturn Vector3|Plane|AABB|PoolVector3Array Transformed value
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
	--- Inverse-transforms the given `Vector3`, `Plane`, `AABB`, or `PoolVector3Array` by this transform.
	-- @function xform_inv
	-- @tparam Vector3|Plane|AABB|PoolVector3Array value
	-- @treturn Vector3|Plane|AABB|PoolVector3Array Transformed value
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

--- Constants
-- @section constants

--- Transform with no translation, rotation or scaling applied.
-- @field IDENTITY  Transform(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0)

--- Transform with mirroring applied perpendicular to the YZ plane.
-- @field FLIP_X  Transform(-1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0)

--- Transform with mirroring applied perpendicular to the XZ plane.
-- @field FLIP_Y  Transform(1, 0, 0, 0, -1, 0, 0, 0, 1, 0, 0, 0)

--- Transform with mirroring applied perpendicular to the XY plane.
-- @field FLIP_Z  Transform(1, 0, 0, 0, 1, 0, 0, 0, -1, 0, 0, 0)

--- @section end

methods.IDENTITY = ffi_new('godot_transform', { elements = { 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0 } })
methods.FLIP_X = ffi_new('godot_transform', { elements = { -1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0 } })
methods.FLIP_Y = ffi_new('godot_transform', { elements = { 1, 0, 0, 0, -1, 0, 0, 0, 1, 0, 0, 0 } })
methods.FLIP_Z = ffi_new('godot_transform', { elements = { 1, 0, 0, 0, 1, 0, 0, 0, -1, 0, 0, 0 } })

--- Metamethods
-- @section metamethods
Transform = ffi_metatype('godot_transform', {
	--- Transform constructor, called by the idiom `Transform(...)`.
	--
	-- * `Transform()`: `IDENTITY` transform
	-- * `Transform(Basis basis[, Vector3 origin = Vector3.ZERO])`: set `basis` and `origin`
	-- * `Transform(Quat quat[, Vector3 origin = Vector3.ZERO])`: set `basis` from quaternion and `origin`
	-- * `Transform(Vector3 euler[, Vector3 origin = Vector3.ZERO])`: set `basis` from Euler angles and `origin`
	-- * `Transform(Vector3 x, Vector3 y, Vector3 z, Vector3 origin)`: constructs the transform from the four column vectors.
	-- * `Transform(Transform other)`: returns a copy of `other`
	-- @function __new
	-- @param ...
	-- @treturn Transform
	__new = function(mt, x, y, z, origin)
		if ffi_istype(mt, x) then
			return ffi_new(mt, x)
		end
		if not x then
			return ffi_new(mt, mt.IDENTITY)
		elseif ffi_istype(Vector3, x) then
			local self = ffi_new(mt)
			api.godot_transform_new_with_axis_origin(self, x, y, z, origin)
			return self
		else
			return ffi_new(mt, { basis = Basis(x), origin = y })
		end
	end,
	__index = methods,
	--- Returns a Lua string representation of this transform.
	-- @function __tostring
	-- @treturn string
	__tostring = gd_tostring,
	--- Concatenates values.
	-- @function __concat
	-- @param a  First value, stringified with `GD.str`
	-- @param b  First value, stringified with `GD.str`
	-- @treturn String
	__concat = concat_gdvalues,
	--- Multiplication operation.
	-- Either multiply another Transform or `xform` value.
	-- @tparam Transform self
	-- @tparam Transform|Vector3|Plane|AABB|PoolVector3Array b
	-- @treturn Transform|Vector3|Plane|AABB|PoolVector3Array Transformed value
	__mul = function(self, b)
		if ffi_istype(Transform, b) then
			return api.godot_transform_operator_multiply(self, b)
		else
			return self:xform(b)
		end
	end,
	--- Equality operation
	-- If either `a` or `b` are not of type `Transform`, always return `false`.
	-- @function __eq
	-- @tparam Transform a
	-- @tparam Transform b
	-- @treturn bool
	__eq = function(a, b)
		return ffi_istype(Transform, a) and ffi_istype(Transform, b) and a.basis == b.basis and a.origin == b.origin
	end,
})
