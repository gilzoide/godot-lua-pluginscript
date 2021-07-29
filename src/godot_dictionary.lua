local methods = {
    set = function(self, key, value)
        GD.api.godot_dictionary_set(self, Variant(key), Variant(value))
    end,
    get = function(self, key)
        return GD.api.godot_dictionary_get(self, Variant(key)):unbox()
    end,
    tovariant = ffi.C.hgdn_new_dictionary_variant,
}

Dictionary = ffi.metatype('godot_dictionary', {
    __new = function(mt, value)
        local self = ffi.new('godot_dictionary')
        if ffi.istype(mt, value) then
            GD.api.godot_dictionary_new_copy(self, value)
        else
            GD.api.godot_dictionary_new(self)
            if value then
                for k, v in pairs(value) do
                    self[k] = v
                end
            end
        end
        return self
    end,
    __gc = GD.api.godot_dictionary_destroy,
    __index = function(self, key)
        local method = methods[key]
        if method ~= nil then
            return method
        else
            return methods.get(self, key)
        end
    end,
    __newindex = methods.set,
    __tostring = GD.str,
    __len = function(self)
        return GD.api.godot_dictionary_size(self)
    end,
})
