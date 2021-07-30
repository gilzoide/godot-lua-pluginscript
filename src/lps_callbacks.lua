local loadstring = loadstring or load
local unpack = table.unpack or unpack

local lps_scripts = {}
local lps_instances = {}

local function pointer_to_index(ptr)
    return tonumber(ffi.cast('uintptr_t', ptr))
end

local function wrap_callback(f)
    -- TODO: use `pcall` on debug only?
    return function(...)
        return select(2, xpcall(f, GD.print_error, ...))
    end
end

-- void (*lps_language_add_global_constant_cb)(const godot_string *name, const godot_variant *value);
ffi.C.lps_language_add_global_constant_cb = wrap_callback(function(_data, name, value)
    _G[tostring(name)] = value:unbox()
    print('GLOBAL', name, value)
end)

-- godot_error (*lps_script_init_cb)(godot_pluginscript_script_manifest *data, const godot_string *path, const godot_string *source);
ffi.C.lps_script_init_cb = wrap_callback(function(manifest, path, source)
    path = tostring(path)
    source = tostring(source)
    local script, err = loadstring(source, path)
    if not script then
        GD.print_error('Error parsing script: ' .. err)
        return GD.ERR_PARSE_ERROR
    end
    local success, metadata = pcall(script)
    if not success then
        GD.print_error('Error loading script: ' .. metadata)
        return GD.ERR_SCRIPT_FAILED
    end
    if type(metadata) ~= 'table' then
        GD.print_error(path .. ': script must return a table')
        return GD.ERR_SCRIPT_FAILED
    end
    local metadata_index = pointer_to_index(touserdata(metadata))
    lps_scripts[metadata_index] = metadata
    -- TODO: load metadata into manifest struct
    if metadata.extends then
        manifest.base = StringName(metadata.extends)
    end

    manifest.data = ffi.cast('void *', metadata_index)
    return GD.OK
end)

-- void (*lps_script_finish_cb)(godot_pluginscript_script_data *data);
ffi.C.lps_script_finish_cb = wrap_callback(function(data)
    lps_scripts[pointer_to_index(data)] = nil
end)

-- godot_pluginscript_instance_data *(*lps_instance_init_cb)(godot_pluginscript_script_data *data, godot_object *owner);
ffi.C.lps_instance_init_cb = wrap_callback(function(script_data, owner)
    local script = lps_scripts[pointer_to_index(script_data)]
    local instance = {
        __owner = owner,
        __script = script,
    }
    -- TODO: add metatable?
    local instance_index = pointer_to_index(touserdata(instance))
    lps_instances[instance_index] = instance
    return ffi.cast('void *', instance_index)
end)

-- void (*lps_instance_finish_cb)(godot_pluginscript_instance_data *data);
ffi.C.lps_instance_finish_cb = wrap_callback(function(data)
    lps_instances[pointer_to_index(data)] = nil
end)

-- godot_bool (*lps_instance_set_prop_cb)(godot_pluginscript_instance_data *data, const godot_string *name, const godot_variant *value);
ffi.C.lps_instance_set_prop_cb = wrap_callback(function(data, name, value)
    local self = lps_instances[pointer_to_index(data)]
    name = tostring(name)
    local prop = self.__script[name]
    if prop ~= nil then
        print('SET', self, name, value)
        self[tostring(name)] = value:unbox()
        return true
    else
        return false
    end
end)

-- godot_bool (*lps_instance_get_prop_cb)(godot_pluginscript_instance_data *data, const godot_string *name, godot_variant *ret);
ffi.C.lps_instance_get_prop_cb = wrap_callback(function(data, name, ret)
    local self = lps_instances[pointer_to_index(data)]
    name = tostring(name)
    local prop = self.__script[name]
    if prop ~= nil then
        print('GET', self, name, ret)
        ret = Variant(self[name])
        return true
    else
        return false
    end
end)

-- void (*lps_instance_call_method_cb)(godot_pluginscript_instance_data *data, const godot_string_name *method, const godot_variant **args, int argcount, godot_variant *ret, godot_variant_call_error *error);
ffi.C.lps_instance_call_method_cb = wrap_callback(function(data, name, args, argcount, ret, err)
    local self = lps_instances[pointer_to_index(data)]
    name = tostring(name)
    local method = self.__script[name]
    if method ~= nil then
        print('CALL', self, method, f ~= nil)
        local args_table = {}
        for i = 1, argcount do
            args_table[i] = args[i - 1]:unbox()
        end
        local unboxed_ret = method(self, unpack(args_table))
        ret = Variant(unboxed_ret)
        err = GD.CALL_OK
    else
        err = GD.CALL_ERROR_INVALID_METHOD
    end
end)

-- void (*lps_instance_notification_cb)(godot_pluginscript_instance_data *data, int notification);
ffi.C.lps_instance_notification_cb = function(data, notification)

end
