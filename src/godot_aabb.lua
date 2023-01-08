-- @file godot_aabb.lua  Wrapper for GDNative's AABB
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

--- AABB metatype, wrapper for `godot_aabb`.
-- Constructed using the idiom `AABB(...)`, which calls `__new`.
--     typedef union godot_aabb {
--         uint8_t data[24];
--         float elements[6];
--         struct { Vector3 position, size; };
--     } godot_aabb;
-- @classmod AABB

local methods = {
	fillvariant = api.godot_variant_new_aabb,
	varianttype = VariantType.AABB,

	--- Returns the volume of the AABB.
	-- @function get_area
	-- @treturn number
	get_area = api.godot_aabb_get_area,
	--- Returns `true` if the AABB is flat or empty.
	-- @function has_no_area
	-- @treturn bool
	has_no_area = api.godot_aabb_has_no_area,
	--- Returns `true` if the AABB is empty.
	-- @function has_no_surface
	-- @treturn bool
	has_no_surface = api.godot_aabb_has_no_surface,
	--- Returns `true` if the AABB overlaps with another.
	-- @function intersects
	-- @tparam AABB with
	-- @treturn bool
	intersects = api.godot_aabb_intersects,
	--- Returns `true` if this AABB completely encloses another one.
	-- @function encloses
	-- @tparam AABB with
	-- @treturn bool
	encloses = api.godot_aabb_encloses,
	--- Returns a larger AABB that contains both this AABB and `with`.
	-- @function merge
	-- @tparam AABB with
	-- @treturn AABB
	merge = api.godot_aabb_merge,
	--- Returns the intersection between two AABB. An empty AABB (size 0,0,0) is returned on failure.
	-- @function intersection
	-- @tparam AABB with
	-- @treturn AABB
	intersection = api.godot_aabb_intersection,
	--- Returns `true` if the AABB is on both sides of a plane.
	-- @function intersects_plane
	-- @tparam Plane plane
	-- @treturn bool
	intersects_plane = api.godot_aabb_intersects_plane,
	--- Returns `true` if the AABB intersects the line segment between `from` and `to`.
	-- @function intersects_segment
	-- @tparam Vector3 from
	-- @tparam Vector3 to
	-- @treturn bool
	intersects_segment = api.godot_aabb_intersects_segment,
	--- Returns `true` if the AABB contains a point.
	-- @function has_point
	-- @tparam Vector3 point
	-- @treturn bool
	has_point = api.godot_aabb_has_point,
	--- Returns the support point in a given `direction`.
	-- This is useful for collision detection algorithms.
	-- @function get_support
	-- @tparam Vector3 direction
	-- @treturn Vector3
	get_support = api.godot_aabb_get_support,
	--- Returns the normalized longest axis of the AABB.
	-- @function get_longest_axis
	-- @treturn Vector3
	get_longest_axis = api.godot_aabb_get_longest_axis,
	--- Returns the index of the longest axis of the AABB (according to Vector3's `AXIS_*` constants).
	-- @function get_longest_axis_index
	-- @treturn int
	get_longest_axis_index = api.godot_aabb_get_longest_axis_index,
	--- Returns the scalar length of the longest axis of the AABB.
	-- @function get_longest_axis_size
	-- @treturn number
	get_longest_axis_size = api.godot_aabb_get_longest_axis_size,
	--- Returns the normalized shortest axis of the AABB.
	-- @function get_shortest_axis
	-- @treturn Vector3
	get_shortest_axis = api.godot_aabb_get_shortest_axis,
	--- Returns the index of the shortest axis of the AABB (according to Vector3's `AXIS_*` constants).
	-- @function get_shortest_axis_index
	-- @treturn int
	get_shortest_axis_index = api.godot_aabb_get_shortest_axis_index,
	--- Returns the scalar length of the shortest axis of the AABB.
	-- @function get_shortest_axis_size
	-- @treturn number
	get_shortest_axis_size = api.godot_aabb_get_shortest_axis_size,
	--- Returns this AABB expanded to include a given `point`.
	-- @function expand
	-- @tparam Vector3 point
	-- @treturn AABB
	expand = api.godot_aabb_expand,
	--- Returns a copy of the AABB grown a given amount of units towards all the sides.
	-- @function grow
	-- @tparam number by
	-- @treturn AABB
	grow = api.godot_aabb_grow,
	--- Gets the position of the 8 endpoints of the AABB in space.
	-- @function get_endpoint
	-- @tparam int index
	-- @treturn Vector3
	get_endpoint = api.godot_aabb_get_endpoint,
}

AABB = ffi_metatype('godot_aabb', {
	--- AABB constructor, called by the idiom `AABB(...)`.
	--
	-- * `AABB()`: all zeros (`AABB() == AABB(Vector3.ZERO, Vector3.ZERO)`)
	-- * `AABB(Vector3 position, Vector3 size)`: set position and size
	-- * `AABB(AABB other)`: copy values from `other`
	-- @function __new
	-- @param ...
	-- @treturn AABB
	__new = function(mt, position, size)
		if ffi_istype(mt, position) then
			return ffi_new(mt, position)
		else
			return ffi_new(mt, { position = position, size = size })
		end
	end,
	__index = methods,
	--- Returns a Lua string representation of this AABB.
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
	-- If either `a` or `b` are not of type `AABB`, always return `false`.
	-- @function __eq
	-- @tparam AABB a
	-- @tparam AABB b
	-- @treturn bool
	__eq = function(a, b)
		return ffi_istype(AABB, a) and ffi_istype(AABB, b) and a.position == b.position and a.size == b.size
	end,
})


