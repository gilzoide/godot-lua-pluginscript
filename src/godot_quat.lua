-- @file godot_quat.lua  Wrapper for GDNative's Quat
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

--- Quat metatype, wrapper for `godot_quat`.
-- Constructed using the idiom `Quat(...)`, which calls `__new`.
--
-- The X, Y, Z and W components may be accessed through `elements` or individually
-- with `x/y/z/w`. `Vector2` with two adjacent components may be get/set with the
-- pairs `xy/yz/zw`. `Vector3` with three adjacent components may be get/set with
-- the triplets `xyz/yzw`:
--     typedef union godot_quat {
--         float elements[4];
--         struct { float x, y, z, w; };
--         struct { Vector2 xy; Vector2 zw; };
--         struct { float _; Vector2 yz; float _; };
--         struct { Vector3 xyz; float _; };
--         struct { float _; Vector3 yzw; };
--     } godot_quat;
-- @classmod Quat

local methods = {
	fillvariant = api.godot_variant_new_quat,
	varianttype = VariantType.Quat,

	--- Returns the length of the quaternion.
	-- @function length
	-- @treturn number
	length = api.godot_quat_length,
	--- Returns the length of the quaternion, squared.
	-- @function length_squared
	-- @treturn number
	length_squared = api.godot_quat_length_squared,
	--- Returns a copy of the quaternion, normalized to unit length.
	-- @function normalized
	-- @treturn Quat
	normalized = api.godot_quat_normalized,
	--- Returns whether the quaternion is normalized or not.
	-- @function is_normalized
	-- @treturn bool
	is_normalized = api.godot_quat_is_normalized,
	--- Returns the inverse of the quaternion.
	-- @function inverse
	-- @treturn Quat
	inverse = api.godot_quat_inverse,
	--- Returns the dot product of two quaternions.
	-- @function dot
	-- @tparam Quat b
	-- @treturn number
	dot = api.godot_quat_dot,
	--- Returns a vector transformed (multiplied) by this quaternion.
	-- @function xform
	-- @tparam Vector3 v
	-- @treturn Vector3
	xform = api.godot_quat_xform,
	--- Returns the result of the spherical linear interpolation between this quaternion and `to` by amount `weight`.
	-- Note: Both quaternions must be normalized.
	-- @function slerp
	-- @tparam Quat to
	-- @tparam number weight
	-- @treturn Quat
	-- @see slerpni
	slerp = api.godot_quat_slerp,
	--- Returns the result of the spherical linear interpolation between this quaternion and `to` by amount `weight`, but without checking if the rotation path is not bigger than 90 degrees.
	-- Note: Both quaternions must be normalized.
	-- @function slerpni
	-- @tparam Quat to
	-- @tparam number weight
	-- @treturn Quat
	-- @see slerp
	slerpni = api.godot_quat_slerpni,
	--- Performs a cubic spherical interpolation between quaternions `preA`, this vector, `b`, and `postB`, by the given amount `t`.
	-- @function cubic_slerp
	-- @tparam Quat b
	-- @tparam Quat preA
	-- @tparam Quat postB
	-- @tparam number t
	-- @treturn Quat
	cubic_slerp = api.godot_quat_cubic_slerp,
}

--- Returns all elements.
-- @function unpack
-- @treturn number X
-- @treturn number Y
-- @treturn number Z
-- @treturn number W
methods.unpack = function(self)
	return self.x, self.y, self.z, self.w
end

--- Constants
-- @section constants

--- The identity quaternion, representing no rotation.
-- Equivalent to an identity `Basis` matrix. If a vector is transformed by an identity quaternion, it will not change.
-- @field IDENTITY  Quat(0, 0, 0, 1)

--- @section end

methods.IDENTITY = ffi_new('godot_quat', { elements = { 0, 0, 0, 1 } })

--- Metamethods
-- @section metamethods
Quat = ffi_metatype('godot_quat', {
	--- Quat constructor, called by the idiom `Quat(...)`.
	--
	-- * `Quat()`: `IDENTITY` quaternion (`Quat() == Quat(0, 0, 0, 1)`)
	-- * `Quat(number x[, number y = 0[, number z = 0[, number w = 1]]])`: set XYZW
	-- * `Quat(Basis basis)`: construct from basis
	-- * `Quat(Vector3 euler)`: rotation specified by Euler angles (in the YXZ convention: when decomposing, first Z, then X, and Y last)
	-- * `Quat(Vector3 axis, number angle)`: rotates around the given axis by the specified angle. The axis must be a normalized vector.
	-- * `Quat(Quat other)`: copy values from `other`
	-- @function __new
	-- @param ...
	-- @treturn Quat
	__new = function(mt, x, y, z, w)
		if ffi_istype(mt, x) then
			return ffi_new(mt, x)
		end
		local self = ffi_new(mt)
		if ffi_istype(Vector3, x) then
			if y then
				api.godot_quat_new_with_axis_angle(self, x, y)
			else
				api_1_1.godot_quat_new_with_euler(self, x)
			end
		elseif ffi_istype(Basis, x) then
			api_1_1.godot_quat_new_with_basis(self, x)
		else
			api.godot_quat_new(self, x or 0, y or 0, z or 0, w or 1)
		end
		return self
	end,
	__index = methods,
	--- Returns a Lua string representation of this quaternion.
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
	-- @tparam Quat a
	-- @tparam Quat b
	-- @treturn Quat
	__add = function(a, b)
		return Quat(a.x + b.x, a.y + b.y, a.z + b.z, a.w + b.w)
	end,
	--- Subtraction operation
	-- @function __sub
	-- @tparam Quat a
	-- @tparam Quat b
	-- @treturn Quat
	__sub = function(a, b)
		return Quat(a.x - b.x, a.y - b.y, a.z - b.z, a.w - b.w)
	end,
	--- Multiplication operation
	-- @function __mul
	-- @tparam Quat a
	-- @tparam Vector3|number b  If a Vector3 is passed, calls `xform`.
	--  Otherwise, returns a Quat with each component multiplied by `b`.
	-- @treturn Quat|Vector3
	__mul = function(self, b)
		if ffi_istype(Vector3, b) then
			return self:xform(b)
		else
			return Quat(self.x * b, self.y * b, self.z * b, self.w * b)
		end
	end,
	--- Division operation
	-- @function __div
	-- @tparam Quat a
	-- @tparam number s
	-- @treturn Quat
	__div = function(self, s)
		return self * (1.0 / s)
	end,
	--- Unary minus operation
	-- @function __unm
	-- @treturn Quat
	__unm = function(self)
		return Quat(-self.x, -self.y, -self.z, -self.w)
	end,
	--- Equality operation
	-- If either `a` or `b` are not of type `Quat`, always return `false`.
	-- @function __eq
	-- @tparam Quat a
	-- @tparam Quat b
	-- @treturn bool
	__eq = function(a, b)
		return ffi_istype(Quat, a) and ffi_istype(Quat, b) and a.x == b.x and a.y == b.y and a.z == b.z and a.w == b.w
	end,
})


