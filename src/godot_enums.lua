-- @file godot_globals.lua  Global Godot functionality and enum values
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

--- GDNative enumerations, all accessible globally.
-- @module Enumerations

--- Enum `godot_error`, mapping UPPER_CASED names to ordinal values and vice-versa.
--     assert(Error.OK == GODOT_OK and Error[Error.OK] == 'OK')
--     ...
-- @table Error
-- @field OK  Ok
-- @field FAILED  Failed
-- @field UNAVAILABLE  Unavailable
-- @field UNCONFIGURED  Unconfigured
-- @field UNAUTHORIZED  Unauthorized
-- @field PARAMETER_RANGE_ERROR  Parameter Range Error
-- @field OUT_OF_MEMORY  Out Of Memory
-- @field FILE_NOT_FOUND  File Not Found
-- @field FILE_BAD_DRIVE  File Bad Drive
-- @field FILE_BAD_PATH  File Bad Path
-- @field FILE_NO_PERMISSION  File No Permission
-- @field FILE_ALREADY_IN_USE  File Already In Use
-- @field FILE_CANT_OPEN  File Can't Open
-- @field FILE_CANT_WRITE  File Can't Write
-- @field FILE_CANT_READ  File Can't Read
-- @field FILE_UNRECOGNIZED  File Unrecognized
-- @field FILE_CORRUPT  File Corrupt
-- @field FILE_MISSING_DEPENDENCIES  File Missing Dependencies
-- @field FILE_EOF  File EOF
-- @field CANT_OPEN  Can't Open
-- @field CANT_CREATE  Can't Create
-- @field QUERY_FAILED  Query Failed
-- @field ALREADY_IN_USE  Already In Use
-- @field LOCKED  Locked
-- @field TIMEOUT  Timeout
-- @field CANT_CONNECT  Can't Connect
-- @field CANT_RESOLVE  Can't Resolve
-- @field CONNECTION_ERROR  Connection Error
-- @field CANT_ACQUIRE_RESOURCE  Can't Acquire Resource
-- @field CANT_FORK  Can't Fork
-- @field INVALID_DATA  Invalid Data
-- @field INVALID_PARAMETER  Invalid Parameter
-- @field ALREADY_EXISTS  Already Exists
-- @field DOES_NOT_EXIST  Does Not Exist
-- @field DATABASE_CANT_READ  Database Cant Read
-- @field DATABASE_CANT_WRITE  Database Cant Write
-- @field COMPILATION_FAILED  Compilation Failed
-- @field METHOD_NOT_FOUND  Method Not Found
-- @field LINK_FAILED  Link Failed
-- @field SCRIPT_FAILED  Script Failed
-- @field CYCLIC_LINK  Cyclic Link
-- @field INVALID_DECLARATION  Invalid Declaration
-- @field DUPLICATE_SYMBOL  Duplicate Symbol
-- @field PARSE_ERROR  Parse Error
-- @field BUSY  Busy
-- @field SKIP  Skip
-- @field HELP  Help
-- @field BUG  Bug
-- @field PRINTER_ON_FIRE  Printer On Fire
local Error = {
	OK = clib.GODOT_OK, 
	FAILED = clib.GODOT_FAILED, 
	UNAVAILABLE = clib.GODOT_ERR_UNAVAILABLE, 
	UNCONFIGURED = clib.GODOT_ERR_UNCONFIGURED, 
	UNAUTHORIZED = clib.GODOT_ERR_UNAUTHORIZED, 
	PARAMETER_RANGE_ERROR = clib.GODOT_ERR_PARAMETER_RANGE_ERROR, 
	OUT_OF_MEMORY = clib.GODOT_ERR_OUT_OF_MEMORY, 
	FILE_NOT_FOUND = clib.GODOT_ERR_FILE_NOT_FOUND,
	FILE_BAD_DRIVE = clib.GODOT_ERR_FILE_BAD_DRIVE,
	FILE_BAD_PATH = clib.GODOT_ERR_FILE_BAD_PATH,
	FILE_NO_PERMISSION = clib.GODOT_ERR_FILE_NO_PERMISSION, 
	FILE_ALREADY_IN_USE = clib.GODOT_ERR_FILE_ALREADY_IN_USE,
	FILE_CANT_OPEN = clib.GODOT_ERR_FILE_CANT_OPEN,
	FILE_CANT_WRITE = clib.GODOT_ERR_FILE_CANT_WRITE,
	FILE_CANT_READ = clib.GODOT_ERR_FILE_CANT_READ,
	FILE_UNRECOGNIZED = clib.GODOT_ERR_FILE_UNRECOGNIZED, 
	FILE_CORRUPT = clib.GODOT_ERR_FILE_CORRUPT,
	FILE_MISSING_DEPENDENCIES = clib.GODOT_ERR_FILE_MISSING_DEPENDENCIES,
	FILE_EOF = clib.GODOT_ERR_FILE_EOF,
	CANT_OPEN = clib.GODOT_ERR_CANT_OPEN, 
	CANT_CREATE = clib.GODOT_ERR_CANT_CREATE, 
	QUERY_FAILED = clib.GODOT_ERR_QUERY_FAILED,
	ALREADY_IN_USE = clib.GODOT_ERR_ALREADY_IN_USE,
	LOCKED = clib.GODOT_ERR_LOCKED, 
	TIMEOUT = clib.GODOT_ERR_TIMEOUT,
	CANT_CONNECT = clib.GODOT_ERR_CANT_CONNECT, 
	CANT_RESOLVE = clib.GODOT_ERR_CANT_RESOLVE,
	CONNECTION_ERROR = clib.GODOT_ERR_CONNECTION_ERROR,
	CANT_ACQUIRE_RESOURCE = clib.GODOT_ERR_CANT_ACQUIRE_RESOURCE,
	CANT_FORK = clib.GODOT_ERR_CANT_FORK,
	INVALID_DATA = clib.GODOT_ERR_INVALID_DATA, 
	INVALID_PARAMETER = clib.GODOT_ERR_INVALID_PARAMETER, 
	ALREADY_EXISTS = clib.GODOT_ERR_ALREADY_EXISTS, 
	DOES_NOT_EXIST = clib.GODOT_ERR_DOES_NOT_EXIST, 
	DATABASE_CANT_READ = clib.GODOT_ERR_DATABASE_CANT_READ, 
	DATABASE_CANT_WRITE = clib.GODOT_ERR_DATABASE_CANT_WRITE, 
	COMPILATION_FAILED = clib.GODOT_ERR_COMPILATION_FAILED,
	METHOD_NOT_FOUND = clib.GODOT_ERR_METHOD_NOT_FOUND,
	LINK_FAILED = clib.GODOT_ERR_LINK_FAILED,
	SCRIPT_FAILED = clib.GODOT_ERR_SCRIPT_FAILED,
	CYCLIC_LINK = clib.GODOT_ERR_CYCLIC_LINK, 
	INVALID_DECLARATION = clib.GODOT_ERR_INVALID_DECLARATION,
	DUPLICATE_SYMBOL = clib.GODOT_ERR_DUPLICATE_SYMBOL,
	PARSE_ERROR = clib.GODOT_ERR_PARSE_ERROR,
	BUSY = clib.GODOT_ERR_BUSY,
	SKIP = clib.GODOT_ERR_SKIP, 
	HELP = clib.GODOT_ERR_HELP, 
	BUG = clib.GODOT_ERR_BUG, 
	PRINTER_ON_FIRE = clib.GODOT_ERR_PRINTER_ON_FIRE, 
}
for k, v in pairs(Error) do Error[v] = k end
_G.Error = Error

--- Enum `godot_variant_type`, mapping PascalCased names to ordinal value and vice-versa.
--     assert(VariantType.Nil == GODOT_VARIANT_TYPE_NIL and VariantType[VariantType.Nil] == 'Nil')
--     ...
-- @table VariantType
-- @field Nil  Nil
-- @field Bool  Bool
-- @field Int  Int
-- @field Real  Real
-- @field String  String
-- @field Vector2  Vector2
-- @field Rect2  Rect2
-- @field Vector3  Vector3
-- @field Transform2D  Transform2D
-- @field Plane  Plane
-- @field Quat  Quat
-- @field AABB  AABB
-- @field Basis  Basis
-- @field Transform  Transform
-- @field Color  Color
-- @field NodePath  NodePath
-- @field RID  RID
-- @field Object  Object
-- @field Dictionary  Dictionary
-- @field Array  Array
-- @field PoolByteArray  PoolByteArray
-- @field PoolIntArray  PoolIntArray
-- @field PoolRealArray  PoolRealArray
-- @field PoolStringArray  PoolStringArray
-- @field PoolVector2Array  PoolVector2Array
-- @field PoolVector3Array  PoolVector3Array
-- @field PoolColorArray  PoolColorArray
local VariantType = {
	Nil = clib.GODOT_VARIANT_TYPE_NIL,
	Bool = clib.GODOT_VARIANT_TYPE_BOOL,
	Int = clib.GODOT_VARIANT_TYPE_INT,
	Real = clib.GODOT_VARIANT_TYPE_REAL,
	String = clib.GODOT_VARIANT_TYPE_STRING,
	Vector2 = clib.GODOT_VARIANT_TYPE_VECTOR2,
	Rect2 = clib.GODOT_VARIANT_TYPE_RECT2,
	Vector3 = clib.GODOT_VARIANT_TYPE_VECTOR3,
	Transform2D = clib.GODOT_VARIANT_TYPE_TRANSFORM2D,
	Plane = clib.GODOT_VARIANT_TYPE_PLANE,
	Quat = clib.GODOT_VARIANT_TYPE_QUAT,
	AABB = clib.GODOT_VARIANT_TYPE_AABB,
	Basis = clib.GODOT_VARIANT_TYPE_BASIS,
	Transform = clib.GODOT_VARIANT_TYPE_TRANSFORM,
	Color = clib.GODOT_VARIANT_TYPE_COLOR,
	NodePath = clib.GODOT_VARIANT_TYPE_NODE_PATH,
	RID = clib.GODOT_VARIANT_TYPE_RID,
	Object = clib.GODOT_VARIANT_TYPE_OBJECT,
	Dictionary = clib.GODOT_VARIANT_TYPE_DICTIONARY,
	Array = clib.GODOT_VARIANT_TYPE_ARRAY,
	PoolByteArray = clib.GODOT_VARIANT_TYPE_POOL_BYTE_ARRAY,
	PoolIntArray = clib.GODOT_VARIANT_TYPE_POOL_INT_ARRAY,
	PoolRealArray = clib.GODOT_VARIANT_TYPE_POOL_REAL_ARRAY,
	PoolStringArray = clib.GODOT_VARIANT_TYPE_POOL_STRING_ARRAY,
	PoolVector2Array = clib.GODOT_VARIANT_TYPE_POOL_VECTOR2_ARRAY,
	PoolVector3Array = clib.GODOT_VARIANT_TYPE_POOL_VECTOR3_ARRAY,
	PoolColorArray = clib.GODOT_VARIANT_TYPE_POOL_COLOR_ARRAY,
}
for k, v in pairs(VariantType) do VariantType[v] = k end
_G.VariantType = VariantType

--- Enum `godot_variant_call_error`, mapping UPPER_CASED names to ordinal values and vice-versa.
--     assert(CallError.OK == GODOT_CALL_ERROR_CALL_OK and CallError[CallError.OK] == 'OK')
--     ...
-- @table CallError
-- @field OK  Ok
-- @field ERROR_INVALID_METHOD  Invalid Method
-- @field ERROR_INVALID_ARGUMENT  Invalid Argument
-- @field ERROR_TOO_MANY_ARGUMENTS  Too Many Arguments
-- @field ERROR_TOO_FEW_ARGUMENTS  Too Few Arguments
-- @field ERROR_INSTANCE_IS_NULL  Instance Is Null
local CallError = {
	OK = clib.GODOT_CALL_ERROR_CALL_OK,
	ERROR_INVALID_METHOD = clib.GODOT_CALL_ERROR_CALL_ERROR_INVALID_METHOD,
	ERROR_INVALID_ARGUMENT = clib.GODOT_CALL_ERROR_CALL_ERROR_INVALID_ARGUMENT,
	ERROR_TOO_MANY_ARGUMENTS = clib.GODOT_CALL_ERROR_CALL_ERROR_TOO_MANY_ARGUMENTS,
	ERROR_TOO_FEW_ARGUMENTS = clib.GODOT_CALL_ERROR_CALL_ERROR_TOO_FEW_ARGUMENTS,
	ERROR_INSTANCE_IS_NULL = clib.GODOT_CALL_ERROR_CALL_ERROR_INSTANCE_IS_NULL,
}
for k, v in pairs(CallError) do CallError[v] = k end
_G.CallError = CallError

--- Enum `godot_method_rpc_mode`, mapping UPPER_CASED names to ordinal values and vice-versa.
--     assert(RPCMode.DISABLED == GODOT_METHOD_RPC_MODE_DISABLED and RPCMode[RPCMode.DISABLED] == 'DISABLED')
--     ...
-- @table RPCMode
-- @field DISABLED  RPC Disabled
-- @field REMOTE  RPC Remote
-- @field MASTER  RPC Master
-- @field PUPPET  RPC Puppet
-- @field SLAVE  RPC Slave
-- @field REMOTESYNC  RPC Remotesync
-- @field SYNC  RPC Sync
-- @field MASTERSYNC  RPC Mastersync
-- @field PUPPETSYNC  RPC Puppetsync
local RPCMode = {
	DISABLED = clib.GODOT_METHOD_RPC_MODE_DISABLED,
	REMOTE = clib.GODOT_METHOD_RPC_MODE_REMOTE,
	MASTER = clib.GODOT_METHOD_RPC_MODE_MASTER,
	PUPPET = clib.GODOT_METHOD_RPC_MODE_PUPPET,
	SLAVE = clib.GODOT_METHOD_RPC_MODE_SLAVE,
	REMOTESYNC = clib.GODOT_METHOD_RPC_MODE_REMOTESYNC,
	SYNC = clib.GODOT_METHOD_RPC_MODE_SYNC,
	MASTERSYNC = clib.GODOT_METHOD_RPC_MODE_MASTERSYNC,
	PUPPETSYNC = clib.GODOT_METHOD_RPC_MODE_PUPPETSYNC,
}
for k, v in pairs(RPCMode) do RPCMode[v] = k end
_G.RPCMode = RPCMode

--- Enum `godot_property_hint`, mapping UPPER_CASED names to ordinal values and vice-versa.
--     assert(PropertyHint.NONE == GODOT_PROPERTY_HINT_NONE and PropertyHint[PropertyHint.NONE] == 'NONE')
--     ...
-- @table PropertyHint
-- @field NONE  None
-- @field RANGE  Range (hint_string = `"min,max,step,slider"`; step and slider are optional)
-- @field EXP_RANGE  Exp Range (hint_string = `"min,max,step"`; exponential edit)
-- @field ENUM  Enum (hint_string = `"val1,val2,val3,etc"`)
-- @field EXP_EASING  Exp Easing
-- @field LENGTH  Length (hint_string = `"length"`; as integer)
-- @field SPRITE_FRAME  Sprite Frame (Obsolete)
-- @field KEY_ACCEL  Key Accel (hint_string = `"length"`; as integer)
-- @field FLAGS  Flags (hint_string = `"flag1,flag2,etc"`; as bit flags)
-- @field LAYERS_2D_RENDER  Layers 2D Render
-- @field LAYERS_2D_PHYSICS  Layers 2D Physics
-- @field LAYERS_3D_RENDER  Layers 3D Render
-- @field LAYERS_3D_PHYSICS  Layers 3D Physics
-- @field FILE  File (optional hint_string: file filter, e.g. `"\*.png,\*.wav"`)
-- @field DIR  Dir
-- @field GLOBAL_FILE  Global File
-- @field GLOBAL_DIR  Global Dir
-- @field RESOURCE_TYPE  Resource Type
-- @field MULTILINE_TEXT  Multiline Text
-- @field PLACEHOLDER_TEXT  Placeholder Text
-- @field COLOR_NO_ALPHA  Color No Alpha
-- @field IMAGE_COMPRESS_LOSSY  Image Compress Lossy
-- @field IMAGE_COMPRESS_LOSSLESS  Image Compress Lossless
-- @field OBJECT_ID  Object Id
-- @field TYPE_STRING  Type String (hint_string = `"base class name"`)
-- @field NODE_PATH_TO_EDITED_NODE  Node Path To Edited Node
-- @field METHOD_OF_VARIANT_TYPE  Method Of Variant Type
-- @field METHOD_OF_BASE_TYPE  Method Of Base Type
-- @field METHOD_OF_INSTANCE  Method Of Instance
-- @field METHOD_OF_SCRIPT  Method Of Script
-- @field PROPERTY_OF_VARIANT_TYPE  Property Of Variant Type
-- @field PROPERTY_OF_BASE_TYPE  Property Of Base Type
-- @field PROPERTY_OF_INSTANCE  Property Of Instance
-- @field PROPERTY_OF_SCRIPT  Property Of Script
local PropertyHint = {
	NONE = clib.GODOT_PROPERTY_HINT_NONE, 
	RANGE = clib.GODOT_PROPERTY_HINT_RANGE, 
	EXP_RANGE = clib.GODOT_PROPERTY_HINT_EXP_RANGE, 
	ENUM = clib.GODOT_PROPERTY_HINT_ENUM, 
	EXP_EASING = clib.GODOT_PROPERTY_HINT_EXP_EASING, 
	LENGTH = clib.GODOT_PROPERTY_HINT_LENGTH, 
	SPRITE_FRAME = clib.GODOT_PROPERTY_HINT_SPRITE_FRAME, 
	KEY_ACCEL = clib.GODOT_PROPERTY_HINT_KEY_ACCEL, 
	FLAGS = clib.GODOT_PROPERTY_HINT_FLAGS, 
	LAYERS_2D_RENDER = clib.GODOT_PROPERTY_HINT_LAYERS_2D_RENDER,
	LAYERS_2D_PHYSICS = clib.GODOT_PROPERTY_HINT_LAYERS_2D_PHYSICS,
	LAYERS_3D_RENDER = clib.GODOT_PROPERTY_HINT_LAYERS_3D_RENDER,
	LAYERS_3D_PHYSICS = clib.GODOT_PROPERTY_HINT_LAYERS_3D_PHYSICS,
	FILE = clib.GODOT_PROPERTY_HINT_FILE, 
	DIR = clib.GODOT_PROPERTY_HINT_DIR, 
	GLOBAL_FILE = clib.GODOT_PROPERTY_HINT_GLOBAL_FILE, 
	GLOBAL_DIR = clib.GODOT_PROPERTY_HINT_GLOBAL_DIR, 
	RESOURCE_TYPE = clib.GODOT_PROPERTY_HINT_RESOURCE_TYPE, 
	MULTILINE_TEXT = clib.GODOT_PROPERTY_HINT_MULTILINE_TEXT, 
	PLACEHOLDER_TEXT = clib.GODOT_PROPERTY_HINT_PLACEHOLDER_TEXT, 
	COLOR_NO_ALPHA = clib.GODOT_PROPERTY_HINT_COLOR_NO_ALPHA, 
	IMAGE_COMPRESS_LOSSY = clib.GODOT_PROPERTY_HINT_IMAGE_COMPRESS_LOSSY,
	IMAGE_COMPRESS_LOSSLESS = clib.GODOT_PROPERTY_HINT_IMAGE_COMPRESS_LOSSLESS,
	OBJECT_ID = clib.GODOT_PROPERTY_HINT_OBJECT_ID,
	TYPE_STRING = clib.GODOT_PROPERTY_HINT_TYPE_STRING, 
	NODE_PATH_TO_EDITED_NODE = clib.GODOT_PROPERTY_HINT_NODE_PATH_TO_EDITED_NODE, 
	METHOD_OF_VARIANT_TYPE = clib.GODOT_PROPERTY_HINT_METHOD_OF_VARIANT_TYPE, 
	METHOD_OF_BASE_TYPE = clib.GODOT_PROPERTY_HINT_METHOD_OF_BASE_TYPE, 
	METHOD_OF_INSTANCE = clib.GODOT_PROPERTY_HINT_METHOD_OF_INSTANCE, 
	METHOD_OF_SCRIPT = clib.GODOT_PROPERTY_HINT_METHOD_OF_SCRIPT, 
	PROPERTY_OF_VARIANT_TYPE = clib.GODOT_PROPERTY_HINT_PROPERTY_OF_VARIANT_TYPE, 
	PROPERTY_OF_BASE_TYPE = clib.GODOT_PROPERTY_HINT_PROPERTY_OF_BASE_TYPE, 
	PROPERTY_OF_INSTANCE = clib.GODOT_PROPERTY_HINT_PROPERTY_OF_INSTANCE, 
	PROPERTY_OF_SCRIPT = clib.GODOT_PROPERTY_HINT_PROPERTY_OF_SCRIPT, 
}
for k, v in pairs(PropertyHint) do PropertyHint[v] = k end
_G.PropertyHint = PropertyHint

--- Enum `godot_property_usage_flags`, mapping UPPER_CASED names to ordinal values and vice-versa.
--     assert(PropertyUsage.STORAGE == GODOT_PROPERTY_USAGE_STORAGE and PropertyUsage[PropertyUsage.STORAGE] == 'STORAGE')
--     ...
-- @table PropertyUsage
-- @field STORAGE  Storage
-- @field EDITOR  Editor
-- @field NETWORK  Network
-- @field EDITOR_HELPER  Editor Helper
-- @field CHECKABLE  Checkable
-- @field CHECKED  Checked
-- @field INTERNATIONALIZED  Internationalized
-- @field GROUP  Group
-- @field CATEGORY  Category
-- @field STORE_IF_NONZERO  Store If Nonzero (Obsolete)
-- @field STORE_IF_NONONE  Store If Nonone (Obsolete)
-- @field NO_INSTANCE_STATE  No Instance State
-- @field RESTART_IF_CHANGED  Restart If Changed
-- @field SCRIPT_VARIABLE  Script Variable
-- @field STORE_IF_NULL  Store If Null
-- @field ANIMATE_AS_TRIGGER  Animate As Trigger
-- @field UPDATE_ALL_IF_MODIFIED  Update All If Modified
-- @field DEFAULT  Default
-- @field DEFAULT_INTL  Default Internationalized
-- @field NOEDITOR  No Editor
local PropertyUsage = {
	STORAGE = clib.GODOT_PROPERTY_USAGE_STORAGE,
	EDITOR = clib.GODOT_PROPERTY_USAGE_EDITOR,
	NETWORK = clib.GODOT_PROPERTY_USAGE_NETWORK,
	EDITOR_HELPER = clib.GODOT_PROPERTY_USAGE_EDITOR_HELPER,
	CHECKABLE = clib.GODOT_PROPERTY_USAGE_CHECKABLE, 
	CHECKED = clib.GODOT_PROPERTY_USAGE_CHECKED, 
	INTERNATIONALIZED = clib.GODOT_PROPERTY_USAGE_INTERNATIONALIZED, 
	GROUP = clib.GODOT_PROPERTY_USAGE_GROUP, 
	CATEGORY = clib.GODOT_PROPERTY_USAGE_CATEGORY,
	STORE_IF_NONZERO = clib.GODOT_PROPERTY_USAGE_STORE_IF_NONZERO, 
	STORE_IF_NONONE = clib.GODOT_PROPERTY_USAGE_STORE_IF_NONONE, 
	NO_INSTANCE_STATE = clib.GODOT_PROPERTY_USAGE_NO_INSTANCE_STATE,
	RESTART_IF_CHANGED = clib.GODOT_PROPERTY_USAGE_RESTART_IF_CHANGED,
	SCRIPT_VARIABLE = clib.GODOT_PROPERTY_USAGE_SCRIPT_VARIABLE,
	STORE_IF_NULL = clib.GODOT_PROPERTY_USAGE_STORE_IF_NULL,
	ANIMATE_AS_TRIGGER = clib.GODOT_PROPERTY_USAGE_ANIMATE_AS_TRIGGER,
	UPDATE_ALL_IF_MODIFIED = clib.GODOT_PROPERTY_USAGE_UPDATE_ALL_IF_MODIFIED,
	DEFAULT = clib.GODOT_PROPERTY_USAGE_DEFAULT,
	DEFAULT_INTL = clib.GODOT_PROPERTY_USAGE_DEFAULT_INTL,
	NOEDITOR = clib.GODOT_PROPERTY_USAGE_NOEDITOR,
}
for k, v in pairs(PropertyUsage) do PropertyUsage[v] = k end
_G.PropertyUsage = PropertyUsage
