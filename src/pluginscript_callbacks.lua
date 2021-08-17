-- Error printing facility
local function print_error(message)
    local info = debug.getinfo(2, 'nSl')
    api.godot_print_error(message, info.name, info.short_src, info.currentline)
end

-- All callbacks will be run in protected mode, to avoid errors in Lua
-- aborting the game/application
-- If an error is thrown, it will be printed in the output console
local function wrap_callback(f)
    return function(...)
        local success, result = xpcall(f, print_error, ...)
        return result
    end
end

-- void (*lps_language_add_global_constant_cb)(const godot_string *name, const godot_variant *value);
ffi.C.lps_language_add_global_constant_cb = wrap_callback(function(name, value)
    api.godot_print(String('TODO: add_global_constant'))
end)

-- void (*lps_script_init_cb)(godot_pluginscript_script_manifest *manifest, const godot_string *path, const godot_string *source, godot_error *error);
ffi.C.lps_script_init_cb = wrap_callback(function(manifest, path, source, err)
    api.godot_print(String('TODO: script_init ' .. path))
end)

-- void (*lps_script_finish_cb)(godot_pluginscript_script_data *data);
ffi.C.lps_script_finish_cb = wrap_callback(function(data)
    api.godot_print(String('TODO: script_finish'))
end)

-- godot_pluginscript_instance_data *(*lps_instance_init_cb)(godot_pluginscript_script_data *data, godot_object *owner);
ffi.C.lps_instance_init_cb = wrap_callback(function(script_data, owner)
    api.godot_print(String('TODO: instance_init'))
    return nil
end)

-- void (*lps_instance_finish_cb)(godot_pluginscript_instance_data *data);
ffi.C.lps_instance_finish_cb = wrap_callback(function(data)
    api.godot_print(String('TODO: instance_finish'))
end)

-- godot_bool (*lps_instance_set_prop_cb)(godot_pluginscript_instance_data *data, const godot_string *name, const godot_variant *value);
ffi.C.lps_instance_set_prop_cb = wrap_callback(function(data, name, value)
    api.godot_print(String('TODO: instance_set_prop'))
    return false
end)

-- godot_bool (*lps_instance_get_prop_cb)(godot_pluginscript_instance_data *data, const godot_string *name, godot_variant *ret);
ffi.C.lps_instance_get_prop_cb = wrap_callback(function(data, name, ret)
    api.godot_print(String('TODO: instance_get_prop'))
    return false
end)

-- void (*lps_instance_call_method_cb)(godot_pluginscript_instance_data *data, const godot_string_name *method, const godot_variant **args, int argcount, godot_variant *ret, godot_variant_call_error *error);
ffi.C.lps_instance_call_method_cb = wrap_callback(function(data, name, args, argcount, ret, err)
    api.godot_print(String('TODO: instance_call_method'))
end)

-- void (*lps_instance_notification_cb)(godot_pluginscript_instance_data *data, int notification);
ffi.C.lps_instance_notification_cb = wrap_callback(function(data, what)
    api.godot_print(String('TODO: instance_notification'))
end)
