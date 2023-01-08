-- @file godot_rect2.lua  Wrapper for GDNative's Rect2
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

--- Color metatype, wrapper for `godot_rect2`.
-- Construct using the idiom `Rect2(...)`, which calls `__new`.
--
-- Components may be accessed through `elements`, individually using
-- `x/y/width/height` or as `Vector2` `position/size`:
--     typedef union godot_rect2 {
--         uint8_t data[16];
--         float elements[4];
--         struct { float x, y, width, height; };
--         struct { Vector2 position; Vector2 size; };
--     } godot_rect2;
-- @classmod Rect2

local methods = {
	fillvariant = api.godot_variant_new_rect2,
	varianttype = VariantType.Rect2,

	--- Returns the area of the Rect2.
	-- @function get_area
	-- @treturn number
	get_area = api.godot_rect2_get_area,
	--- Returns `true` if the Rect2 overlaps with `b`. (i.e. they have at least one point in common).
	-- @function intersects
	-- @tparam Rect2 b
	-- @param[opt=false] include_borders  If `true`, they will also be considered overlapping if their borders touch, even without intersection.
	-- @treturn bool
	intersects = function(self, b, include_borders)
		return api.godot_rect2_intersects(self, b, include_borders or false)
	end,
	--- Returns `true` if this Rect2 completely encloses another one.
	-- @function encloses
	-- @tparam Rect2 b
	-- @treturn bool
	encloses = api.godot_rect2_encloses,
	--- Returns `true` if the Rect2 is flat or empty.
	-- @function has_no_area
	-- @treturn bool
	has_no_area = api.godot_rect2_has_no_area,
	--- Returns the intersection of this Rect2 and `b`.
	-- @function clip
	-- @tparam Rect2 b
	-- @treturn Rect2
	clip = api.godot_rect2_clip,
	--- Returns a larger Rect2 that contains this Rect2 and `b`.
	-- @function merge
	-- @tparam Rect2 b
	-- @treturn Rect2
	merge = api.godot_rect2_merge,
	--- Returns `true` if the Rect2 contains a point.
	-- @function has_point
	-- @tparam Vector2 point
	-- @treturn bool
	has_point = api.godot_rect2_has_point,
	--- Returns a copy of the Rect2 grown a given `amount` of units towards all the sides.
	-- @function grow
	-- @tparam number amount
	-- @treturn Rect2
	grow = api.godot_rect2_grow,
	--- Returns this Rect2 expanded to include a given point.
	-- @function expand
	-- @tparam Vector2 point
	-- @treturn Rect2
	expand = api.godot_rect2_expand,
}

--- Returns all elements.
-- @function unpack
-- @treturn number X
-- @treturn number Y
-- @treturn number width
-- @treturn number height
methods.unpack = function(self)
	return self.x, self.y, self.width, self.height
end

if api_1_1 then
	--- Returns a copy of the Rect2 grown a given amount of units towards each direction individually.
	-- @function grow_individual
	-- @tparam number left
	-- @tparam number top
	-- @tparam number right
	-- @tparam number bottom
	-- @treturn Rect2
	methods.grow_individual = api_1_1.godot_rect2_grow_individual
	--- Returns a copy of the Rect2 grown a given amount of units towards the Margin direction.
	-- @function grow_margin
	-- @tparam int margin
	-- @tparam number amount
	-- @treturn Rect2
	methods.grow_margin = api_1_1.godot_rect2_grow_margin
	--- Returns a Rect2 with equivalent position and area, modified so that the top-left corner is the origin and `width` and `height` are positive.
	-- @function abs
	-- @treturn Rect2
	methods.abs = api_1_1.godot_rect2_abs
end

Rect2 = ffi_metatype('godot_rect2', {
	--- Rect2 constructor, called by the idiom `Rect2(...)`.
	--
	-- * `Rect2()`: all zeros (`Rect2() == Rect2(0, 0, 0, 0)`)
	-- * `Rect2(number x, number y, number width, number height)`: set XY and width/height
	-- * `Rect2(Vector2 position, Vector2 size)`: set position and size
	-- * `Rect2(Rect2 other)`: copy values from `other`
	-- @function __new
	-- @param ...
	-- @treturn Rect2
	__new = function(mt, x, y, width, height)
		if ffi_istype(mt, x) then
			return ffi_new(mt, x)
		elseif ffi_istype(Vector2, x) then
			-- (Vector2, Vector2)
			if ffi_istype(Vector2, y) then
				x, y, width, height = x.x, x.y, y.x, y.y
			-- (Vector2, float?, float?)
			else
				x, y, width, height = x.x, x.y, y, width
			end
		-- (float, float, Vector2)
		elseif ffi_istype(Vector2, width) then
			x, y, width, height = x, y, width.x, width.y
		end
		return ffi_new(mt, { x = x, y = y, width = width, height = height })
	end,
	__index = methods,
	--- Returns a Lua string representation of this rect.
	-- @function __tostring
	-- @treturn string
	__tostring = gd_tostring,
	--- Concatenates values.
	-- @function __concat
	-- @param a  First value, stringified with `GD.str`
	-- @param b  First value, stringified with `GD.str`
	-- @treturn String
	__concat = concat_gdvalues,
	--- Equality operation
	-- @function __eq
	-- @tparam Rect2 a
	-- @tparam Rect2 b
	-- @treturn bool
	__eq = function(a, b)
		return a.x == b.x and a.y == b.y and a.width == b.width and a.height == b.height
	end,
})


