if Engine:is_editor_hint() then
	-- void (*lps_get_template_source_code_cb)(const godot_string *class_name, const godot_string *base_class_name, godot_string *ret)
	ffi.C.lps_get_template_source_code_cb = function(class_name, base_class_name, ret)
		ret[0] = String('local ' .. class_name .. ' = {\n\textends = "' .. base_class_name .. '",\n}\n\nreturn ' .. class_name)
	end
end
