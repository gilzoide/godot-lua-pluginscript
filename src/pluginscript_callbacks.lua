-- @file pluginscript_callbacks.lua  PluginScript callbacks implementation
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
local lps_scripts = {}
local lps_instances = setmetatable({}, weak_k)

local function pointer_to_index(ptr)
	return tonumber(ffi_cast('uintptr_t', ptr))
end

local lps_coroutine_pool = {
	acquire = function(self, f)
		return setthreadfunc(table_remove(self), f)
	end,
	release = function(self, co)
		if coroutine_status(co) == 'dead' then
			table_insert(self, co)
		end
	end,
}

local lps_callstack = {
	push = function(self, ...)
		table_insert(self, { ... })
	end,
	pop = table_remove,
}

local function print_coroutine_error(co, err)
	local filename, line, msg = string_match(err, ERROR_PATH_LINE_MESSAGE_PATT)
	msg = debug_traceback(co, msg, 1)
	for i = #lps_callstack, 1, -1 do
		msg = msg .. '\n\tin ' .. table_concat(lps_callstack[i], ' ')
	end
	api.godot_print_error(msg, debug_getinfo(co, 0, 'n').name, filename, tonumber(line))
end

local function wrap_callback(f, error_return)
	return function(...)
		local co = lps_coroutine_pool:acquire(f)
		local success, result = coroutine_resume(co, ...)
		if success then
			lps_coroutine_pool:release(co)
			lps_callstack:pop()
			return result
		else
			print_coroutine_error(co, result)
			lps_callstack:pop()
			return error_return
		end
	end
end

local function get_lua_instance(ptr)
	return lps_instances[pointer_to_index(ptr)]
end

local function set_lua_instance(ptr, instance)
	lps_instances[pointer_to_index(ptr)] = instance
end

-- void (*lps_language_add_global_constant_cb)(const godot_string *name, const godot_variant *value);
clib.lps_language_add_global_constant_cb = wrap_callback(function(name, value)
	name = tostring(name)
	lps_callstack:push('add_global', string_quote(name))
	_G[name] = value:unbox()
end)

-- void (*lps_script_init_cb)(godot_pluginscript_script_manifest *manifest, const godot_string *path, const godot_string *source, godot_error *error);
clib.lps_script_init_cb = wrap_callback(function(manifest, path, source, err)
	path = tostring(path)
	source = tostring(source)
	lps_callstack:push(string_quote(path))
	local script, err_message = loadstring(source, path)
	if not script then
		local line, msg = string_match(err_message, ERROR_LINE_MESSAGE_PATT)
		api.godot_print_error('Error parsing script: ' .. msg, path, path, tonumber(line))
		err[0] = GD.ERR_PARSE_ERROR
		return
	end
	local success, metadata = pcall(script)
	if not success then
		local line, msg = string_match(metadata, ERROR_LINE_MESSAGE_PATT)
		api.godot_print_error('Error loading script metadata: ' .. msg, path, path, tonumber(line))
		return
	end
	if type(metadata) ~= 'table' then
		api.godot_print_error('Script must return a table', path, path, -1)
		return
	end
	local getters, setters = {}, {}
	for k, v in pairs(metadata) do
		if k == 'class_name' then
			manifest.name = StringName(v)
		elseif k == 'is_tool' then
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
			local prop, default_value, get, set = property_to_dictionary(v)
			prop.name = String(k)
			-- Maintain default value directly for __indexing
			metadata[k] = default_value
			if get then
				getters[k] = get
			end
			if set then
				setters[k] = set
			end
			manifest.properties:append(prop)
		end
	end
	metadata.__path = path
	metadata.__getter = getters
	metadata.__setter = setters

	local metadata_index = pointer_to_index(touserdata(metadata))
	lps_scripts[metadata_index] = metadata
	manifest.data = ffi_cast('void *', metadata_index)
	err[0] = GD.OK
end)

-- void (*lps_script_finish_cb)(godot_pluginscript_script_data *data);
clib.lps_script_finish_cb = wrap_callback(function(data)
	lps_callstack:push('script_finish')
	lps_scripts[pointer_to_index(data)] = nil
end)

-- godot_pluginscript_instance_data *(*lps_instance_init_cb)(godot_pluginscript_script_data *data, godot_object *owner);
clib.lps_instance_init_cb = wrap_callback(function(script_data, owner)
	local script = lps_scripts[pointer_to_index(script_data)]
	lps_callstack:push('_init', '@', string_quote(script.__path))
	local instance = setmetatable({
		__owner = owner,
		__script = script,
	}, Instance)
	local _init = script._init
	if _init then
		_init(instance)
	end
	set_lua_instance(owner, instance)
	return owner
end)

-- void (*lps_instance_finish_cb)(godot_pluginscript_instance_data *data);
clib.lps_instance_finish_cb = wrap_callback(function(data)
	lps_callstack:push('finish')
	set_lua_instance(data, nil)
end)

-- godot_bool (*lps_instance_set_prop_cb)(godot_pluginscript_instance_data *data, const godot_string *name, const godot_variant *value);
clib.lps_instance_set_prop_cb = wrap_callback(function(data, name, value)
	name = tostring(name)
	local self = get_lua_instance(data)
	local script = self.__script
	lps_callstack:push('set', string_quote(name), '@', string_quote(script.__path))
	local setter = script.__setter[name]
	if setter then
		setter(self, name, value:unbox())
		return true
	elseif script[name] ~= nil then
		self[name] = value:unbox()
		return true
	else
		local _set = script._set
		if _set then
			return _set(self, name, value:unbox())
		end
	end
	return false
end, false)

-- godot_bool (*lps_instance_get_prop_cb)(godot_pluginscript_instance_data *data, const godot_string *name, godot_variant *ret);
clib.lps_instance_get_prop_cb = wrap_callback(function(data, name, ret)
	name = tostring(name)
	local self = get_lua_instance(data)
	local script = self.__script
	lps_callstack:push('get', string_quote(name), '@', string_quote(script.__path))
	local getter = script.__getter[name]
	if getter then
		ret[0] = ffi_gc(Variant(getter(self)), nil)
		return true
	elseif script[name] ~= nil then
		ret[0] = ffi_gc(Variant(self[name]), nil)
		return true
	else
		local _get = script._get
		if _get then
			local unboxed_ret = _get(self, name)
			if unboxed_ret ~= nil then
				ret[0] = ffi_gc(Variant(unboxed_ret), nil)
				return true
			end
		end
	end
	return false
end, false)

-- void (*lps_instance_call_method_cb)(godot_pluginscript_instance_data *data, const godot_string_name *method, const godot_variant **args, int argcount, godot_variant *ret, godot_variant_call_error *error);

clib.lps_instance_call_method_cb = wrap_callback(function(data, name, args, argcount, ret, err)
	name = tostring(name)
	local self = get_lua_instance(data)
	local script = self.__script
	lps_callstack:push('call', name, '@', script.__path)
	local method = script[name]
	if method ~= nil then
		local args_table = {}
		for i = 1, argcount do
			args_table[i] = args[i - 1]:unbox()
		end
		local co = lps_coroutine_pool:acquire(method)
		local success, unboxed_ret = coroutine_resume(co, self, unpack(args_table))
		if success then
			lps_coroutine_pool:release(co)
			ret[0] = ffi_gc(Variant(unboxed_ret), nil)
			if err ~= nil then
				err.error = GD.CALL_OK
			end
		else
			print_coroutine_error(co, unboxed_ret)
		end
	end
end)

-- void (*lps_instance_notification_cb)(godot_pluginscript_instance_data *data, int notification);
clib.lps_instance_notification_cb = wrap_callback(function(data, what)
	local self = get_lua_instance(data)
	local script = self.__script
	lps_callstack:push('_notification', '@', script.__path)
	local _notification = script._notification
	if _notification then
		return _notification(self, what)
	end
end)
