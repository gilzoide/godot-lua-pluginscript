local methods = {
    tovariant = ffi.C.hgdn_new_array_variant,
}

Array = ffi.metatype('godot_array', {
    __tostring = GD.str,
    __index = function(self, key)
        if typeof(key) == 'number' then
            -- TODO: index array
        else
            return methods[key]
        end
    end,
})
