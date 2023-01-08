-- @file godot_plane.lua  Wrapper for GDNative's Plane
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

--- Plane metatype, wrapper for `godot_plane`.
-- Constructed using the idiom `Plane(...)`, which calls `__new`.
--
-- The components may be accessed through `elements` or individually as
-- `normal/d`:
--     typedef union godot_plane {
--         float elements[4];
--         struct { Vector3 normal; float d; };
--     } godot_plane;
-- @classmod Plane

local methods = {
	fillvariant = api.godot_variant_new_plane,
	varianttype = VariantType.Plane,

	--- Returns a copy of the plane, normalized.
	-- @function normalized
	-- @treturn Plane
	normalized = api.godot_plane_normalized,
	--- Returns the center of the plane.
	-- @function center
	-- @treturn Vector3
	center = api.godot_plane_center,
	--- Returns `true` if `point` is located above the plane.
	-- @function is_point_over
	-- @tparam Vector2 point
	-- @treturn bool
	is_point_over = api.godot_plane_is_point_over,
	--- Returns the shortest distance from the plane to the position `point`.
	-- @function distance_to
	-- @tparam Vector3 point
	-- @treturn number
	distance_to = api.godot_plane_distance_to,
	--- Returns `true` if `point` is inside the plane.
	-- Comparison uses a custom minimum `epsilon` threshold.
	-- @function has_point
	-- @tparam Vector3 point
	-- @tparam[opt=1e-5] number epsilon
	-- @treturn bool
	has_point = function(self, point, epsilon)
		return api.godot_plane_has_point(self, point, epsilon or 1e-5)
	end,
	--- Returns the orthogonal projection of `point` into a point in the plane.
	-- @function project
	-- @tparam Vector3 point
	-- @treturn Vector3
	project = api.godot_plane_project,
	--- Returns the intersection point of the three planes `b`, `c` and this plane.
	-- @function intersect_3
	-- @tparam Plane b
	-- @tparam Plane c
	-- @treturn[1] Vector3  Intersection point, if there is any
	-- @treturn[2] nil  If no intersection is found
	intersect_3 = function(self, b, c)
		local dest = Vector3()
		if api.godot_plane_intersect_3(self, dest, b, c) then
			return dest
		else
			return nil
		end
	end,
	--- Returns the intersection point of a ray consisting of the position `from` and the direction normal `dir` with this plane.
	-- @function intersects_ray
	-- @tparam Vector3 from
	-- @tparam Vector3 dir
	-- @treturn[1] Vector3  Intersection point, if there is any
	-- @treturn[2] nil  If no intersection is found
	intersects_ray = function(self, from, dir)
		local dest = Vector3()
		if api.godot_plane_intersects_ray(self, dest, from, dir) then
			return dest
		else
			return nil
		end
	end,
	--- Returns the intersection point of a segment from position `begin` to position `end` with this plane.
	-- @function intersects_segment
	-- @tparam Vector3 begin
	-- @tparam Vector3 end
	-- @treturn[1] Vector3  Intersection point, if there is any
	-- @treturn[2] nil  If no intersection is found
	intersects_segment = function(self, begin, end_)
		local dest = Vector3()
		if api.godot_plane_intersects_segment(self, dest, begin, end_) then
			return dest
		else
			return nil
		end
	end,
}

--- Returns all elements.
-- @function unpack
-- @treturn number normal.x
-- @treturn number normal.y
-- @treturn number normal.z
-- @treturn number d
methods.unpack = function(self)
	return self.normal.x, self.normal.y, self.normal.z, self.d
end

--- Constants
-- @section constants

--- A plane that extends in the Y and Z axes (normal vector points +X).
-- @field YZ  Plane(1, 0, 0, 0)

--- A plane that extends in the X and Z axes (normal vector points +Y).
-- @field XZ  Plane(0, 1, 0, 0)

--- A plane that extends in the X and Y axes (normal vector points +Z).
-- @field XY  Plane(0, 0, 1, 0)

--- @section end

methods.YZ = ffi_new('godot_plane', { elements = { 1, 0, 0, 0 } })
methods.XZ = ffi_new('godot_plane', { elements = { 0, 1, 0, 0 } })
methods.XY = ffi_new('godot_plane', { elements = { 0, 0, 1, 0 } })

--- Metamethods
-- @section metamethods
Plane = ffi_metatype('godot_plane', {
	--- Plane constructor, called by the idiom `Plane(...)`.
	--
	-- * `Plane(Vector3 normal, number d)`: set the normal and the plane's distance to the origin
	-- * `Plane(number a, number b, number c, number d)`: normal is set to `Vector3(a, b, c)`, distance is set to `d`
	-- * `Plane(Vector3 a, Vector3 b, Vector3 c)`: creates a plane from the three points, given in clockwise order
	-- * `Plane(Plane other)`: copy values from `other`
	-- @function __new
	-- @param ...
	-- @treturn Plane
	__new = function(mt, a, b, c, d)
		if ffi_istype(mt, a) then
			return ffi_new(mt, a)
		end
		local self = ffi_new(mt)
		if ffi_istype(Vector3, a) then
			if ffi.istype(Vector3, b) then
				api.godot_plane_new_with_vectors(self, a, b, c)
			else
				api.godot_plane_new_with_normal(self, a, b)
			end
		else
			api.godot_plane_new_with_reals(self, a, b, c, d)
		end
		return self
	end,
	__index = methods,
	--- Returns a Lua string representation of this plane.
	-- @function __tostring
	-- @treturn string
	__tostring = gd_tostring,
	--- Concatenates values.
	-- @function __concat
	-- @param a  First value, stringified with `GD.str`
	-- @param b  First value, stringified with `GD.str`
	-- @treturn String
	__concat = concat_gdvalues,
	--- Unary minus operation
	-- @function __unm
	-- @treturn Plane
	__unm = function(self)
		return Plane(-self.normal, -self.d)
	end,
	--- Equality operation
	-- If either `a` or `b` are not of type `Plane`, always return `false`.
	-- @function __eq
	-- @tparam Plane a
	-- @tparam Plane b
	-- @treturn bool
	__eq = function(a, b)
		return a.d == b.d and a.normal == b.normal
	end,
})


