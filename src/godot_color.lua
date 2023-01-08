-- @file godot_color.lua  Wrapper for GDNative's Color
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

--- Color metatype, wrapper for `godot_color`.
-- Construct using the idiom `Color(...)`, which calls `__new`.
--
-- The R, G, B and A components may be accessed through `elements` or individually
-- with `r/g/b/a`. `Vector2` with two adjacent components may be get/set with the
-- pairs `rg/gb/ba`. `Vector3` with three adjacent components may be get/set with
-- the triplets `rgb/gba`:
--     typedef union godot_color {
--         uint8_t data[16];
--         float elements[4];
--         struct { float r, g, b, a; };
--         struct { Vector2 rg; Vector2 ba; };
--         struct { float _; Vector2 gb; float _; };
--         struct { Vector3 rgb; float _; };
--         struct { float _; Vector3 gba; };
--     } godot_color;
-- @classmod Color


local methods = {
	fillvariant = api.godot_variant_new_color,
	varianttype = VariantType.Color,

	--- Returns the HSV hue of this color, on the range 0 to 1.
	-- @function get_h
	-- @treturn number
	get_h = api.godot_color_get_h,
	--- Returns the HSV saturation of this color, on the range 0 to 1.
	-- @function get_s
	-- @treturn number
	get_s = api.godot_color_get_s,
	--- Returns the HSV value (brightness) of this color, on the range 0 to 1.
	-- @function get_v
	-- @treturn number
	get_v = api.godot_color_get_v,
	--- Returns the color's grayscale representation.
	-- The gray value is calculated as `(r + g + b) / 3`.
	-- @function gray
	-- @treturn number
	gray = api.godot_color_gray,
	--- Returns the inverted color `(1 - r, 1 - g, 1 - b, a)`.
	-- @function inverted
	-- @treturn Color
	inverted = api.godot_color_inverted,
	--- Returns the most contrasting color.
	-- @function contrasted
	-- @treturn Color
	contrasted = api.godot_color_contrasted,
	--- Returns the linear interpolation with another color.
	-- The interpolation factor `t` is between 0 and 1.
	-- @function linear_interpolate
	-- @tparam Color b
	-- @tparam number t
	-- @treturn Color
	linear_interpolate = api.godot_color_linear_interpolate,
	--- Returns a new color resulting from blending this color over another.
	-- If the color is opaque, the result is also opaque.
	-- The second color may have a range of alpha values.
	-- @function blend
	-- @tparam Color over
	-- @treturn Color
	blend = api.godot_color_blend,
	--- Returns the color's HTML hexadecimal color string in ARGB format (ex: ff34f822).
	-- Setting `with_alpha` to `false` excludes alpha from the hexadecimal string.
	-- @function to_html
	-- @param[opt=true] with_alpha
	-- @treturn String
	to_html = function(self, with_alpha)
		return ffi_gc(api.godot_color_to_html(self, with_alpha == nil or with_alpha), api.godot_string_destroy)
	end,
}

--- Returns all elements.
-- @function unpack
-- @treturn number R
-- @treturn number G
-- @treturn number B
-- @treturn number A
methods.unpack = function(self)
	return self.r, self.g, self.b, self.a
end

if api_1_1 ~= nil then
	--- Returns a new color resulting from making this color darker by the specified percentage (ratio from 0 to 1).
	-- @function darkened
	-- @tparam number amount
	-- @treturn Color
	methods.darkened = api_1_1.godot_color_darkened
	--- Returns a new color resulting from making this color lighter by the specified percentage (ratio from 0 to 1).
	-- @function lightened
	-- @tparam number amount
	-- @treturn Color
	methods.lightened = api_1_1.godot_color_lightened

	--- Static Functions.
	-- These don't receive `self` and should be called directly as `Color.static_function(...)`
	-- @section static_funcs
	
	--- Constructs a color from an HSV profile. h, s, and v are values between 0 and 1.
	-- @function from_hsv
	-- @tparam number h
	-- @tparam number s
	-- @tparam number v
	-- @tparam[opt=1.0] number a
	-- @treturn Color
	methods.from_hsv = function(h, s, v, a)
		return api_1_1.godot_color_from_hsv(ffi_new(Color), h, s, v, a or 1)
	end
end

--- Metamethods
-- @section metamethods
Color = ffi_metatype('godot_color', {
	--- Color constructor, called by the idiom `Color(...)`.
	--
	-- * `Color()`: RGB are set to 0, A is set to 1 (`Color() == Color(0, 0, 0, 1)`)
	-- * `Color(number r)`: RGB are set to `r`, A is set to 1 (`Color(0.5) == Color(0.5, 0.5, 0.5, 1)`)
	-- * `Color(number r, number g[, number b = 0[, number a = 1]])`: set RGBA
	-- * `Color(number r, number g, Vector2 ba)`: set RGBA
	-- * `Color(number r, Vector2 gb[, number a = 1])`: set RGBA
	-- * `Color(number r, Vector3 gba)`: set RGBA
	-- * `Color(Vector2 rg[, number b = 0[, number a = 1]])`: set RGBA
	-- * `Color(Vector2 rg, Vector2 ba)`: set RGBA
	-- * `Color(Vector3 rgb[, number a = 1])`: set RGBA
	-- * `Color(Color other)`: copy values from `other`
	-- @function __new
	-- @param ...
	-- @treturn Color
	__new = function(mt, r, g, b, a)
		if ffi_istype(mt, r) then
			return ffi.new(mt, r)
		elseif ffi_istype(Vector2, r) then
			-- (Vector2, Vector2)
			if ffi_istype(Vector2, g) then
				r, g, b, a = r.x, r.y, g.x, g.y
			-- (Vector2, float?, float?)
			else
				r, g, b, a = r.x, r.y, g, b
			end
		-- (Vector3, float?)
		elseif ffi_istype(Vector3, r) then
			r, g, b, a = r.x, r.y, r.z, g
		-- (float, Vector2, float?)
		elseif ffi_istype(Vector2, g) then
			r, g, b, a = r, g.x, g.y, b
		-- (float, float, Vector2)
		elseif ffi_istype(Vector2, b) then
			r, g, b, a = r, g, b.x, b.y
		-- (float, Vector3)
		elseif ffi_istype(Vector3, g) then
			r, g, b, a = r, g.x, g.y, g.z
		end
		return ffi_new(mt, { elements = { r or 0, g or r or 0, b or (not g and r) or 0, a or 1 }})
	end,
	__index = methods,
	--- Returns a Lua string representation of this color.
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
	-- @tparam Color|Vector3|Vector2|number a
	-- @tparam Color|Vector3|Vector2|number b
	-- @treturn Color
	__add = function(a, b)
		a, b = Color(a), Color(b)
		return Color(a.r + b.r, a.g + b.g, a.b + b.b, a.a + b.a)
	end,
	--- Subtraction operation
	-- @function __sub
	-- @tparam Color|Vector3|Vector2|number a
	-- @tparam Color|Vector3|Vector2|number b
	-- @treturn Color
	__sub = function(a, b)
		a, b = Color(a), Color(b)
		return Color(a.r - b.r, a.g - b.g, a.b - b.b, a.a - b.a)
	end,
	--- Multiplication operation
	-- @function __mul
	-- @tparam Color|Vector3|Vector2|number a
	-- @tparam Color|Vector3|Vector2|number b
	-- @treturn Color
	__mul = function(a, b)
		a, b = Color(a), Color(b)
		return Color(a.r * b.r, a.g * b.g, a.b * b.b, a.a * b.a)
	end,
	--- Division operation
	-- @function __div
	-- @tparam Color|Vector3|Vector2|number a
	-- @tparam Color|Vector3|Vector2|number b
	-- @treturn Color
	__div = function(a, b)
		a, b = Color(a), Color(b)
		return Color(a.r / b.r, a.g / b.g, a.b / b.b, a.a / b.a)
	end,
	--- Module operation
	-- @function __mod
	-- @tparam Color|Vector3|Vector2|number a
	-- @tparam Color|Vector3|Vector2|number b
	-- @treturn Color
	__mod = function(a, b)
		a, b = Color(a), Color(b)
		return Color(a.r % b.r, a.g % b.g, a.b % b.b, a.a % b.a)
	end,
	--- Power operation
	-- @function __pow
	-- @tparam Color|Vector3|Vector2|number a
	-- @tparam Color|Vector3|Vector2|number b
	-- @treturn Color
	__pow = function(a, b)
		a, b = Color(a), Color(b)
		return Color(a.r ^ b.r, a.g ^ b.g, a.b ^ b.b, a.a ^ b.a)
	end,
	--- Unary minus operation: `1 - self`
	-- @function __unm
	-- @treturn Color
	__unm = function(self)
		return 1 - self
	end,
	--- Equality operation
	-- If either `a` or `b` are not of type `Color`, always return `false`.
	-- @function __eq
	-- @tparam Color a
	-- @tparam Color b
	-- @treturn bool
	__eq = function(a, b)
		return ffi_istype(Color, a) and ffi_istype(Color, b) and a.r == b.r and a.g == b.g and a.b == b.b and a.a == b.a
	end,
	--- Less than operation
	-- @function __lt
	-- @tparam Color a
	-- @tparam Color b
	-- @treturn bool
	__lt = function(a, b)
		if a.r == b.r then
			if a.g == b.g then
				if a.b == b.b then
					return a.a < b.a
				else
					return a.b < b.b
				end
			else
				return a.g < b.g
			end
		else
			return a.r < b.r
		end
	end,
})


