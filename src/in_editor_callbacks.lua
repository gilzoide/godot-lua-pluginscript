if Engine:is_editor_hint() then
	-- void (*lps_get_template_source_code_cb)(const godot_string *class_name, const godot_string *base_class_name, godot_string *ret)
	clib.lps_get_template_source_code_cb = wrap_callback(function(class_name, base_class_name, ret)
		ret[0] = String('local ' .. class_name .. ' = {\n\textends = "' .. base_class_name .. '",\n}\n\nreturn ' .. class_name)
	end)

	-- godot_bool (*lps_validate_cb)(const godot_string *script, int *line_error, int *col_error, godot_string *test_error, const godot_string *path, godot_pool_string_array *functions);
	clib.lps_validate_cb = wrap_callback(function(script, line_error, col_error, test_error, path, functions)
		local f, err = loadstring(tostring(script), tostring(path))
		if not f then
			local line, msg = err:match(":(%d+):%s*(.*)")
			line_error[0] = tonumber(line)
			test_error[0] = String(msg)
		end
		return f ~= nil
	end)
end
