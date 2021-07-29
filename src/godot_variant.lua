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

Variant = ffi.metatype("godot_variant", {
    __new = function(mt, value)
        local t = type(value)
        if t == 'boolean' then
            return ffi.C.hgdn_new_bool_variant(value)
        elseif t == 'string' then
            return ffi.C.hgdn_new_cstring_variant(value)
        elseif t == 'number' or tonumber(value) then
            return ffi.C.hgdn_new_real_variant(value)
        elseif t == 'table' then
            return ffi.C.hgdn_new_dictionary_variant(Dictionary(value))
        elseif t == 'cdata' then
            return value:tovariant()
        else
            return ffi.C.hgdn_new_nil_variant()
        end
    end,
    __gc = GD.api.godot_variant_destroy,
    __tostring = function(self)
        return tostring(GD.api.godot_variant_as_string(self))
    end,
    __index = {
        tovariant = ffi.C.hgdn_new_variant_copy,
        unbox = function(self)
            local t = GD.api.godot_variant_get_type(self)
            if t == ffi.C.GODOT_VARIANT_TYPE_NIL then
                return nil
            elseif t == ffi.C.GODOT_VARIANT_TYPE_BOOL then
                return GD.api.godot_variant_as_bool(self)
            elseif t == ffi.C.GODOT_VARIANT_TYPE_INT then
                return GD.api.godot_variant_as_int(self)
            elseif t == ffi.C.GODOT_VARIANT_TYPE_REAL then
                return GD.api.godot_variant_as_real(self)
            elseif t == ffi.C.GODOT_VARIANT_TYPE_STRING then
                return GD.api.godot_variant_as_string(self)
            elseif t == ffi.C.GODOT_VARIANT_TYPE_VECTOR2 then
                return GD.api.godot_variant_as_vector2(self)
            elseif t == ffi.C.GODOT_VARIANT_TYPE_RECT2 then
                return GD.api.godot_variant_as_rect2(self)
            elseif t == ffi.C.GODOT_VARIANT_TYPE_VECTOR3 then
                return GD.api.godot_variant_as_vector3(self)
            elseif t == ffi.C.GODOT_VARIANT_TYPE_TRANSFORM2D then
                return GD.api.godot_variant_as_transform2d(self)
            elseif t == ffi.C.GODOT_VARIANT_TYPE_PLANE then
                return GD.api.godot_variant_as_plane(self)
            elseif t == ffi.C.GODOT_VARIANT_TYPE_QUAT then
                return GD.api.godot_variant_as_quat(self)
            elseif t == ffi.C.GODOT_VARIANT_TYPE_AABB then
                return GD.api.godot_variant_as_aabb(self)
            elseif t == ffi.C.GODOT_VARIANT_TYPE_BASIS then
                return GD.api.godot_variant_as_basis(self)
            elseif t == ffi.C.GODOT_VARIANT_TYPE_TRANSFORM then
                return GD.api.godot_variant_as_transform(self)
            elseif t == ffi.C.GODOT_VARIANT_TYPE_COLOR then
                return GD.api.godot_variant_as_color(self)
            elseif t == ffi.C.GODOT_VARIANT_TYPE_NODE_PATH then
                return GD.api.godot_variant_as_node_path(self)
            elseif t == ffi.C.GODOT_VARIANT_TYPE_RID then
                return GD.api.godot_variant_as_rid(self)
            elseif t == ffi.C.GODOT_VARIANT_TYPE_OBJECT then
                return GD.api.godot_variant_as_object(self)
            elseif t == ffi.C.GODOT_VARIANT_TYPE_DICTIONARY then
                return GD.api.godot_variant_as_dictionary(self)
            elseif t == ffi.C.GODOT_VARIANT_TYPE_ARRAY then
                return GD.api.godot_variant_as_array(self)
            elseif t == ffi.C.GODOT_VARIANT_TYPE_POOL_BYTE_ARRAY then
                return GD.api.godot_variant_as_pool_byte_array(self)
            elseif t == ffi.C.GODOT_VARIANT_TYPE_POOL_INT_ARRAY then
                return GD.api.godot_variant_as_pool_int_array(self)
            elseif t == ffi.C.GODOT_VARIANT_TYPE_POOL_REAL_ARRAY then
                return GD.api.godot_variant_as_pool_real_array(self)
            elseif t == ffi.C.GODOT_VARIANT_TYPE_POOL_STRING_ARRAY then
                return GD.api.godot_variant_as_pool_string_array(self)
            elseif t == ffi.C.GODOT_VARIANT_TYPE_POOL_VECTOR2_ARRAY then
                return GD.api.godot_variant_as_pool_vector2_array(self)
            elseif t == ffi.C.GODOT_VARIANT_TYPE_POOL_VECTOR3_ARRAY then
                return GD.api.godot_variant_as_pool_vector3_array(self)
            elseif t == ffi.C.GODOT_VARIANT_TYPE_POOL_COLOR_ARRAY then
                return GD.api.godot_variant_as_pool_color_array(self)
            end
        end,
    },
})
