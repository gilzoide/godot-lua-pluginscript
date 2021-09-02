-- @file godot_misc.lua  Wrapper for GDNative's NodePath, RID and Object
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
local node_path_methods = {
	fillvariant = api.godot_variant_new_node_path,
	varianttype = GD.TYPE_NODE_PATH,

	as_string = function(self)
		return ffi_gc(api.godot_node_path_as_string(self), api.godot_string_destroy)
	end,
	path_is_absolute = api.godot_node_path_is_absolute,
	path_get_name_count = api.godot_node_path_get_name_count,
	path_get_name = function(self, idx)
		return ffi_gc(api.godot_node_path_get_name(self, idx), api.godot_string_destroy)
	end,
	path_get_subname_count = api.godot_node_path_get_subname_count,
	path_get_subname = function(self, idx)
		return ffi_gc(api.godot_node_path_get_subname(self, idx), api.godot_string_destroy)
	end,
	path_get_concatenated_subnames = function(self)
		return ffi_gc(api.godot_node_path_get_concatenated_subnames(self), api.godot_string_destroy)
	end,
	path_is_empty = api.godot_node_path_is_empty,
	path_get_as_property_path = function(self)
		return ffi_gc(api.godot_node_path_get_as_property_path(self), api.godot_node_path_destroy)
	end,
}
NodePath = ffi_metatype('godot_node_path', {
	__new = function(mt, text_or_nodepath)
		local self = ffi_new(mt)
		if ffi_istype(mt, text_or_nodepath) then
			api.godot_node_path_new_copy(self, text_or_nodepath)
		else
			api.godot_node_path_new(self, str(text_or_nodepath))
		end
		return self
	end,
	__gc = api.godot_node_path_destroy,
	__tostring = function(self)
		return tostring(node_path_methods.as_string(self))
	end,
	__index = node_path_methods,
	__concat = concat_gdvalues,
	__eq = function(a, b)
		return api.godot_node_path_operator_equal(NodePath(a), NodePath(b))
	end,
})
