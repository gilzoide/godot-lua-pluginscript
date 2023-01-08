-- @file godot_transform2d.lua  Wrapper for GDNative's Transform2D
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

--- Transform2D metatype, wrapper for `godot_transform2d`.
-- Constructed using the idiom `Transform2D(...)`, which calls `__new`.
--     typedef union godot_transform2d {
--         uint8_t data[24];
--         float elements[6];
--         Vector2 columns[3];
--         struct { Vector2 x, y, origin; };
--     } godot_transform2d;
-- @classmod Transform2D

local methods = {
	fillvariant = api.godot_variant_new_transform2d,
	varianttype = VariantType.Transform2D,

	--- Returns the inverse of the transform, under the assumption that the transformation is composed of rotation and translation (no scaling, use `affine_inverse` for transforms with scaling).
	-- @function inverse
	-- @treturn Transform2D
	-- @see affine_inverse
	inverse = api.godot_transform2d_inverse,
	--- Returns the inverse of the transform, under the assumption that the transformation is composed of rotation, scaling and translation.
	-- @function affine_inverse
	-- @treturn Transform2D
	affine_inverse = api.godot_transform2d_affine_inverse,
	--- Returns the transform's rotation (in radians).
	-- @function get_rotation
	-- @treturn number
	get_rotation = api.godot_transform2d_get_rotation,
	--- Returns the transform's origin (translation).
	-- @function get_origin
	-- @treturn Vector2
	get_origin = api.godot_transform2d_get_origin,
	--- Returns the scale.
	-- @function get_scale
	-- @treturn Vector2
	get_scale = api.godot_transform2d_get_scale,
	--- Returns the transform with the basis orthogonal (90 degrees), and normalized axis vectors (scale of 1 or -1).
	-- @function orthonormalized
	-- @treturn Transform2D
	orthonormalized = api.godot_transform2d_orthonormalized,
	--- Rotates the transform by the given `angle` (in radians), using matrix multiplication.
	-- @function rotated
	-- @tparam number angle
	-- @treturn Transform2D
	rotated = api.godot_transform2d_rotated,
	--- Scales the transform by the given `scale` factor, using matrix multiplication.
	-- @function scaled
	-- @tparam Vector2 scale
	-- @treturn Transform2D
	scaled = api.godot_transform2d_scaled,
	--- Translates the transform by the given `offset`, relative to the transform's basis vectors.
	-- Unlike rotated and scaled, this does not use matrix multiplication.
	-- @function translated
	-- @tparam Vector2 offset
	-- @treturn Transform2D
	translated = api.godot_transform2d_translated,
	--- Transforms the given Vector2.
	-- @function xform_vector2
	-- @tparam Vector2 vector
	-- @treturn Vector2
	-- @see xform
	xform_vector2 = api.godot_transform2d_xform_vector2,
	--- Inverse-transforms the given Vector2.
	-- @function xform_inv_vector2
	-- @tparam Vector2 vector
	-- @treturn Vector2
	-- @see xform_inv
	xform_inv_vector2 = api.godot_transform2d_xform_inv_vector2,
	--- Returns a vector transformed (multiplied) by the basis matrix.
	-- This method does not account for translation (the origin vector).
	-- @function basis_xform_vector2
	-- @tparam Vector2 vector
	-- @treturn Vector2
	basis_xform = api.godot_transform2d_basis_xform_vector2,
	--- Returns a vector transformed (multiplied) by the inverse basis matrix.
	-- This method does not account for translation (the origin vector).
	-- @function basis_xform_inv
	-- @tparam Vector2 vector
	-- @treturn Vector2
	basis_xform_inv = api.godot_transform2d_basis_xform_inv_vector2,
	--- Returns a transform interpolated between this transform and another by a given `weight` (on the range of 0.0 to 1.0).
	-- @function interpolate_with
	-- @tparam Transform2D transform
	-- @tparam number weight
	interpolate_with = api.godot_transform2d_interpolate_with,
	--- Transforms the given Rect2.
	-- @function xform_rect2
	-- @tparam Rect2 vector
	-- @treturn Rect2
	-- @see xform
	xform_rect2 = api.godot_transform2d_xform_rect2,
	--- Inverse-transforms the given Rect2.
	-- @function xform_inv_rect2
	-- @tparam Rect2 vector
	-- @treturn Rect2
	-- @see xform_inv
	xform_inv_rect2 = api.godot_transform2d_xform_inv_rect2,
	--- Transforms the given `Vector2`, `Rect2`, or `PoolVector2Array` by this transform.
	-- @function xform
	-- @tparam Vector2|Rect2|PoolVector2Array value
	-- @treturn Vector2|Rect2|PoolVector2Array Transformed value
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
	--- Inverse-transforms the given `Vector2`, `Rect2`, or `PoolVector2Array` by this transform.
	-- @function xform_inv
	-- @tparam Vector2|Rect2|PoolVector2Array value
	-- @treturn Vector2|Rect2|PoolVector2Array Transformed value
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

--- Constants
-- @section constants

--- The identity Transform2D with no translation, rotation or scaling applied.
-- @field IDENTITY  Transform2D(1, 0, 0, 1, 0, 0)

--- The Transform2D that will flip something along the X axis.
-- @field FLIP_X  Transform2D(-1, 0, 0, 1, 0, 0)

--- The Transform2D that will flip something along the Y axis.
-- @field FLIP_Y  Transform2D(1, 0, 0, -1, 0, 0)

--- @section end

methods.IDENTITY = ffi_new('godot_transform2d', { elements = { 1, 0, 0, 1, 0, 0 } })
methods.FLIP_X = ffi_new('godot_transform2d', { elements = { -1, 0, 0, 1, 0, 0 } })
methods.FLIP_Y = ffi_new('godot_transform2d', { elements = { 1, 0, 0, -1, 0, 0 } })

--- Metamethods
-- @section metamethods
Transform2D = ffi_metatype('godot_transform2d', {
	--- Transform2D constructor, called by the idiom `Transform2D(...)`.
	--
	-- * `Transform2D()`: creates an `IDENTITY` transform.
	-- * `Transform2D(number angle, Vector2 position)`: constructs the transform from a given angle (in radians) and position.
	-- * `Transform2D(Vector2 x, Vector2 y, Vector2 origin)`: constructs the transform from the three column vectors.
	-- * `Transform2D(Transform2D other)`: returns a copy of `other`
	-- @function __new
	-- @param ...
	-- @treturn Transform2D
	__new = function(mt, x, y, origin)
		if ffi_istype(mt, x) then
			return ffi_new(mt, x)
		end
		local self = ffi_new(mt)
		if not x then
			api.godot_transform2d_new_identity(self)
		elseif tonumber(x) then
			api.godot_transform2d_new(self, x, y)
		else
			api.godot_transform2d_new_axis_origin(self, x, y, origin)
		end
		return self
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
	-- Either multiply another Transform2D or `xform` value.
	-- @tparam Transform2D self
	-- @tparam Transform2D|Vector2|Rect2|PoolVector2Array b
	-- @treturn Transform2D|Vector2|Rect2|PoolVector2Array Transformed value
	__mul = function(self, b)
		if ffi_istype(Transform2D, b) then
			return api.godot_transform2d_operator_multiply(self, b)
		else
			return self:xform(b)
		end
	end,
	--- Equality operation
	-- If either `a` or `b` are not of type `Transform2D`, always return `false`.
	-- @function __eq
	-- @tparam Transform2D a
	-- @tparam Transform2D b
	-- @treturn bool
	__eq = function(a, b)
		return ffi_istype(Transform2D, a) and ffi_istype(Transform2D, b) and a.elements[0] == b.elements[0] and a.elements[1] == b.elements[1] and a.elements[2] == b.elements[2]
	end,
})


