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
		if ffi.istype(mt, x) then
			return ffi.new(mt, x)
		elseif ffi.istype(Vector2, x) then
			return ffi.new(mt, { x = x.x, y = x.y, z = y })
		elseif ffi.istype(Vector2, y) then
			return ffi.new(mt, { x = x, y = y.x, z = y.y })
		else
			return ffi.new(mt, { elements = { x, y, z }})
		end
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

Vector4 = ffi.metatype('godot_vector4', {
	__tostring = GD.tostring,
	__index = {
		tovariant = ffi.C.hgdn_new_color_variant,
		varianttype = GD.TYPE_COLOR,
	},
	__concat = concat_gdvalues,
})
Color = Vector4

Rect2 = ffi.metatype('godot_rect2', {
	__tostring = GD.tostring,
	__index = {
		tovariant = ffi.C.hgdn_new_rect2_variant,
		varianttype = GD.TYPE_RECT2,
	},
	__concat = concat_gdvalues,
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
