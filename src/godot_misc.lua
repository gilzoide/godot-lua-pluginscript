RID = ffi.metatype('godot_rid', {
    __tostring = GD.str,
    __index = {
        tovariant = ffi.C.hgdn_new_rid_variant,
    },
})

Object = ffi.metatype('godot_object', {
    __tostring = GD.str,
    __index = {
        tovariant = ffi.C.hgdn_new_object_variant,
    },
})