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
})

RID = ffi.metatype('godot_rid', {
	__tostring = GD.tostring,
	__index = {
		tovariant = ffi.C.hgdn_new_rid_variant,
		varianttype = GD.TYPE_RID,
	},
})

Object = ffi.metatype('godot_object', {
	__tostring = GD.tostring,
	__index = {
		tovariant = ffi.C.hgdn_new_object_variant,
		varianttype = GD.TYPE_OBJECT,
	},
})
