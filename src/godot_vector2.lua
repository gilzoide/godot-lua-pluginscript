-- @file godot_vector2.lua  Wrapper for GDNative's Vector2
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

--- Vector2 metatype, wrapper for `godot_vector2`.
-- Construct using the idiom `Vector2(...)`, which calls `__new`.
--
-- The X and Y components may be accessed through `elements` or the pairs
-- `x/y`, `r/g`, `s/t`, `u/v`, `width/height`:
--     typedef union godot_vector2 {
--         uint8_t data[8];
--         float elements[2];
--         // xy
--         struct { float x, y; };
--         // rg
--         struct { float r, g; };
--         // st
--         struct { float s, t; };
--         // uv
--         struct { float u, v; };
--         // Size: width/height
--         struct { float width, height; };
--     } godot_vector2;
-- @classmod Vector2

local methods = {
	fillvariant = api.godot_variant_new_vector2,
	varianttype = VariantType.Vector2,

	--- Returns the vector scaled to unit length.
	-- Equivalent to `v / v:length()`.
	-- @function normalized
	-- @treturn Vector2
	normalized = api.godot_vector2_normalized,
	--- Returns the length (magnitude) of this vector.
	-- @function length
	-- @treturn number
	length = api.godot_vector2_length,
	--- Returns the squared length (squared magnitude) of this vector.
	-- This method runs faster than `length`, so prefer it if you need to compare vectors or need the squared distance for some formula.
	-- @function length_squared
	-- @treturn number
	length_squared = api.godot_vector2_length_squared,
	--- Returns this vector's angle with respect to the positive X axis, or `(1, 0)` vector, in radians.
	-- @function angle
	-- @treturn number
	angle = api.godot_vector2_angle,
	--- Returns `true` if the vector is normalized.
	-- @function is_normalized
	-- @treturn bool
	is_normalized = api.godot_vector2_is_normalized,
	--- Returns the distance between this vector and `to`.
	-- @function distance_to
	-- @tparam Vector2 to
	-- @treturn number
	distance_to = api.godot_vector2_distance_to,
	--- Returns the squared distance between this vector and `to`.
	-- This method runs faster than `distance_to`, so prefer it if you need to compare vectors or need the squared distance for some formula.
	-- @function distance_squared_to
	-- @tparam Vector2 to
	-- @treturn number
	distance_squared_to = api.godot_vector2_distance_squared_to,
	--- Returns the angle to the given vector, in radians.
	-- @function angle_to
	-- @tparam Vector2 to
	-- @treturn number
	angle_to = api.godot_vector2_angle_to,
	--- Returns the angle between the line connecting the two points and the X axis, in radians.
	-- @function angle_to_point
	-- @tparam Vector2 to
	-- @treturn number
	angle_to_point = api.godot_vector2_angle_to_point,
	--- Returns the result of the linear interpolation between this vector and `b` by amount `t`.
	-- `t` is on the range of 0.0 to 1.0, representing the amount of interpolation.
	-- @function linear_interpolate
	-- @tparam Vector2 b
	-- @tparam number t
	-- @treturn Vector2
	linear_interpolate = api.godot_vector2_linear_interpolate,
	--- Cubically interpolates between this vector and b using pre_a and post_b as handles, and returns the result at position `t`.
	-- `t` is on the range of 0.0 to 1.0, representing the amount of interpolation.
	-- @function cubic_interpolate
	-- @tparam Vector2 b
	-- @tparam number t
	-- @treturn Vector2
	cubic_interpolate = api.godot_vector2_cubic_interpolate,
	--- Returns the vector rotated by `phi` radians.
	-- @function rotated
	-- @tparam number phi
	-- @treturn Vector2
	rotated = api.godot_vector2_rotated,
	--- Returns a perpendicular vector rotated 90 degrees counter-clockwise compared to the original, with the same length.
	-- @function tangent
	-- @treturn Vector2
	tangent = api.godot_vector2_tangent,
	--- Returns the vector with all components rounded down (towards negative infinity).
	-- @function floor
	-- @treturn Vector2
	floor = api.godot_vector2_floor,
	--- Returns this vector with each component snapped to the nearest multiple of `step`.
	-- This can also be used to round to an arbitrary number of decimals.
	-- @function snapped
	-- @tparam Vector2 step
	-- @treturn Vector2
	snapped = api.godot_vector2_snapped,
	--- Returns the aspect ratio of this vector, the ratio of x to y.
	-- @function aspect
	-- @treturn number
	aspect = api.godot_vector2_aspect,
	--- Returns the dot product of this vector and `b`.
	-- @function dot
	-- @tparam Vector2 b
	-- @treturn number
	dot = api.godot_vector2_dot,
	--- Returns this vector slid along a plane defined by the given `normal`.
	-- @function slide
	-- @tparam Vector2 normal
	-- @treturn Vector2
	slide = api.godot_vector2_slide,
	--- Returns the vector "bounced off" from a plane defined by the given `normal`.
	-- @function bounce
	-- @tparam Vector2 normal
	-- @treturn Vector2
	bounce = api.godot_vector2_bounce,
	--- Returns the vector reflected from a plane defined by the given normal.
	-- @function reflect
	-- @tparam Vector2 normal
	-- @treturn Vector2
	reflect = api.godot_vector2_reflect,
	--- Returns a new vector with all components in absolute values (i.e. positive).
	-- @function abs
	-- @treturn Vector2
	abs = api.godot_vector2_abs,
	--- Returns the vector with a maximum length by limiting its length to `length`.
	-- @function clamped
	-- @treturn Vector2
	clamped = api.godot_vector2_clamped,
}

--- Returns all elements.
-- @function unpack
-- @treturn number X
-- @treturn number Y
methods.unpack = function(self)
	return self.x, self.y
end

if api_1_2 ~= nil then
	--- Moves the vector toward `to` by the fixed `delta` amount.
	-- @function move_toward
	-- @tparam Vector2 to
	-- @tparam number delta
	-- @treturn Vector2
	methods.move_toward = api_1_2.godot_vector2_move_toward
	--- Returns the normalized vector pointing from this vector to `b`.
	-- This is equivalent to using `(b - a).normalized()`.
	-- @function direction_to
	-- @tparam Vector2 b
	-- @treturn Vector2
	methods.direction_to = api_1_2.godot_vector2_direction_to
end

--- Constants
-- @section constants

--- Enumerated value for the X axis.
-- @field AXIS_X  0

--- Enumerated value for the Y axis.
-- @field AXIS_Y  1

--- Zero vector, a vector with all components set to 0.
-- @field ZERO  Vector2(0)

--- One vector, a vector with all components set to 1.
-- @field ONE  Vector2(1)

--- Infinity vector, a vector with all components set to `inf`.
-- @field INF  Vector2(1 / 0)

--- Left unit vector. Represents the direction of left.
-- @field LEFT  Vector2(-1, 0)

--- Right unit vector. Represents the direction of right.
-- @field RIGHT  Vector2(1, 0)

--- Up unit vector. Y is down in 2D, so this vector points -Y.
-- @field UP  Vector2(0, -1)

--- Down unit vector. Y is down in 2D, so this vector points +Y.
-- @field DOWN  Vector2(0, 1)

--- @section end

methods.AXIS_X = 0
methods.AXIS_Y = 1
methods.ZERO = ffi_new('godot_vector2', { elements = { 0 } })
methods.ONE = ffi_new('godot_vector2', { elements = { 1 } })
methods.INF = ffi_new('godot_vector2', { elements = { 1 / 0 } })
methods.LEFT = ffi_new('godot_vector2', { elements = { -1, 0 } })
methods.RIGHT = ffi_new('godot_vector2', { elements = { 1, 0 } })
methods.UP = ffi_new('godot_vector2', { elements = { 0, -1 } })
methods.DOWN = ffi_new('godot_vector2', { elements = { 0, 1 } })

--- Metamethods
-- @section metamethods
Vector2 = ffi_metatype('godot_vector2', {
	--- Vector2 constructor, called by the idiom `Vector2(...)`.
	-- 
	-- * `Vector2()`: all zeros (`Vector2() == Vector2(0, 0)`)
	-- * `Vector2(number x)`: all components are set to `x` (`Vector2(1) == Vector2(1, 1)`)
	-- * `Vector2(number x, number y)`: set XY
	-- * `Vector2(Vector2 other)`: copy values from `other`
	-- @function __new
	-- @param ...
	-- @treturn Vector2
	__new = function(mt, x, y)
		if ffi_istype(mt, x) then
			return ffi_new(mt, x)
		else
			return ffi_new(mt, { elements = { x, y }})
		end
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
	-- @tparam Vector2|number a
	-- @tparam Vector2|number b
	-- @treturn Vector2
	__add = function(a, b)
		a, b = Vector2(a), Vector2(b)
		return Vector2(a.x + b.x, a.y + b.y)
	end,
	--- Subtraction operation
	-- @function __sub
	-- @tparam Vector2|number a
	-- @tparam Vector2|number b
	-- @treturn Vector2
	__sub = function(a, b)
		a, b = Vector2(a), Vector2(b)
		return Vector2(a.x - b.x, a.y - b.y)
	end,
	--- Multiplication operation
	-- @function __mul
	-- @tparam Vector2|number a
	-- @tparam Vector2|number b
	-- @treturn Vector2
	__mul = function(a, b)
		a, b = Vector2(a), Vector2(b)
		return Vector2(a.x * b.x, a.y * b.y)
	end,
	--- Division operation
	-- @function __div
	-- @tparam Vector2|number a
	-- @tparam Vector2|number b
	-- @treturn Vector2
	__div = function(a, b)
		a, b = Vector2(a), Vector2(b)
		return Vector2(a.x / b.x, a.y / b.y)
	end,
	--- Module operation
	-- @function __mod
	-- @tparam Vector2|number a
	-- @tparam Vector2|number b
	-- @treturn Vector2
	__mod = function(a, b)
		a, b = Vector2(a), Vector2(b)
		return Vector2(a.x % b.x, a.y % b.y)
	end,
	--- Power operation
	-- @function __pow
	-- @tparam Vector2|number a
	-- @tparam Vector2|number b
	-- @treturn Vector2
	__pow = function(a, b)
		a, b = Vector2(a), Vector2(b)
		return Vector2(a.x ^ b.x, a.y ^ b.y)
	end,
	--- Unary minus operation
	-- @function __unm
	-- @treturn Vector2
	__unm = function(self)
		return Vector2(-self.x, -self.y)
	end,
	--- Equality operation
	-- @function __eq
	-- @tparam Vector2|number a
	-- @tparam Vector2|number b
	-- @treturn bool
	__eq = function(a, b)
		a, b = Vector2(a), Vector2(b)
		return a.x == b.x and a.y == b.y
	end,
	--- Less than operation
	-- @function __lt
	-- @tparam Vector2|number a
	-- @tparam Vector2|number b
	-- @treturn bool
	__lt = function(a, b)
		a, b = Vector2(a), Vector2(b)
		if a.x == b.x then
			return a.y < b.y
		else
			return a.x < b.x
		end
	end,
})

