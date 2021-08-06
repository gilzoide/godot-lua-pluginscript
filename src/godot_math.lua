local vector2_methods = {
	tovariant = ffi.C.hgdn_new_vector2_variant,
	varianttype = GD.TYPE_VECTOR2,

	as_string = api.godot_vector2_as_string,
	normalized = api.godot_vector2_normalized,
	length = api.godot_vector2_length,
	angle = api.godot_vector2_angle,
	length_squared = api.godot_vector2_length_squared,
	is_normalized = api.godot_vector2_is_normalized,
	distance_to = api.godot_vector2_distance_to,
	distance_squared_to = api.godot_vector2_distance_squared_to,
	angle_to = api.godot_vector2_angle_to,
	angle_to_point = api.godot_vector2_angle_to_point,
	linear_interpolate = api.godot_vector2_linear_interpolate,
	cubic_interpolate = api.godot_vector2_cubic_interpolate,
	rotated = api.godot_vector2_rotated,
	tangent = api.godot_vector2_tangent,
	floor = api.godot_vector2_floor,
	snapped = api.godot_vector2_snapped,
	aspect = api.godot_vector2_aspect,
	dot = api.godot_vector2_dot,
	slide = api.godot_vector2_slide,
	bounce = api.godot_vector2_bounce,
	reflect = api.godot_vector2_reflect,
	abs = api.godot_vector2_abs,
	clamped = api.godot_vector2_clamped,
}

if api_1_2 then
	vector2_methods.move_toward = api_1_2.godot_vector2_move_toward
	vector2_methods.direction_to = api_1_2.godot_vector2_direction_to
end

Vector2 = ffi.metatype('godot_vector2', {
	__new = function(mt, x, y)
		if ffi.istype(mt, x) then
			return ffi.new(mt, x)
		else
			return ffi.new(mt, { elements = { x, y }})
		end
	end,
	__tostring = GD.tostring,
	__index = vector2_methods,
	__concat = concat_gdvalues,
	__add = function(a, b)
		a, b = Vector2(a), Vector2(b)
		return Vector2(a.x + b.x, a.y + b.y)
	end,
	__sub = function(a, b)
		a, b = Vector2(a), Vector2(b)
		return Vector2(a.x - b.x, a.y - b.y)
	end,
	__mul = function(a, b)
		a, b = Vector2(a), Vector2(b)
		return Vector2(a.x * b.x, a.y * b.y)
	end,
	__div = function(a, b)
		a, b = Vector2(a), Vector2(b)
		return Vector2(a.x / b.x, a.y / b.y)
	end,
	__mod = function(a, b)
		a, b = Vector2(a), Vector2(b)
		return Vector2(a.x % b.x, a.y % b.y)
	end,
	__pow = function(a, b)
		a, b = Vector2(a), Vector2(b)
		return Vector2(a.x ^ b.x, a.y ^ b.y)
	end,
	__unm = function(a)
		a = Vector2(a)
		return Vector2(-a.x, -a.y)
	end,
	__eq = function(a, b)
		a, b = Vector2(a), Vector2(b)
		return a.x == b.x and a.y == b.y
	end,
	__lt = function(a, b)
		a, b = Vector2(a), Vector2(b)
		if a.x == b.x then
			return a.y < b.y
		else
			return a.x < b.x
		end
	end,
})

local vector3_methods = {
	tovariant = ffi.C.hgdn_new_vector3_variant,
	varianttype = GD.TYPE_VECTOR3,

	as_string = api.godot_vector3_as_string,
	min_axis = api.godot_vector3_min_axis,
	max_axis = api.godot_vector3_max_axis,
	length = api.godot_vector3_length,
	length_squared = api.godot_vector3_length_squared,
	is_normalized = api.godot_vector3_is_normalized,
	normalized = api.godot_vector3_normalized,
	inverse = api.godot_vector3_inverse,
	snapped = api.godot_vector3_snapped,
	rotated = api.godot_vector3_rotated,
	linear_interpolate = api.godot_vector3_linear_interpolate,
	cubic_interpolate = api.godot_vector3_cubic_interpolate,
	dot = api.godot_vector3_dot,
	cross = api.godot_vector3_cross,
	outer = api.godot_vector3_outer,
	to_diagonal_matrix = api.godot_vector3_to_diagonal_matrix,
	abs = api.godot_vector3_abs,
	floor = api.godot_vector3_floor,
	ceil = api.godot_vector3_ceil,
	distance_to = api.godot_vector3_distance_to,
	distance_squared_to = api.godot_vector3_distance_squared_to,
	angle_to = api.godot_vector3_angle_to,
	slide = api.godot_vector3_slide,
	bounce = api.godot_vector3_bounce,
	reflect = api.godot_vector3_reflect,
}

if api_1_2 then
	vector3_methods.move_toward = api_1_2.godot_vector3_move_toward
	vector3_methods.direction_to = api_1_2.godot_vector3_direction_to
end

Vector3 = ffi.metatype('godot_vector3', {
	__new = function(mt, x, y, z)
		-- (Vector3)
		if ffi.istype(mt, x) then
			return ffi.new(mt, x)
		-- (Vector2, float?)
		elseif ffi.istype(Vector2, x) then
			x, y, z = x.x, x.y, y
		-- (float, Vector2)
		elseif ffi.istype(Vector2, y) then
			x, y, z = x, y.x, y.y
		end
		return ffi.new(mt, { elements = { x, y, z }})
	end,
	__tostring = GD.tostring,
	__index = vector3_methods,
	__concat = concat_gdvalues,
	__add = function(a, b)
		a, b = Vector3(a), Vector3(b)
		return Vector3(a.x + b.x, a.y + b.y, a.z + b.z)
	end,
	__sub = function(a, b)
		a, b = Vector3(a), Vector3(b)
		return Vector3(a.x - b.x, a.y - b.y, a.z - b.z)
	end,
	__mul = function(a, b)
		a, b = Vector3(a), Vector3(b)
		return Vector3(a.x * b.x, a.y * b.y, a.z * b.z)
	end,
	__div = function(a, b)
		a, b = Vector3(a), Vector3(b)
		return Vector3(a.x / b.x, a.y / b.y, a.z / b.z)
	end,
	__mod = function(a, b)
		a, b = Vector3(a), Vector3(b)
		return Vector3(a.x % b.x, a.y % b.y, a.z % b.z)
	end,
	__pow = function(a, b)
		a, b = Vector3(a), Vector3(b)
		return Vector3(a.x ^ b.x, a.y ^ b.y, a.z ^ b.z)
	end,
	__unm = function(a)
		a = Vector3(a)
		return Vector3(-a.x, -a.y, -a.z)
	end,
	__eq = function(a, b)
		a, b = Vector3(a), Vector3(b)
		return a.x == b.x and a.y == b.y and a.z == b.z
	end,
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

local color_methods = {
	get_h = api.godot_color_get_h,
	get_s = api.godot_color_get_s,
	get_v = api.godot_color_get_v,
	as_string = api.godot_color_as_string,
	to_rgba32 = api.godot_color_to_rgba32,
	to_argb32 = api.godot_color_to_argb32,
	gray = api.godot_color_gray,
	inverted = api.godot_color_inverted,
	contrasted = api.godot_color_contrasted,
	linear_interpolate = api.godot_color_linear_interpolate,
	blend = api.godot_color_blend,
	to_html = api.godot_color_to_html,
}

if api_1_1 then
	color_methods.to_abgr32 = api_1_1.godot_color_to_abgr32
	color_methods.to_abgr64 = api_1_1.godot_color_to_abgr64
	color_methods.to_argb64 = api_1_1.godot_color_to_argb64
	color_methods.to_rgba64 = api_1_1.godot_color_to_rgba64
	color_methods.darkened = api_1_1.godot_color_darkened
	color_methods.from_hsv = api_1_1.godot_color_from_hsv
	color_methods.lightened = api_1_1.godot_color_lightened
end

Color = ffi.metatype('godot_color', {
	__new = function(mt, r, g, b, a)
		if ffi.istype(mt, r) then
			return ffi.new(mt, r)
		elseif ffi.istype(Vector2, r) then
			-- (Vector2, Vector2)
			if ffi.istype(Vector2, g) then
				r, g, b, a = r.x, r.y, g.x, g.y
			-- (Vector2, float?, float?)
			else
				r, g, b, a = r.x, r.y, g, b
			end
		-- (Vector3, float?)
		elseif ffi.istype(Vector3, r) then
			r, g, b, a = r.x, r.y, r.z, g
		-- (float, Vector2, float?)
		elseif ffi.istype(Vector2, g) then
			r, g, b, a = r, g.x, g.y, b
		-- (float, float, Vector2)
		elseif ffi.istype(Vector2, b) then
			r, g, b, a = r, g, b.x, b.y
		-- (float, Vector3)
		elseif ffi.istype(Vector3, g) then
			r, g, b, a = r, g.x, g.y, g.z
		end
		return ffi.new(mt, { elements = { r or 0, g or 0, b or 0, a or 1 }})
	end,
	__tostring = GD.tostring,
	__index = color_methods,
	__concat = concat_gdvalues,
	__eq = function(a, b)
		return a.r == b.r and a.g == b.g and a.b == b.b and a.a == b.a
	end,
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

local rect2_methods = {
	tovariant = ffi.C.hgdn_new_rect2_variant,
	varianttype = GD.TYPE_RECT2,

	as_string = api.godot_rect2_as_string,
	get_area = api.godot_rect2_get_area,
	intersects = api.godot_rect2_intersects,
	encloses = api.godot_rect2_encloses,
	has_no_area = api.godot_rect2_has_no_area,
	clip = api.godot_rect2_clip,
	merge = api.godot_rect2_merge,
	has_point = api.godot_rect2_has_point,
	grow = api.godot_rect2_grow,
	expand = api.godot_rect2_expand,
}

if api_1_1 then
	rect2_methods.grow_individual = api_1_1.godot_rect2_grow_individual
	rect2_methods.grow_margin = api_1_1.godot_rect2_grow_margin
	rect2_methods.abs = api_1_1.godot_rect2_abs
end

Rect2 = ffi.metatype('godot_rect2', {
	__new = function(mt, x, y, width, height)
		if ffi.istype(mt, x) then
			return ffi.new(mt, x)
		elseif ffi.istype(Vector2, x) then
			-- (Vector2, Vector2)
			if ffi.istype(Vector2, y) then
				x, y, width, height = x.x, x.y, y.x, y.y
			-- (Vector2, float?, float?)
			else
				x, y, width, height = x.x, x.y, y, width
			end
		-- (float, float, Vector2)
		elseif ffi.istype(Vector2, width) then
			x, y, width, height = x, y, width.x, width.y
		end
		return ffi.new(mt, { x = x, y = y, width = width, height = height })
	end,
	__tostring = GD.tostring,
	__index = rect2_methods,
	__concat = concat_gdvalues,
	__eq = function(a, b)
		return a.x == b.x and a.y == b.y and a.width == b.width and a.height == b.height
	end,
})

Plane = ffi.metatype('godot_plane', {
	__tostring = GD.tostring,
	__index = {
		tovariant = ffi.C.hgdn_new_plane_variant,
		varianttype = GD.TYPE_PLANE,
	},
	__concat = concat_gdvalues,
})

Quat = ffi.metatype('godot_quat', {
	__tostring = GD.tostring,
	__index = {
		tovariant = ffi.C.hgdn_new_quat_variant,
		varianttype = GD.TYPE_QUAT,
	},
	__concat = concat_gdvalues,
})

Basis = ffi.metatype('godot_basis', {
	__tostring = GD.tostring,
	__index = {
		tovariant = ffi.C.hgdn_new_basis_variant,
		varianttype = GD.TYPE_BASIS,
	},
	__concat = concat_gdvalues,
})

AABB = ffi.metatype('godot_aabb', {
	__tostring = GD.tostring,
	__index = {
		tovariant = ffi.C.hgdn_new_aabb_variant,
		varianttype = GD.TYPE_AABB,
	},
	__concat = concat_gdvalues,
})

Transform2D = ffi.metatype('godot_transform2d', {
	__tostring = GD.tostring,
	__index = {
		tovariant = ffi.C.hgdn_new_transform2d_variant,
		varianttype = GD.TYPE_TRANSFORM2D,
	},
	__concat = concat_gdvalues,
})

Transform = ffi.metatype('godot_transform', {
	__tostring = GD.tostring,
	__index = {
		tovariant = ffi.C.hgdn_new_transform_variant,
		varianttype = GD.TYPE_TRANSFORM,
	},
	__concat = concat_gdvalues,
})
