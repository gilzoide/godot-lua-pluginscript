Vector2 = ffi.metatype('godot_vector2', {
	__tostring = GD.tostring,
	__index = {
		tovariant = ffi.C.hgdn_new_vector2_variant,
		varianttype = GD.TYPE_VECTOR2,
	},
})

Vector3 = ffi.metatype('godot_vector3', {
	__tostring = GD.tostring,
	__index = {
		tovariant = ffi.C.hgdn_new_vector3_variant,
		varianttype = GD.TYPE_VECTOR3,
	},
})

Vector4 = ffi.metatype('godot_vector4', {
	__tostring = GD.tostring,
	__index = {
		tovariant = ffi.C.hgdn_new_color_variant,
		varianttype = GD.TYPE_COLOR,
	},
})
Color = Vector4

Rect2 = ffi.metatype('godot_rect2', {
	__tostring = GD.tostring,
	__index = {
		tovariant = ffi.C.hgdn_new_rect2_variant,
		varianttype = GD.TYPE_RECT2,
	},
})

Plane = ffi.metatype('godot_plane', {
	__tostring = GD.tostring,
	__index = {
		tovariant = ffi.C.hgdn_new_plane_variant,
		varianttype = GD.TYPE_PLANE,
	},
})

Quat = ffi.metatype('godot_quat', {
	__tostring = GD.tostring,
	__index = {
		tovariant = ffi.C.hgdn_new_quat_variant,
		varianttype = GD.TYPE_QUAT,
	},
})

Basis = ffi.metatype('godot_basis', {
	__tostring = GD.tostring,
	__index = {
		tovariant = ffi.C.hgdn_new_basis_variant,
		varianttype = GD.TYPE_BASIS,
	},
})

AABB = ffi.metatype('godot_aabb', {
	__tostring = GD.tostring,
	__index = {
		tovariant = ffi.C.hgdn_new_aabb_variant,
		varianttype = GD.TYPE_AABB,
	},
})

Transform2D = ffi.metatype('godot_transform2d', {
	__tostring = GD.tostring,
	__index = {
		tovariant = ffi.C.hgdn_new_transform2d_variant,
		varianttype = GD.TYPE_TRANSFORM2D,
	},
})

Transform = ffi.metatype('godot_transform', {
	__tostring = GD.tostring,
	__index = {
		tovariant = ffi.C.hgdn_new_transform_variant,
		varianttype = GD.TYPE_TRANSFORM,
	},
})
