-- @file godot_rid.lua  Wrapper for GDNative's RID
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

--- RID metatype, wrapper for `godot_rid`.
-- Construct using the idiom `RID(from)`, which calls `__new`.
-- @classmod RID

local methods = {
	fillvariant = api.godot_variant_new_rid,
	varianttype = VariantType.RID,

	--- Returns the ID of the referenced resource.
	-- @function get_id
	-- @treturn int
	get_id = api.godot_rid_get_id,
}
RID = ffi_metatype('godot_rid', {
	--- RID constructor, called by the idiom `RID(from)`.
	-- @function __new
	-- @param[opt] from
	-- @treturn RID
	__new = function(mt, from)
		local self = ffi_new(mt)
		if from then
			api.godot_rid_new_with_resource(self, from)
		else
			api.godot_rid_new(self)
		end
		return self
	end,
	__index = methods,
	--- Returns a Lua string representation of this RID.
	-- @function __tostring
	-- @treturn string
	__tostring = gd_tostring,
	--- Concatenates values.
	-- @function __concat
	-- @param a  First value, stringified with `GD.str`
	-- @param b  First value, stringified with `GD.str`
	-- @treturn String
	__concat = concat_gdvalues,
	--- Equality comparison (`a == b`).
	-- If either `a` or `b` are not RIDs, always return `false`.
	-- @function __eq
	-- @param a
	-- @param b
	-- @treturn bool
	__eq = function(a, b)
		return ffi_istype(RID, a) and ffi_istype(RID, b) and api.godot_rid_operator_equal(a, b)
	end,
	--- Less than comparison (`a < b`).
	-- @function __lt
	-- @param a
	-- @param b
	-- @treturn bool
	__lt = api.godot_rid_operator_less,
})

