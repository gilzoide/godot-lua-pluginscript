local function register_pool_array(name, ctype)
    _G[name] = ffi.metatype(ctype, {})
end

register_pool_array('PoolByteArray', 'godot_pool_byte_array')
register_pool_array('PoolIntArray', 'godot_pool_int_array')
register_pool_array('PoolRealArray', 'godot_pool_real_array')
register_pool_array('PoolStringArray', 'godot_pool_string_array')
register_pool_array('PoolVector2Array', 'godot_pool_vector2_array')
register_pool_array('PoolVector3Array', 'godot_pool_vector3_array')
register_pool_array('PoolColorArray', 'godot_pool_color_array')

