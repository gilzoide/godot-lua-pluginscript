-- @file godot_string_name.lua  Wrapper for GDNative's StringName
-- This file is part of Godot Lua PluginScript: https://github.com/gilzoide/godot-lua-pluginscript
--
-- Copyright (C) 2021-2023 Gil Barbosa Reis.
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

--- StringName metatype, wrapper for `godot_string_name`.
-- Construct using the idiom `StringName(name)`, which calls `__new`.
-- @classmod StringName

local methods = {
	fillvariant = function(var, self)
		api.godot_variant_new_string(var, self:get_name())
	end,
	varianttype = VariantType.String,

	--- Returns this StringName as a `String`.
	-- @function get_name
	-- @treturn String
	get_name = function(self)
		return ffi_gc(api.godot_string_name_get_name(self), api.godot_string_destroy)
	end,
	--- Returns this StringName's 32-bit hash value.
	-- @function get_hash
	-- @treturn uint32_t
	get_hash = api.godot_string_name_get_hash,
	--- Returns this StringName's data pointer (`const void *`)
	-- @function get_data_unique_pointer
	-- @return[type=const void *]
	get_data_unique_pointer = api.godot_string_name_get_data_unique_pointer,
}
StringName = ffi_metatype('godot_string_name', {
	--- StringName constructor, called by the idiom `StringName(name)`.
	-- @function __new
	-- @param[opt=""] name  Name, stringified with `GD.str`
	-- @treturn StringName
	__new = function(mt, name)
		local self = ffi_new(mt)
		api.godot_string_name_new(self, str(name or ''))
		return self
	end,
	__gc = api.godot_string_name_destroy,
	--- Returns a Lua string representation of this StringName.
	-- @function __tostring
	-- @treturn string
	-- @see get_name
	__tostring = function(self)
		return tostring(self:get_name())
	end,
	--- Return this StringName's amount of characters.
	-- @function __len
	-- @treturn int
	__len = function(self)
		return #self:get_name()
	end,
	__index = methods,
	--- Concatenates values.
	-- @function __concat
	-- @param a  First value, stringified with `GD.str`
	-- @param b  First value, stringified with `GD.str`
	-- @treturn String
	__concat = concat_gdvalues,
})
