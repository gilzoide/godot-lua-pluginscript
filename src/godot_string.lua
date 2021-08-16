-- @file godot_string.lua  Wrapper for GDNative's CharString, String and StringName
-- This file is part of Godot Lua PluginScript: https://github.com/gilzoide/godot-lua-pluginscript
--
-- Copyright (C) 2021 Gil Barbosa Reis.
-- 
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the “Software”), to
-- deal in the Software without restriction, including without limitation the
-- rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
-- sell copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
-- 
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
-- 
-- THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
-- FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
-- IN THE SOFTWARE.
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
	fillvariant = api.godot_variant_new_string,
	varianttype = GD.TYPE_STRING,

	wide_str = api.godot_string_wide_str,
	length = api.godot_string_length,
	casecmp_to = function(self, str)
		return api.godot_string_casecmp_to(self, GD.str(str))
	end,
	nocasecmp_to = function(self, str)
		return api.godot_string_nocasecmp_to(self, GD.str(str))
	end,
	naturalnocasecmp_to = function(self, str)
		return api.godot_string_naturalnocasecmp_to(self, GD.str(str))
	end,
	begins_with = function(self, str)
		if ffi.istype(String, str) then
			return api.godot_string_begins_with(self, str)
		else
			return api.godot_string_begins_with_char_array(self, tostring(str))
		end
	end,
	bigrams = function(self)
		return ffi.gc(api.godot_string_bigrams(self), api.godot_array_destroy)
	end,
	ends_with = function(self, str)
		return api.godot_string_ends_with(self, GD.str(str))
	end,
	count = function(self, what, from, to)
		return api.godot_string_count(self, GD.str(what), from or 0, to or 0)
	end,
	countn = function(self, what, from, to)
		return api.godot_string_countn(self, GD.str(what), from or 0, to or 0)
	end,
	find = function(self, what, from)
		return api.godot_string_find_from(self, GD.str(what), from or 0)
	end,
	findmk = function(self, keys, from)
		local r_key = ffi.new(int)
		local ret = api.godot_string_findmk_from_in_place(self, keys, from or 0, r_key)
		return ret, r_key
	end,
	findn = function(self, what, from)
		return api.godot_string_findn_from(self, GD.str(what), from or 0)
	end,
	find_last = function(self, what)
		return api.godot_string_find_last(self, GD.str(what))
	end,
	format = function(self, values, placeholder)
		return ffi.gc(api.godot_string_format_with_custom_placeholder(self, Variant(values), placeholder or String("{_}")), api.godot_string_destroy)
	end,
	hex_encode_buffer = function(buffer, len)
		return ffi.gc(api.godot_string_hex_encode_buffer(buffer, len), api.godot_string_destroy)
	end,
	hex_to_int = api.godot_string_hex_to_int,
	hex_to_int_without_prefix = api.godot_string_hex_to_int_without_prefix,
	insert = function(self, position, what)
		return ffi.gc(api.godot_string_insert(self, position, GD.str(what)), api.godot_string_destroy)
	end,
	is_numeric = api.godot_string_is_numeric,
	is_subsequence_of = function(self, str)
		return api.godot_string_is_subsequence_of(self, GD.str(str))
	end,
	is_subsequence_ofi = function(self, str)
		return api.godot_string_is_subsequence_ofi(self, GD.str(str))
	end,
	lpad = function(self, min_length, character)
		return ffi.gc(api.godot_string_lpad_with_custom_character(self, min_length, character and GD.str(character) or String(" ")), api.godot_string_destroy)
	end,
	match = function(self, expr)
		return api.godot_string_match(self, GD.str(expr))
	end,
	matchn = function(self, expr)
		return api.godot_string_matchn(self, GD.str(expr))
	end,
	replace_first = function(self, what, forwhat)
		return ffi.gc(api.godot_string_replace_first(self, GD.str(what), GD.str(forwhat)), api.godot_string_destroy)
	end,
	replace = function(self, what, forwhat)
		return ffi.gc(api.godot_string_replace(self, GD.str(what), GD.str(forwhat)), api.godot_string_destroy)
	end,
	replacen = function(self, what, forwhat)
		return ffi.gc(api.godot_string_replacen(self, GD.str(what), GD.str(forwhat)), api.godot_string_destroy)
	end,
	rfind = function(self, what, from)
		return api.godot_string_rfind_from(self, GD.str(what), from or -1)
	end,
	rfindn = function(self, what, from)
		return api.godot_string_rfindn_from(self, GD.str(what), from or -1)
	end,
	rpad = function(self, min_length, character)
		return ffi.gc(api.godot_string_rpad_with_custom_character(self, min_length, character and GD.str(character) or String(" ")), api.godot_string_destroy)
	end,
	similarity = function(self, str)
		return api.godot_string_similarity(self, GD.str(str))
	end,
	sprintf = function(self, values, ...)
		local r_error = ffi.new(bool)
		if select('#', ...) > 0 or not ffi.istype(Array, values) then
			values = Array(values, ...)
		end
		local ret = ffi.gc(api.godot_string_sprintf(self, values, r_error), api.godot_string_destroy)
		if r_error then
			return nil, ret
		else
			return ret
		end
	end,
	substr = function(self, from, len)
		return ffi.gc(api.godot_string_substr(self, from or 0, len or -1), api.godot_string_destroy)
	end,
	to_double = api.godot_string_to_double,
	to_float = api.godot_string_to_float,
	to_int = api.godot_string_to_int,
	camelcase_to_underscore = function(self)
		return ffi.gc(api.godot_string_camelcase_to_underscore(self), api.godot_string_destroy)
	end,
	camelcase_to_underscore_lowercased = function(self)
		return ffi.gc(api.godot_string_camelcase_to_underscore_lowercased(self), api.godot_string_destroy)
	end,
	capitalize = function(self)
		return ffi.gc(api.godot_string_capitalize(self), api.godot_string_destroy)
	end,
	get_slice_count = function(self, splitter)
		return api.godot_string_get_slice_count(self, GD.str(splitter))
	end,
	get_slice = function(self, splitter, slice)
		return ffi.gc(api.godot_string_get_slice(self, GD.str(splitter), slice), api.godot_string_destroy)
	end,
	get_slicec = function(self, splitter, slice)
		return ffi.gc(api.godot_string_get_slicec(self, splitter, slice), api.godot_string_destroy)
	end,
	split = function(self, splitter, allow_empty)
		if allow_empty == nil then allow_empty = true end
		return ffi.gc(api.godot_string_split_allow_empty(self, GD.str(splitter), allow_empty), api.godot_array_destroy)
	end,
	split_floats = function(self, splitter, allow_empty)
		if allow_empty == nil then allow_empty = true end
		if ffi.istype(Array, splitter) then
			return ffi.gc(api.godot_string_split_floats_mk_allows_empty(self, splitter, allow_empty), api.godot_array_destroy)
		else
			return ffi.gc(api.godot_string_split_floats_allows_empty(self, GD.str(splitter), allow_empty), api.godot_array_destroy)
		end
	end,
	split_ints = function(self, splitter, allow_empty)
		if allow_empty == nil then allow_empty = true end
		if ffi.istype(Array, splitter) then
			return ffi.gc(api.godot_string_split_ints_mk_allows_empty(self, splitter, allow_empty), api.godot_array_destroy)
		else
			return ffi.gc(api.godot_string_split_ints_allows_empty(self, GD.str(splitter), allow_empty), api.godot_array_destroy)
		end
	end,
	split_spaces = function(self)
		return ffi.gc(api.godot_string_split_spaces(self), api.godot_array_destroy)
	end,
	to_lower = function(self)
		return ffi.gc(api.godot_string_to_lower(self), api.godot_string_destroy)
	end,
	to_upper = function(self)
		return ffi.gc(api.godot_string_to_upper(self), api.godot_string_destroy)
	end,
	get_basename = function(self)
		return ffi.gc(api.godot_string_get_basename(self), api.godot_string_destroy)
	end,
	get_extension = function(self)
		return ffi.gc(api.godot_string_get_extension(self), api.godot_string_destroy)
	end,
	left = function(self)
		return ffi.gc(api.godot_string_left(self), api.godot_string_destroy)
	end,
	ord_at = api.godot_string_ord_at,
	plus_file = function(self, file)
		return ffi.gc(api.godot_string_plus_file(self, GD.str(file)), api.godot_string_destroy)
	end,
	right = function(self)
		return ffi.gc(api.godot_string_right(self), api.godot_string_destroy)
	end,
	strip_edges = function(self, left, right)
		if left == nil then left = true end
		if right == nil then right = true end
		return ffi.gc(api.godot_string_strip_edges(self, left, right), api.godot_string_destroy)
	end,
	strip_escapes = function(self)
		return ffi.gc(api.godot_string_strip_escapes(self), api.godot_string_destroy)
	end,
	erase = api.godot_string_erase,
	hash = api.godot_string_hash,
	hash64 = api.godot_string_hash64,
	md5_buffer = function(self)
		return ffi.gc(api.godot_string_md5_buffer(self), api.godot_pool_byte_array_destroy)
	end,
	md5_text = function(self)
		return ffi.gc(api.godot_string_md5_text(self), api.godot_string_destroy)
	end,
	sha256_buffer = function(self)
		return ffi.gc(api.godot_string_sha256_buffer(self), api.godot_pool_byte_array_destroy)
	end,
	sha256_text = function(self)
		return ffi.gc(api.godot_string_sha256_text(self), api.godot_string_destroy)
	end,
	empty = api.godot_string_empty,
	get_base_dir = function(self)
		return ffi.gc(api.godot_string_get_base_dir(self), api.godot_string_destroy)
	end,
	get_file = function(self)
		return ffi.gc(api.godot_string_get_file(self), api.godot_string_destroy)
	end,
	humanize_size = function(size)
		return ffi.gc(api.godot_string_humanize_size(size), api.godot_string_destroy)
	end,
	is_abs_path = api.godot_string_is_abs_path,
	is_rel_path = api.godot_string_is_rel_path,
	is_resource_file = api.godot_string_is_resource_file,
	path_to = function(self, path)
		return ffi.gc(api.godot_string_path_to(self, GD.str(path)), api.godot_string_destroy)
	end,
	path_to_file = function(self, path)
		return ffi.gc(api.godot_string_path_to_file(self, GD.str(path)), api.godot_string_destroy)
	end,
	simplify_path = function(self)
		return ffi.gc(api.godot_string_simplify_path(self), api.godot_string_destroy)
	end,
	c_escape = function(self)
		return ffi.gc(api.godot_string_c_escape(self), api.godot_string_destroy)
	end,
	c_escape_multiline = function(self)
		return ffi.gc(api.godot_string_c_escape_multiline(self), api.godot_string_destroy)
	end,
	c_unescape = function(self)
		return ffi.gc(api.godot_string_c_unescape(self), api.godot_string_destroy)
	end,
	http_escape = function(self)
		return ffi.gc(api.godot_string_http_escape(self), api.godot_string_destroy)
	end,
	http_unescape = function(self)
		return ffi.gc(api.godot_string_http_unescape(self), api.godot_string_destroy)
	end,
	json_escape = function(self)
		return ffi.gc(api.godot_string_json_escape(self), api.godot_string_destroy)
	end,
	word_wrap = function(self)
		return ffi.gc(api.godot_string_word_wrap(self), api.godot_string_destroy)
	end,
	xml_escape = function(self)
		return ffi.gc(api.godot_string_xml_escape(self), api.godot_string_destroy)
	end,
	xml_escape_with_quotes = function(self)
		return ffi.gc(api.godot_string_xml_escape_with_quotes(self), api.godot_string_destroy)
	end,
	xml_unescape = function(self)
		return ffi.gc(api.godot_string_xml_unescape(self), api.godot_string_destroy)
	end,
	percent_decode = function(self)
		return ffi.gc(api.godot_string_percent_decode(self), api.godot_string_destroy)
	end,
	percent_encode = function(self)
		return ffi.gc(api.godot_string_percent_encode(self), api.godot_string_destroy)
	end,
	is_valid_float = api.godot_string_is_valid_float,
	is_valid_hex_number = function(self, with_prefix)
		return api.godot_string_is_valid_hex_number(self, with_prefix or false)
	end,
	is_valid_html_color = api.godot_string_is_valid_html_color,
	is_valid_identifier = api.godot_string_is_valid_identifier,
	is_valid_integer = api.godot_string_is_valid_integer,
	is_valid_ip_address = api.godot_string_is_valid_ip_address,
}

-- Implement some of the Lua string API
string_methods.byte = function(self, i, j)
	return string.byte(tostring(self), i, j)
end

string_methods.gmatch = function(self, patt, init)
	return string.gmatch(tostring(self), patt, init)
end

string_methods.gsub = function(self, patt, repl, n)
	return string.gsub(tostring(self), patt, repl, n)
end

string_methods.len = string_methods.length
string_methods.lower = string_methods.to_lower
string_methods.upper = string_methods.to_upper

string_methods.match = function(self, patt, init)
	return string.match(tostring(self), patt, init)
end

string_methods.rep = function(self, n, sep)
	return string.rep(tostring(self), n, sep)
end

string_methods.reverse = function(self)
	return string.reverse(tostring(self))
end

string_methods.sub = function(self, i, j)
	i = i or 1
	j = j or -1
	if i < 0 then i = i + #self + 1 end
	if i <= 0 then i = 1 end
	if j < 0 then j = j + #self + 1 end
	i = i - 1
	return string_methods.substr(self, i, j - i)
end

if api_1_1 then
	string_methods.dedent = function(self)
		return ffi.gc(api_1_1.godot_string_dedent(self), api.godot_string_destroy)
	end
	string_methods.trim_prefix = function(self, prefix)
		return ffi.gc(api_1_1.godot_string_trim_prefix(self, GD.str(prefix)), api.godot_string_destroy)
	end
	string_methods.trim_suffix = function(self, suffix)
		return ffi.gc(api_1_1.godot_string_trim_suffix(self, GD.str(suffix)), api.godot_string_destroy)
	end
	string_methods.rstrip = function(self, chars)
		return ffi.gc(api_1_1.godot_string_rstrip(self, GD.str(chars)), api.godot_string_destroy)
	end
	string_methods.rsplit = function(self, delimiter, allow_empty, maxsplit)
		if allow_empty == nil then allow_empty = true end
		return ffi.gc(api_1_1.godot_string_rsplit(self, GD.str(delimiter), allow_empty, maxsplit or 0), api.godot_pool_string_array_destroy)
	end
end

String = ffi.metatype('godot_string', {
	__new = function(mt, ...)
		local text, length = ...
		if select('#', ...) == 0 then
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
	__len = function(self)
		return string_methods.length(self)
	end,
	__index = string_methods,
	__concat = concat_gdvalues,
	__eq = function(a, b)
		return api.godot_string_operator_equal(GD.str(a), GD.str(b))
	end,
	__lt = function(a, b)
		return api.godot_string_operator_less(GD.str(a), GD.str(b))
	end,
	__mod = function(self, values)
		return assert(string_methods.sprintf(self, values))
	end,
})

local string_name_methods = {
	fillvariant = function(var, self)
		api.godot_variant_new_string(var, api.godot_string_name_get_name(self))
	end,
	get_name = function(self)
		return ffi.gc(api.godot_string_name_get_name(self), api.godot_string_destroy)
	end,
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
