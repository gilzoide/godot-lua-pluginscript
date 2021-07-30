local methods = {
    tovariant = ffi.C.hgdn_new_dictionary_variant,
    duplicate = function(self, deep)
        return GD.api.godot_dictionary_duplicate(self, deep or false)
    end,
    size = function(self)
        return GD.api.godot_dictionary_size(self)
    end,
    empty = GD.api.godot_dictionary_empty,
    clear = GD.api.godot_dictionary_clear,
    has = function(self, key)
        return GD.api.godot_dictionary_has(self, Variant(key))
    end,
    has_all = function(self, ...)
        local keys = Array{ ... }
        return GD.api.godot_dictionary_has_all(self, keys)
    end,
    erase = function(self, key)
        GD.api.godot_dictionary_erase(self, Variant(key))
    end,
    hash = GD.api.godot_dictionary_hash,
    keys = GD.api.godot_dictionary_keys,
    values = GD.api.godot_dictionary_values,
    get = function(self, key)
        return GD.api.godot_dictionary_get(self, Variant(key)):unbox()
    end,
    set = function(self, key, value)
        GD.api.godot_dictionary_set(self, Variant(key), Variant(value))
    end,
    next = function(self, key)  -- behave like `next(table [, index])` for __pairs
        if key ~= nil then
            key = Variant(key)
        end
        local next_key = GD.api.godot_dictionary_next(self, key)
        if next_key ~= nil then
            return next_key:unbox(), self:get(next_key)
        else
            return nil
        end
    end,
    to_json = GD.api.godot_dictionary_to_json,
}

if GD.api_1_1 then
    methods.erase_with_return = function(self, key)
        return GD.api_1_1.godot_dictionary_erase_with_return(self, Variant(key))
    end
    methods.get_with_default = function(self, key, default)
        return GD.api_1_1.godot_dictionary_get_with_default(self, Variant(key), Variant(default))
    end
end

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
    __tostring = GD.tostring,
    __len = methods.size,
    __pairs = function(self)
        return methods.next, self, nil
    end,
})
