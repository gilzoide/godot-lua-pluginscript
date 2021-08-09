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
clib.lps_language_add_global_constant_cb = wrap_callback(function(name, value)
	_G[tostring(name)] = value:unbox()
end)

-- godot_error (*lps_script_init_cb)(godot_pluginscript_script_manifest *data, const godot_string *path, const godot_string *source);
clib.lps_script_init_cb = wrap_callback(function(manifest, path, source)
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
	for k, v in pairs(metadata) do
		if k == 'class_name' then
			manifest.name = StringName(v)
		elseif k == 'tool' then
			manifest.is_tool = bool(v)
		elseif k == 'extends' then
			manifest.base = StringName(v)
		elseif type(v) == 'function' then
			local method = method_to_dictionary(v)
			method.name = String(k)
			manifest.methods:append(method)
		elseif is_signal(v) then
			local sig = signal_to_dictionary(v)
			sig.name = String(k)
			manifest.signals:append(sig)
		else
			local prop, default_value = property_to_dictionary(v)
			prop.name = String(k)
			-- Maintain default value directly for __indexing
			metadata[k] = default_value
			manifest.properties:append(prop)
		end
	end

	if #manifest.name == 0 then
		manifest.name = StringName("Reference")
	end

	manifest.data = ffi.cast('void *', metadata_index)
	return GD.OK
end)

-- void (*lps_script_finish_cb)(godot_pluginscript_script_data *data);
clib.lps_script_finish_cb = wrap_callback(function(data)
	lps_scripts[pointer_to_index(data)] = nil
end)

-- godot_pluginscript_instance_data *(*lps_instance_init_cb)(godot_pluginscript_script_data *data, godot_object *owner);
clib.lps_instance_init_cb = wrap_callback(function(script_data, owner)
	local script = lps_scripts[pointer_to_index(script_data)]
	local instance = setmetatable({
		__owner = owner,
		__script = script,
	}, Instance)
	if script._init then
		script._init(instance)
	end
	local instance_index = pointer_to_index(touserdata(instance))
	lps_instances[instance_index] = instance
	return ffi.cast('void *', instance_index)
end)

-- void (*lps_instance_finish_cb)(godot_pluginscript_instance_data *data);
clib.lps_instance_finish_cb = wrap_callback(function(data)
	lps_instances[pointer_to_index(data)] = nil
end)

-- godot_bool (*lps_instance_set_prop_cb)(godot_pluginscript_instance_data *data, const godot_string *name, const godot_variant *value);
clib.lps_instance_set_prop_cb = wrap_callback(function(data, name, value)
	local self = lps_instances[pointer_to_index(data)]
	local script = self.__script
	name = tostring(name)
	local prop = script[name]
	if prop ~= nil then
		self[name] = value:unbox()
		return true
	elseif script._set then
		return script._set(self, name, value:unbox())
	else
		return false
	end
end)

-- godot_bool (*lps_instance_get_prop_cb)(godot_pluginscript_instance_data *data, const godot_string *name, godot_variant *ret);
clib.lps_instance_get_prop_cb = wrap_callback(function(data, name, ret)
	local self = lps_instances[pointer_to_index(data)]
	local script = self.__script
	name = tostring(name)
	local prop = script[name]
	if prop ~= nil then
		ret[0] = Variant(self[name])
		return true
	elseif script._get then
		local unboxed_ret = script._get(self, name)
		if unboxed_ret ~= nil then
			ret[0] = Variant(unboxed_ret)
			return true
		else
			return false
		end
	else
		return false
	end
end)

-- void (*lps_instance_call_method_cb)(godot_pluginscript_instance_data *data, const godot_string_name *method, const godot_variant **args, int argcount, godot_variant *ret, godot_variant_call_error *error);
clib.lps_instance_call_method_cb = wrap_callback(function(data, name, args, argcount, ret, err)
	local self = lps_instances[pointer_to_index(data)]
	name = tostring(name)
	local method = self.__script[name]
	if method ~= nil then
		local args_table = {}
		for i = 1, argcount do
			args_table[i] = args[i - 1]:unbox()
		end
		local unboxed_ret = method(self, unpack(args_table))
		ret[0] = Variant(unboxed_ret)
		err.error = GD.CALL_OK
	else
		err.error = GD.CALL_ERROR_INVALID_METHOD
	end
end)

-- void (*lps_instance_notification_cb)(godot_pluginscript_instance_data *data, int notification);
clib.lps_instance_notification_cb = function(data, what)
	local self = lps_instances[pointer_to_index(data)]
	self:call("_notification", what)
end
