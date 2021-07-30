local function register_pool_array(kind)
    local name = 'Pool' .. kind:sub(1, 1):upper() .. kind:sub(2) .. 'Array'
    local kind_type = 'pool_' .. kind .. '_array'
    local ctype = 'godot_' .. kind_type
    local new_array_name = 'godot_array_new_' .. ctype
    local new_pool_array_name = ctype .. '_new'
    
    local methods = {
        tovariant = ffi.C['hgdn_new_' .. kind_type .. '_variant'],
        toarray = function(self)
            local array = ffi.new('godot_array')
            api[new_array_name](array, self)
            return array
        end,
        get = api[ctype .. '_get'],
        set = api[ctype .. '_set'],
        append = api[ctype .. '_append'],
        size = function(self)
            return api[ctype .. '_size'](self)
        end,
    }

    _G[name] = ffi.metatype(ctype, {
        __new = function(mt, value)
            local self = ffi.new(mt)
            if ffi.istype(mt, value) then
                api[ctype .. '_new_copy'](self, value)
            elseif ffi.istype(mt, Array) then
                api[ctype .. '_new_with_array'](self, value)
            else
                api[ctype .. '_new'](self)
                if value then
                    for i, v in ipairs(value) do
                        methods.append(self, v)
                    end
                end
            end
            return self
        end,
        __gc = api[ctype .. '_destroy'],
        __tostring = GD.tostring,
        __index = function(self, key)
            local method = methods[key]
            if method then
                return method
            else
                key = assert(tonumber(key), name .. " indices must be numeric")
                if key >= 0 and key < #self then
                    return methods.get(self, key)
                end
            end
        end,
        __newindex = function(self, key, value)
            key = assert(key, "Array indices must be numeric")
            if key == #self then
                methods.append(self, value)
            else
                methods.set(self, key, value)
            end
        end,
        __len = methods.size,
    })
end

register_pool_array('byte')
register_pool_array('int')
register_pool_array('real')
register_pool_array('string')
register_pool_array('vector2')
register_pool_array('vector3')
register_pool_array('color')

