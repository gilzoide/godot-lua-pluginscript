Vector2 = ffi.metatype('godot_vector2', {
	__tostring = GD.tostring,
	__index = {
		tovariant = ffi.C.hgdn_new_vector2_variant,
	},
})

Vector3 = ffi.metatype('godot_vector3', {
	__tostring = GD.tostring,
	__index = {
		tovariant = ffi.C.hgdn_new_vector3_variant,
	},
})

Vector4 = ffi.metatype('godot_vector4', {
	__tostring = GD.tostring,
	__index = {
		tovariant = ffi.C.hgdn_new_color_variant,
	},
})
Color = Vector4

Rect2 = ffi.metatype('godot_rect2', {
	__tostring = GD.tostring,
	__index = {
		tovariant = ffi.C.hgdn_new_rect2_variant,
	},
})

Plane = ffi.metatype('godot_plane', {
	__tostring = GD.tostring,
	__index = {
		tovariant = ffi.C.hgdn_new_plane_variant,
	},
})

Quat = ffi.metatype('godot_quat', {
	__tostring = GD.tostring,
	__index = {
		tovariant = ffi.C.hgdn_new_quat_variant,
	},
})

Basis = ffi.metatype('godot_basis', {
	__tostring = GD.tostring,
	__index = {
		tovariant = ffi.C.hgdn_new_basis_variant,
	},
})

AABB = ffi.metatype('godot_aabb', {
	__tostring = GD.tostring,
	__index = {
		tovariant = ffi.C.hgdn_new_aabb_variant,
	},
})

Transform2D = ffi.metatype('godot_transform2d', {
	__tostring = GD.tostring,
	__index = {
		tovariant = ffi.C.hgdn_new_transform2d_variant,
	},
})

Transform = ffi.metatype('godot_transform', {
	__tostring = GD.tostring,
	__index = {
		tovariant = ffi.C.hgdn_new_transform_variant,
	},
})
