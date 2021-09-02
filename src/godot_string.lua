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

--- String metatype, wrapper for `godot_string`
-- @classmod String
local function consume_char_string(cs)
	local lua_str = ffi_string(api.godot_char_string_get_data(cs), api.godot_char_string_length(cs))
	api.godot_char_string_destroy(cs)
	return lua_str
end

local string_methods = {
	fillvariant = api.godot_variant_new_string,
	varianttype = GD.TYPE_STRING,

	--- Return the String as a wide char string (`const wchar_t *`).
	-- @function wide_str
	-- @return `const wchar_t *`
	wide_str = api.godot_string_wide_str,
	--- Returns the String's amount of characters
	-- @function length
	-- @treturn int
	length = api.godot_string_length,
	--- Performs a case-sensitive comparison to another string.
	-- @function casecmp_to
	-- @param s  Other value, stringified with `GD.str`
	-- @treturn int  -1 if less than, 1 if greater than, or 0 if equal
	casecmp_to = function(self, s)
		return api.godot_string_casecmp_to(self, str(s))
	end,
	--- Performs a case-insensitive comparison to another string.
	-- @function nocasecmp_to
	-- @param s  Other value, stringified with `GD.str`
	-- @treturn int  -1 if less than, 1 if greater than, or 0 if equal
	nocasecmp_to = function(self, s)
		return api.godot_string_nocasecmp_to(self, str(s))
	end,
	--- Performs a case-insensitive natural order comparison to another string
	-- @function naturalnocasecmp_to
	-- @param s  Other value, stringified with `GD.str`
	-- @treturn int  -1 if less than, 1 if greater than, or 0 if equal
	naturalnocasecmp_to = function(self, s)
		return api.godot_string_naturalnocasecmp_to(self, str(s))
	end,
	--- Returns `true` if the String begins with the given string.
	-- @function begins_with
	-- @param s  Other value, stringified with `GD.str`
	-- @treturn bool
	begins_with = function(self, s)
		return api.godot_string_begins_with(self, str(s))
	end,
	--- Returns the bigrams (pairs of consecutive letters) of this string.
	-- @function bigrams
	-- @treturn PoolStringArray
	bigrams = function(self)
		return ffi_gc(api.godot_string_bigrams(self), api.godot_array_destroy)
	end,
	--- Returns `true` if the String ends with the given string.
	-- @function ends_with
	-- @param s  Other value, stringified with `GD.str`
	-- @treturn bool
	ends_with = function(self, s)
		return api.godot_string_ends_with(self, str(s))
	end,
	--- Returns the number of occurrences of substring `what` between `from` and `to` positions.
	-- If `from` and `to` equals 0 the whole string will be used. If only `to` equals 0 the remained substring will be used.
	-- @function count
	-- @param what  Substring, stringified with `GD.str`
	-- @param[opt=0] from
	-- @param[opt=0] to
	-- @treturn int
	count = function(self, what, from, to)
		return api.godot_string_count(self, str(what), from or 0, to or 0)
	end,
	--- Returns the number of occurrences of substring `what` (ignoring case) between `from` and `to` positions.
	-- If `from` and `to` equals 0 the whole string will be used. If only `to` equals 0 the remained substring will be used.
	-- @function countn
	-- @param what  Substring, stringified with `GD.str`
	-- @param[opt=0] from
	-- @param[opt=0] to
	-- @treturn int
	countn = function(self, what, from, to)
		return api.godot_string_countn(self, str(what), from or 0, to or 0)
	end,
	--- Finds the first occurrence of a substring.
	-- @function find
	-- @param what  Substring, stringified with `GD.str`
	-- @param[opt=0] from
	-- @treturn int  Starting position of the substring or -1 if not found
	find = function(self, what, from)
		return api.godot_string_find_from(self, str(what), from or 0)
	end,
	--- Finds the first occurrence of one of the substrings provided in `keys`.
	-- @function findmk
	-- @tparam Array keys  Array of substrings
	-- @param[opt=0] from
	-- @treturn int  Starting position of the substring or -1 if not found
	-- @treturn int  Index of the key found
	findmk = function(self, keys, from)
		local r_key = ffi_new(int)
		local ret = api.godot_string_findmk_from_in_place(self, keys, from or 0, r_key)
		return ret, r_key
	end,
	--- Finds the first occurrence of a substring, ignoring case.
	-- @function findn
	-- @param what  Substring, stringified with `GD.str`
	-- @param[opt=0] from
	-- @treturn int  Starting position of the substring or -1 if not found
	findn = function(self, what, from)
		return api.godot_string_findn_from(self, str(what), from or 0)
	end,
	--- Finds the last occurrence of a substring.
	-- @function find_last
	-- @param what  Substring, stringified with `GD.str`
	-- @treturn int  Starting position of the substring or -1 if not found
	find_last = function(self, what)
		return api.godot_string_find_last(self, str(what))
	end,
	--- Formats the string by replacing all occurrences of `placeholder` with `values`.
	-- @function format
	-- @param values
	-- @param[opt="{_}"] placeholder
	-- @treturn String
	format = function(self, values, placeholder)
		return ffi_gc(api.godot_string_format_with_custom_placeholder(self, Variant(values), placeholder or String("{_}")), api.godot_string_destroy)
	end,
	--- Return Lua's `tonumber` applied to self.
	-- @function to_number
	-- @param[opt] base  Number base
	-- @treturn number|nil
	to_number = function(self, base)
		return tonumber(tostring(self), base)
	end,
	--- Returns a copy of the String with the substring `what` inserted at the given position.
	-- @function insert
	-- @tparam int position
	-- @param what  Value to be inserted, stringified with `GD.str`
	-- @treturn String
	insert = function(self, position, what)
		return ffi_gc(api.godot_string_insert(self, position, str(what)), api.godot_string_destroy)
	end,
	--- Returns whether String contents is a number
	-- @function is_numeric
	-- @treturn bool
	is_numeric = api.godot_string_is_numeric,
	--- Returns `true` if this String is a subsequence of the given string.
	-- @function is_subsequence_of
	-- @param s  Other value, stringified with `GD.str`
	-- @treturn bool
	is_subsequence_of = function(self, s)
		return api.godot_string_is_subsequence_of(self, str(s))
	end,
	--- Returns `true` if this String is a subsequence of the given string, without considering case.
	-- @function is_subsequence_ofi
	-- @param s  Other value, stringified with `GD.str`
	-- @treturn bool
	is_subsequence_ofi = function(self, s)
		return api.godot_string_is_subsequence_ofi(self, str(s))
	end,
	--- Left-pad String with the given character.
	-- @function lpad
	-- @tparam int  min_length  Desired minimum length
	-- @param[opt=" "] character  Pad character, stringified with `GD.str`
	-- @treturn String
	lpad = function(self, min_length, character)
		return ffi_gc(api.godot_string_lpad_with_custom_character(self, min_length, character and str(character) or String(" ")), api.godot_string_destroy)
	end,
	--- Replaces the first occurrence of a case-sensitive substring with the given one inside the String.
	-- @function replace_first
	-- @param what  Substring to be replaced, stringified with `GD.str`
	-- @param forwhat  Replacement, stringified with `GD.str`
	-- @treturn String
	replace_first = function(self, what, forwhat)
		return ffi_gc(api.godot_string_replace_first(self, str(what), str(forwhat)), api.godot_string_destroy)
	end,
	--- Replaces occurrences of a case-sensitive substring with the given one inside the String.
	-- @function replace
	-- @param what  Substring to be replaced, stringified with `GD.str`
	-- @param forwhat  Replacement, stringified with `GD.str`
	-- @treturn String
	replace = function(self, what, forwhat)
		return ffi_gc(api.godot_string_replace(self, str(what), str(forwhat)), api.godot_string_destroy)
	end,
	--- Replaces occurrences of a case-insensitive substring with the given one inside the String.
	-- @function replacen
	-- @param what  Substring to be replaced, stringified with `GD.str`
	-- @param forwhat  Replacement, stringified with `GD.str`
	-- @treturn String
	replacen = function(self, what, forwhat)
		return ffi_gc(api.godot_string_replacen(self, str(what), str(forwhat)), api.godot_string_destroy)
	end,
	--- Performs a case-sensitive search for a substring, but starts from the end of the String instead of the beginning.
	-- @function rfind
	-- @param what  Substring to be searched, stringified with `GD.str`
	-- @tparam[opt=-1] int from  Search start position
	-- @treturn[1] int  Position of substring, if it was found
	-- @treturn[2] int  -1 otherwise
	rfind = function(self, what, from)
		return api.godot_string_rfind_from(self, str(what), from or -1)
	end,
	--- Performs a case-insensitive search for a substring, but starts from the end of the String instead of the beginning.
	-- @function rfindn
	-- @param what  Substring to be searched, stringified with `GD.str`
	-- @tparam[opt=-1] int from  Search start position
	-- @treturn[1] int  Position of substring, if it was found
	-- @treturn[2] int  -1 otherwise
	rfindn = function(self, what, from)
		return api.godot_string_rfindn_from(self, str(what), from or -1)
	end,
	--- Right-pad String with the given character.
	-- @function rpad
	-- @tparam int  min_length  Desired minimum length
	-- @param[opt=" "] character  Pad character, stringified with `GD.str`
	-- @treturn String
	rpad = function(self, min_length, character)
		return ffi_gc(api.godot_string_rpad_with_custom_character(self, min_length, character and str(character) or String(" ")), api.godot_string_destroy)
	end,
	--- Returns the similarity index of the text compared to this string.
	-- 1 means totally similar and 0 means totally dissimilar.
	-- @function similarity
	-- @param s  Other value, stringified with `GD.str`
	-- @treturn float
	similarity = function(self, s)
		return api.godot_string_similarity(self, str(s))
	end,
	--- Formats the String by substituting placeholder character-sequences with the given values
	-- ([reference documentation](https://docs.godotengine.org/en/stable/getting_started/scripting/gdscript/gdscript_format_string.html))
	-- @function sprintf
	-- @param ...  If only an `Array` value is passed, each value will correspond to a placeholder
	-- @treturn[1] String  Formatted String
	-- @treturn[2] nil
	-- @treturn[2] String  Error message, in case format is not compatible with the given values
	sprintf = function(self, values, ...)
		local r_error = ffi_new(bool)
		if select('#', ...) > 0 or not ffi.istype(Array, values) then
			values = Array(values, ...)
		end
		local ret = ffi.gc(api.godot_string_sprintf(self, values, r_error), api.godot_string_destroy)
		if r_error == 0 then
			return nil, ret
		else
			return ret
		end
	end,
	--- Returns part of the String from the position `from` with length `len`.
	-- Passing -1 to `len` will return remaining characters from given position.
	-- @function substr
	-- @tparam[opt=0] int from
	-- @tparam[opt=-1] int len
	-- @treturn String
	substr = function(self, from, len)
		return ffi_gc(api.godot_string_substr(self, from or 0, len or -1), api.godot_string_destroy)
	end,
	--- Returns a copy of String with Camel cased words separated by underscores.
	-- If `lowercased` is absent or truthy, result is converted to lower case.
	-- @function camelcase_to_underscore
	-- @param[opt=true] lowercased
	-- @treturn String
	camelcase_to_underscore = function(self, lowercased)
		if lowercased == nil or lowercased then
			return ffi_gc(api.godot_string_camelcase_to_underscore_lowercased(self), api.godot_string_destroy)
		else
			return ffi_gc(api.godot_string_camelcase_to_underscore(self), api.godot_string_destroy)
		end
	end,
	--- Changes the case of some letters.
	-- Replaces underscores with spaces, adds spaces before in-word uppercase characters, converts all letters to lowercase, then capitalizes the first letter and every letter following a space character.
	-- For `capitalize camelCase mixed_with_underscores`, it will return `Capitalize Camel Case Mixed With Underscores`.
	-- @function capitalize
	-- @treturn String
	capitalize = function(self)
		return ffi_gc(api.godot_string_capitalize(self), api.godot_string_destroy)
	end,
	--- Returns the number of slices when splitting String with `splitter`.
	-- @function get_slice_count
	-- @param splitter  Splitter substring, stringified with `GD.str`
	-- @treturn int  Number of slices
	get_slice_count = function(self, splitter)
		return api.godot_string_get_slice_count(self, str(splitter))
	end,
	--- Returns the Nth slice when splitting String with `splitter`.
	-- @function get_slice
	-- @param splitter  Splitter substring, stringified with `GD.str`
	-- @tparam int n  Slice index
	-- @treturn[1] String
	-- @return[2] Empty string, if there is no Nth slice
	get_slice = function(self, splitter, slice)
		return ffi_gc(api.godot_string_get_slice(self, str(splitter), slice), api.godot_string_destroy)
	end,
	--- Splits the String by a `delimiter` string and returns an array of the substrings.
	-- The `delimiter` can be of any length.
	-- @function split
	-- @param delimiter  Delimiter substring, stringified with `GD.str`
	-- @param[opt=true] allow_empty  If absent or truthy, inserts empty substrings in the resulting Array
	-- @treturn String
	split = function(self, splitter, allow_empty)
		return ffi_gc(api.godot_string_split_allow_empty(self, str(splitter), allow_empty == nil or allow_empty), api.godot_array_destroy)
	end,
	--- Splits the String in numbers by using a delimiter and returns an array of reals.
	-- @function split_floats
	-- @param delimiter  If an Array is passed, all values are used as delimiters. Otherwise, it is stringified with `GD.str`
	-- @param[opt=true] allow_empty  If absent or truthy, inserts a number for empty substrings
	-- @treturn PoolRealArray
	split_floats = function(self, splitter, allow_empty)
		allow_empty = allow_empty == nil or allow_empty
		if ffi_istype(Array, splitter) then
			return ffi_gc(api.godot_string_split_floats_mk_allows_empty(self, splitter, allow_empty), api.godot_array_destroy)
		else
			return ffi_gc(api.godot_string_split_floats_allows_empty(self, str(splitter), allow_empty), api.godot_array_destroy)
		end
	end,
	--- Splits the String in integers by using a delimiter string and returns an array of integers.
	-- @function split_floats
	-- @param delimiter  If an Array is passed, all values are used as delimiters. Otherwise, it is stringified with `GD.str`
	-- @param[opt=true] allow_empty  If absent or truthy, inserts a number for empty substrings
	-- @treturn PoolIntArray
	split_ints = function(self, splitter, allow_empty)
		allow_empty = allow_empty == nil or allow_empty
		if ffi_istype(Array, splitter) then
			return ffi_gc(api.godot_string_split_ints_mk_allows_empty(self, splitter, allow_empty), api.godot_array_destroy)
		else
			return ffi_gc(api.godot_string_split_ints_allows_empty(self, str(splitter), allow_empty), api.godot_array_destroy)
		end
	end,
	--- Splits the String by whitespace and returns an array of the substrings.
	-- @function split_spaces
	-- @treturn Array
	split_spaces = function(self)
		return ffi_gc(api.godot_string_split_spaces(self), api.godot_array_destroy)
	end,
	--- Returns the string converted to lowercase.
	-- @function to_lower
	-- @treturn String
	to_lower = function(self)
		return ffi_gc(api.godot_string_to_lower(self), api.godot_string_destroy)
	end,
	--- Returns the string converted to uppercase.
	-- @function to_upper
	-- @treturn String
	to_upper = function(self)
		return ffi_gc(api.godot_string_to_upper(self), api.godot_string_destroy)
	end,
	--- If the string is a valid file path, returns the full file path without the extension.
	-- @function get_basename
	-- @treturn String
	get_basename = function(self)
		return ffi_gc(api.godot_string_get_basename(self), api.godot_string_destroy)
	end,
	--- If the string is a valid file path, returns the extension.
	-- @function get_extension
	-- @treturn String
	get_extension = function(self)
		return ffi_gc(api.godot_string_get_extension(self), api.godot_string_destroy)
	end,
	--- Returns a number of characters from the left of the String.
	-- @function left
	-- @tparam[opt=0] int position
	-- @treturn String
	left = function(self, position)
		return ffi_gc(api.godot_string_left(self, position or 0), api.godot_string_destroy)
	end,
	--- Returns the character code at position `at`.
	-- @function ord_at
	-- @treturn String
	ord_at = api.godot_string_ord_at,
	--- If the String is a path, concatenates `file` at the end of the String as a subpath.
	-- @function plus_file
	-- @param file  File path to be concatenated, stringified with `GD.str`
	-- @treturn String
	plus_file = function(self, file)
		return ffi_gc(api.godot_string_plus_file(self, str(file)), api.godot_string_destroy)
	end,
	--- Returns the right side of the String from a given position.
	-- @function right
	-- @tparam[opt=0] int position
	-- @treturn String
	right = function(self, position)
		return ffi_gc(api.godot_string_right(self, position or 0), api.godot_string_destroy)
	end,
	--- Returns a copy of the String stripped of any non-printable character (including tabulations, spaces and line breaks) at the beginning and the end.
	-- @function strip_edges
	-- @param[opt=true] left  Toggle strip left edge
	-- @param[opt=true] right  Toggle strip right edge
	-- @treturn String
	strip_edges = function(self, left, right)
		return ffi_gc(api.godot_string_strip_edges(self, left == nil or left, right == nil or right), api.godot_string_destroy)
	end,
	--- Returns a copy of the String stripped of any escape character.
	-- These include all non-printable control characters of the first page of the ASCII table (< 32), such as tabulation (`\t`) and newline ( `\n` and `\r`) characters, but not spaces.
	-- @function strip_escapes
	-- @treturn String
	strip_escapes = function(self)
		return ffi_gc(api.godot_string_strip_escapes(self), api.godot_string_destroy)
	end,
	erase = api.godot_string_erase,
	ascii = function(self)
		return consume_char_string(api.godot_string_ascii(self))
	end,
	ascii_extended = function(self)
		return consume_char_string(api.godot_string_ascii_extended(self))
	end,
	utf8 = function(self)
		return consume_char_string(api.godot_string_utf8(self))
	end,
	hash = api.godot_string_hash,
	hash64 = api.godot_string_hash64,
	md5_buffer = function(self)
		return ffi_gc(api.godot_string_md5_buffer(self), api.godot_pool_byte_array_destroy)
	end,
	md5_text = function(self)
		return ffi_gc(api.godot_string_md5_text(self), api.godot_string_destroy)
	end,
	sha256_buffer = function(self)
		return ffi_gc(api.godot_string_sha256_buffer(self), api.godot_pool_byte_array_destroy)
	end,
	sha256_text = function(self)
		return ffi_gc(api.godot_string_sha256_text(self), api.godot_string_destroy)
	end,
	empty = api.godot_string_empty,
	get_base_dir = function(self)
		return ffi_gc(api.godot_string_get_base_dir(self), api.godot_string_destroy)
	end,
	get_file = function(self)
		return ffi_gc(api.godot_string_get_file(self), api.godot_string_destroy)
	end,
	is_abs_path = api.godot_string_is_abs_path,
	is_rel_path = api.godot_string_is_rel_path,
	is_resource_file = api.godot_string_is_resource_file,
	path_to = function(self, path)
		return ffi_gc(api.godot_string_path_to(self, str(path)), api.godot_string_destroy)
	end,
	path_to_file = function(self, path)
		return ffi_gc(api.godot_string_path_to_file(self, str(path)), api.godot_string_destroy)
	end,
	simplify_path = function(self)
		return ffi_gc(api.godot_string_simplify_path(self), api.godot_string_destroy)
	end,
	c_escape = function(self)
		return ffi_gc(api.godot_string_c_escape(self), api.godot_string_destroy)
	end,
	c_escape_multiline = function(self)
		return ffi_gc(api.godot_string_c_escape_multiline(self), api.godot_string_destroy)
	end,
	c_unescape = function(self)
		return ffi_gc(api.godot_string_c_unescape(self), api.godot_string_destroy)
	end,
	http_escape = function(self)
		return ffi_gc(api.godot_string_http_escape(self), api.godot_string_destroy)
	end,
	http_unescape = function(self)
		return ffi_gc(api.godot_string_http_unescape(self), api.godot_string_destroy)
	end,
	json_escape = function(self)
		return ffi_gc(api.godot_string_json_escape(self), api.godot_string_destroy)
	end,
	word_wrap = function(self)
		return ffi_gc(api.godot_string_word_wrap(self), api.godot_string_destroy)
	end,
	xml_escape = function(self)
		return ffi_gc(api.godot_string_xml_escape(self), api.godot_string_destroy)
	end,
	xml_escape_with_quotes = function(self)
		return ffi_gc(api.godot_string_xml_escape_with_quotes(self), api.godot_string_destroy)
	end,
	xml_unescape = function(self)
		return ffi_gc(api.godot_string_xml_unescape(self), api.godot_string_destroy)
	end,
	percent_decode = function(self)
		return ffi_gc(api.godot_string_percent_decode(self), api.godot_string_destroy)
	end,
	percent_encode = function(self)
		return ffi_gc(api.godot_string_percent_encode(self), api.godot_string_destroy)
	end,
	is_valid_float = api.godot_string_is_valid_float,
	is_valid_hex_number = function(self, with_prefix)
		return api.godot_string_is_valid_hex_number(self, with_prefix or false)
	end,
	is_valid_html_color = api.godot_string_is_valid_html_color,
	is_valid_identifier = api.godot_string_is_valid_identifier,
	is_valid_integer = api.godot_string_is_valid_integer,
	is_valid_ip_address = api.godot_string_is_valid_ip_address,
	--- Static Functions.
	-- These don't receive `self` and should be called directly as `String.static_function(...)`
	-- @section static_funcs

	--- Encode a sized byte buffer into a String with hexadecimal numbers.
	-- @function String.hex_encode_buffer
	-- @param buffer  Lua string or pointer convertible to `const uint8_t *`
	-- @param[opt=#buffer] len  Buffer length
	-- @treturn String  String with hexadecimal representation of buffer
	hex_encode_buffer = function(buffer, len)
		return ffi_gc(api.godot_string_hex_encode_buffer(buffer, len or #buffer), api.godot_string_destroy)
	end,
	--- Converts `size` represented as number of bytes to human-readable format using internationalized set of data size units, namely: B, KiB, MiB, GiB, TiB, PiB, EiB.
	-- Note that the next smallest unit is picked automatically to hold at most 1024 units.
	-- @treturn String
	humanize_size = function(size)
		return ffi_gc(api.godot_string_humanize_size(size), api.godot_string_destroy)
	end,
}

-- Implement some of the Lua string API
string_methods.byte = function(self, i, j)
	return string_byte(tostring(self), i, j)
end

string_methods.gmatch = function(self, patt, init)
	return string_gmatch(tostring(self), patt, init)
end

string_methods.gsub = function(self, patt, repl, n)
	return string_gsub(tostring(self), patt, repl, n)
end

string_methods.len = string_methods.length
string_methods.lower = string_methods.to_lower
string_methods.upper = string_methods.to_upper

string_methods.match = function(self, patt, init)
	return string_match(tostring(self), patt, init)
end

string_methods.rep = function(self, n, sep)
	return string_rep(tostring(self), n, sep)
end

string_methods.reverse = function(self)
	return string_reverse(tostring(self))
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
		return ffi_gc(api_1_1.godot_string_dedent(self), api.godot_string_destroy)
	end
	string_methods.trim_prefix = function(self, prefix)
		return ffi_gc(api_1_1.godot_string_trim_prefix(self, str(prefix)), api.godot_string_destroy)
	end
	string_methods.trim_suffix = function(self, suffix)
		return ffi_gc(api_1_1.godot_string_trim_suffix(self, str(suffix)), api.godot_string_destroy)
	end
	string_methods.rstrip = function(self, chars)
		return ffi_gc(api_1_1.godot_string_rstrip(self, str(chars)), api.godot_string_destroy)
	end
	string_methods.rsplit = function(self, delimiter, allow_empty, maxsplit)
		if allow_empty == nil then allow_empty = true end
		return ffi_gc(api_1_1.godot_string_rsplit(self, str(delimiter), allow_empty, maxsplit or 0), api.godot_pool_string_array_destroy)
	end
end

String = ffi.metatype('godot_string', {
	__new = function(mt, ...)
		local text, length = ...
		if select('#', ...) == 0 then
			local self = ffi_new(mt)
			api.godot_string_new(self)
			return self
		elseif ffi_istype(mt, text) then
			local self = ffi_new(mt)
			api.godot_string_new_copy(self, text)
			return self
		elseif ffi_istype(StringName, text) then
			return text:get_name()
		elseif ffi_istype('char *', text) then
			if length then
				return ffi_gc(api.godot_string_chars_to_utf8_with_len(text, length), api.godot_string_destroy)
			else
				return ffi_gc(api.godot_string_chars_to_utf8(text), api.godot_string_destroy)
			end
		elseif ffi_istype('wchar_t *', text) then
			local self = ffi_new(mt)
			api.godot_string_new_with_wide_string(self, text, length or -1)
			return self
		elseif ffi_istype('wchar_t', text) or ffi_istype('char', text) then
			return ffi_gc(api.godot_string_chr(text), api.godot_string_destroy)
		else
			text = tostring(text)
			return ffi_gc(api.godot_string_chars_to_utf8_with_len(text, length or #text), api.godot_string_destroy)
		end
	end,
	__gc = api.godot_string_destroy,
	__tostring = string_methods.utf8,
	__len = function(self)
		return string_methods.length(self)
	end,
	__index = string_methods,
	__concat = concat_gdvalues,
	__eq = function(a, b)
		return api.godot_string_operator_equal(str(a), str(b))
	end,
	__lt = function(a, b)
		return api.godot_string_operator_less(str(a), str(b))
	end,
	__mod = function(self, values)
		return assert(string_methods.sprintf(self, values))
	end,
})

local string_name_methods = {
	fillvariant = function(var, self)
		api.godot_variant_new_string(var, self:get_name())
	end,

	get_name = function(self)
		return ffi_gc(api.godot_string_name_get_name(self), api.godot_string_destroy)
	end,
	get_hash = api.godot_string_name_get_hash,
	get_data_unique_pointer = api.godot_string_name_get_data_unique_pointer,
}
StringName = ffi.metatype('godot_string_name', {
	__new = function(mt, text)
		local self = ffi_new(mt)
		api.godot_string_name_new(self, str(text or ''))
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
