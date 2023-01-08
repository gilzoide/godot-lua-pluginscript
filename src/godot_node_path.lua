-- @file godot_node_path.lua  Wrapper for GDNative's NodePath
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

--- NodePath metatype, wrapper for `godot_node_path`.
-- Construct using the idiom `NodePath(path)`, which calls `__new`.
-- @classmod NodePath

local function is_a_node_path(v)
	return is_a_string(v) or ffi_istype(NodePath, v)
end

local methods = {
	fillvariant = api.godot_variant_new_node_path,
	varianttype = VariantType.NodePath,

	--- Gets a `String` that represents this NodePath.
	-- @function as_string
	-- @treturn String
	as_string = function(self)
		return ffi_gc(api.godot_node_path_as_string(self), api.godot_string_destroy)
	end,
	--- Returns `true` if the node path is absolute (as opposed to relative), which means that it starts with a slash character (`/`).
	-- @function is_absolute
	-- @treturn bool
	is_absolute = api.godot_node_path_is_absolute,
	--- Gets the number of node names which make up the path.
	-- Subnames (see `get_subname_count`) are not included.
	-- @function get_name_count
	-- @treturn int
	get_name_count = api.godot_node_path_get_name_count,
	--- Gets the node name indicated by `idx`.
	-- @function get_name
	-- @tparam int idx
	-- @treturn String
	get_name = function(self, idx)
		return ffi_gc(api.godot_node_path_get_name(self, idx), api.godot_string_destroy)
	end,
	--- Gets the number of resource or property names ("subnames") in the path.
	-- Each subname is listed after a colon character (`:`) in the node path.
	-- @function get_subname_count
	-- @treturn int
	get_subname_count = api.godot_node_path_get_subname_count,
	--- Gets the resource or property name indicated by `idx`.
	-- @function get_subname
	-- @tparam int idx
	-- @treturn String
	get_subname = function(self, idx)
		return ffi_gc(api.godot_node_path_get_subname(self, idx), api.godot_string_destroy)
	end,
	--- Returns all subnames concatenated with a colon character (`:`) as separator, i.e. the right side of the first colon in a node path.
	-- @function get_concatenated_subnames
	-- @treturn String
	get_concatenated_subnames = function(self)
		return ffi_gc(api.godot_node_path_get_concatenated_subnames(self), api.godot_string_destroy)
	end,
	--- Returns `true` if the node path is empty.
	-- @function is_empty
	-- @treturn bool
	is_empty = api.godot_node_path_is_empty,
	--- Returns a node path with a colon character (`:`) prepended, transforming it to a pure property path with no node name (defaults to resolving from the current node).
	-- @function get_as_property_path
	-- @treturn String
	get_as_property_path = function(self)
		return ffi_gc(api.godot_node_path_get_as_property_path(self), api.godot_node_path_destroy)
	end,
}
NodePath = ffi_metatype('godot_node_path', {
	--- NodePath constructor, called by the idiom `NodePath(path)`.
	--
	-- * `NodePath()`: empty NodePath
	-- * `NodePath(any path)`: created with `path` stringified with `GD.str`
	-- * `NodePath(NodePath other)`: copy from `other`
	-- @function __new
	-- @param[opt] path
	-- @treturn NodePath
	__new = function(mt, path)
		local self = ffi_new(mt)
		if ffi_istype(mt, path) then
			api.godot_node_path_new_copy(self, path)
		else
			api.godot_node_path_new(self, str(path or ''))
		end
		return self
	end,
	__gc = api.godot_node_path_destroy,
	__index = methods,
	--- Returns a Lua string representation of this NodePath.
	-- @function __tostring
	-- @treturn string
	-- @see as_string
	__tostring = function(self)
		return tostring(methods.as_string(self))
	end,
	--- Concatenates values.
	-- @function __concat
	-- @param a  First value, stringified with `GD.str`
	-- @param b  First value, stringified with `GD.str`
	-- @treturn String
	__concat = concat_gdvalues,
	--- Equality comparison (`a == b`).
	-- If either `a` or `b` are not of type `NodePath`, `String` or Lua `string`, always return `false`.
	-- @function __eq
	-- @param a
	-- @param b
	-- @treturn bool
	__eq = function(a, b)
		return is_a_node_path(a) and is_a_node_path(b) and api.godot_node_path_operator_equal(NodePath(a), NodePath(b))
	end,
})
