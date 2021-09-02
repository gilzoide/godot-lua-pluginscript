-- @file godot_globals.lua  Global Godot functionality and enum values
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
local function str(value)
	if ffi_istype(String, value) then
		return value
	else
		return Variant(value):as_string()
	end
end

local function concat_gdvalues(a, b)
	return ffi_gc(api.godot_string_operator_plus(str(a), str(b)), api.godot_string_destroy)
end

--- Global table with Godot functions and enums
-- @module GD
GD = {
	--- (`const godot_gdnative_core_api_struct *`) GDNative core API 1.0
	api = api,
	--- (`const godot_gdnative_core_1_1_api_struct *`) GDNative core API 1.1
	api_1_1 = api_1_1,
	--- (`const godot_gdnative_core_1_2_api_struct *`) GDNative core API 1.2
	api_1_2 = api_1_2,
	--- `(godot_error) OK`
	OK = clib.GODOT_OK, 
	--- `(godot_error) FAILED`
	FAILED = clib.GODOT_FAILED, 
	--- `(godot_error) ERR_UNAVAILABLE`
	ERR_UNAVAILABLE = clib.GODOT_ERR_UNAVAILABLE, 
	--- `(godot_error) ERR_UNCONFIGURED`
	ERR_UNCONFIGURED = clib.GODOT_ERR_UNCONFIGURED, 
	--- `(godot_error) ERR_UNAUTHORIZED`
	ERR_UNAUTHORIZED = clib.GODOT_ERR_UNAUTHORIZED, 
	--- `(godot_error) ERR_PARAMETER_RANGE_ERROR`
	ERR_PARAMETER_RANGE_ERROR = clib.GODOT_ERR_PARAMETER_RANGE_ERROR, 
	--- `(godot_error) ERR_OUT_OF_MEMORY`
	ERR_OUT_OF_MEMORY = clib.GODOT_ERR_OUT_OF_MEMORY, 
	--- `(godot_error) ERR_FILE_NOT_FOUND`
	ERR_FILE_NOT_FOUND = clib.GODOT_ERR_FILE_NOT_FOUND,
	--- `(godot_error) ERR_FILE_BAD_DRIVE`
	ERR_FILE_BAD_DRIVE = clib.GODOT_ERR_FILE_BAD_DRIVE,
	--- `(godot_error) ERR_FILE_BAD_PATH`
	ERR_FILE_BAD_PATH = clib.GODOT_ERR_FILE_BAD_PATH,
	--- `(godot_error) ERR_FILE_NO_PERMISSION`
	ERR_FILE_NO_PERMISSION = clib.GODOT_ERR_FILE_NO_PERMISSION, 
	--- `(godot_error) ERR_FILE_ALREADY_IN_USE`
	ERR_FILE_ALREADY_IN_USE = clib.GODOT_ERR_FILE_ALREADY_IN_USE,
	--- `(godot_error) ERR_FILE_CANT_OPEN`
	ERR_FILE_CANT_OPEN = clib.GODOT_ERR_FILE_CANT_OPEN,
	--- `(godot_error) ERR_FILE_CANT_WRITE`
	ERR_FILE_CANT_WRITE = clib.GODOT_ERR_FILE_CANT_WRITE,
	--- `(godot_error) ERR_FILE_CANT_READ`
	ERR_FILE_CANT_READ = clib.GODOT_ERR_FILE_CANT_READ,
	--- `(godot_error) ERR_FILE_UNRECOGNIZED`
	ERR_FILE_UNRECOGNIZED = clib.GODOT_ERR_FILE_UNRECOGNIZED, 
	--- `(godot_error) ERR_FILE_CORRUPT`
	ERR_FILE_CORRUPT = clib.GODOT_ERR_FILE_CORRUPT,
	--- `(godot_error) ERR_FILE_MISSING_DEPENDENCIES`
	ERR_FILE_MISSING_DEPENDENCIES = clib.GODOT_ERR_FILE_MISSING_DEPENDENCIES,
	--- `(godot_error) ERR_FILE_EOF`
	ERR_FILE_EOF = clib.GODOT_ERR_FILE_EOF,
	--- `(godot_error) ERR_CANT_OPEN`
	ERR_CANT_OPEN = clib.GODOT_ERR_CANT_OPEN, 
	--- `(godot_error) ERR_CANT_CREATE`
	ERR_CANT_CREATE = clib.GODOT_ERR_CANT_CREATE, 
	--- `(godot_error) ERR_QUERY_FAILED`
	ERR_QUERY_FAILED = clib.GODOT_ERR_QUERY_FAILED,
	--- `(godot_error) ERR_ALREADY_IN_USE`
	ERR_ALREADY_IN_USE = clib.GODOT_ERR_ALREADY_IN_USE,
	--- `(godot_error) ERR_LOCKED`
	ERR_LOCKED = clib.GODOT_ERR_LOCKED, 
	--- `(godot_error) ERR_TIMEOUT`
	ERR_TIMEOUT = clib.GODOT_ERR_TIMEOUT,
	--- `(godot_error) ERR_CANT_CONNECT`
	ERR_CANT_CONNECT = clib.GODOT_ERR_CANT_CONNECT, 
	--- `(godot_error) ERR_CANT_RESOLVE`
	ERR_CANT_RESOLVE = clib.GODOT_ERR_CANT_RESOLVE,
	--- `(godot_error) ERR_CONNECTION_ERROR`
	ERR_CONNECTION_ERROR = clib.GODOT_ERR_CONNECTION_ERROR,
	--- `(godot_error) ERR_CANT_ACQUIRE_RESOURCE`
	ERR_CANT_ACQUIRE_RESOURCE = clib.GODOT_ERR_CANT_ACQUIRE_RESOURCE,
	--- `(godot_error) ERR_CANT_FORK`
	ERR_CANT_FORK = clib.GODOT_ERR_CANT_FORK,
	--- `(godot_error) ERR_INVALID_DATA`
	ERR_INVALID_DATA = clib.GODOT_ERR_INVALID_DATA, 
	--- `(godot_error) ERR_INVALID_PARAMETER`
	ERR_INVALID_PARAMETER = clib.GODOT_ERR_INVALID_PARAMETER, 
	--- `(godot_error) ERR_ALREADY_EXISTS`
	ERR_ALREADY_EXISTS = clib.GODOT_ERR_ALREADY_EXISTS, 
	--- `(godot_error) ERR_DOES_NOT_EXIST`
	ERR_DOES_NOT_EXIST = clib.GODOT_ERR_DOES_NOT_EXIST, 
	--- `(godot_error) ERR_DATABASE_CANT_READ`
	ERR_DATABASE_CANT_READ = clib.GODOT_ERR_DATABASE_CANT_READ, 
	--- `(godot_error) ERR_DATABASE_CANT_WRITE`
	ERR_DATABASE_CANT_WRITE = clib.GODOT_ERR_DATABASE_CANT_WRITE, 
	--- `(godot_error) ERR_COMPILATION_FAILED`
	ERR_COMPILATION_FAILED = clib.GODOT_ERR_COMPILATION_FAILED,
	--- `(godot_error) ERR_METHOD_NOT_FOUND`
	ERR_METHOD_NOT_FOUND = clib.GODOT_ERR_METHOD_NOT_FOUND,
	--- `(godot_error) ERR_LINK_FAILED`
	ERR_LINK_FAILED = clib.GODOT_ERR_LINK_FAILED,
	--- `(godot_error) ERR_SCRIPT_FAILED`
	ERR_SCRIPT_FAILED = clib.GODOT_ERR_SCRIPT_FAILED,
	--- `(godot_error) ERR_CYCLIC_LINK`
	ERR_CYCLIC_LINK = clib.GODOT_ERR_CYCLIC_LINK, 
	--- `(godot_error) ERR_INVALID_DECLARATION`
	ERR_INVALID_DECLARATION = clib.GODOT_ERR_INVALID_DECLARATION,
	--- `(godot_error) ERR_DUPLICATE_SYMBOL`
	ERR_DUPLICATE_SYMBOL = clib.GODOT_ERR_DUPLICATE_SYMBOL,
	--- `(godot_error) ERR_PARSE_ERROR`
	ERR_PARSE_ERROR = clib.GODOT_ERR_PARSE_ERROR,
	--- `(godot_error) ERR_BUSY`
	ERR_BUSY = clib.GODOT_ERR_BUSY,
	--- `(godot_error) ERR_SKIP`
	ERR_SKIP = clib.GODOT_ERR_SKIP, 
	--- `(godot_error) ERR_HELP`
	ERR_HELP = clib.GODOT_ERR_HELP, 
	--- `(godot_error) ERR_BUG`
	ERR_BUG = clib.GODOT_ERR_BUG, 
	--- `(godot_error) ERR_PRINTER_ON_FIRE`
	ERR_PRINTER_ON_FIRE = clib.GODOT_ERR_PRINTER_ON_FIRE, 
	--- `(godot_variant_type) TYPE_NIL`
	TYPE_NIL = clib.GODOT_VARIANT_TYPE_NIL,
	--- `(godot_variant_type) TYPE_BOOL`
	TYPE_BOOL = clib.GODOT_VARIANT_TYPE_BOOL,
	--- `(godot_variant_type) TYPE_INT`
	TYPE_INT = clib.GODOT_VARIANT_TYPE_INT,
	--- `(godot_variant_type) TYPE_REAL`
	TYPE_REAL = clib.GODOT_VARIANT_TYPE_REAL,
	--- `(godot_variant_type) TYPE_STRING`
	TYPE_STRING = clib.GODOT_VARIANT_TYPE_STRING,
	--- `(godot_variant_type) TYPE_VECTOR2`
	TYPE_VECTOR2 = clib.GODOT_VARIANT_TYPE_VECTOR2, 
	--- `(godot_variant_type) TYPE_RECT2`
	TYPE_RECT2 = clib.GODOT_VARIANT_TYPE_RECT2,
	--- `(godot_variant_type) TYPE_VECTOR3`
	TYPE_VECTOR3 = clib.GODOT_VARIANT_TYPE_VECTOR3,
	--- `(godot_variant_type) TYPE_TRANSFORM2D`
	TYPE_TRANSFORM2D = clib.GODOT_VARIANT_TYPE_TRANSFORM2D,
	--- `(godot_variant_type) TYPE_PLANE`
	TYPE_PLANE = clib.GODOT_VARIANT_TYPE_PLANE,
	--- `(godot_variant_type) TYPE_QUAT`
	TYPE_QUAT = clib.GODOT_VARIANT_TYPE_QUAT, 
	--- `(godot_variant_type) TYPE_AABB`
	TYPE_AABB = clib.GODOT_VARIANT_TYPE_AABB,
	--- `(godot_variant_type) TYPE_BASIS`
	TYPE_BASIS = clib.GODOT_VARIANT_TYPE_BASIS,
	--- `(godot_variant_type) TYPE_TRANSFORM`
	TYPE_TRANSFORM = clib.GODOT_VARIANT_TYPE_TRANSFORM,
	--- `(godot_variant_type) TYPE_COLOR`
	TYPE_COLOR = clib.GODOT_VARIANT_TYPE_COLOR,
	--- `(godot_variant_type) TYPE_NODE_PATH`
	TYPE_NODE_PATH = clib.GODOT_VARIANT_TYPE_NODE_PATH, 
	--- `(godot_variant_type) TYPE_RID`
	TYPE_RID = clib.GODOT_VARIANT_TYPE_RID,
	--- `(godot_variant_type) TYPE_OBJECT`
	TYPE_OBJECT = clib.GODOT_VARIANT_TYPE_OBJECT,
	--- `(godot_variant_type) TYPE_DICTIONARY`
	TYPE_DICTIONARY = clib.GODOT_VARIANT_TYPE_DICTIONARY,
	--- `(godot_variant_type) TYPE_ARRAY`
	TYPE_ARRAY = clib.GODOT_VARIANT_TYPE_ARRAY, 
	--- `(godot_variant_type) TYPE_POOL_BYTE_ARRAY`
	TYPE_POOL_BYTE_ARRAY = clib.GODOT_VARIANT_TYPE_POOL_BYTE_ARRAY,
	--- `(godot_variant_type) TYPE_POOL_INT_ARRAY`
	TYPE_POOL_INT_ARRAY = clib.GODOT_VARIANT_TYPE_POOL_INT_ARRAY,
	--- `(godot_variant_type) TYPE_POOL_REAL_ARRAY`
	TYPE_POOL_REAL_ARRAY = clib.GODOT_VARIANT_TYPE_POOL_REAL_ARRAY,
	--- `(godot_variant_type) TYPE_POOL_STRING_ARRAY`
	TYPE_POOL_STRING_ARRAY = clib.GODOT_VARIANT_TYPE_POOL_STRING_ARRAY,
	--- `(godot_variant_type) TYPE_POOL_VECTOR2_ARRAY`
	TYPE_POOL_VECTOR2_ARRAY = clib.GODOT_VARIANT_TYPE_POOL_VECTOR2_ARRAY, 
	--- `(godot_variant_type) TYPE_POOL_VECTOR3_ARRAY`
	TYPE_POOL_VECTOR3_ARRAY = clib.GODOT_VARIANT_TYPE_POOL_VECTOR3_ARRAY,
	--- `(godot_variant_type) TYPE_POOL_COLOR_ARRAY`
	TYPE_POOL_COLOR_ARRAY = clib.GODOT_VARIANT_TYPE_POOL_COLOR_ARRAY,
	--- `(godot_variant_call_error_error) CALL_OK`
	CALL_OK = clib.GODOT_CALL_ERROR_CALL_OK,
	--- `(godot_variant_call_error_error) CALL_ERROR_INVALID_METHOD`
	CALL_ERROR_INVALID_METHOD = clib.GODOT_CALL_ERROR_CALL_ERROR_INVALID_METHOD,
	--- `(godot_variant_call_error_error) CALL_ERROR_INVALID_ARGUMENT`
	CALL_ERROR_INVALID_ARGUMENT = clib.GODOT_CALL_ERROR_CALL_ERROR_INVALID_ARGUMENT,
	--- `(godot_variant_call_error_error) CALL_ERROR_TOO_MANY_ARGUMENTS`
	CALL_ERROR_TOO_MANY_ARGUMENTS = clib.GODOT_CALL_ERROR_CALL_ERROR_TOO_MANY_ARGUMENTS,
	--- `(godot_variant_call_error_error) CALL_ERROR_TOO_FEW_ARGUMENTS`
	CALL_ERROR_TOO_FEW_ARGUMENTS = clib.GODOT_CALL_ERROR_CALL_ERROR_TOO_FEW_ARGUMENTS,
	--- `(godot_variant_call_error_error) CALL_ERROR_INSTANCE_IS_NULL`
	CALL_ERROR_INSTANCE_IS_NULL = clib.GODOT_CALL_ERROR_CALL_ERROR_INSTANCE_IS_NULL,
	--- `(godot_method_rpc_mode) RPC_MODE_DISABLED`
	RPC_MODE_DISABLED = clib.GODOT_METHOD_RPC_MODE_DISABLED,
	--- `(godot_method_rpc_mode) RPC_MODE_REMOTE`
	RPC_MODE_REMOTE = clib.GODOT_METHOD_RPC_MODE_REMOTE,
	--- `(godot_method_rpc_mode) RPC_MODE_MASTER`
	RPC_MODE_MASTER = clib.GODOT_METHOD_RPC_MODE_MASTER,
	--- `(godot_method_rpc_mode) RPC_MODE_PUPPET`
	RPC_MODE_PUPPET = clib.GODOT_METHOD_RPC_MODE_PUPPET,
	--- `(godot_method_rpc_mode) RPC_MODE_SLAVE`
	RPC_MODE_SLAVE = clib.GODOT_METHOD_RPC_MODE_SLAVE,
	--- `(godot_method_rpc_mode) RPC_MODE_REMOTESYNC`
	RPC_MODE_REMOTESYNC = clib.GODOT_METHOD_RPC_MODE_REMOTESYNC,
	--- `(godot_method_rpc_mode) RPC_MODE_SYNC`
	RPC_MODE_SYNC = clib.GODOT_METHOD_RPC_MODE_SYNC,
	--- `(godot_method_rpc_mode) RPC_MODE_MASTERSYNC`
	RPC_MODE_MASTERSYNC = clib.GODOT_METHOD_RPC_MODE_MASTERSYNC,
	--- `(godot_method_rpc_mode) RPC_MODE_PUPPETSYNC`
	RPC_MODE_PUPPETSYNC = clib.GODOT_METHOD_RPC_MODE_PUPPETSYNC,
	--- `(godot_property_hint) PROPERTY_HINT_NONE`
	PROPERTY_HINT_NONE = clib.GODOT_PROPERTY_HINT_NONE, 
	--- `(godot_property_hint) PROPERTY_HINT_RANGE`
	PROPERTY_HINT_RANGE = clib.GODOT_PROPERTY_HINT_RANGE, 
	--- `(godot_property_hint) PROPERTY_HINT_EXP_RANGE`
	PROPERTY_HINT_EXP_RANGE = clib.GODOT_PROPERTY_HINT_EXP_RANGE, 
	--- `(godot_property_hint) PROPERTY_HINT_ENUM`
	PROPERTY_HINT_ENUM = clib.GODOT_PROPERTY_HINT_ENUM, 
	--- `(godot_property_hint) PROPERTY_HINT_EXP_EASING`
	PROPERTY_HINT_EXP_EASING = clib.GODOT_PROPERTY_HINT_EXP_EASING, 
	--- `(godot_property_hint) PROPERTY_HINT_LENGTH`
	PROPERTY_HINT_LENGTH = clib.GODOT_PROPERTY_HINT_LENGTH, 
	--- `(godot_property_hint) PROPERTY_HINT_SPRITE_FRAME`
	PROPERTY_HINT_SPRITE_FRAME = clib.GODOT_PROPERTY_HINT_SPRITE_FRAME, 
	--- `(godot_property_hint) PROPERTY_HINT_KEY_ACCEL`
	PROPERTY_HINT_KEY_ACCEL = clib.GODOT_PROPERTY_HINT_KEY_ACCEL, 
	--- `(godot_property_hint) PROPERTY_HINT_FLAGS`
	PROPERTY_HINT_FLAGS = clib.GODOT_PROPERTY_HINT_FLAGS, 
	--- `(godot_property_hint) PROPERTY_HINT_LAYERS_2D_RENDER`
	PROPERTY_HINT_LAYERS_2D_RENDER = clib.GODOT_PROPERTY_HINT_LAYERS_2D_RENDER,
	--- `(godot_property_hint) PROPERTY_HINT_LAYERS_2D_PHYSICS`
	PROPERTY_HINT_LAYERS_2D_PHYSICS = clib.GODOT_PROPERTY_HINT_LAYERS_2D_PHYSICS,
	--- `(godot_property_hint) PROPERTY_HINT_LAYERS_3D_RENDER`
	PROPERTY_HINT_LAYERS_3D_RENDER = clib.GODOT_PROPERTY_HINT_LAYERS_3D_RENDER,
	--- `(godot_property_hint) PROPERTY_HINT_LAYERS_3D_PHYSICS`
	PROPERTY_HINT_LAYERS_3D_PHYSICS = clib.GODOT_PROPERTY_HINT_LAYERS_3D_PHYSICS,
	--- `(godot_property_hint) PROPERTY_HINT_FILE`
	PROPERTY_HINT_FILE = clib.GODOT_PROPERTY_HINT_FILE, 
	--- `(godot_property_hint) PROPERTY_HINT_DIR`
	PROPERTY_HINT_DIR = clib.GODOT_PROPERTY_HINT_DIR, 
	--- `(godot_property_hint) PROPERTY_HINT_GLOBAL_FILE`
	PROPERTY_HINT_GLOBAL_FILE = clib.GODOT_PROPERTY_HINT_GLOBAL_FILE, 
	--- `(godot_property_hint) PROPERTY_HINT_GLOBAL_DIR`
	PROPERTY_HINT_GLOBAL_DIR = clib.GODOT_PROPERTY_HINT_GLOBAL_DIR, 
	--- `(godot_property_hint) PROPERTY_HINT_RESOURCE_TYPE`
	PROPERTY_HINT_RESOURCE_TYPE = clib.GODOT_PROPERTY_HINT_RESOURCE_TYPE, 
	--- `(godot_property_hint) PROPERTY_HINT_MULTILINE_TEXT`
	PROPERTY_HINT_MULTILINE_TEXT = clib.GODOT_PROPERTY_HINT_MULTILINE_TEXT, 
	--- `(godot_property_hint) PROPERTY_HINT_PLACEHOLDER_TEXT`
	PROPERTY_HINT_PLACEHOLDER_TEXT = clib.GODOT_PROPERTY_HINT_PLACEHOLDER_TEXT, 
	--- `(godot_property_hint) PROPERTY_HINT_COLOR_NO_ALPHA`
	PROPERTY_HINT_COLOR_NO_ALPHA = clib.GODOT_PROPERTY_HINT_COLOR_NO_ALPHA, 
	--- `(godot_property_hint) PROPERTY_HINT_IMAGE_COMPRESS_LOSSY`
	PROPERTY_HINT_IMAGE_COMPRESS_LOSSY = clib.GODOT_PROPERTY_HINT_IMAGE_COMPRESS_LOSSY,
	--- `(godot_property_hint) PROPERTY_HINT_IMAGE_COMPRESS_LOSSLESS`
	PROPERTY_HINT_IMAGE_COMPRESS_LOSSLESS = clib.GODOT_PROPERTY_HINT_IMAGE_COMPRESS_LOSSLESS,
	--- `(godot_property_hint) PROPERTY_HINT_OBJECT_ID`
	PROPERTY_HINT_OBJECT_ID = clib.GODOT_PROPERTY_HINT_OBJECT_ID,
	--- `(godot_property_hint) PROPERTY_HINT_TYPE_STRING`
	PROPERTY_HINT_TYPE_STRING = clib.GODOT_PROPERTY_HINT_TYPE_STRING, 
	--- `(godot_property_hint) PROPERTY_HINT_NODE_PATH_TO_EDITED_NODE`
	PROPERTY_HINT_NODE_PATH_TO_EDITED_NODE = clib.GODOT_PROPERTY_HINT_NODE_PATH_TO_EDITED_NODE, 
	--- `(godot_property_hint) PROPERTY_HINT_METHOD_OF_VARIANT_TYPE`
	PROPERTY_HINT_METHOD_OF_VARIANT_TYPE = clib.GODOT_PROPERTY_HINT_METHOD_OF_VARIANT_TYPE, 
	--- `(godot_property_hint) PROPERTY_HINT_METHOD_OF_BASE_TYPE`
	PROPERTY_HINT_METHOD_OF_BASE_TYPE = clib.GODOT_PROPERTY_HINT_METHOD_OF_BASE_TYPE, 
	--- `(godot_property_hint) PROPERTY_HINT_METHOD_OF_INSTANCE`
	PROPERTY_HINT_METHOD_OF_INSTANCE = clib.GODOT_PROPERTY_HINT_METHOD_OF_INSTANCE, 
	--- `(godot_property_hint) PROPERTY_HINT_METHOD_OF_SCRIPT`
	PROPERTY_HINT_METHOD_OF_SCRIPT = clib.GODOT_PROPERTY_HINT_METHOD_OF_SCRIPT, 
	--- `(godot_property_hint) PROPERTY_HINT_PROPERTY_OF_VARIANT_TYPE`
	PROPERTY_HINT_PROPERTY_OF_VARIANT_TYPE = clib.GODOT_PROPERTY_HINT_PROPERTY_OF_VARIANT_TYPE, 
	--- `(godot_property_hint) PROPERTY_HINT_PROPERTY_OF_BASE_TYPE`
	PROPERTY_HINT_PROPERTY_OF_BASE_TYPE = clib.GODOT_PROPERTY_HINT_PROPERTY_OF_BASE_TYPE, 
	--- `(godot_property_hint) PROPERTY_HINT_PROPERTY_OF_INSTANCE`
	PROPERTY_HINT_PROPERTY_OF_INSTANCE = clib.GODOT_PROPERTY_HINT_PROPERTY_OF_INSTANCE, 
	--- `(godot_property_hint) PROPERTY_HINT_PROPERTY_OF_SCRIPT`
	PROPERTY_HINT_PROPERTY_OF_SCRIPT = clib.GODOT_PROPERTY_HINT_PROPERTY_OF_SCRIPT, 
	--- `(godot_property_usage_flags) PROPERTY_USAGE_STORAGE`
	PROPERTY_USAGE_STORAGE = clib.GODOT_PROPERTY_USAGE_STORAGE,
	--- `(godot_property_usage_flags) PROPERTY_USAGE_EDITOR`
	PROPERTY_USAGE_EDITOR = clib.GODOT_PROPERTY_USAGE_EDITOR,
	--- `(godot_property_usage_flags) PROPERTY_USAGE_NETWORK`
	PROPERTY_USAGE_NETWORK = clib.GODOT_PROPERTY_USAGE_NETWORK,
	--- `(godot_property_usage_flags) PROPERTY_USAGE_EDITOR_HELPER`
	PROPERTY_USAGE_EDITOR_HELPER = clib.GODOT_PROPERTY_USAGE_EDITOR_HELPER,
	--- `(godot_property_usage_flags) PROPERTY_USAGE_CHECKABLE`
	PROPERTY_USAGE_CHECKABLE = clib.GODOT_PROPERTY_USAGE_CHECKABLE, 
	--- `(godot_property_usage_flags) PROPERTY_USAGE_CHECKED`
	PROPERTY_USAGE_CHECKED = clib.GODOT_PROPERTY_USAGE_CHECKED, 
	--- `(godot_property_usage_flags) PROPERTY_USAGE_INTERNATIONALIZED`
	PROPERTY_USAGE_INTERNATIONALIZED = clib.GODOT_PROPERTY_USAGE_INTERNATIONALIZED, 
	--- `(godot_property_usage_flags) PROPERTY_USAGE_GROUP`
	PROPERTY_USAGE_GROUP = clib.GODOT_PROPERTY_USAGE_GROUP, 
	--- `(godot_property_usage_flags) PROPERTY_USAGE_CATEGORY`
	PROPERTY_USAGE_CATEGORY = clib.GODOT_PROPERTY_USAGE_CATEGORY,
	--- `(godot_property_usage_flags) PROPERTY_USAGE_STORE_IF_NONZERO`
	PROPERTY_USAGE_STORE_IF_NONZERO = clib.GODOT_PROPERTY_USAGE_STORE_IF_NONZERO, 
	--- `(godot_property_usage_flags) PROPERTY_USAGE_STORE_IF_NONONE`
	PROPERTY_USAGE_STORE_IF_NONONE = clib.GODOT_PROPERTY_USAGE_STORE_IF_NONONE, 
	--- `(godot_property_usage_flags) PROPERTY_USAGE_NO_INSTANCE_STATE`
	PROPERTY_USAGE_NO_INSTANCE_STATE = clib.GODOT_PROPERTY_USAGE_NO_INSTANCE_STATE,
	--- `(godot_property_usage_flags) PROPERTY_USAGE_RESTART_IF_CHANGED`
	PROPERTY_USAGE_RESTART_IF_CHANGED = clib.GODOT_PROPERTY_USAGE_RESTART_IF_CHANGED,
	--- `(godot_property_usage_flags) PROPERTY_USAGE_SCRIPT_VARIABLE`
	PROPERTY_USAGE_SCRIPT_VARIABLE = clib.GODOT_PROPERTY_USAGE_SCRIPT_VARIABLE,
	--- `(godot_property_usage_flags) PROPERTY_USAGE_STORE_IF_NULL`
	PROPERTY_USAGE_STORE_IF_NULL = clib.GODOT_PROPERTY_USAGE_STORE_IF_NULL,
	--- `(godot_property_usage_flags) PROPERTY_USAGE_ANIMATE_AS_TRIGGER`
	PROPERTY_USAGE_ANIMATE_AS_TRIGGER = clib.GODOT_PROPERTY_USAGE_ANIMATE_AS_TRIGGER,
	--- `(godot_property_usage_flags) PROPERTY_USAGE_UPDATE_ALL_IF_MODIFIED`
	PROPERTY_USAGE_UPDATE_ALL_IF_MODIFIED = clib.GODOT_PROPERTY_USAGE_UPDATE_ALL_IF_MODIFIED,
	--- `(godot_property_usage_flags) PROPERTY_USAGE_DEFAULT`
	PROPERTY_USAGE_DEFAULT = clib.GODOT_PROPERTY_USAGE_DEFAULT,
	--- `(godot_property_usage_flags) PROPERTY_USAGE_DEFAULT_INTL`
	PROPERTY_USAGE_DEFAULT_INTL = clib.GODOT_PROPERTY_USAGE_DEFAULT_INTL,
	--- `(godot_property_usage_flags) PROPERTY_USAGE_NOEDITOR`
	PROPERTY_USAGE_NOEDITOR = clib.GODOT_PROPERTY_USAGE_NOEDITOR,
}

--- Convert any value to a `godot_string`.
-- If `value` is already a `godot_string`, return it unmodified.
-- Otherwise, constructs a Variant and calls `as_string` on it.
-- @function GD.str
-- @param value  Value to be stringified
-- @treturn String
GD.str = str

local function join_str(sep, ...)
	local result = {}
	for i = 1, select('#', ...) do
		table_insert(result, tostring(select(i, ...)))
	end
	return table_concat(result, sep)
end

--- Print a message to Godot's Output panel, with values separated by tabs
function GD.print(...)
	local message = String(join_str('\t', ...))
	api.godot_print(message)
end

--- Print a warning to Godot's Output panel, with values separated by tabs
function GD.print_warning(...)
	local info = debug_getinfo(2, 'nSl')
	local message = join_str('\t', ...)
	api.godot_print_warning(message, info.name, info.short_src, info.currentline)
end

--- Print an error to Godot's Output panel, with values separated by tabs
function GD.print_error(...)
	local info = debug_getinfo(2, 'nSl')
	local message = join_str('\t', ...)
	api.godot_print_error(message, info.name, info.short_src, info.currentline)
end

local ResourceLoader = api.godot_global_get_singleton("ResourceLoader")
--- Loads a Resource by path, similar to GDScript's [load](https://docs.godotengine.org/en/stable/classes/class_%40gdscript.html#class-gdscript-method-load)
function GD.load(path)
	return ResourceLoader:load(path)
end
