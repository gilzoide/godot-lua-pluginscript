-- @file pluginscript_callbacks.lua  PluginScript callbacks implementation
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
local lps_next_instance_data

local function get_lua_instance(ptr)
	return lps_lua_objects[pointer_to_index(ptr)]
end

local function set_lua_instance(ptr, instance)
	lps_lua_objects[pointer_to_index(ptr)] = instance
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

local function print_coroutine_error(co, err, msg_prefix)
	err = tostring(err)
	local filename, line, err_msg = string_match(err, ERROR_PATH_LINE_MESSAGE_PATT)
	if not filename then
		filename, line, err_msg = '?', -1, err
	end
	api.godot_print_error((msg_prefix or filename .. ':' .. line .. ': ') .. err_msg, debug_getinfo(co, 0, 'n').name, filename, tonumber(line))
end

local function wrap_callback(f, error_return)
	return function(...)
		local co = lps_coroutine_pool:acquire(f)
		local success, result = coroutine_resume(co, ...)
		if success then
			lps_coroutine_pool:release(co)
		else
			print_coroutine_error(co, result)
			result = error_return
		end
		lps_callstack:pop()
		return result
	end
end
pluginscript_callbacks.wrap_callback = wrap_callback

-- void (*)(const godot_string *name, const godot_variant *value);
pluginscript_callbacks.language_add_global_constant = wrap_callback(function(name, value)
	name = tostring(ffi_cast('godot_string *', name))

	lps_callstack:push('add_global', string_quote(name))

	_G[name] = ffi_cast('godot_variant *', value):unbox()
end)

-- void (*)(godot_pluginscript_script_manifest *manifest, const godot_string *path, const godot_string *source, godot_error *error);
pluginscript_callbacks.script_init = wrap_callback(function(manifest, path, source, err)
	manifest = ffi_cast('godot_pluginscript_script_manifest *', manifest)
	path = tostring(ffi_cast('godot_string *', path))
	source = tostring(ffi_cast('godot_string *', source))
	err = ffi_cast('godot_error *', err)

	lps_callstack:push('script_load', '@', string_quote(path))

	local script, err_message = loadstring(source, path)
	if not script then
		local line, msg = string_match(err_message, ERROR_LINE_MESSAGE_PATT)
		api.godot_print_error('Error parsing script: ' .. msg, path, path, tonumber(line))
		err[0] = Error.PARSE_ERROR
		return
	end
	local co = lps_coroutine_pool:acquire(script)
	local success, script = coroutine_resume(co)
	if not success then
		print_coroutine_error(co, script, 'Error loading script metadata: ')
		return
	end
	lps_coroutine_pool:release(co)
	if type(script) ~= 'table' then
		api.godot_print_error('Script must return a table', path, path, -1)
		return
	end

	local base_class
	local known_properties = {}
	for k, v in pairs(script) do
		if k == 'class_name' then
			manifest.name = ffi_gc(StringName(v), nil)
		elseif k == 'is_tool' then
			manifest.is_tool = bool(v)
		elseif k == 'extends' then
			local cls = is_class_wrapper(v) and v or ClassWrapper_cache[v]
			if not cls then
				api.godot_print_error(
					string_format('Invalid value for "extends": %q is not a Godot class', v),
					path, path, -1
				)
				return
			end
			base_class = cls.class_name
			manifest.base = ffi_gc(StringName(base_class), nil)
		elseif type(v) == 'function' then
			local method = Dictionary()
			method.name = String(k)
			manifest.methods:append(method)
		elseif is_signal(v) then
			local sig = signal_to_dictionary(v)
			sig.name = String(k)
			manifest.signals:append(sig)
		else
			local prop = is_property(v) and v or property(v)
			known_properties[k] = prop
			local prop_dict, default_value = property_to_dictionary(prop)
			prop_dict.name = String(k)
			-- Maintain default value directly for __indexing
			script[k] = default_value
			manifest.properties:append(prop_dict)
		end
	end
	manifest.data = LuaScript_new(path, base_class, known_properties, script)
	err[0] = Error.OK
end)

-- void (*)(godot_pluginscript_script_data *data);
pluginscript_callbacks.script_finish = wrap_callback(function(data)
	local script = ffi_cast('lps_lua_script *', data)

	lps_callstack:push('script_finish')

	LuaScript_destroy(script)
end)

-- void (*)(godot_pluginscript_script_data *data, godot_object *owner, void **result);
pluginscript_callbacks.instance_init = wrap_callback(function(data, owner, result)
	local script = ffi_cast('lps_lua_script *', data)
	owner = ffi_cast('godot_object *', owner)
	result = ffi_cast('lps_script_instance **', result)

	lps_callstack:push('_init', '@', string_quote(script.__path))

	local self = LuaScriptInstance_new(owner, script, lps_next_instance_data)
	lps_next_instance_data = nil
	for name, prop in pairs(script.__properties) do
		if not prop.getter then
			local property_initializer = property_initializer_for_type[prop.type]
			if property_initializer then
				self:rawset(name, property_initializer(prop.default_value))
			end
		end
	end
	local _init = script._init
	if _init then
		_init(self)
	end
	result[0] = self
	set_lua_instance(self.__owner, self)
end)

-- void (*)(godot_pluginscript_instance_data *data);
pluginscript_callbacks.instance_finish = wrap_callback(function(data)
	local self = ffi_cast('lps_script_instance *', data)
	
	lps_callstack:push('finish')

	set_lua_instance(self.__owner, nil)
	LuaScriptInstance_destroy(self)
end)

-- godot_bool (*)(godot_pluginscript_instance_data *data, const godot_string *name, const godot_variant *value);
pluginscript_callbacks.instance_set_prop = wrap_callback(function(data, name, value)
	local self = ffi_cast('lps_script_instance *', data)
	name = tostring(ffi_cast('godot_string *', name))
	value = ffi_cast('godot_variant *', value)

	local script = self.__script
	lps_callstack:push('set', string_quote(name), '@', string_quote(script.__path))

	local prop = script.__properties[name]
	if prop then
		local setter = prop.setter
		if setter then
			setter(self, value:unbox())
		else
			-- Avoid infinite recursion from `self[name] = value`, since `__newindex` calls `Object:set`
			self:rawset(name, value:unbox())
		end
		return true
	else
		local _set = script._set
		if _set then
			return _set(self, name, value:unbox())
		end
	end
	return false
end, false)

-- godot_bool (*)(godot_pluginscript_instance_data *data, const godot_string *name, godot_variant *ret);
pluginscript_callbacks.instance_get_prop = wrap_callback(function(data, name, ret)
	local self = ffi_cast('lps_script_instance *', data)
	name = tostring(ffi_cast('godot_string *', name))
	ret = ffi_cast('godot_variant *', ret)

	local script = self.__script
	lps_callstack:push('get', string_quote(name), '@', string_quote(script.__path))

	local prop = script.__properties[name]
	if prop then
		local getter, value = prop.getter, nil
		if getter then
			value = getter(self)
		else
			-- Avoid infinite recursion from `self[name]`, since `__index` may call `Object:get`
			value = self:rawget(name)
			if value == nil then
				value = prop.default_value
			end
		end
		ret[0] = ffi_gc(Variant(value), nil)
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

-- void (*)(godot_pluginscript_instance_data *data, const godot_string_name *method, const godot_variant **args, int argcount, godot_variant *ret, godot_variant_call_error *error);
pluginscript_callbacks.instance_call_method = wrap_callback(function(data, name, args, argcount, ret, err)
	local self = ffi_cast('lps_script_instance *', data)
	name = tostring(ffi_cast('godot_string_name *', name))
	args = ffi_cast('godot_variant **', args)
	ret = ffi_cast('godot_variant *', ret)
	err = ffi_cast('godot_variant_call_error *', err)

	local script = self.__script
	lps_callstack:push('call', name, '@', string_quote(script.__path))

	local method = script[name]
	if method ~= nil then
		local args_table = {}
		for i = 1, argcount do
			args_table[i] = args[i - 1]:unbox()
		end
		local co = lps_coroutine_pool:acquire(method)
		local success, unboxed_ret = coroutine_resume(co, self, table_unpack(args_table))
		if success then
			lps_coroutine_pool:release(co)
			ret[0] = ffi_gc(Variant(unboxed_ret), nil)
			if err ~= nil then
				err.error = CallError.OK
			end
		else
			print_coroutine_error(co, unboxed_ret)
		end
	end
end)

-- void (*)(godot_pluginscript_instance_data *data, int notification);
pluginscript_callbacks.instance_notification = wrap_callback(function(data, what)
	local self = ffi_cast('lps_script_instance *', data)
	
	local script = self.__script
	lps_callstack:push('_notification', '@', string_quote(script.__path))

	local _notification = script._notification
	if _notification then
		return _notification(self, what)
	end
end)
