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
		return tostring(api.godot_node_path_as_string(self))
	end,
	__index = node_path_methods,
	__concat = concat_gdvalues,
	__eq = function(a, b)
		return api.godot_node_path_operator_equal(NodePath(a), NodePath(b))
	end,
})

RID = ffi_metatype('godot_rid', {
	__new = function(mt, resource)
		local self = ffi_new(mt)
		if resource then
			api.godot_rid_new_with_resource(self, resource)
		else
			api.godot_rid_new(self)
		end
		return self
	end,
	__tostring = GD.tostring,
	__index = {
		fillvariant = api.godot_variant_new_rid,
		varianttype = GD.TYPE_RID,
		get_id = api.godot_rid_get_id,
	},
	__concat = concat_gdvalues,
	__eq = api.godot_rid_operator_equal,
	__lt = api.godot_rid_operator_less,
})

local object_methods = {
	fillvariant = api.godot_variant_new_object,
	varianttype = GD.TYPE_OBJECT,

	add_user_signal = api.godot_method_bind_get_method('Object', 'add_user_signal'),
	call = function(self, method, ...)
		local result = Object_call(self, method, ...)
		-- Workaround for correcting reference counts of instantiated scripts
		-- Godot initializes the reference count when constructing a Variant from
		-- the Object and Lua automatically references it again (count == 2)
		if method == 'new' and Object_is_class(self, 'Script') then
			Object_call(result, 'unreference')
		end
		return result
	end,
	call_deferred = api.godot_method_bind_get_method('Object', 'call_deferred'),
	can_translate_messages = api.godot_method_bind_get_method('Object', 'can_translate_messages'),
	connect = api.godot_method_bind_get_method('Object', 'connect'),
	disconnect = api.godot_method_bind_get_method('Object', 'disconnect'),
	emit_signal = api.godot_method_bind_get_method('Object', 'emit_signal'),
	free = api.godot_method_bind_get_method('Object', 'free'),
	get = Object_get,
	get_class = api.godot_method_bind_get_method('Object', 'get_class'),
	get_incoming_connections = api.godot_method_bind_get_method('Object', 'get_incoming_connections'),
	get_indexed = api.godot_method_bind_get_method('Object', 'get_indexed'),
	get_instance_id = api.godot_method_bind_get_method('Object', 'get_instance_id'),
	get_meta = api.godot_method_bind_get_method('Object', 'get_meta'),
	get_meta_list = api.godot_method_bind_get_method('Object', 'get_meta_list'),
	get_method_list = api.godot_method_bind_get_method('Object', 'get_method_list'),
	get_property_list = api.godot_method_bind_get_method('Object', 'get_property_list'),
	get_script = api.godot_method_bind_get_method('Object', 'get_script'),
	get_signal_connection_list = api.godot_method_bind_get_method('Object', 'get_signal_connection_list'),
	get_signal_list = api.godot_method_bind_get_method('Object', 'get_signal_list'),
	has_meta = api.godot_method_bind_get_method('Object', 'has_meta'),
	has_method = Object_has_method,
	has_signal = api.godot_method_bind_get_method('Object', 'has_signal'),
	has_user_signal = api.godot_method_bind_get_method('Object', 'has_user_signal'),
	is_blocking_signals = api.godot_method_bind_get_method('Object', 'is_blocking_signals'),
	is_class = Object_is_class,
	is_connected = api.godot_method_bind_get_method('Object', 'is_connected'),
	is_queued_for_deletion = api.godot_method_bind_get_method('Object', 'is_queued_for_deletion'),
	notification = api.godot_method_bind_get_method('Object', 'notification'),
	property_list_changed_notify = api.godot_method_bind_get_method('Object', 'property_list_changed_notify'),
	remove_meta = api.godot_method_bind_get_method('Object', 'remove_meta'),
	set = api.godot_method_bind_get_method('Object', 'set'),
	set_block_signals = api.godot_method_bind_get_method('Object', 'set_block_signals'),
	set_deferred = api.godot_method_bind_get_method('Object', 'set_deferred'),
	set_indexed = api.godot_method_bind_get_method('Object', 'set_indexed'),
	set_message_translation = api.godot_method_bind_get_method('Object', 'set_message_translation'),
	set_meta = api.godot_method_bind_get_method('Object', 'set_meta'),
	set_script = api.godot_method_bind_get_method('Object', 'set_script'),
	to_string = api.godot_method_bind_get_method('Object', 'to_string'),
	tr = api.godot_method_bind_get_method('Object', 'tr'),
}

object_methods.pcall = function(self, method, ...)
	if Object_has_method(self, method) then
		return true, object_methods.call(self, method, ...)
	else
		return false
	end
end

_Object = ffi_metatype('godot_object', {
	__new = function(mt, init)
		if ffi_istype(mt, init) then
			return init
		else
			return init.__owner
		end
	end,
	__tostring = function(self)
		return tostring(object_methods.to_string(self))
	end,
	__index = function(self, key)
		if type(key) ~= 'string' then
			return
		end
		local method = object_methods[key]
		if method then
			return method
		elseif Object_has_method(self, key) then
			return MethodBindByName:new(key)
		else
			return Object_get(self, key)
		end
	end,
	__concat = concat_gdvalues,
})

Object = Class:new 'Object'
