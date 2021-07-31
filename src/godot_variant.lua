ffi.cdef[[
godot_variant hgdn_new_variant_copy(const godot_variant *value);
godot_variant hgdn_new_nil_variant();
godot_variant hgdn_new_bool_variant(const godot_bool value);
godot_variant hgdn_new_uint_variant(const uint64_t value);
godot_variant hgdn_new_int_variant(const int64_t value);
godot_variant hgdn_new_real_variant(const double value);
godot_variant hgdn_new_vector2_variant(const godot_vector2 value);
godot_variant hgdn_new_vector3_variant(const godot_vector3 value);
godot_variant hgdn_new_rect2_variant(const godot_rect2 value);
godot_variant hgdn_new_plane_variant(const godot_plane value);
godot_variant hgdn_new_quat_variant(const godot_quat value);
godot_variant hgdn_new_aabb_variant(const godot_aabb value);
godot_variant hgdn_new_basis_variant(const godot_basis value);
godot_variant hgdn_new_transform2d_variant(const godot_transform2d value);
godot_variant hgdn_new_transform_variant(const godot_transform value);
godot_variant hgdn_new_color_variant(const godot_color value);
godot_variant hgdn_new_node_path_variant(const godot_node_path *value);
godot_variant hgdn_new_rid_variant(const godot_rid *value);
godot_variant hgdn_new_object_variant(const godot_object *value);
godot_variant hgdn_new_string_variant(const godot_string *value);
godot_variant hgdn_new_cstring_variant(const char *value);
godot_variant hgdn_new_wide_string_variant(const wchar_t *value);
godot_variant hgdn_new_dictionary_variant(const godot_dictionary *value);
godot_variant hgdn_new_array_variant(const godot_array *value);
godot_variant hgdn_new_pool_byte_array_variant(const godot_pool_byte_array *value);
godot_variant hgdn_new_pool_int_array_variant(const godot_pool_int_array *value);
godot_variant hgdn_new_pool_real_array_variant(const godot_pool_real_array *value);
godot_variant hgdn_new_pool_vector2_array_variant(const godot_pool_vector2_array *value);
godot_variant hgdn_new_pool_vector3_array_variant(const godot_pool_vector3_array *value);
godot_variant hgdn_new_pool_color_array_variant(const godot_pool_color_array *value);
godot_variant hgdn_new_pool_string_array_variant(const godot_pool_string_array *value);
]]

local Variant_p_array = ffi.typeof('godot_variant *[?]')
local const_Variant_pp = ffi.typeof('const godot_variant **')
local VariantCallError = ffi.typeof('godot_variant_call_error')

local methods = {
	tovariant = function(self)
		return self
	end,
	as_bool = api.godot_variant_as_bool,
	as_uint = api.godot_variant_as_uint,
	as_int = api.godot_variant_as_int,
	as_real = api.godot_variant_as_real,
	as_string = api.godot_variant_as_string,
	as_vector2 = api.godot_variant_as_vector2,
	as_rect2 = api.godot_variant_as_rect2,
	as_vector3 = api.godot_variant_as_vector3,
	as_transform2d = api.godot_variant_as_transform2d,
	as_plane = api.godot_variant_as_plane,
	as_quat = api.godot_variant_as_quat,
	as_aabb = api.godot_variant_as_aabb,
	as_basis = api.godot_variant_as_basis,
	as_transform = api.godot_variant_as_transform,
	as_color = api.godot_variant_as_color,
	as_node_path = api.godot_variant_as_node_path,
	as_rid = api.godot_variant_as_rid,
	as_object = api.godot_variant_as_object,
	as_dictionary = api.godot_variant_as_dictionary,
	as_array = api.godot_variant_as_array,
	as_pool_byte_array = api.godot_variant_as_pool_byte_array,
	as_pool_int_array = api.godot_variant_as_pool_int_array,
	as_pool_real_array = api.godot_variant_as_pool_real_array,
	as_pool_string_array = api.godot_variant_as_pool_string_array,
	as_pool_vector2_array = api.godot_variant_as_pool_vector2_array,
	as_pool_vector3_array = api.godot_variant_as_pool_vector3_array,
	as_pool_color_array = api.godot_variant_as_pool_color_array,
	get_type = api.godot_variant_get_type,
	pcall = function(self, method, ...)
		local argc = select('#', ...)
		local argv = ffi.new(Variant_p_array, argc)
		for i = 1, argc do
			local arg = select(i, ...)
			argv[i - 1] = Variant(arg)
		end
		local r_error = ffi.new(VariantCallError)
		local value = api.godot_variant_call(self, String(method), ffi.cast(const_Variant_pp, argv), argc, r_error)
		if r_error.error == GD.CALL_OK then
			return true, value:unbox()
		else
			return false, r_error
		end
	end,
	call = function(self, method, ...)
		local success, value = self:pcall(method, ...)
		if success then
			return value
		else
			return nil
		end
	end,
	has_method = function(self, method)
		return api.godot_variant_has_method(self, String(method))
	end,
	hash_compare = function(self, other)
		return api.godot_variant_hash_compare(self, Variant(other))
	end,
	booleanize = api.godot_variant_booleanize,
	unbox = function(self)
		local t = self:get_type()
		if t == GD.TYPE_NIL then
			return nil
		elseif t == GD.TYPE_BOOL then
			return api.godot_variant_as_bool(self)
		elseif t == GD.TYPE_INT then
			return api.godot_variant_as_int(self)
		elseif t == GD.TYPE_REAL then
			return api.godot_variant_as_real(self)
		elseif t == GD.TYPE_STRING then
			return api.godot_variant_as_string(self)
		elseif t == GD.TYPE_VECTOR2 then
			return api.godot_variant_as_vector2(self)
		elseif t == GD.TYPE_RECT2 then
			return api.godot_variant_as_rect2(self)
		elseif t == GD.TYPE_VECTOR3 then
			return api.godot_variant_as_vector3(self)
		elseif t == GD.TYPE_TRANSFORM2D then
			return api.godot_variant_as_transform2d(self)
		elseif t == GD.TYPE_PLANE then
			return api.godot_variant_as_plane(self)
		elseif t == GD.TYPE_QUAT then
			return api.godot_variant_as_quat(self)
		elseif t == GD.TYPE_AABB then
			return api.godot_variant_as_aabb(self)
		elseif t == GD.TYPE_BASIS then
			return api.godot_variant_as_basis(self)
		elseif t == GD.TYPE_TRANSFORM then
			return api.godot_variant_as_transform(self)
		elseif t == GD.TYPE_COLOR then
			return api.godot_variant_as_color(self)
		elseif t == GD.TYPE_NODE_PATH then
			return api.godot_variant_as_node_path(self)
		elseif t == GD.TYPE_RID then
			return api.godot_variant_as_rid(self)
		elseif t == GD.TYPE_OBJECT then
			return api.godot_variant_as_object(self)
		elseif t == GD.TYPE_DICTIONARY then
			return api.godot_variant_as_dictionary(self)
		elseif t == GD.TYPE_ARRAY then
			return api.godot_variant_as_array(self)
		elseif t == GD.TYPE_POOL_BYTE_ARRAY then
			return api.godot_variant_as_pool_byte_array(self)
		elseif t == GD.TYPE_POOL_INT_ARRAY then
			return api.godot_variant_as_pool_int_array(self)
		elseif t == GD.TYPE_POOL_REAL_ARRAY then
			return api.godot_variant_as_pool_real_array(self)
		elseif t == GD.TYPE_POOL_STRING_ARRAY then
			return api.godot_variant_as_pool_string_array(self)
		elseif t == GD.TYPE_POOL_VECTOR2_ARRAY then
			return api.godot_variant_as_pool_vector2_array(self)
		elseif t == GD.TYPE_POOL_VECTOR3_ARRAY then
			return api.godot_variant_as_pool_vector3_array(self)
		elseif t == GD.TYPE_POOL_COLOR_ARRAY then
			return api.godot_variant_as_pool_color_array(self)
		end
	end,
}

Variant = ffi.metatype("godot_variant", {
	__new = function(mt, value)
		local t = type(value)
		if t == 'boolean' then
			return ffi.C.hgdn_new_bool_variant(value)
		elseif t == 'string' then
			return ffi.C.hgdn_new_cstring_variant(value)
		elseif ffi.istype(int, value) then
			return ffi.C.hgdn_new_int_variant(value)
		elseif t == 'number' or tonumber(value) then
			return ffi.C.hgdn_new_real_variant(value)
		elseif t == 'table' then
			return ffi.C.hgdn_new_dictionary_variant(Dictionary(value))
		elseif t == 'cdata' and value.tovariant then
			return value:tovariant()
		end
		return ffi.C.hgdn_new_nil_variant()
	end,
	__gc = api.godot_variant_destroy,
	__tostring = function(self)
		return tostring(self:as_string())
	end,
	__concat = concat_gdvalues,
	__index = methods,
})
