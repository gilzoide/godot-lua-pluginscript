-- @file godot_vector3.lua  Wrapper for GDNative's Vector3
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

--- Vector3 metatype, wrapper for `godot_vector3`.
-- Construct using the idiom `Vector3(...)`, which calls `__new`.
--
-- The X, Y and Z components may be accessed through `elements` or the triplets
-- `x/y/z`, `r/g/b`, `s/t/p`, `width/height/depth`, the pair `u/v`. `Vector2` with
-- two adjacent components may be get/set with pairs like `xy` or `yz`:
--     typedef union godot_vector3 {
--         uint8_t data[12];
--         float elements[3];
--         // xyz
--         struct { float x, y, z; };
--         struct { Vector2 xy; float _; };
--         struct { float _; Vector2 yz; };
--         // rgb
--         struct { float r, g, b; };
--         struct { Vector2 rg; float _; };
--         struct { float _; Vector2 gb; };
--         // stp
--         struct { float s, t, p; };
--         struct { Vector2 st; float _; };
--         struct { float _; Vector2 tp; };
--         // uv
--         struct { float u, v, _; };
--         struct { Vector2 uv; float _; };
--         // 3D Size: width/height/depth
--         struct { float width, height, depth; };
--     } godot_vector3;
-- @classmod Vector3

local methods = {
	fillvariant = api.godot_variant_new_vector3,
	varianttype = VariantType.Vector3,

	--- Returns the axis of the vector's smallest value.
	-- If all components are equal, this method returns `AXIS_Z`.
	-- @function min_axis
	-- @treturn int  `AXIS_X`, `AXIS_Y` or `AXIS_Z`
	min_axis = api.godot_vector3_min_axis,
	--- Returns the axis of the vector's largest value.
	-- If all components are equal, this method returns `AXIS_Z`.
	-- @function max_axis
	-- @treturn int  `AXIS_X`, `AXIS_Y` or `AXIS_Z`
	max_axis = api.godot_vector3_max_axis,
	--- Returns the length (magnitude) of this vector.
	-- @function length
	-- @treturn number
	length = api.godot_vector3_length,
	--- Returns the squared length (squared magnitude) of this vector.
	-- This method runs faster than `length`, so prefer it if you need to compare vectors or need the squared distance for some formula.
	-- @function length_squared
	-- @treturn number
	length_squared = api.godot_vector3_length_squared,
	--- Returns `true` if the vector is normalized.
	-- @function is_normalized
	-- @treturn bool
	is_normalized = api.godot_vector3_is_normalized,
	--- Returns the vector scaled to unit length.
	-- Equivalent to `v / v.length()`.
	-- @function normalized
	-- @treturn Vector3
	normalized = api.godot_vector3_normalized,
	--- Returns the inverse of the vector.
	-- Equivalent to `1.0 / v`.
	-- @function inverse
	-- @treturn Vector3
	inverse = api.godot_vector3_inverse,
	--- Returns this vector with each component snapped to the nearest multiple of `step`.
	-- This can also be used to round to an arbitrary number of decimals.
	-- @function snapped
	-- @tparam Vector3 step
	-- @treturn Vector3
	snapped = api.godot_vector3_snapped,
	--- Rotates this vector around a given `axis` by `phi` radians.
	-- The `axis` must be a normalized vector.
	-- @function rotated
	-- @tparam Vector3 axis
	-- @tparam number phi
	-- @treturn Vector3
	rotated = api.godot_vector3_rotated,
	--- Returns the result of the linear interpolation between this vector and `b` by amount `t`.
	-- `t` is on the range of 0.0 to 1.0, representing the amount of interpolation.
	-- @function linear_interpolate
	-- @tparam Vector3 b
	-- @tparam number t
	-- @treturn Vector3
	linear_interpolate = api.godot_vector3_linear_interpolate,
	--- Performs a cubic interpolation between vectors `pre_a`, `a`, `b`, `post_b` (`a` is current), by the given amount `t`.
	-- `t` is on the range of 0.0 to 1.0, representing the amount of interpolation.
	-- @function cubic_interpolate
	-- @treturn Vector3
	cubic_interpolate = api.godot_vector3_cubic_interpolate,
	--- Returns the dot product of this vector and `b`.
	-- @function dot
	-- @tparam Vector3 b
	-- @treturn Vector3
	dot = api.godot_vector3_dot,
	--- Returns the cross product of this vector and `b`.
	-- @function cross
	-- @tparam Vector3 b
	-- @treturn Vector3
	cross = api.godot_vector3_cross,
	--- Returns the outer product with `b`.
	-- @function outer
	-- @tparam Vector3 b
	-- @treturn Basis
	outer = api.godot_vector3_outer,
	--- Returns a diagonal matrix with the vector as main diagonal.
	-- This is equivalent to a Basis with no rotation or shearing and this vector's components set as the scale.
	-- @function to_diagonal_matrix
	-- @treturn Basis
	to_diagonal_matrix = api.godot_vector3_to_diagonal_matrix,
	--- Returns a new vector with all components in absolute values (i.e. positive).
	-- @function abs
	-- @treturn Vector3
	abs = api.godot_vector3_abs,
	--- Returns a new vector with all components rounded down (towards negative infinity).
	-- @function floor
	-- @treturn Vector3
	floor = api.godot_vector3_floor,
	--- Returns a new vector with all components rounded up (towards positive infinity).
	-- @function ceil
	-- @treturn Vector3
	ceil = api.godot_vector3_ceil,
	--- Returns the distance between this vector and `b`.
	-- @function distance_to
	-- @tparam Vector3 b
	-- @treturn number
	distance_to = api.godot_vector3_distance_to,
	--- Returns the squared distance between this vector and `b`.
	-- This method runs faster than `distance_to`, so prefer it if you need to compare vectors or need the squared distance for some formula.
	-- @function distance_squared_to
	-- @tparam Vector3 b
	-- @treturn number
	distance_squared_to = api.godot_vector3_distance_squared_to,
	--- Returns the minimum angle to the given vector, in radians.
	-- @function angle_to
	-- @tparam Vector3 b
	-- @treturn number
	angle_to = api.godot_vector3_angle_to,
	--- Returns this vector slid along a plane defined by the given `normal`.
	-- @function slide
	-- @tparam Vector3 normal
	-- @treturn Vector3
	slide = api.godot_vector3_slide,
	--- Returns the vector "bounced off" from a plane defined by the given `normal`.
	-- @function bounce
	-- @tparam Vector3 normal
	-- @treturn Vector3
	bounce = api.godot_vector3_bounce,
	--- Returns this vector reflected from a plane defined by the given `normal`.
	-- @function reflect
	-- @tparam Vector3 normal
	-- @treturn Vector3
	reflect = api.godot_vector3_reflect,
}

--- Returns all elements.
-- @function unpack
-- @treturn number X
-- @treturn number Y
-- @treturn number Z
methods.unpack = function(self)
	return self.x, self.y, self.z
end

if api_1_2 ~= nil then
	--- Moves this vector toward `to` by the fixed `delta` amount.
	-- @function move_toward
	-- @tparam Vector3 to
	-- @tparam number delta
	-- @treturn Vector3
	methods.move_toward = api_1_2.godot_vector3_move_toward
	--- Returns the normalized vector pointing from this vector to `b`.
	-- Equivalent to `(b - a).normalized()`.
	-- @function direction_to
	-- @tparam Vector3 to
	-- @treturn Vector3
	methods.direction_to = api_1_2.godot_vector3_direction_to
end

--- Constants
-- @section constants

--- Enumerated value for the X axis.
-- @field AXIS_X  0

--- Enumerated value for the Y axis.
-- @field AXIS_Y  1

--- Enumerated value for the Z axis.
-- @field AXIS_Z  2

--- Zero vector, a vector with all components set to 0.
-- @field ZERO  Vector3(0)

--- One vector, a vector with all components set to 1.
-- @field ONE  Vector3(1)

--- Infinity vector, a vector with all components set to `inf`.
-- @field INF  Vector3(1 / 0)

--- Left unit vector. Represents the local direction of left, and the global direction of west.
-- @field LEFT  Vector3(-1, 0, 0)

--- Right unit vector. Right unit vector. Represents the local direction of right, and the global direction of east.
-- @field RIGHT  Vector3(1, 0, 0)

--- Up unit vector.
-- @field UP  Vector3(0, 1, 0)

--- Down unit vector.
-- @field DOWN  Vector3(0, -1, 0)

--- Forward unit vector. Represents the local direction of forward, and the global direction of north.
-- @field FORWARD  Vector3(0, 0, -1)

--- Back unit vector. Represents the local direction of back, and the global direction of south.
-- @field BACK  Vector3(0, 0, 1)

--- @section end

methods.AXIS_X = 0
methods.AXIS_Y = 1
methods.AXIS_Z = 2
methods.ZERO = ffi_new('godot_vector3', { elements = { 0 } })
methods.ONE = ffi_new('godot_vector3', { elements = { 1 } })
methods.INF = ffi_new('godot_vector3', { elements = { 1 / 0 } })
methods.LEFT = ffi_new('godot_vector3', { elements = { -1, 0, 0 } })
methods.RIGHT = ffi_new('godot_vector3', { elements = { 1, 0, 0 } })
methods.UP = ffi_new('godot_vector3', { elements = { 0, 1, 0 } })
methods.DOWN = ffi_new('godot_vector3', { elements = { 0, -1, 0 } })
methods.FORWARD = ffi_new('godot_vector3', { elements = { 0, 0, -1 } })
methods.BACK = ffi_new('godot_vector3', { elements = { 0, 0, 1 } })

--- Metamethods
-- @section metamethods
Vector3 = ffi_metatype('godot_vector3', {
	--- Vector3 constructor, called by the idiom `Vector3(...)`.
	--
	-- * `Vector3()`: all zeros (`Vector3() == Vector3(0, 0, 0)`)
	-- * `Vector3(number x)`: all components are set to `x` (`Vector3(1) == Vector3(1, 1, 1)`)
	-- * `Vector3(number x, number y[, number z = 0])`: set XYZ
	-- * `Vector3(Vector2 xy[, number z = 0])`: set XYZ
	-- * `Vector3(number x, Vector2 yz)`: set XYZ
	-- * `Vector3(Vector3 other)`: copy values from `other`
	-- @function __new
	-- @param ...
	-- @treturn Vector3
	__new = function(mt, x, y, z)
		-- (Vector3)
		if ffi_istype(mt, x) then
			return ffi_new(mt, x)
		-- (Vector2, float?)
		elseif ffi_istype(Vector2, x) then
			x, y, z = x.x, x.y, y
		-- (float, Vector2)
		elseif ffi_istype(Vector2, y) then
			x, y, z = x, y.x, y.y
		end
		return ffi_new(mt, { elements = { x, y, z }})
	end,
	__index = methods,
	--- Returns a Lua string representation of this vector.
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
	-- @tparam Vector3|Vector2|number a
	-- @tparam Vector3|Vector2|number b
	-- @treturn Vector3
	__add = function(a, b)
		a, b = Vector3(a), Vector3(b)
		return Vector3(a.x + b.x, a.y + b.y, a.z + b.z)
	end,
	--- Subtraction operation
	-- @function __sub
	-- @tparam Vector3|Vector2|number a
	-- @tparam Vector3|Vector2|number b
	-- @treturn Vector3
	__sub = function(a, b)
		a, b = Vector3(a), Vector3(b)
		return Vector3(a.x - b.x, a.y - b.y, a.z - b.z)
	end,
	--- Multiplication operation
	-- @function __mul
	-- @tparam Vector3|Vector2|number a
	-- @tparam Vector3|Vector2|number b
	-- @treturn Vector3
	__mul = function(a, b)
		a, b = Vector3(a), Vector3(b)
		return Vector3(a.x * b.x, a.y * b.y, a.z * b.z)
	end,
	--- Division operation
	-- @function __div
	-- @tparam Vector3|Vector2|number a
	-- @tparam Vector3|Vector2|number b
	-- @treturn Vector3
	__div = function(a, b)
		a, b = Vector3(a), Vector3(b)
		return Vector3(a.x / b.x, a.y / b.y, a.z / b.z)
	end,
	--- Module operation
	-- @function __mod
	-- @tparam Vector3|Vector2|number a
	-- @tparam Vector3|Vector2|number b
	-- @treturn Vector3
	__mod = function(a, b)
		a, b = Vector3(a), Vector3(b)
		return Vector3(a.x % b.x, a.y % b.y, a.z % b.z)
	end,
	--- Power operation
	-- @function __pow
	-- @tparam Vector3|Vector2|number a
	-- @tparam Vector3|Vector2|number b
	-- @treturn Vector3
	__pow = function(a, b)
		a, b = Vector3(a), Vector3(b)
		return Vector3(a.x ^ b.x, a.y ^ b.y, a.z ^ b.z)
	end,
	--- Unary minus operation
	-- @function __unm
	-- @treturn Vector3
	__unm = function(self)
		return Vector3(-self.x, -self.y, -self.z)
	end,
	--- Equality operation
	-- @function __eq
	-- @tparam Vector3|Vector2|number a
	-- @tparam Vector3|Vector2|number b
	-- @treturn bool
	__eq = function(a, b)
		a, b = Vector3(a), Vector3(b)
		return a.x == b.x and a.y == b.y and a.z == b.z
	end,
	--- Less than operation
	-- @function __lt
	-- @tparam Vector3|Vector2|number a
	-- @tparam Vector3|Vector2|number b
	-- @treturn bool
	__lt = function(a, b)
		a, b = Vector3(a), Vector3(b)
		if a.x == b.x then
			if a.y == b.y then
				return a.z < b.z
			else
				return a.y < b.y
			end
		else
			return a.x < b.x
		end
	end,
})


