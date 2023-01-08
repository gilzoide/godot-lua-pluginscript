-- @file godot_basis.lua  Wrapper for GDNative's Basis
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

--- Basis metatype, wrapper for `godot_basis`.
-- Constructed using the idiom `Basis(...)`, which calls `__new`.
--
-- The matrix rows may be accessed through `rows` or in bulk through `elements`:
--     typedef union godot_basis {
--         uint8_t data[36];
--         float elements[9];
--         Vector3 rows[3];
--     } godot_basis;
-- @classmod Basis

local methods = {
	fillvariant = api.godot_variant_new_basis,
	varianttype = VariantType.Basis,

	--- Returns the inverse of the matrix.
	-- @function inverse
	-- @treturn Basis
	inverse = api.godot_basis_inverse,
	--- Returns the transposed version of the matrix.
	-- @function transposed
	-- @treturn Basis
	transposed = api.godot_basis_transposed,
	--- Returns the orthonormalized version of the matrix (useful to call from time to time to avoid rounding error for orthogonal matrices).
	-- This performs a Gram-Schmidt orthonormalization on the basis of the matrix.
	-- @function orthonormalized
	-- @treturn Basis
	orthonormalized = api.godot_basis_orthonormalized,
	--- Returns the determinant of the basis matrix. If the basis is uniformly scaled, its determinant is the square of the scale.
	-- A negative determinant means the basis has a negative scale.
	-- A zero determinant means the basis isn't invertible, and is usually considered invalid.
	-- @function determinant
	-- @treturn number
	determinant = api.godot_basis_determinant,
	--- Introduce an additional rotation around the given `axis` by `phi` (radians).
	-- The `axis` must be a normalized vector.
	-- @function rotated
	-- @tparam Vector3 axis
	-- @tparam number phi
	-- @treturn Basis
	rotated = api.godot_basis_rotated,
	--- Introduce an additional scaling specified by the given 3D scaling factor.
	-- @function scaled
	-- @tparam Vector3 scale
	-- @treturn Basis
	scaled = api.godot_basis_scaled,
	--- Assuming that the matrix is the combination of a rotation and scaling, return the absolute value of scaling factors along each axis.
	-- @function get_scale
	-- @treturn Vector3
	get_scale = api.godot_basis_get_scale,
	--- Returns the basis's rotation in the form of Euler angles (in the YXZ convention: when decomposing, first Z, then X, and Y last).
	-- The returned vector contains the rotation angles in the format (X angle, Y angle, Z angle).
	-- Consider using the `get_rotation_quat` method instead, which returns a quaternion instead of Euler angles.
	-- @function get_euler
	-- @treturn Vector3
	-- @see get_rotation_quat
	get_euler = api.godot_basis_get_euler,
	--- Transposed dot product with the X axis of the matrix.
	-- @function tdotx
	-- @tparam Vector3 with
	-- @treturn number
	tdotx = api.godot_basis_tdotx,
	--- Transposed dot product with the Y axis of the matrix.
	-- @function tdoty
	-- @tparam Vector3 with
	-- @treturn number
	tdoty = api.godot_basis_tdoty,
	--- Transposed dot product with the Z axis of the matrix.
	-- @function tdotz
	-- @tparam Vector3 with
	-- @treturn number
	tdotz = api.godot_basis_tdotz,
	--- Returns a vector transformed (multiplied) by the matrix.
	-- @function xform
	-- @tparam Vector3 v
	-- @treturn Vector3
	xform = api.godot_basis_xform,
	--- Returns a vector transformed (multiplied) by the transposed basis matrix.
	-- Note: This results in a multiplication by the inverse of the matrix only if it represents a rotation-reflection.
	-- @function xform_inv
	-- @tparam Vector3 v
	-- @treturn Vector3
	xform_inv = api.godot_basis_xform_inv,
	--- This function considers a discretization of rotations into 24 points on unit sphere, lying along the vectors (x,y,z) with each component being either -1, 0, or 1, and returns the index of the point best representing the orientation of the object.
	-- It is mainly used by the GridMap editor.
	-- For further details, refer to the Godot source code.
	-- @function get_orthogonal_index
	-- @treturn int
	get_orthogonal_index = api.godot_basis_get_orthogonal_index,
	--- Returns the given `axis` (column).
	-- @function get_axis
	-- @tparam int axis
	-- @treturn Vector3
	get_axis = api.godot_basis_get_axis,
	--- Set a new value for `axis` (column).
	-- @function set_axis
	-- @tparam int axis
	-- @tparam Vector3 value
	set_axis = api.godot_basis_set_axis,
	--- Returns the given `row`.
	-- @function get_row
	-- @tparam int row
	-- @treturn Vector3
	get_row = api.godot_basis_get_row,
	--- Set a new value for `row`.
	-- @function set_row
	-- @tparam int row
	-- @tparam Vector3 value
	set_row = api.godot_basis_set_row,
}

if api_1_1 ~= nil then
	--- Assuming that the matrix is a proper rotation matrix, slerp performs a spherical-linear interpolation with another rotation matrix.
	-- @function slerp
	-- @tparam Basis b
	-- @tparam number t
	-- @treturn Basis
	methods.slerp = api_1_1.godot_basis_slerp
	--- Returns the basis's rotation in the form of a quaternion.
	-- See `get_euler` if you need Euler angles, but keep in mind quaternions should generally be preferred to Euler angles.
	-- @function get_rotation_quat
	-- @treturn Quat
	methods.get_rotation_quat = api_1_1.godot_basis_get_quat
end

--- Constants
-- @section constants

--- The identity basis, with no rotation or scaling applied.
-- @field IDENTITY  Basis(1, 0, 0, 0, 1, 0, 0, 0, 1)

--- The basis that will flip something along the X axis when used in a transformation.
-- @field FLIP_X  Basis(-1, 0, 0, 0, 1, 0, 0, 0, 1)

--- The basis that will flip something along the Y axis when used in a transformation.
-- @field FLIP_Y  Basis(1, 0, 0, 0, -1, 0, 0, 0, 1)

--- The basis that will flip something along the Z axis when used in a transformation.
-- @field FLIP_Z  Basis(1, 0, 0, 0, 1, 0, 0, 0, -1)

--- @section end

methods.IDENTITY = ffi_new('godot_basis', { elements = { 1, 0, 0, 0, 1, 0, 0, 0, 1 } })
methods.FLIP_X = ffi_new('godot_basis', { elements = { -1, 0, 0, 0, 1, 0, 0, 0, 1 } })
methods.FLIP_Y = ffi_new('godot_basis', { elements = { 1, 0, 0, 0, -1, 0, 0, 0, 1 } })
methods.FLIP_Z = ffi_new('godot_basis', { elements = { 1, 0, 0, 0, 1, 0, 0, 0, -1 } })

--- Metamethods
-- @section metamethods
Basis = ffi_metatype('godot_basis', {
	--- Basis constructor, called by the idiom `Basis(...)`.
	--
	-- * `Basis()`: `IDENTITY` basis matrix
	-- * `Basis(Quat quat)`: pure rotation basis matrix from the given quaternion
	-- * `Basis(Vector3 euler)`: pure rotation basis matrix from the given Euler angles (in the YXZ convention: when *composing*, first Y, then X, and Z last)
	-- * `Basis(Vector3 axis, number angle)`: pure rotation basis matrix, rotated around the given axis by angle, in radians. The axis must be a normalized vector
	-- * `Basis(Vector3 x, Vector3 y, Vector3 z)`: basis matrix from 3 row vectors
	-- * `Basis(Basis other)`: copy values from `other`
	-- @function __new
	-- @param ...
	-- @treturn Basis
	__new = function(mt, x, y, z)
		if ffi_istype(mt, x) then
			return ffi_new(mt, x)
		end
		local self = ffi_new(mt)
		if ffi_istype(Vector3, x) then
			if ffi_istype(Vector3, y) then
				api.godot_basis_new_with_rows(self, x, y, z)
			elseif y then
				api.godot_basis_new_with_axis_and_angle(self, x, y)
			else
				api.godot_basis_new_with_euler(self, x)
			end
		elseif ffi_istype(Quat, x) then
			api.godot_basis_new_with_euler_quat(self, x)
		else
			api.godot_basis_new(self)
		end
		return self
	end,
	__index = methods,
	--- Returns a Lua string representation of this basis.
	-- @function __tostring
	-- @treturn string
	__tostring = gd_tostring,
	--- Concatenates values.
	-- @function __concat
	-- @param a  First value, stringified with `GD.str`
	-- @param b  First value, stringified with `GD.str`
	-- @treturn String
	__concat = concat_gdvalues,
	--- Addition operation
	-- @function __add
	-- @tparam Basis a
	-- @tparam Basis b
	-- @treturn Basis
	__add = function(a, b)
		return Basis(a.elements[0] + b.elements[0], a.elements[1] + b.elements[1], a.elements[2] + b.elements[2])
	end,
	--- Subtraction operation
	-- @function __sub
	-- @tparam Basis a
	-- @tparam Basis b
	-- @treturn Basis
	__sub = function(a, b)
		return Basis(a.elements[0] - b.elements[0], a.elements[1] - b.elements[1], a.elements[2] - b.elements[2])
	end,
	--- Multiplication operation
	-- @function __mul
	-- @tparam Basis self
	-- @tparam Basis|Vector3|number b  If a Basis is passed, returns the multiplied matrices.
	--  If a Vector3 is passed, calls `xform`.
	--  Otherwise, returns a Basis with each component multiplied by `b`.
	-- @treturn Basis|Vector3
	__mul = function(self, b)
		if ffi_istype(Basis, b) then
			return api.godot_basis_operator_multiply_vector(self, b)
		elseif ffi_istype(Vector3, b) then
			return self:xform(b)
		else
			return Basis(self.elements[0] * b, self.elements[1] * b, self.elements[2] * b)
		end
	end,
	--- Equality operation
	-- If either `a` or `b` are not of type `Basis`, always return `false`.
	-- @function __eq
	-- @tparam Basis a
	-- @tparam Basis b
	-- @treturn bool
	__eq = function(a, b)
		return ffi_istype(Basis, a) and ffi_istype(Basis, b) and a.elements[0] == b.elements[0] and a.elements[1] == b.elements[1] and a.elements[2] == b.elements[2]
	end,
})


