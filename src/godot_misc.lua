local node_path_methods = {
	tovariant = ffi.C.hgdn_new_node_path_variant,
	varianttype = GD.TYPE_NODE_PATH,
}
NodePath = ffi.metatype('godot_node_path', {
	__new = function(mt, text_or_nodepath)
		local self = ffi.new(mt)
		if ffi.istype(mt, text_or_nodepath) then
			api.godot_node_path_new_copy(self, text_or_nodepath)
		elseif ffi.istype(String, text_or_nodepath) then
			api.godot_node_path_new(self, text_or_nodepath)
		else
			api.godot_node_path_new(self, String(text_or_nodepath))
		end
		return self
	end,
	__gc = api.godot_node_path_destroy,
	__tostring = function(self)
		return tostring(api.godot_node_path_as_string(self))
	end,
	__index = node_path_methods,
	__concat = concat_gdvalues,
})

RID = ffi.metatype('godot_rid', {
	__new = function(mt, resource)
		local self = ffi.new(mt)
		if resource then
			api.godot_rid_new_with_resource(self, resource)
		else
			api.godot_rid_new(self)
		end
		return self
	end,
	__tostring = GD.tostring,
	__index = {
		tovariant = ffi.C.hgdn_new_rid_variant,
		varianttype = GD.TYPE_RID,
		get_id = api.godot_rid_get_id,
	},
	__concat = concat_gdvalues,
	__eq = api.godot_rid_operator_equal,
	__lt = api.godot_rid_operator_less,
})

local object_methods = {
	tovariant = ffi.C.hgdn_new_object_variant,
	varianttype = GD.TYPE_OBJECT,
	pcall = function(self, method, ...)
		if self:has_method() then
			return true, self:call(method, ...)
		else
			return false
		end
	end,
	add_user_signal = api.godot_method_bind_get_method('Object', 'add_user_signal'),
	call = api.godot_method_bind_get_method('Object', 'call'),
	call_deferred = api.godot_method_bind_get_method('Object', 'call_deferred'),
	can_translate_messages = api.godot_method_bind_get_method('Object', 'can_translate_messages'),
	connect = api.godot_method_bind_get_method('Object', 'connect'),
	disconnect = api.godot_method_bind_get_method('Object', 'disconnect'),
	emit_signal = api.godot_method_bind_get_method('Object', 'emit_signal'),
	free = api.godot_method_bind_get_method('Object', 'free'),
	get = api.godot_method_bind_get_method('Object', 'get'),
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
	has_method = api.godot_method_bind_get_method('Object', 'has_method'),
	has_signal = api.godot_method_bind_get_method('Object', 'has_signal'),
	has_user_signal = api.godot_method_bind_get_method('Object', 'has_user_signal'),
	is_blocking_signals = api.godot_method_bind_get_method('Object', 'is_blocking_signals'),
	is_class = api.godot_method_bind_get_method('Object', 'is_class'),
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
Object = ffi.metatype('godot_object', {
	__new = function(mt, init)
		if ffi.istype(mt, init) then
			return init
		else
			return init.__owner
		end
	end,
	__tostring = GD.tostring,
	__index = function(self, key)
		if type(key) ~= 'string' then
			return
		end
		local method = object_methods[key]
		if method then
			return method
		end
		if self:has_method(key) then
			return MethodBindByName:new(key)
		else
			self:get(key)
		end
	end,
	__concat = concat_gdvalues,
})
