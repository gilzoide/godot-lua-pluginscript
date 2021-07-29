local function register_pool_array(kind)
    local name = 'Pool' .. kind:sub(1, 1):upper() .. kind:sub(2) .. 'Array'
    local kind_type = 'pool_' .. kind .. '_array'
    local ctype = 'godot_' .. kind_type
    local new_variant_name = 'hgdn_new_' .. kind_type .. '_variant'
    
    local methods = {
        tovariant = ffi.C[new_variant_name],
    }

    _G[name] = ffi.metatype(ctype, {
        __tostring = GD.str,
        __index = function(self, key)
            if typeof(key) == 'number' then
                -- TODO: index array
            else
                return methods[key]
            end
        end,
    })
end

register_pool_array('byte')
register_pool_array('int')
register_pool_array('real')
register_pool_array('string')
register_pool_array('vector2')
register_pool_array('vector3')
register_pool_array('color')

