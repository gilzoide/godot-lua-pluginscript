local CharString = ffi.metatype('godot_char_string', {
    __gc = GD.api.godot_char_string_destroy,
    __tostring = function(self)
        local ptr = GD.api.godot_char_string_get_data(self)
        return ffi.string(ptr, #self)
    end,
    __len = function(self)
        return GD.api.godot_char_string_length(self)
    end,
})

local string_methods = {
    tovariant = ffi.C.hgdn_new_string_variant,
    length = function(self)
        return GD.api.godot_string_length(self)
    end,
}
String = ffi.metatype('godot_string', {
    __new = function(mt, text, length)
        if not text then
            return GD.api.godot_string_chars_to_utf8('')
        elseif ffi.istype(mt, text) then
            local self = ffi.new('godot_string')
            GD.api.godot_string_new_copy(self, text)
            return self
        elseif ffi.istype('wchar_t *', text) then
            local self = ffi.new('godot_string')
            GD.api.godot_string_new_with_wide_string(self, text, length or -1)
            return self
        elseif length then
            return GD.api.godot_string_chars_to_utf8_with_len(text, length)
        else
            return GD.api.godot_string_chars_to_utf8(text)
        end
    end,
    __gc = GD.api.godot_string_destroy,
    __tostring = function(self)
        return tostring(GD.api.godot_string_utf8(self))
    end,
    __len = string_methods.length,
    __index = string_methods,
})

local string_name_methods = {
    tovariant = function(self)
        return GD.api.godot_string_name_get_name(self):tovariant()
    end,
    get_name = GD.api.godot_string_name_get_name,
    get_hash = GD.api.godot_string_name_get_hash,
    get_data_unique_pointer = GD.api.godot_string_name_get_data_unique_pointer,
}
StringName = ffi.metatype('godot_string_name', {
    __new = function(mt, text)
        text = text or ''
        local self = ffi.new('godot_string_name')
        if ffi.istype(String, text) then
            GD.api.godot_string_name_new(self, text)
        else
            GD.api.godot_string_name_new_data(self, text)
        end
        return self
    end,
    __gc = GD.api.godot_string_name_destroy,
    __tostring = function(self)
        return tostring(self:get_name())
    end,
    __len = function(self)
        return #self:get_name()
    end,
    __index = string_name_methods,
})

local node_path_methods = {
    tovariant = ffi.C.hgdn_new_node_path_variant,
}
NodePath = ffi.metatype('godot_node_path', {
    __new = function(mt, text_or_nodepath)
        local self = ffi.new('godot_node_path')
        if ffi.istype(mt, text_or_nodepath) then
            GD.api.godot_node_path_new_copy(self, text_or_nodepath)
        elseif ffi.istype(String, text_or_nodepath) then
            GD.api.godot_node_path_new(self, text_or_nodepath)
        else
            GD.api.godot_node_path_new(self, String(text_or_nodepath))
        end
        return self
    end,
    __gc = GD.api.godot_node_path_destroy,
    __tostring = function(self)
        return tostring(GD.api.godot_node_path_as_string(self))
    end,
    __index = node_path_methods,
})
