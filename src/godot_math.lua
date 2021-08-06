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
	tovariant = ffi.C.hgdn_new_color_variant,
	varianttype = GD.TYPE_COLOR,

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

local plane_methods = {
	tovariant = ffi.C.hgdn_new_plane_variant,
	varianttype = GD.TYPE_PLANE,

	as_string = api.godot_plane_as_string,
	normalized = api.godot_plane_normalized,
	center = api.godot_plane_center,
	get_any_point = api.godot_plane_get_any_point,
	is_point_over = api.godot_plane_is_point_over,
	distance_to = api.godot_plane_distance_to,
	has_point = api.godot_plane_has_point,
	project = api.godot_plane_project,
	intersect_3 = function(self, b, c)
		local dest = Vector3()
		if api.godot_plane_intersect_3(self, dest, b, c) then
			return dest
		else
			return nil
		end
	end,
	intersects_ray = function(self, from, dir)
		local dest = Vector3()
		if api.godot_plane_intersects_ray(self, dest, from, dir) then
			return dest
		else
			return nil
		end
	end,
	intersects_segment = function(self, begin, end_)
		local dest = Vector3()
		if api.godot_plane_intersects_segment(self, dest, begin, end_) then
			return dest
		else
			return nil
		end
	end,
}

Plane = ffi.metatype('godot_plane', {
	__new = function(mt, a, b, c, d)
		if ffi.istype(mt, a) then
			return ffi.new(mt, a)
		elseif ffi.istype(Vector3, a) then
			if ffi.istype(Vector3, b) then
				local self = ffi.new(mt)
				api.godot_plane_new_with_vectors(self, a, b, c)
				return self
			else
				return ffi.new(mt, { normal = a, d = b })
			end
		else
			return ffi.new(mt, { normal = Vector3(a, b, c), d = d })
		end
	end,
	__tostring = GD.tostring,
	__index = plane_methods,
	__concat = concat_gdvalues,
	__unm = function(self)
		return api.godot_plane_operator_neg(self)
	end,
	__eq = function(a, b)
		return a.d == b.d and a.normal == b.normal
	end,
})

local quat_methods = {
	tovariant = ffi.C.hgdn_new_quat_variant,
	varianttype = GD.TYPE_QUAT,

	as_string = api.godot_quat_as_string,
	length = api.godot_quat_length,
	length_squared = api.godot_quat_length_squared,
	normalized = api.godot_quat_normalized,
	is_normalized = api.godot_quat_is_normalized,
	inverse = api.godot_quat_inverse,
	dot = api.godot_quat_dot,
	xform = api.godot_quat_xform,
	slerp = api.godot_quat_slerp,
	slerpni = api.godot_quat_slerpni,
	cubic_slerp = api.godot_quat_cubic_slerp,
}

if api_1_1 then
	quat_methods.set_axis_angle = api_1_1.godot_quat_set_axis_angle
end

Quat = ffi.metatype('godot_quat', {
	__new = function(mt, x, y, z, w)
		if ffi.istype(mt, x) then
			return ffi.new(mt, x)
		elseif ffi.istype(Vector3, x) then
			local self = ffi.new(mt)
			if y then
				api.godot_quat_new_with_axis_angle(self, x, y)
			else
				assert(api_1_1, "Core API 1.1 is necessary for initializing Quat from Euler angles").godot_quat_new_with_euler(self, x)
			end
			return self
		elseif api_1_1 and ffi.istype(Basis, x) then
			local self = ffi.new(mt)
			api_1_1.godot_quat_new_with_basis(self, x)
			return self
		end
		return ffi.new(mt, { x = x, y = y, z = z, w = w or 1 })
	end,
	__tostring = GD.tostring,
	__index = quat_methods,
	__concat = concat_gdvalues,
	__eq = function(a, b)
		return a.x == b.x and a.y == b.y and a.z == b.z and a.w == b.w
	end,
	__add = function(a, b)
		return Quat(a.x + b.x, a.y + b.y, a.z + b.z, a.w + b.w)
	end,
	__sub = function(a, b)
		return Quat(a.x - b.x, a.y - b.y, a.z - b.z, a.w - b.w)
	end,
	__mul = function(self, s)
		return Quat(self.x * s, self.y * s, self.z * s, self.w * s)
	end,
	__div = function(self, s)
		return self * (1.0 / s)
	end,
	__unm = function(self)
		return Quat(-self.x, -self.y, -self.z, -self.w)
	end,
})

local basis_methods = {
	tovariant = ffi.C.hgdn_new_basis_variant,
	varianttype = GD.TYPE_BASIS,

	as_string = api.godot_basis_as_string,
	inverse = api.godot_basis_inverse,
	transposed = api.godot_basis_transposed,
	orthonormalized = api.godot_basis_orthonormalized,
	determinant = api.godot_basis_determinant,
	rotated = api.godot_basis_rotated,
	scaled = api.godot_basis_scaled,
	get_scale = api.godot_basis_get_scale,
	get_euler = api.godot_basis_get_euler,
	tdotx = api.godot_basis_tdotx,
	tdoty = api.godot_basis_tdoty,
	tdotz = api.godot_basis_tdotz,
	xform = api.godot_basis_xform,
	xform_inv = api.godot_basis_xform_inv,
	get_orthogonal_index = api.godot_basis_get_orthogonal_index,
	get_axis = api.godot_basis_get_axis,
	set_axis = api.godot_basis_set_axis,
	get_row = api.godot_basis_get_row,
	set_row = api.godot_basis_set_row,
}

if api_1_1 then
	basis_methods.slerp = api_1_1.godot_basis_slerp
	basis_methods.get_quat = api_1_1.godot_basis_get_quat
	basis_methods.set_quat = api_1_1.godot_basis_set_quat
	basis_methods.set_axis_angle_scale = api_1_1.godot_basis_set_axis_angle_scale
	basis_methods.set_euler_scale = api_1_1.godot_basis_set_euler_scale
	basis_methods.set_quat_scale = api_1_1.godot_basis_set_quat_scale
end

Basis = ffi.metatype('godot_basis', {
	__new = function(mt, x, y, z)
		if ffi.istype(mt, x) then
			return ffi.new(mt, x)
		end
		local self = ffi.new(mt)
		if ffi.istype(Vector3, x) then
			if ffi.istype(Vector3, y) then
				api.godot_basis_new_with_rows(self, x, y, z)
			elseif y then
				api.godot_basis_new_with_axis_and_angle(self, x, y)
			else
				api.godot_basis_new_with_euler(self, x)
			end
		elseif ffi.istype(Quat, x) then
			api.godot_basis_new_with_euler_quat(self, x)
		else
			api.godot_basis_new(self)
		end
		return self
	end,
	__tostring = GD.tostring,
	__index = basis_methods,
	__concat = concat_gdvalues,
	__eq = function(a, b)
		return a.elements[0] == b.elements[0] and a.elements[1] == b.elements[1] and a.elements[2] == b.elements[2]
	end,
	__add = function(a, b)
		return Basis(a.elements[0] + b.elements[0], a.elements[1] + b.elements[1], a.elements[2] + b.elements[2])
	end,
	__sub = function(a, b)
		return Basis(a.elements[0] - b.elements[0], a.elements[1] - b.elements[1], a.elements[2] - b.elements[2])
	end,
	__mul = function(a, b)
		if ffi.istype(Basis, a) then
			if ffi.istype(Basis, b) then
				return api.godot_basis_operator_multiply_vector(a, b)
			else
				return Basis(a.elements[0] * b, a.elements[1] * b, a.elements[2] * b)
			end
		else
			return Basis(a * b.elements[0], a * b.elements[1], a * b.elements[2])
		end
	end,
})

local aabb_methods = {
	tovariant = ffi.C.hgdn_new_aabb_variant,
	varianttype = GD.TYPE_AABB,

	as_string = api.godot_aabb_as_string,
	get_area = api.godot_aabb_get_area,
	has_no_area = api.godot_aabb_has_no_area,
	has_no_surface = api.godot_aabb_has_no_surface,
	intersects = api.godot_aabb_intersects,
	encloses = api.godot_aabb_encloses,
	merge = api.godot_aabb_merge,
	intersection = api.godot_aabb_intersection,
	intersects_plane = api.godot_aabb_intersects_plane,
	intersects_segment = api.godot_aabb_intersects_segment,
	has_point = api.godot_aabb_has_point,
	get_support = api.godot_aabb_get_support,
	get_longest_axis = api.godot_aabb_get_longest_axis,
	get_longest_axis_index = api.godot_aabb_get_longest_axis_index,
	get_longest_axis_size = api.godot_aabb_get_longest_axis_size,
	get_shortest_axis = api.godot_aabb_get_shortest_axis,
	get_shortest_axis_index = api.godot_aabb_get_shortest_axis_index,
	get_shortest_axis_size = api.godot_aabb_get_shortest_axis_size,
	expand = api.godot_aabb_expand,
	grow = api.godot_aabb_grow,
	get_endpoint = api.godot_aabb_get_endpoint,
}

AABB = ffi.metatype('godot_aabb', {
	__tostring = GD.tostring,
	__index = aabb_methods,
	__concat = concat_gdvalues,
	__eq = function(a, b)
		return a.position == b.position and a.size == b.size
	end,
})

local transform2d_methods = {
	tovariant = ffi.C.hgdn_new_transform2d_variant,
	varianttype = GD.TYPE_TRANSFORM2D,

	new = api.godot_transform2d_new,
	new_axis_origin = api.godot_transform2d_new_axis_origin,
	as_string = api.godot_transform2d_as_string,
	inverse = api.godot_transform2d_inverse,
	affine_inverse = api.godot_transform2d_affine_inverse,
	get_rotation = api.godot_transform2d_get_rotation,
	get_origin = api.godot_transform2d_get_origin,
	get_scale = api.godot_transform2d_get_scale,
	orthonormalized = api.godot_transform2d_orthonormalized,
	rotated = api.godot_transform2d_rotated,
	scaled = api.godot_transform2d_scaled,
	translated = api.godot_transform2d_translated,
	xform_vector2 = api.godot_transform2d_xform_vector2,
	xform_inv_vector2 = api.godot_transform2d_xform_inv_vector2,
	basis_xform_vector2 = api.godot_transform2d_basis_xform_vector2,
	basis_xform_inv_vector2 = api.godot_transform2d_basis_xform_inv_vector2,
	interpolate_with = api.godot_transform2d_interpolate_with,
	new_identity = api.godot_transform2d_new_identity,
	xform_rect2 = api.godot_transform2d_xform_rect2,
	xform_inv_rect2 = api.godot_transform2d_xform_inv_rect2,
}

Transform2D = ffi.metatype('godot_transform2d', {
	__new = function(mt, x, y, origin)
		if ffi.istype(mt, x) then
			return ffi.new(mt, x)
		end
		local self = ffi.new(mt)
		if not x then
			self:new_identity()
		elseif tonumber(x) then
			self:new(x, y)
		else
			self:new_axis_origin(x, y, origin)
		end
		return self
	end,
	__tostring = GD.tostring,
	__index = transform2d_methods,
	__concat = concat_gdvalues,
	__eq = function(a, b)
		return a.elements[0] == b.elements[0] and a.elements[1] == b.elements[1] and a.elements[2] == b.elements[2]
	end,
	__mul = api.godot_transform2d_operator_multiply,
})

Transform = ffi.metatype('godot_transform', {
	__tostring = GD.tostring,
	__index = {
		tovariant = ffi.C.hgdn_new_transform_variant,
		varianttype = GD.TYPE_TRANSFORM,
	},
	__concat = concat_gdvalues,
})
