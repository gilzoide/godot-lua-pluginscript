local CharString = ffi.metatype('godot_char_string', {
	__gc = api.godot_char_string_destroy,
	__tostring = function(self)
		local ptr = api.godot_char_string_get_data(self)
		return ffi.string(ptr, #self)
	end,
	__len = function(self)
		return api.godot_char_string_length(self)
	end,
})

local string_methods = {
	tovariant = ffi.C.hgdn_new_string_variant,
	varianttype = GD.TYPE_STRING,
	length = function(self)
		return api.godot_string_length(self)
	end,
	wide_str = api.godot_string_wide_str,
	-- TODO: add the rest
}
String = ffi.metatype('godot_string', {
	__new = function(mt, text, length)
		if text == nil then
			return api.godot_string_chars_to_utf8('')
		elseif ffi.istype(mt, text) then
			local self = ffi.new(mt)
			api.godot_string_new_copy(self, text)
			return self
		elseif ffi.istype(StringName, text) then
			return text:get_name()
		elseif ffi.istype('char *', text) then
			if length then
				return api.godot_string_chars_to_utf8_with_len(text, length)
			else
				return api.godot_string_chars_to_utf8(text)
			end
		elseif ffi.istype('wchar_t *', text) then
			local self = ffi.new(mt)
			api.godot_string_new_with_wide_string(self, text, length or -1)
			return self
		elseif ffi.istype('wchar_t', text) or ffi.istype('char', text) then
			return api.godot_string_chr(text)
		else
			text = tostring(text)
			return api.godot_string_chars_to_utf8_with_len(text, length or #text)
		end
	end,
	__gc = api.godot_string_destroy,
	__tostring = function(self)
		return tostring(api.godot_string_utf8(self))
	end,
	__len = string_methods.length,
	__index = string_methods,
	__concat = concat_gdvalues,
})

local string_name_methods = {
	tovariant = function(self)
		return api.godot_string_name_get_name(self):tovariant()
	end,
	get_name = api.godot_string_name_get_name,
	get_hash = api.godot_string_name_get_hash,
	get_data_unique_pointer = api.godot_string_name_get_data_unique_pointer,
}
StringName = ffi.metatype('godot_string_name', {
	__new = function(mt, text)
		text = text or ''
		local self = ffi.new(mt)
		if ffi.istype(String, text) then
			api.godot_string_name_new(self, text)
		else
			api.godot_string_name_new_data(self, text)
		end
		return self
	end,
	__gc = api.godot_string_name_destroy,
	__tostring = function(self)
		return tostring(self:get_name())
	end,
	__len = function(self)
		return #self:get_name()
	end,
	__index = string_name_methods,
	__concat = concat_gdvalues,
})
