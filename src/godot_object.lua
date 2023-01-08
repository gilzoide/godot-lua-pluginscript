-- @file godot_object.lua  Wrapper for GDNative's Object
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

--- Object metatype, wrapper for `godot_object`.
-- @classmod Object

local methods = {
	fillvariant = api.godot_variant_new_object,
	varianttype = VariantType.Object,

	--- Adds a user-defined signal.
	-- @function add_user_signal
	-- @param signal  Signal name
	-- @param[opt] arguments  Array of Dictionaries, each containing name: String and type: int (see `Variant.Type`) entries.
	add_user_signal = api.godot_method_bind_get_method('Object', 'add_user_signal'),
	--- Calls the `method` on the Object and returns the result.
	-- @function call
	-- @param method  Method name
	-- @param ...
	-- @return Method result
	-- @see pcall
	call = function(self, method, ...)
		local result = Object_call(self, method, ...)
		-- Workaround for correcting reference counts of instantiated scripts
		-- Godot initializes the reference count when constructing a Variant from
		-- the Object and Lua automatically references it again (count == 2)
		if method == 'new' and Object_is_class(self, 'Script') and Object_is_class(result, 'Reference') then
			Reference_unreference(result)
		end
		return result
	end,
	--- Calls the `method` on the Object during idle time.
	-- @function call_deferred
	-- @param method  Method name
	-- @param ...
	call_deferred = api.godot_method_bind_get_method('Object', 'call_deferred'),
	--- Returns `true` if the Object can translate strings.
	-- @function can_translate_messages
	-- @treturn bool
	-- @see set_message_translation, tr
	can_translate_messages = api.godot_method_bind_get_method('Object', 'can_translate_messages'),
	--- Connects a `signal` to a `method` on a `target` Object.
	-- Parameters passed in `binds` will be passed to the method after any parameter used in the call to `emit_signal`.
	-- @function connect
	-- @param signal  Signal name
	-- @param target  Target Object
	-- @param method  Method name
	-- @tparam[opt] Array binds
	-- @param[opt] flags
	-- @treturn Error
	-- @see disconnect, is_connected
	connect = api.godot_method_bind_get_method('Object', 'connect'),
	--- Disconnects a `signal` from a `method` on the given `target`.
	-- @function disconnect
	-- @param signal  Signal name
	-- @param target  Target Object
	-- @param method  Method name
	-- @see connect, is_connected
	disconnect = api.godot_method_bind_get_method('Object', 'disconnect'),
	--- Emits the given signal.
	-- The signal must exist.
	-- @function emit_signal
	-- @param signal  Signal name
	-- @param ...
	emit_signal = api.godot_method_bind_get_method('Object', 'emit_signal'),
	--- Deletes the object from memory immediately.
	-- For Nodes, you may want to use `Node.queue_free` to queue the node for safe deletion at the end of the current frame.
	-- @function free
	free = api.godot_method_bind_get_method('Object', 'free'),
	--- Returns the value of the given property.
	-- @function get
	-- @param property  Property name
	-- @return[1] Property value, if it exists
	-- @treturn[2] nil  If property does not exist
	get = Object_get,
	--- Returns the Object's class name.
	-- @function get_class
	-- @treturn String
	get_class = api.godot_method_bind_get_method('Object', 'get_class'),
	--- Returns an Array of Dictionaries with information about signals that are connected to the Object.
	-- Each Dictionary contains three String entries:
	--
	-- - `source` is a reference to the signal emitter.
	-- - `signal_name` is the name of the connected signal.
	-- - `method_name` is the name of the method to which the signal is connected.
	-- @function get_incoming_connections
	-- @treturn Array
	get_incoming_connections = api.godot_method_bind_get_method('Object', 'get_incoming_connections'),
	--- Gets the Object's property indexed by the given NodePath.
	-- The node path should be relative to the current object and can use the colon character (`:`) to access nested properties.
	-- @function get_indexed
	-- @param property
	-- @return Property value
	get_indexed = api.godot_method_bind_get_method('Object', 'get_indexed'),
	--- Returns the Object's unique instance ID.
	-- @function get_instance_id
	-- @treturn int
	get_instance_id = api.godot_method_bind_get_method('Object', 'get_instance_id'),
	-- Returns the Object's metadata entry for the given name.
	-- @function get_meta
	-- @param name
	-- @return Metadata value
	get_meta = api.godot_method_bind_get_method('Object', 'get_meta'),
	--- Returns the Object's metadata as a `PoolStringArray`.
	-- @function get_meta_list
	-- @treturn PoolStringArray
	get_meta_list = api.godot_method_bind_get_method('Object', 'get_meta_list'),
	--- Returns the object's methods and their signatures as an `Array`.
	-- @function get_method_list
	-- @treturn Array
	get_method_list = api.godot_method_bind_get_method('Object', 'get_method_list'),
	--- Returns the Object's property list as an Array of Dictionaries.
	-- Each property's Dictionary contain at least `name: String` and `type: int` (see `Variant.Type`) entries.
	-- Optionally, it can also include `hint: int` (see PropertyHint), `hint_string: String`, and `usage: int` (see PropertyUsageFlags).
	-- @function get_property_list
	-- @treturn Array
	get_property_list = api.godot_method_bind_get_method('Object', 'get_property_list'),
	--- Returns the object's Script instance, or `nil` if none is assigned.
	-- @function get_script
	-- @treturn Object|nil
	get_script = api.godot_method_bind_get_method('Object', 'get_script'),
	--- Returns an `Array` of connections for the given signal.
	-- @function get_signal_connection_list
	-- @param signal  Signal name
	-- @treturn Array
	get_signal_connection_list = api.godot_method_bind_get_method('Object', 'get_signal_connection_list'),
	--- Returns the list of signals as an `Array` of dictionaries.
	-- @function get_signal_list
	-- @treturn Array
	get_signal_list = api.godot_method_bind_get_method('Object', 'get_signal_list'),
	--- Returns `true` if a metadata entry is found with the given `name`.
	-- @function has_meta
	-- @param name
	-- @treturn bool
	has_meta = api.godot_method_bind_get_method('Object', 'has_meta'),
	--- Returns `true` if the Object contains a method with the given `name`.
	-- @function has_method
	-- @param name
	-- @treturn bool
	has_method = Object_has_method,
	--- Returns `true` if the given `signal` exists.
	-- @function has_signal
	-- @param signal
	-- @treturn bool
	has_signal = api.godot_method_bind_get_method('Object', 'has_signal'),
	--- Returns `true` if the given user-defined `signal` exists.
	-- Only signals added using `add_user_signal` are taken into account.
	-- @function has_user_signal
	-- @param signal
	-- @treturn bool
	has_user_signal = api.godot_method_bind_get_method('Object', 'has_user_signal'),
	--- Returns `true` if signal emission blocking is enabled.
	-- @function is_blocking_signals
	-- @treturn bool
	-- @see set_block_signals
	is_blocking_signals = api.godot_method_bind_get_method('Object', 'is_blocking_signals'),
	--- Returns `true` if the Object inherits from the given `class`.
	-- @function is_class
	-- @param class
	-- @treturn bool
	is_class = Object_is_class,
	--- Returns `true` if a connection exists for a given `signal`, `target`, and `method`.
	-- @function is_connected
	-- @param signal  Signal name
	-- @param target  Target Object
	-- @param method  Method name
	-- @treturn bool
	-- @see connect, disconnect
	is_connected = api.godot_method_bind_get_method('Object', 'is_connected'),
	--- Returns `true` if the `Node.queue_free` method was called for the Object.
	-- @function is_queued_for_deletion
	-- @treturn bool
	is_queued_for_deletion = api.godot_method_bind_get_method('Object', 'is_queued_for_deletion'),
	--- Send a given notification to the object, which will also trigger a call to the `_notification` method of all classes that the Object inherits from.
	-- @function notification
	-- @param what
	-- @param[opt=false] reversed
	notification = api.godot_method_bind_get_method('Object', 'notification'),
	--- Notify the editor that the property list has changed, so that editor plugins can take the new values into account.
	-- Does nothing on export builds.
	-- @function property_list_changed_notify
	property_list_changed_notify = api.godot_method_bind_get_method('Object', 'property_list_changed_notify'),
	--- Removes a given entry from the object's metadata.
	-- @function remove_meta
	-- @param name
	-- @see set_meta
	remove_meta = api.godot_method_bind_get_method('Object', 'remove_meta'),
	--- Assigns a new value to the given property.
	-- If the `property` does not exist, nothing will happen.
	-- @function set
	-- @param property
	-- @param value
	set = Object_set,
	--- If set to `true`, signal emission is blocked.
	-- @function set_block_signals
	-- @param enable
	set_block_signals = api.godot_method_bind_get_method('Object', 'set_block_signals'),
	--- Assigns a new value to the given property, after the current frame's physics step.
	-- This is equivalent to calling set via `call_deferred`.
	-- @function set_deferred
	-- @param property
	-- @param value
	set_deferred = api.godot_method_bind_get_method('Object', 'set_deferred'),
	--- Assigns a new value to the property identified by the NodePath.
	-- The node path should be relative to the current object and can use the colon character (`:`) to access nested properties.
	-- @function set_indexed
	-- @param property
	-- @param value
	set_indexed = api.godot_method_bind_get_method('Object', 'set_indexed'),
	--- Defines whether the Object can translate strings (with calls to `tr`).
	-- Enabled by default.
	-- @function set_message_translation
	-- @param enable
	-- @see tr
	set_message_translation = api.godot_method_bind_get_method('Object', 'set_message_translation'),
	--- Adds, changes or removes a given entry in the Object's metadata.
	-- If `value` is set to `nil`, metadata for `name` is removed.
	-- @function set_meta
	-- @param name
	-- @param value
	set_meta = api.godot_method_bind_get_method('Object', 'set_meta'),
	--- Assigns a script to the Object.
	-- If the Object already had a script, the previous script instance will be freed and its variables and state will be lost.
	-- @function set_script
	-- @tparam Object|nil script
	set_script = api.godot_method_bind_get_method('Object', 'set_script'),
	--- Returns a String representing the Object.
	-- Override the method `_to_string` to customize the `String` representation.
	-- If not overridden, defaults to `"[ClassName:RID]"`.
	-- @function to_string
	-- @treturn String
	to_string = api.godot_method_bind_get_method('Object', 'to_string'),
	--- Translates a message using translation catalogs configured in the Project Settings.
	-- Only works if message translation is enabled (which it is by default), otherwise it returns the `message` unchanged.
	-- @function tr
	-- @param message
	-- @treturn String
	-- @see set_message_translation
	tr = api.godot_method_bind_get_method('Object', 'tr'),
}

if api_1_1 ~= nil then
	--- Check if an Object is a valid instance.
	-- Can also be called as `Object.is_instance_valid(some_object_or_nil)`
	-- @function is_instance_valid
	-- @treturn bool
	methods.is_instance_valid = api_1_1.godot_is_instance_valid
end

--- Make a protected call to method with the passed name and arguments.
-- @function pcall
-- @param method  Method name
-- @param ...
-- @treturn[1] bool  `true` if method was called successfully
-- @return[1] Method call result
-- @treturn[2] bool  `false` on errors
-- @return[2] Error message
-- @see call
methods.pcall = function(self, method, ...)
	return pcall(methods.call, self, method, ...)
end

--- Get the `OOP.ClassWrapper` associated with this Object's class.
-- `OOP.ClassWrapper` instances are cached internally.
-- @function get_class_wrapper
-- @treturn ClassWrapper
methods.get_class_wrapper = function(self)
	return ClassWrapper_cache[self:get_class()]
end

_Object = ffi_metatype('godot_object', {
	__new = function(mt, init)
		if ffi_istype(mt, init) then
			return init
		elseif ffi_istype(LuaScriptInstance, init) then
			return init.__owner
		else
			error(string_format('Object or LuaScriptInstance expected, got %q', type(init)))
		end
	end,
	--- Returns a Lua string representation of this Object, as per `to_string`.
	-- @function __tostring
	-- @treturn string
	__tostring = function(self)
		return self == nil and 'Null' or tostring(methods.to_string(self))
	end,
	--- Returns a method binding if `key` is a method name, otherwise returns
	-- `self:get(key)`.
	-- @function __index
	-- @tparam string key
	-- @treturn[1] OOP.MethodBindByName  If `self:has_method(key)`
	-- @return[2] Result from `self:get(key)`
	-- @see get, has_method
	__index = function(self, key)
		return methods[key]
			or (Object_has_method(self, key) and MethodBindByName:new(key))
			or Object_get(self, key)
	end,
	--- Alias for `set`, so that the idiom `object.property = value` sets a property.
	-- @function __newindex
	-- @param property
	-- @param value
	-- @see set
	__newindex = function(self, property, value)
		Object_set(self, property, value)
	end,
	--- Concatenates values.
	-- @function __concat
	-- @param a  First value, stringified with `GD.str`
	-- @param b  First value, stringified with `GD.str`
	-- @treturn String
	__concat = concat_gdvalues,
})

Object = ClassWrapper_cache.Object
Object.call = methods.call
Object.pcall = methods.pcall
Object.is_instance_valid = methods.is_instance_valid
--- (`(godot_object *) NULL`): The `null` Object, useful as default values of properties.
Object.null = ffi_new('godot_object *', nil)
