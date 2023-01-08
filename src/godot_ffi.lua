-- @file godot_ffi.lua  FFI definitions for Godot APIs and PluginScript callbacks
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
local ffi = require 'ffi'

ffi.cdef[[
// GDNative type definitions
typedef bool godot_bool;
typedef int godot_int;
typedef float godot_real;

typedef struct godot_object {
	uint8_t _dont_touch_that[0];
} godot_object;
typedef struct godot_string {
	uint8_t _dont_touch_that[sizeof(void *)];
} godot_string;
typedef struct godot_char_string {
	uint8_t _dont_touch_that[sizeof(void *)];
} godot_char_string;
typedef struct godot_string_name {
	uint8_t _dont_touch_that[sizeof(void *)];
} godot_string_name;
typedef struct godot_node_path {
	uint8_t _dont_touch_that[sizeof(void *)];
} godot_node_path;
typedef struct godot_rid {
	uint8_t _dont_touch_that[sizeof(void *)];
} godot_rid;
typedef struct godot_dictionary {
	uint8_t _dont_touch_that[sizeof(void *)];
} godot_dictionary;
typedef struct godot_array {
	uint8_t _dont_touch_that[sizeof(void *)];
} godot_array;

typedef struct godot_pool_byte_array_read_access {
	uint8_t _dont_touch_that[1];
} godot_pool_byte_array_read_access;
typedef struct godot_pool_int_array_read_access {
	uint8_t _dont_touch_that[1];
} godot_pool_int_array_read_access;
typedef struct godot_pool_real_array_read_access {
	uint8_t _dont_touch_that[1];
} godot_pool_real_array_read_access;
typedef struct godot_pool_string_array_read_access {
	uint8_t _dont_touch_that[1];
} godot_pool_string_array_read_access;
typedef struct godot_pool_vector2_array_read_access {
	uint8_t _dont_touch_that[1];
} godot_pool_vector2_array_read_access;
typedef struct godot_pool_vector3_array_read_access {
	uint8_t _dont_touch_that[1];
} godot_pool_vector3_array_read_access;
typedef struct godot_pool_color_array_read_access {
	uint8_t _dont_touch_that[1];
} godot_pool_color_array_read_access;
typedef struct godot_pool_array_write_access {
	uint8_t _dont_touch_that[1];
} godot_pool_array_write_access;
typedef struct godot_pool_byte_array_write_access {
	uint8_t _dont_touch_that[1];
} godot_pool_byte_array_write_access;
typedef struct godot_pool_int_array_write_access {
	uint8_t _dont_touch_that[1];
} godot_pool_int_array_write_access;
typedef struct godot_pool_real_array_write_access {
	uint8_t _dont_touch_that[1];
} godot_pool_real_array_write_access;
typedef struct godot_pool_string_array_write_access {
	uint8_t _dont_touch_that[1];
} godot_pool_string_array_write_access;
typedef struct godot_pool_vector2_array_write_access {
	uint8_t _dont_touch_that[1];
} godot_pool_vector2_array_write_access;
typedef struct godot_pool_vector3_array_write_access {
	uint8_t _dont_touch_that[1];
} godot_pool_vector3_array_write_access;
typedef struct godot_pool_color_array_write_access {
	uint8_t _dont_touch_that[1];
} godot_pool_color_array_write_access;

typedef struct godot_pool_byte_array {
	uint8_t _dont_touch_that[sizeof(void *)];
} godot_pool_byte_array;
typedef struct godot_pool_int_array {
	uint8_t _dont_touch_that[sizeof(void *)];
} godot_pool_int_array;
typedef struct godot_pool_real_array {
	uint8_t _dont_touch_that[sizeof(void *)];
} godot_pool_real_array;
typedef struct godot_pool_string_array {
	uint8_t _dont_touch_that[sizeof(void *)];
} godot_pool_string_array;
typedef struct godot_pool_vector2_array {
	uint8_t _dont_touch_that[sizeof(void *)];
} godot_pool_vector2_array;
typedef struct godot_pool_vector3_array {
	uint8_t _dont_touch_that[sizeof(void *)];
} godot_pool_vector3_array;
typedef struct godot_pool_color_array {
	uint8_t _dont_touch_that[sizeof(void *)];
} godot_pool_color_array;

typedef struct godot_variant {
	uint8_t _dont_touch_that[(16 + sizeof(int64_t))];
} godot_variant;

// Math type definitions copied from HGDN
typedef union godot_vector2 {
	// raw data, must be the first field for guaranteeing ABI compatibility with Godot
	uint8_t _dont_touch_that[sizeof(godot_real[2])];
	// float elements
	godot_real elements[2];
	// xy
	struct { godot_real x, y; };
	// rg
	struct { godot_real r, g; };
	// st
	struct { godot_real s, t; };
	// uv
	struct { godot_real u, v; };
	// Size: width/height
	struct { godot_real width, height; };
} godot_vector2;

typedef union godot_vector3 {
	// raw data, must be the first field for guaranteeing ABI compatibility with Godot
	uint8_t _dont_touch_that[sizeof(godot_real[3])];
	// float elements
	godot_real elements[3];
	// xyz
	struct { godot_real x, y, z; };
	struct { godot_vector2 xy; godot_real _0; };
	struct { godot_real _1; godot_vector2 yz; };
	// rgb
	struct { godot_real r, g, b; };
	struct { godot_vector2 rg; godot_real _2; };
	struct { godot_real _3; godot_vector2 gb; };
	// stp
	struct { godot_real s, t, p; };
	struct { godot_vector2 st; godot_real _6; };
	struct { godot_real _7; godot_vector2 tp; };
	// uv
	struct { godot_real u, v, _4; };
	struct { godot_vector2 uv; godot_real _5; };
	// 3D Size: width/height/depth
	struct { godot_real width, height, depth; };
} godot_vector3;

typedef union godot_color {
	// raw data, must be the first field for guaranteeing ABI compatibility with Godot
	uint8_t _dont_touch_that[sizeof(godot_real[4])];
	godot_real elements[4];
	struct { godot_real r, g, b, a; };
	struct { godot_vector2 rg; godot_vector2 ba; };
	struct { godot_real _0; godot_vector2 gb; godot_real _1; };
	struct { godot_vector3 rgb; godot_real _2; };
	struct { godot_real _3; godot_vector3 gba; };
} godot_color;

typedef union godot_rect2 {
	// raw data, must be the first field for guaranteeing ABI compatibility with Godot
	uint8_t _dont_touch_that[sizeof(godot_real[4])];
	godot_real elements[4];
	struct { godot_real x, y, width, height; };
	struct { godot_vector2 position; godot_vector2 size; };
} godot_rect2;

typedef union godot_plane {
	// raw data, must be the first field for guaranteeing ABI compatibility with Godot
	uint8_t _dont_touch_that[sizeof(godot_real[4])];
	godot_real elements[4];
	struct { godot_vector3 normal; godot_real d; };
} godot_plane;

typedef union godot_quat {
	// raw data, must be the first field for guaranteeing ABI compatibility with Godot
	uint8_t _dont_touch_that[sizeof(godot_real[4])];
	godot_real elements[4];
	struct { godot_real x, y, z, w; };
	struct { godot_vector2 xy; godot_vector2 zw; };
	struct { godot_real _0; godot_vector2 yz; godot_real _1; };
	struct { godot_vector3 xyz; godot_real _2; };
	struct { godot_real _3; godot_vector3 yzw; };
} godot_quat;

typedef union godot_basis {
	// raw data, must be the first field for guaranteeing ABI compatibility with Godot
	uint8_t _dont_touch_that[sizeof(godot_real[9])];
	godot_real elements[9];
	godot_vector3 rows[3];
} godot_basis;

typedef union godot_aabb {
	// raw data, must be the first field for guaranteeing ABI compatibility with Godot
	uint8_t _dont_touch_that[sizeof(godot_real[6])];
	godot_real elements[6];
	struct { godot_vector3 position, size; };
} godot_aabb;

typedef union godot_transform2d {
	// raw data, must be the first field for guaranteeing ABI compatibility with Godot
	uint8_t _dont_touch_that[sizeof(godot_real[6])];
	godot_real elements[6];
	godot_vector2 columns[3];
	struct { godot_vector2 x, y, origin; };
} godot_transform2d;

typedef union godot_transform {
	// raw data, must be the first field for guaranteeing ABI compatibility with Godot
	uint8_t _dont_touch_that[sizeof(godot_real[12])];
	godot_real elements[12];
	struct { godot_basis basis; godot_vector3 origin; };
} godot_transform;

// Enums
typedef enum {
	GODOT_OK, // (0)
	GODOT_FAILED, ///< Generic fail error
	GODOT_ERR_UNAVAILABLE, ///< What is requested is unsupported/unavailable
	GODOT_ERR_UNCONFIGURED, ///< The object being used hasn't been properly set up yet
	GODOT_ERR_UNAUTHORIZED, ///< Missing credentials for requested resource
	GODOT_ERR_PARAMETER_RANGE_ERROR, ///< Parameter given out of range (5)
	GODOT_ERR_OUT_OF_MEMORY, ///< Out of memory
	GODOT_ERR_FILE_NOT_FOUND,
	GODOT_ERR_FILE_BAD_DRIVE,
	GODOT_ERR_FILE_BAD_PATH,
	GODOT_ERR_FILE_NO_PERMISSION, // (10)
	GODOT_ERR_FILE_ALREADY_IN_USE,
	GODOT_ERR_FILE_CANT_OPEN,
	GODOT_ERR_FILE_CANT_WRITE,
	GODOT_ERR_FILE_CANT_READ,
	GODOT_ERR_FILE_UNRECOGNIZED, // (15)
	GODOT_ERR_FILE_CORRUPT,
	GODOT_ERR_FILE_MISSING_DEPENDENCIES,
	GODOT_ERR_FILE_EOF,
	GODOT_ERR_CANT_OPEN, ///< Can't open a resource/socket/file
	GODOT_ERR_CANT_CREATE, // (20)
	GODOT_ERR_QUERY_FAILED,
	GODOT_ERR_ALREADY_IN_USE,
	GODOT_ERR_LOCKED, ///< resource is locked
	GODOT_ERR_TIMEOUT,
	GODOT_ERR_CANT_CONNECT, // (25)
	GODOT_ERR_CANT_RESOLVE,
	GODOT_ERR_CONNECTION_ERROR,
	GODOT_ERR_CANT_ACQUIRE_RESOURCE,
	GODOT_ERR_CANT_FORK,
	GODOT_ERR_INVALID_DATA, ///< Data passed is invalid (30)
	GODOT_ERR_INVALID_PARAMETER, ///< Parameter passed is invalid
	GODOT_ERR_ALREADY_EXISTS, ///< When adding, item already exists
	GODOT_ERR_DOES_NOT_EXIST, ///< When retrieving/erasing, it item does not exist
	GODOT_ERR_DATABASE_CANT_READ, ///< database is full
	GODOT_ERR_DATABASE_CANT_WRITE, ///< database is full (35)
	GODOT_ERR_COMPILATION_FAILED,
	GODOT_ERR_METHOD_NOT_FOUND,
	GODOT_ERR_LINK_FAILED,
	GODOT_ERR_SCRIPT_FAILED,
	GODOT_ERR_CYCLIC_LINK, // (40)
	GODOT_ERR_INVALID_DECLARATION,
	GODOT_ERR_DUPLICATE_SYMBOL,
	GODOT_ERR_PARSE_ERROR,
	GODOT_ERR_BUSY,
	GODOT_ERR_SKIP, // (45)
	GODOT_ERR_HELP, ///< user requested help!!
	GODOT_ERR_BUG, ///< a bug in the software certainly happened, due to a double check failing or unexpected behavior.
	GODOT_ERR_PRINTER_ON_FIRE, /// the parallel port printer is engulfed in flames
} godot_error;

typedef enum godot_variant_type {
	GODOT_VARIANT_TYPE_NIL,

	// atomic types
	GODOT_VARIANT_TYPE_BOOL,
	GODOT_VARIANT_TYPE_INT,
	GODOT_VARIANT_TYPE_REAL,
	GODOT_VARIANT_TYPE_STRING,

	// math types
	GODOT_VARIANT_TYPE_VECTOR2, // 5
	GODOT_VARIANT_TYPE_RECT2,
	GODOT_VARIANT_TYPE_VECTOR3,
	GODOT_VARIANT_TYPE_TRANSFORM2D,
	GODOT_VARIANT_TYPE_PLANE,
	GODOT_VARIANT_TYPE_QUAT, // 10
	GODOT_VARIANT_TYPE_AABB,
	GODOT_VARIANT_TYPE_BASIS,
	GODOT_VARIANT_TYPE_TRANSFORM,

	// misc types
	GODOT_VARIANT_TYPE_COLOR,
	GODOT_VARIANT_TYPE_NODE_PATH, // 15
	GODOT_VARIANT_TYPE_RID,
	GODOT_VARIANT_TYPE_OBJECT,
	GODOT_VARIANT_TYPE_DICTIONARY,
	GODOT_VARIANT_TYPE_ARRAY, // 20

	// arrays
	GODOT_VARIANT_TYPE_POOL_BYTE_ARRAY,
	GODOT_VARIANT_TYPE_POOL_INT_ARRAY,
	GODOT_VARIANT_TYPE_POOL_REAL_ARRAY,
	GODOT_VARIANT_TYPE_POOL_STRING_ARRAY,
	GODOT_VARIANT_TYPE_POOL_VECTOR2_ARRAY, // 25
	GODOT_VARIANT_TYPE_POOL_VECTOR3_ARRAY,
	GODOT_VARIANT_TYPE_POOL_COLOR_ARRAY,
} godot_variant_type;

typedef enum godot_variant_call_error_error {
	GODOT_CALL_ERROR_CALL_OK,
	GODOT_CALL_ERROR_CALL_ERROR_INVALID_METHOD,
	GODOT_CALL_ERROR_CALL_ERROR_INVALID_ARGUMENT,
	GODOT_CALL_ERROR_CALL_ERROR_TOO_MANY_ARGUMENTS,
	GODOT_CALL_ERROR_CALL_ERROR_TOO_FEW_ARGUMENTS,
	GODOT_CALL_ERROR_CALL_ERROR_INSTANCE_IS_NULL,
} godot_variant_call_error_error;

typedef struct godot_variant_call_error {
	godot_variant_call_error_error error;
	int argument;
	godot_variant_type expected;
} godot_variant_call_error;

typedef enum godot_variant_operator {
	// comparison
	GODOT_VARIANT_OP_EQUAL,
	GODOT_VARIANT_OP_NOT_EQUAL,
	GODOT_VARIANT_OP_LESS,
	GODOT_VARIANT_OP_LESS_EQUAL,
	GODOT_VARIANT_OP_GREATER,
	GODOT_VARIANT_OP_GREATER_EQUAL,

	// mathematic
	GODOT_VARIANT_OP_ADD,
	GODOT_VARIANT_OP_SUBTRACT,
	GODOT_VARIANT_OP_MULTIPLY,
	GODOT_VARIANT_OP_DIVIDE,
	GODOT_VARIANT_OP_NEGATE,
	GODOT_VARIANT_OP_POSITIVE,
	GODOT_VARIANT_OP_MODULE,
	GODOT_VARIANT_OP_STRING_CONCAT,

	// bitwise
	GODOT_VARIANT_OP_SHIFT_LEFT,
	GODOT_VARIANT_OP_SHIFT_RIGHT,
	GODOT_VARIANT_OP_BIT_AND,
	GODOT_VARIANT_OP_BIT_OR,
	GODOT_VARIANT_OP_BIT_XOR,
	GODOT_VARIANT_OP_BIT_NEGATE,

	// logic
	GODOT_VARIANT_OP_AND,
	GODOT_VARIANT_OP_OR,
	GODOT_VARIANT_OP_XOR,
	GODOT_VARIANT_OP_NOT,

	// containment
	GODOT_VARIANT_OP_IN,

	GODOT_VARIANT_OP_MAX,
} godot_variant_operator;

typedef enum {
	GODOT_VECTOR3_AXIS_X,
	GODOT_VECTOR3_AXIS_Y,
	GODOT_VECTOR3_AXIS_Z,
} godot_vector3_axis;

typedef enum {
	GODOT_METHOD_RPC_MODE_DISABLED,
	GODOT_METHOD_RPC_MODE_REMOTE,
	GODOT_METHOD_RPC_MODE_MASTER,
	GODOT_METHOD_RPC_MODE_PUPPET,
	GODOT_METHOD_RPC_MODE_SLAVE = GODOT_METHOD_RPC_MODE_PUPPET,
	GODOT_METHOD_RPC_MODE_REMOTESYNC,
	GODOT_METHOD_RPC_MODE_SYNC = GODOT_METHOD_RPC_MODE_REMOTESYNC,
	GODOT_METHOD_RPC_MODE_MASTERSYNC,
	GODOT_METHOD_RPC_MODE_PUPPETSYNC,
} godot_method_rpc_mode;

typedef enum {
	GODOT_PROPERTY_HINT_NONE, ///< no hint provided.
	GODOT_PROPERTY_HINT_RANGE, ///< hint_text = "min,max,step,slider; //slider is optional"
	GODOT_PROPERTY_HINT_EXP_RANGE, ///< hint_text = "min,max,step", exponential edit
	GODOT_PROPERTY_HINT_ENUM, ///< hint_text= "val1,val2,val3,etc"
	GODOT_PROPERTY_HINT_EXP_EASING, /// exponential easing function (Math::ease)
	GODOT_PROPERTY_HINT_LENGTH, ///< hint_text= "length" (as integer)
	GODOT_PROPERTY_HINT_SPRITE_FRAME, // FIXME: Obsolete: drop whenever we can break compat
	GODOT_PROPERTY_HINT_KEY_ACCEL, ///< hint_text= "length" (as integer)
	GODOT_PROPERTY_HINT_FLAGS, ///< hint_text= "flag1,flag2,etc" (as bit flags)
	GODOT_PROPERTY_HINT_LAYERS_2D_RENDER,
	GODOT_PROPERTY_HINT_LAYERS_2D_PHYSICS,
	GODOT_PROPERTY_HINT_LAYERS_2D_NAVIGATION,
	GODOT_PROPERTY_HINT_LAYERS_3D_RENDER,
	GODOT_PROPERTY_HINT_LAYERS_3D_PHYSICS,
	GODOT_PROPERTY_HINT_LAYERS_3D_NAVIGATION,
	GODOT_PROPERTY_HINT_FILE, ///< a file path must be passed, hint_text (optionally) is a filter "*.png,*.wav,*.doc,"
	GODOT_PROPERTY_HINT_DIR, ///< a directory path must be passed
	GODOT_PROPERTY_HINT_GLOBAL_FILE, ///< a file path must be passed, hint_text (optionally) is a filter "*.png,*.wav,*.doc,"
	GODOT_PROPERTY_HINT_GLOBAL_DIR, ///< a directory path must be passed
	GODOT_PROPERTY_HINT_RESOURCE_TYPE, ///< a resource object type
	GODOT_PROPERTY_HINT_MULTILINE_TEXT, ///< used for string properties that can contain multiple lines
	GODOT_PROPERTY_HINT_PLACEHOLDER_TEXT, ///< used to set a placeholder text for string properties
	GODOT_PROPERTY_HINT_COLOR_NO_ALPHA, ///< used for ignoring alpha component when editing a color
	GODOT_PROPERTY_HINT_IMAGE_COMPRESS_LOSSY,
	GODOT_PROPERTY_HINT_IMAGE_COMPRESS_LOSSLESS,
	GODOT_PROPERTY_HINT_OBJECT_ID,
	GODOT_PROPERTY_HINT_TYPE_STRING, ///< a type string, the hint is the base type to choose
	GODOT_PROPERTY_HINT_NODE_PATH_TO_EDITED_NODE, ///< so something else can provide this (used in scripts)
	GODOT_PROPERTY_HINT_METHOD_OF_VARIANT_TYPE, ///< a method of a type
	GODOT_PROPERTY_HINT_METHOD_OF_BASE_TYPE, ///< a method of a base type
	GODOT_PROPERTY_HINT_METHOD_OF_INSTANCE, ///< a method of an instance
	GODOT_PROPERTY_HINT_METHOD_OF_SCRIPT, ///< a method of a script & base
	GODOT_PROPERTY_HINT_PROPERTY_OF_VARIANT_TYPE, ///< a property of a type
	GODOT_PROPERTY_HINT_PROPERTY_OF_BASE_TYPE, ///< a property of a base type
	GODOT_PROPERTY_HINT_PROPERTY_OF_INSTANCE, ///< a property of an instance
	GODOT_PROPERTY_HINT_PROPERTY_OF_SCRIPT, ///< a property of a script & base
	GODOT_PROPERTY_HINT_MAX,
} godot_property_hint;

typedef enum {
	GODOT_PROPERTY_USAGE_STORAGE = 1,
	GODOT_PROPERTY_USAGE_EDITOR = 2,
	GODOT_PROPERTY_USAGE_NETWORK = 4,
	GODOT_PROPERTY_USAGE_EDITOR_HELPER = 8,
	GODOT_PROPERTY_USAGE_CHECKABLE = 16, //used for editing global variables
	GODOT_PROPERTY_USAGE_CHECKED = 32, //used for editing global variables
	GODOT_PROPERTY_USAGE_INTERNATIONALIZED = 64, //hint for internationalized strings
	GODOT_PROPERTY_USAGE_GROUP = 128, //used for grouping props in the editor
	GODOT_PROPERTY_USAGE_CATEGORY = 256,
	GODOT_PROPERTY_USAGE_STORE_IF_NONZERO = 512, // FIXME: Obsolete: drop whenever we can break compat
	GODOT_PROPERTY_USAGE_STORE_IF_NONONE = 1024, // FIXME: Obsolete: drop whenever we can break compat
	GODOT_PROPERTY_USAGE_NO_INSTANCE_STATE = 2048,
	GODOT_PROPERTY_USAGE_RESTART_IF_CHANGED = 4096,
	GODOT_PROPERTY_USAGE_SCRIPT_VARIABLE = 8192,
	GODOT_PROPERTY_USAGE_STORE_IF_NULL = 16384,
	GODOT_PROPERTY_USAGE_ANIMATE_AS_TRIGGER = 32768,
	GODOT_PROPERTY_USAGE_UPDATE_ALL_IF_MODIFIED = 65536,

	GODOT_PROPERTY_USAGE_DEFAULT = GODOT_PROPERTY_USAGE_STORAGE | GODOT_PROPERTY_USAGE_EDITOR | GODOT_PROPERTY_USAGE_NETWORK,
	GODOT_PROPERTY_USAGE_DEFAULT_INTL = GODOT_PROPERTY_USAGE_STORAGE | GODOT_PROPERTY_USAGE_EDITOR | GODOT_PROPERTY_USAGE_NETWORK | GODOT_PROPERTY_USAGE_INTERNATIONALIZED,
	GODOT_PROPERTY_USAGE_NOEDITOR = GODOT_PROPERTY_USAGE_STORAGE | GODOT_PROPERTY_USAGE_NETWORK,
} godot_property_usage_flags;

// Core API
typedef struct godot_method_bind {
	uint8_t _dont_touch_that[1];
} godot_method_bind;

typedef struct godot_gdnative_api_version {
	unsigned int major;
	unsigned int minor;
} godot_gdnative_api_version;

typedef struct godot_gdnative_api_struct {
	unsigned int type;
	godot_gdnative_api_version version;
	const struct godot_gdnative_api_struct *next;
} godot_gdnative_api_struct;

typedef godot_object *(*godot_class_constructor)();

typedef godot_variant (*native_call_cb)(void *, godot_array *);

typedef struct godot_gdnative_core_api_struct {
	unsigned int type;
	godot_gdnative_api_version version;
	const godot_gdnative_api_struct *next;
	unsigned int num_extensions;
	const godot_gdnative_api_struct **extensions;
	void (*godot_color_new_rgba)(godot_color *r_dest, const godot_real p_r, const godot_real p_g, const godot_real p_b, const godot_real p_a);
	void (*godot_color_new_rgb)(godot_color *r_dest, const godot_real p_r, const godot_real p_g, const godot_real p_b);
	godot_real (*godot_color_get_r)(const godot_color *p_self);
	void (*godot_color_set_r)(godot_color *p_self, const godot_real r);
	godot_real (*godot_color_get_g)(const godot_color *p_self);
	void (*godot_color_set_g)(godot_color *p_self, const godot_real g);
	godot_real (*godot_color_get_b)(const godot_color *p_self);
	void (*godot_color_set_b)(godot_color *p_self, const godot_real b);
	godot_real (*godot_color_get_a)(const godot_color *p_self);
	void (*godot_color_set_a)(godot_color *p_self, const godot_real a);
	godot_real (*godot_color_get_h)(const godot_color *p_self);
	godot_real (*godot_color_get_s)(const godot_color *p_self);
	godot_real (*godot_color_get_v)(const godot_color *p_self);
	godot_string (*godot_color_as_string)(const godot_color *p_self);
	godot_int (*godot_color_to_rgba32)(const godot_color *p_self);
	godot_int (*godot_color_to_argb32)(const godot_color *p_self);
	godot_real (*godot_color_gray)(const godot_color *p_self);
	godot_color (*godot_color_inverted)(const godot_color *p_self);
	godot_color (*godot_color_contrasted)(const godot_color *p_self);
	godot_color (*godot_color_linear_interpolate)(const godot_color *p_self, const godot_color *p_b, const godot_real p_t);
	godot_color (*godot_color_blend)(const godot_color *p_self, const godot_color *p_over);
	godot_string (*godot_color_to_html)(const godot_color *p_self, const godot_bool p_with_alpha);
	godot_bool (*godot_color_operator_equal)(const godot_color *p_self, const godot_color *p_b);
	godot_bool (*godot_color_operator_less)(const godot_color *p_self, const godot_color *p_b);
	void (*godot_vector2_new)(godot_vector2 *r_dest, const godot_real p_x, const godot_real p_y);
	godot_string (*godot_vector2_as_string)(const godot_vector2 *p_self);
	godot_vector2 (*godot_vector2_normalized)(const godot_vector2 *p_self);
	godot_real (*godot_vector2_length)(const godot_vector2 *p_self);
	godot_real (*godot_vector2_angle)(const godot_vector2 *p_self);
	godot_real (*godot_vector2_length_squared)(const godot_vector2 *p_self);
	godot_bool (*godot_vector2_is_normalized)(const godot_vector2 *p_self);
	godot_real (*godot_vector2_distance_to)(const godot_vector2 *p_self, const godot_vector2 *p_to);
	godot_real (*godot_vector2_distance_squared_to)(const godot_vector2 *p_self, const godot_vector2 *p_to);
	godot_real (*godot_vector2_angle_to)(const godot_vector2 *p_self, const godot_vector2 *p_to);
	godot_real (*godot_vector2_angle_to_point)(const godot_vector2 *p_self, const godot_vector2 *p_to);
	godot_vector2 (*godot_vector2_linear_interpolate)(const godot_vector2 *p_self, const godot_vector2 *p_b, const godot_real p_t);
	godot_vector2 (*godot_vector2_cubic_interpolate)(const godot_vector2 *p_self, const godot_vector2 *p_b, const godot_vector2 *p_pre_a, const godot_vector2 *p_post_b, const godot_real p_t);
	godot_vector2 (*godot_vector2_rotated)(const godot_vector2 *p_self, const godot_real p_phi);
	godot_vector2 (*godot_vector2_tangent)(const godot_vector2 *p_self);
	godot_vector2 (*godot_vector2_floor)(const godot_vector2 *p_self);
	godot_vector2 (*godot_vector2_snapped)(const godot_vector2 *p_self, const godot_vector2 *p_by);
	godot_real (*godot_vector2_aspect)(const godot_vector2 *p_self);
	godot_real (*godot_vector2_dot)(const godot_vector2 *p_self, const godot_vector2 *p_with);
	godot_vector2 (*godot_vector2_slide)(const godot_vector2 *p_self, const godot_vector2 *p_n);
	godot_vector2 (*godot_vector2_bounce)(const godot_vector2 *p_self, const godot_vector2 *p_n);
	godot_vector2 (*godot_vector2_reflect)(const godot_vector2 *p_self, const godot_vector2 *p_n);
	godot_vector2 (*godot_vector2_abs)(const godot_vector2 *p_self);
	godot_vector2 (*godot_vector2_clamped)(const godot_vector2 *p_self, const godot_real p_length);
	godot_vector2 (*godot_vector2_operator_add)(const godot_vector2 *p_self, const godot_vector2 *p_b);
	godot_vector2 (*godot_vector2_operator_subtract)(const godot_vector2 *p_self, const godot_vector2 *p_b);
	godot_vector2 (*godot_vector2_operator_multiply_vector)(const godot_vector2 *p_self, const godot_vector2 *p_b);
	godot_vector2 (*godot_vector2_operator_multiply_scalar)(const godot_vector2 *p_self, const godot_real p_b);
	godot_vector2 (*godot_vector2_operator_divide_vector)(const godot_vector2 *p_self, const godot_vector2 *p_b);
	godot_vector2 (*godot_vector2_operator_divide_scalar)(const godot_vector2 *p_self, const godot_real p_b);
	godot_bool (*godot_vector2_operator_equal)(const godot_vector2 *p_self, const godot_vector2 *p_b);
	godot_bool (*godot_vector2_operator_less)(const godot_vector2 *p_self, const godot_vector2 *p_b);
	godot_vector2 (*godot_vector2_operator_neg)(const godot_vector2 *p_self);
	void (*godot_vector2_set_x)(godot_vector2 *p_self, const godot_real p_x);
	void (*godot_vector2_set_y)(godot_vector2 *p_self, const godot_real p_y);
	godot_real (*godot_vector2_get_x)(const godot_vector2 *p_self);
	godot_real (*godot_vector2_get_y)(const godot_vector2 *p_self);
	void (*godot_quat_new)(godot_quat *r_dest, const godot_real p_x, const godot_real p_y, const godot_real p_z, const godot_real p_w);
	void (*godot_quat_new_with_axis_angle)(godot_quat *r_dest, const godot_vector3 *p_axis, const godot_real p_angle);
	godot_real (*godot_quat_get_x)(const godot_quat *p_self);
	void (*godot_quat_set_x)(godot_quat *p_self, const godot_real val);
	godot_real (*godot_quat_get_y)(const godot_quat *p_self);
	void (*godot_quat_set_y)(godot_quat *p_self, const godot_real val);
	godot_real (*godot_quat_get_z)(const godot_quat *p_self);
	void (*godot_quat_set_z)(godot_quat *p_self, const godot_real val);
	godot_real (*godot_quat_get_w)(const godot_quat *p_self);
	void (*godot_quat_set_w)(godot_quat *p_self, const godot_real val);
	godot_string (*godot_quat_as_string)(const godot_quat *p_self);
	godot_real (*godot_quat_length)(const godot_quat *p_self);
	godot_real (*godot_quat_length_squared)(const godot_quat *p_self);
	godot_quat (*godot_quat_normalized)(const godot_quat *p_self);
	godot_bool (*godot_quat_is_normalized)(const godot_quat *p_self);
	godot_quat (*godot_quat_inverse)(const godot_quat *p_self);
	godot_real (*godot_quat_dot)(const godot_quat *p_self, const godot_quat *p_b);
	godot_vector3 (*godot_quat_xform)(const godot_quat *p_self, const godot_vector3 *p_v);
	godot_quat (*godot_quat_slerp)(const godot_quat *p_self, const godot_quat *p_b, const godot_real p_t);
	godot_quat (*godot_quat_slerpni)(const godot_quat *p_self, const godot_quat *p_b, const godot_real p_t);
	godot_quat (*godot_quat_cubic_slerp)(const godot_quat *p_self, const godot_quat *p_b, const godot_quat *p_pre_a, const godot_quat *p_post_b, const godot_real p_t);
	godot_quat (*godot_quat_operator_multiply)(const godot_quat *p_self, const godot_real p_b);
	godot_quat (*godot_quat_operator_add)(const godot_quat *p_self, const godot_quat *p_b);
	godot_quat (*godot_quat_operator_subtract)(const godot_quat *p_self, const godot_quat *p_b);
	godot_quat (*godot_quat_operator_divide)(const godot_quat *p_self, const godot_real p_b);
	godot_bool (*godot_quat_operator_equal)(const godot_quat *p_self, const godot_quat *p_b);
	godot_quat (*godot_quat_operator_neg)(const godot_quat *p_self);
	void (*godot_basis_new_with_rows)(godot_basis *r_dest, const godot_vector3 *p_x_axis, const godot_vector3 *p_y_axis, const godot_vector3 *p_z_axis);
	void (*godot_basis_new_with_axis_and_angle)(godot_basis *r_dest, const godot_vector3 *p_axis, const godot_real p_phi);
	void (*godot_basis_new_with_euler)(godot_basis *r_dest, const godot_vector3 *p_euler);
	godot_string (*godot_basis_as_string)(const godot_basis *p_self);
	godot_basis (*godot_basis_inverse)(const godot_basis *p_self);
	godot_basis (*godot_basis_transposed)(const godot_basis *p_self);
	godot_basis (*godot_basis_orthonormalized)(const godot_basis *p_self);
	godot_real (*godot_basis_determinant)(const godot_basis *p_self);
	godot_basis (*godot_basis_rotated)(const godot_basis *p_self, const godot_vector3 *p_axis, const godot_real p_phi);
	godot_basis (*godot_basis_scaled)(const godot_basis *p_self, const godot_vector3 *p_scale);
	godot_vector3 (*godot_basis_get_scale)(const godot_basis *p_self);
	godot_vector3 (*godot_basis_get_euler)(const godot_basis *p_self);
	godot_real (*godot_basis_tdotx)(const godot_basis *p_self, const godot_vector3 *p_with);
	godot_real (*godot_basis_tdoty)(const godot_basis *p_self, const godot_vector3 *p_with);
	godot_real (*godot_basis_tdotz)(const godot_basis *p_self, const godot_vector3 *p_with);
	godot_vector3 (*godot_basis_xform)(const godot_basis *p_self, const godot_vector3 *p_v);
	godot_vector3 (*godot_basis_xform_inv)(const godot_basis *p_self, const godot_vector3 *p_v);
	godot_int (*godot_basis_get_orthogonal_index)(const godot_basis *p_self);
	void (*godot_basis_new)(godot_basis *r_dest);
	void (*godot_basis_new_with_euler_quat)(godot_basis *r_dest, const godot_quat *p_euler);
	void (*godot_basis_get_elements)(const godot_basis *p_self, godot_vector3 *p_elements);
	godot_vector3 (*godot_basis_get_axis)(const godot_basis *p_self, const godot_int p_axis);
	void (*godot_basis_set_axis)(godot_basis *p_self, const godot_int p_axis, const godot_vector3 *p_value);
	godot_vector3 (*godot_basis_get_row)(const godot_basis *p_self, const godot_int p_row);
	void (*godot_basis_set_row)(godot_basis *p_self, const godot_int p_row, const godot_vector3 *p_value);
	godot_bool (*godot_basis_operator_equal)(const godot_basis *p_self, const godot_basis *p_b);
	godot_basis (*godot_basis_operator_add)(const godot_basis *p_self, const godot_basis *p_b);
	godot_basis (*godot_basis_operator_subtract)(const godot_basis *p_self, const godot_basis *p_b);
	godot_basis (*godot_basis_operator_multiply_vector)(const godot_basis *p_self, const godot_basis *p_b);
	godot_basis (*godot_basis_operator_multiply_scalar)(const godot_basis *p_self, const godot_real p_b);
	void (*godot_vector3_new)(godot_vector3 *r_dest, const godot_real p_x, const godot_real p_y, const godot_real p_z);
	godot_string (*godot_vector3_as_string)(const godot_vector3 *p_self);
	godot_int (*godot_vector3_min_axis)(const godot_vector3 *p_self);
	godot_int (*godot_vector3_max_axis)(const godot_vector3 *p_self);
	godot_real (*godot_vector3_length)(const godot_vector3 *p_self);
	godot_real (*godot_vector3_length_squared)(const godot_vector3 *p_self);
	godot_bool (*godot_vector3_is_normalized)(const godot_vector3 *p_self);
	godot_vector3 (*godot_vector3_normalized)(const godot_vector3 *p_self);
	godot_vector3 (*godot_vector3_inverse)(const godot_vector3 *p_self);
	godot_vector3 (*godot_vector3_snapped)(const godot_vector3 *p_self, const godot_vector3 *p_by);
	godot_vector3 (*godot_vector3_rotated)(const godot_vector3 *p_self, const godot_vector3 *p_axis, const godot_real p_phi);
	godot_vector3 (*godot_vector3_linear_interpolate)(const godot_vector3 *p_self, const godot_vector3 *p_b, const godot_real p_t);
	godot_vector3 (*godot_vector3_cubic_interpolate)(const godot_vector3 *p_self, const godot_vector3 *p_b, const godot_vector3 *p_pre_a, const godot_vector3 *p_post_b, const godot_real p_t);
	godot_real (*godot_vector3_dot)(const godot_vector3 *p_self, const godot_vector3 *p_b);
	godot_vector3 (*godot_vector3_cross)(const godot_vector3 *p_self, const godot_vector3 *p_b);
	godot_basis (*godot_vector3_outer)(const godot_vector3 *p_self, const godot_vector3 *p_b);
	godot_basis (*godot_vector3_to_diagonal_matrix)(const godot_vector3 *p_self);
	godot_vector3 (*godot_vector3_abs)(const godot_vector3 *p_self);
	godot_vector3 (*godot_vector3_floor)(const godot_vector3 *p_self);
	godot_vector3 (*godot_vector3_ceil)(const godot_vector3 *p_self);
	godot_real (*godot_vector3_distance_to)(const godot_vector3 *p_self, const godot_vector3 *p_b);
	godot_real (*godot_vector3_distance_squared_to)(const godot_vector3 *p_self, const godot_vector3 *p_b);
	godot_real (*godot_vector3_angle_to)(const godot_vector3 *p_self, const godot_vector3 *p_to);
	godot_vector3 (*godot_vector3_slide)(const godot_vector3 *p_self, const godot_vector3 *p_n);
	godot_vector3 (*godot_vector3_bounce)(const godot_vector3 *p_self, const godot_vector3 *p_n);
	godot_vector3 (*godot_vector3_reflect)(const godot_vector3 *p_self, const godot_vector3 *p_n);
	godot_vector3 (*godot_vector3_operator_add)(const godot_vector3 *p_self, const godot_vector3 *p_b);
	godot_vector3 (*godot_vector3_operator_subtract)(const godot_vector3 *p_self, const godot_vector3 *p_b);
	godot_vector3 (*godot_vector3_operator_multiply_vector)(const godot_vector3 *p_self, const godot_vector3 *p_b);
	godot_vector3 (*godot_vector3_operator_multiply_scalar)(const godot_vector3 *p_self, const godot_real p_b);
	godot_vector3 (*godot_vector3_operator_divide_vector)(const godot_vector3 *p_self, const godot_vector3 *p_b);
	godot_vector3 (*godot_vector3_operator_divide_scalar)(const godot_vector3 *p_self, const godot_real p_b);
	godot_bool (*godot_vector3_operator_equal)(const godot_vector3 *p_self, const godot_vector3 *p_b);
	godot_bool (*godot_vector3_operator_less)(const godot_vector3 *p_self, const godot_vector3 *p_b);
	godot_vector3 (*godot_vector3_operator_neg)(const godot_vector3 *p_self);
	void (*godot_vector3_set_axis)(godot_vector3 *p_self, const godot_vector3_axis p_axis, const godot_real p_val);
	godot_real (*godot_vector3_get_axis)(const godot_vector3 *p_self, const godot_vector3_axis p_axis);
	void (*godot_pool_byte_array_new)(godot_pool_byte_array *r_dest);
	void (*godot_pool_byte_array_new_copy)(godot_pool_byte_array *r_dest, const godot_pool_byte_array *p_src);
	void (*godot_pool_byte_array_new_with_array)(godot_pool_byte_array *r_dest, const godot_array *p_a);
	void (*godot_pool_byte_array_append)(godot_pool_byte_array *p_self, const uint8_t p_data);
	void (*godot_pool_byte_array_append_array)(godot_pool_byte_array *p_self, const godot_pool_byte_array *p_array);
	godot_error (*godot_pool_byte_array_insert)(godot_pool_byte_array *p_self, const godot_int p_idx, const uint8_t p_data);
	void (*godot_pool_byte_array_invert)(godot_pool_byte_array *p_self);
	void (*godot_pool_byte_array_push_back)(godot_pool_byte_array *p_self, const uint8_t p_data);
	void (*godot_pool_byte_array_remove)(godot_pool_byte_array *p_self, const godot_int p_idx);
	void (*godot_pool_byte_array_resize)(godot_pool_byte_array *p_self, const godot_int p_size);
	godot_pool_byte_array_read_access *(*godot_pool_byte_array_read)(const godot_pool_byte_array *p_self);
	godot_pool_byte_array_write_access *(*godot_pool_byte_array_write)(godot_pool_byte_array *p_self);
	void (*godot_pool_byte_array_set)(godot_pool_byte_array *p_self, const godot_int p_idx, const uint8_t p_data);
	uint8_t (*godot_pool_byte_array_get)(const godot_pool_byte_array *p_self, const godot_int p_idx);
	godot_int (*godot_pool_byte_array_size)(const godot_pool_byte_array *p_self);
	void (*godot_pool_byte_array_destroy)(godot_pool_byte_array *p_self);
	void (*godot_pool_int_array_new)(godot_pool_int_array *r_dest);
	void (*godot_pool_int_array_new_copy)(godot_pool_int_array *r_dest, const godot_pool_int_array *p_src);
	void (*godot_pool_int_array_new_with_array)(godot_pool_int_array *r_dest, const godot_array *p_a);
	void (*godot_pool_int_array_append)(godot_pool_int_array *p_self, const godot_int p_data);
	void (*godot_pool_int_array_append_array)(godot_pool_int_array *p_self, const godot_pool_int_array *p_array);
	godot_error (*godot_pool_int_array_insert)(godot_pool_int_array *p_self, const godot_int p_idx, const godot_int p_data);
	void (*godot_pool_int_array_invert)(godot_pool_int_array *p_self);
	void (*godot_pool_int_array_push_back)(godot_pool_int_array *p_self, const godot_int p_data);
	void (*godot_pool_int_array_remove)(godot_pool_int_array *p_self, const godot_int p_idx);
	void (*godot_pool_int_array_resize)(godot_pool_int_array *p_self, const godot_int p_size);
	godot_pool_int_array_read_access *(*godot_pool_int_array_read)(const godot_pool_int_array *p_self);
	godot_pool_int_array_write_access *(*godot_pool_int_array_write)(godot_pool_int_array *p_self);
	void (*godot_pool_int_array_set)(godot_pool_int_array *p_self, const godot_int p_idx, const godot_int p_data);
	godot_int (*godot_pool_int_array_get)(const godot_pool_int_array *p_self, const godot_int p_idx);
	godot_int (*godot_pool_int_array_size)(const godot_pool_int_array *p_self);
	void (*godot_pool_int_array_destroy)(godot_pool_int_array *p_self);
	void (*godot_pool_real_array_new)(godot_pool_real_array *r_dest);
	void (*godot_pool_real_array_new_copy)(godot_pool_real_array *r_dest, const godot_pool_real_array *p_src);
	void (*godot_pool_real_array_new_with_array)(godot_pool_real_array *r_dest, const godot_array *p_a);
	void (*godot_pool_real_array_append)(godot_pool_real_array *p_self, const godot_real p_data);
	void (*godot_pool_real_array_append_array)(godot_pool_real_array *p_self, const godot_pool_real_array *p_array);
	godot_error (*godot_pool_real_array_insert)(godot_pool_real_array *p_self, const godot_int p_idx, const godot_real p_data);
	void (*godot_pool_real_array_invert)(godot_pool_real_array *p_self);
	void (*godot_pool_real_array_push_back)(godot_pool_real_array *p_self, const godot_real p_data);
	void (*godot_pool_real_array_remove)(godot_pool_real_array *p_self, const godot_int p_idx);
	void (*godot_pool_real_array_resize)(godot_pool_real_array *p_self, const godot_int p_size);
	godot_pool_real_array_read_access *(*godot_pool_real_array_read)(const godot_pool_real_array *p_self);
	godot_pool_real_array_write_access *(*godot_pool_real_array_write)(godot_pool_real_array *p_self);
	void (*godot_pool_real_array_set)(godot_pool_real_array *p_self, const godot_int p_idx, const godot_real p_data);
	godot_real (*godot_pool_real_array_get)(const godot_pool_real_array *p_self, const godot_int p_idx);
	godot_int (*godot_pool_real_array_size)(const godot_pool_real_array *p_self);
	void (*godot_pool_real_array_destroy)(godot_pool_real_array *p_self);
	void (*godot_pool_string_array_new)(godot_pool_string_array *r_dest);
	void (*godot_pool_string_array_new_copy)(godot_pool_string_array *r_dest, const godot_pool_string_array *p_src);
	void (*godot_pool_string_array_new_with_array)(godot_pool_string_array *r_dest, const godot_array *p_a);
	void (*godot_pool_string_array_append)(godot_pool_string_array *p_self, const godot_string *p_data);
	void (*godot_pool_string_array_append_array)(godot_pool_string_array *p_self, const godot_pool_string_array *p_array);
	godot_error (*godot_pool_string_array_insert)(godot_pool_string_array *p_self, const godot_int p_idx, const godot_string *p_data);
	void (*godot_pool_string_array_invert)(godot_pool_string_array *p_self);
	void (*godot_pool_string_array_push_back)(godot_pool_string_array *p_self, const godot_string *p_data);
	void (*godot_pool_string_array_remove)(godot_pool_string_array *p_self, const godot_int p_idx);
	void (*godot_pool_string_array_resize)(godot_pool_string_array *p_self, const godot_int p_size);
	godot_pool_string_array_read_access *(*godot_pool_string_array_read)(const godot_pool_string_array *p_self);
	godot_pool_string_array_write_access *(*godot_pool_string_array_write)(godot_pool_string_array *p_self);
	void (*godot_pool_string_array_set)(godot_pool_string_array *p_self, const godot_int p_idx, const godot_string *p_data);
	godot_string (*godot_pool_string_array_get)(const godot_pool_string_array *p_self, const godot_int p_idx);
	godot_int (*godot_pool_string_array_size)(const godot_pool_string_array *p_self);
	void (*godot_pool_string_array_destroy)(godot_pool_string_array *p_self);
	void (*godot_pool_vector2_array_new)(godot_pool_vector2_array *r_dest);
	void (*godot_pool_vector2_array_new_copy)(godot_pool_vector2_array *r_dest, const godot_pool_vector2_array *p_src);
	void (*godot_pool_vector2_array_new_with_array)(godot_pool_vector2_array *r_dest, const godot_array *p_a);
	void (*godot_pool_vector2_array_append)(godot_pool_vector2_array *p_self, const godot_vector2 *p_data);
	void (*godot_pool_vector2_array_append_array)(godot_pool_vector2_array *p_self, const godot_pool_vector2_array *p_array);
	godot_error (*godot_pool_vector2_array_insert)(godot_pool_vector2_array *p_self, const godot_int p_idx, const godot_vector2 *p_data);
	void (*godot_pool_vector2_array_invert)(godot_pool_vector2_array *p_self);
	void (*godot_pool_vector2_array_push_back)(godot_pool_vector2_array *p_self, const godot_vector2 *p_data);
	void (*godot_pool_vector2_array_remove)(godot_pool_vector2_array *p_self, const godot_int p_idx);
	void (*godot_pool_vector2_array_resize)(godot_pool_vector2_array *p_self, const godot_int p_size);
	godot_pool_vector2_array_read_access *(*godot_pool_vector2_array_read)(const godot_pool_vector2_array *p_self);
	godot_pool_vector2_array_write_access *(*godot_pool_vector2_array_write)(godot_pool_vector2_array *p_self);
	void (*godot_pool_vector2_array_set)(godot_pool_vector2_array *p_self, const godot_int p_idx, const godot_vector2 *p_data);
	godot_vector2 (*godot_pool_vector2_array_get)(const godot_pool_vector2_array *p_self, const godot_int p_idx);
	godot_int (*godot_pool_vector2_array_size)(const godot_pool_vector2_array *p_self);
	void (*godot_pool_vector2_array_destroy)(godot_pool_vector2_array *p_self);
	void (*godot_pool_vector3_array_new)(godot_pool_vector3_array *r_dest);
	void (*godot_pool_vector3_array_new_copy)(godot_pool_vector3_array *r_dest, const godot_pool_vector3_array *p_src);
	void (*godot_pool_vector3_array_new_with_array)(godot_pool_vector3_array *r_dest, const godot_array *p_a);
	void (*godot_pool_vector3_array_append)(godot_pool_vector3_array *p_self, const godot_vector3 *p_data);
	void (*godot_pool_vector3_array_append_array)(godot_pool_vector3_array *p_self, const godot_pool_vector3_array *p_array);
	godot_error (*godot_pool_vector3_array_insert)(godot_pool_vector3_array *p_self, const godot_int p_idx, const godot_vector3 *p_data);
	void (*godot_pool_vector3_array_invert)(godot_pool_vector3_array *p_self);
	void (*godot_pool_vector3_array_push_back)(godot_pool_vector3_array *p_self, const godot_vector3 *p_data);
	void (*godot_pool_vector3_array_remove)(godot_pool_vector3_array *p_self, const godot_int p_idx);
	void (*godot_pool_vector3_array_resize)(godot_pool_vector3_array *p_self, const godot_int p_size);
	godot_pool_vector3_array_read_access *(*godot_pool_vector3_array_read)(const godot_pool_vector3_array *p_self);
	godot_pool_vector3_array_write_access *(*godot_pool_vector3_array_write)(godot_pool_vector3_array *p_self);
	void (*godot_pool_vector3_array_set)(godot_pool_vector3_array *p_self, const godot_int p_idx, const godot_vector3 *p_data);
	godot_vector3 (*godot_pool_vector3_array_get)(const godot_pool_vector3_array *p_self, const godot_int p_idx);
	godot_int (*godot_pool_vector3_array_size)(const godot_pool_vector3_array *p_self);
	void (*godot_pool_vector3_array_destroy)(godot_pool_vector3_array *p_self);
	void (*godot_pool_color_array_new)(godot_pool_color_array *r_dest);
	void (*godot_pool_color_array_new_copy)(godot_pool_color_array *r_dest, const godot_pool_color_array *p_src);
	void (*godot_pool_color_array_new_with_array)(godot_pool_color_array *r_dest, const godot_array *p_a);
	void (*godot_pool_color_array_append)(godot_pool_color_array *p_self, const godot_color *p_data);
	void (*godot_pool_color_array_append_array)(godot_pool_color_array *p_self, const godot_pool_color_array *p_array);
	godot_error (*godot_pool_color_array_insert)(godot_pool_color_array *p_self, const godot_int p_idx, const godot_color *p_data);
	void (*godot_pool_color_array_invert)(godot_pool_color_array *p_self);
	void (*godot_pool_color_array_push_back)(godot_pool_color_array *p_self, const godot_color *p_data);
	void (*godot_pool_color_array_remove)(godot_pool_color_array *p_self, const godot_int p_idx);
	void (*godot_pool_color_array_resize)(godot_pool_color_array *p_self, const godot_int p_size);
	godot_pool_color_array_read_access *(*godot_pool_color_array_read)(const godot_pool_color_array *p_self);
	godot_pool_color_array_write_access *(*godot_pool_color_array_write)(godot_pool_color_array *p_self);
	void (*godot_pool_color_array_set)(godot_pool_color_array *p_self, const godot_int p_idx, const godot_color *p_data);
	godot_color (*godot_pool_color_array_get)(const godot_pool_color_array *p_self, const godot_int p_idx);
	godot_int (*godot_pool_color_array_size)(const godot_pool_color_array *p_self);
	void (*godot_pool_color_array_destroy)(godot_pool_color_array *p_self);
	godot_pool_byte_array_read_access *(*godot_pool_byte_array_read_access_copy)(const godot_pool_byte_array_read_access *p_read);
	const uint8_t *(*godot_pool_byte_array_read_access_ptr)(const godot_pool_byte_array_read_access *p_read);
	void (*godot_pool_byte_array_read_access_operator_assign)(godot_pool_byte_array_read_access *p_read, godot_pool_byte_array_read_access *p_other);
	void (*godot_pool_byte_array_read_access_destroy)(godot_pool_byte_array_read_access *p_read);
	godot_pool_int_array_read_access *(*godot_pool_int_array_read_access_copy)(const godot_pool_int_array_read_access *p_read);
	const godot_int *(*godot_pool_int_array_read_access_ptr)(const godot_pool_int_array_read_access *p_read);
	void (*godot_pool_int_array_read_access_operator_assign)(godot_pool_int_array_read_access *p_read, godot_pool_int_array_read_access *p_other);
	void (*godot_pool_int_array_read_access_destroy)(godot_pool_int_array_read_access *p_read);
	godot_pool_real_array_read_access *(*godot_pool_real_array_read_access_copy)(const godot_pool_real_array_read_access *p_read);
	const godot_real *(*godot_pool_real_array_read_access_ptr)(const godot_pool_real_array_read_access *p_read);
	void (*godot_pool_real_array_read_access_operator_assign)(godot_pool_real_array_read_access *p_read, godot_pool_real_array_read_access *p_other);
	void (*godot_pool_real_array_read_access_destroy)(godot_pool_real_array_read_access *p_read);
	godot_pool_string_array_read_access *(*godot_pool_string_array_read_access_copy)(const godot_pool_string_array_read_access *p_read);
	const godot_string *(*godot_pool_string_array_read_access_ptr)(const godot_pool_string_array_read_access *p_read);
	void (*godot_pool_string_array_read_access_operator_assign)(godot_pool_string_array_read_access *p_read, godot_pool_string_array_read_access *p_other);
	void (*godot_pool_string_array_read_access_destroy)(godot_pool_string_array_read_access *p_read);
	godot_pool_vector2_array_read_access *(*godot_pool_vector2_array_read_access_copy)(const godot_pool_vector2_array_read_access *p_read);
	const godot_vector2 *(*godot_pool_vector2_array_read_access_ptr)(const godot_pool_vector2_array_read_access *p_read);
	void (*godot_pool_vector2_array_read_access_operator_assign)(godot_pool_vector2_array_read_access *p_read, godot_pool_vector2_array_read_access *p_other);
	void (*godot_pool_vector2_array_read_access_destroy)(godot_pool_vector2_array_read_access *p_read);
	godot_pool_vector3_array_read_access *(*godot_pool_vector3_array_read_access_copy)(const godot_pool_vector3_array_read_access *p_read);
	const godot_vector3 *(*godot_pool_vector3_array_read_access_ptr)(const godot_pool_vector3_array_read_access *p_read);
	void (*godot_pool_vector3_array_read_access_operator_assign)(godot_pool_vector3_array_read_access *p_read, godot_pool_vector3_array_read_access *p_other);
	void (*godot_pool_vector3_array_read_access_destroy)(godot_pool_vector3_array_read_access *p_read);
	godot_pool_color_array_read_access *(*godot_pool_color_array_read_access_copy)(const godot_pool_color_array_read_access *p_read);
	const godot_color *(*godot_pool_color_array_read_access_ptr)(const godot_pool_color_array_read_access *p_read);
	void (*godot_pool_color_array_read_access_operator_assign)(godot_pool_color_array_read_access *p_read, godot_pool_color_array_read_access *p_other);
	void (*godot_pool_color_array_read_access_destroy)(godot_pool_color_array_read_access *p_read);
	godot_pool_byte_array_write_access *(*godot_pool_byte_array_write_access_copy)(const godot_pool_byte_array_write_access *p_write);
	uint8_t *(*godot_pool_byte_array_write_access_ptr)(const godot_pool_byte_array_write_access *p_write);
	void (*godot_pool_byte_array_write_access_operator_assign)(godot_pool_byte_array_write_access *p_write, godot_pool_byte_array_write_access *p_other);
	void (*godot_pool_byte_array_write_access_destroy)(godot_pool_byte_array_write_access *p_write);
	godot_pool_int_array_write_access *(*godot_pool_int_array_write_access_copy)(const godot_pool_int_array_write_access *p_write);
	godot_int *(*godot_pool_int_array_write_access_ptr)(const godot_pool_int_array_write_access *p_write);
	void (*godot_pool_int_array_write_access_operator_assign)(godot_pool_int_array_write_access *p_write, godot_pool_int_array_write_access *p_other);
	void (*godot_pool_int_array_write_access_destroy)(godot_pool_int_array_write_access *p_write);
	godot_pool_real_array_write_access *(*godot_pool_real_array_write_access_copy)(const godot_pool_real_array_write_access *p_write);
	godot_real *(*godot_pool_real_array_write_access_ptr)(const godot_pool_real_array_write_access *p_write);
	void (*godot_pool_real_array_write_access_operator_assign)(godot_pool_real_array_write_access *p_write, godot_pool_real_array_write_access *p_other);
	void (*godot_pool_real_array_write_access_destroy)(godot_pool_real_array_write_access *p_write);
	godot_pool_string_array_write_access *(*godot_pool_string_array_write_access_copy)(const godot_pool_string_array_write_access *p_write);
	godot_string *(*godot_pool_string_array_write_access_ptr)(const godot_pool_string_array_write_access *p_write);
	void (*godot_pool_string_array_write_access_operator_assign)(godot_pool_string_array_write_access *p_write, godot_pool_string_array_write_access *p_other);
	void (*godot_pool_string_array_write_access_destroy)(godot_pool_string_array_write_access *p_write);
	godot_pool_vector2_array_write_access *(*godot_pool_vector2_array_write_access_copy)(const godot_pool_vector2_array_write_access *p_write);
	godot_vector2 *(*godot_pool_vector2_array_write_access_ptr)(const godot_pool_vector2_array_write_access *p_write);
	void (*godot_pool_vector2_array_write_access_operator_assign)(godot_pool_vector2_array_write_access *p_write, godot_pool_vector2_array_write_access *p_other);
	void (*godot_pool_vector2_array_write_access_destroy)(godot_pool_vector2_array_write_access *p_write);
	godot_pool_vector3_array_write_access *(*godot_pool_vector3_array_write_access_copy)(const godot_pool_vector3_array_write_access *p_write);
	godot_vector3 *(*godot_pool_vector3_array_write_access_ptr)(const godot_pool_vector3_array_write_access *p_write);
	void (*godot_pool_vector3_array_write_access_operator_assign)(godot_pool_vector3_array_write_access *p_write, godot_pool_vector3_array_write_access *p_other);
	void (*godot_pool_vector3_array_write_access_destroy)(godot_pool_vector3_array_write_access *p_write);
	godot_pool_color_array_write_access *(*godot_pool_color_array_write_access_copy)(const godot_pool_color_array_write_access *p_write);
	godot_color *(*godot_pool_color_array_write_access_ptr)(const godot_pool_color_array_write_access *p_write);
	void (*godot_pool_color_array_write_access_operator_assign)(godot_pool_color_array_write_access *p_write, godot_pool_color_array_write_access *p_other);
	void (*godot_pool_color_array_write_access_destroy)(godot_pool_color_array_write_access *p_write);
	void (*godot_array_new)(godot_array *r_dest);
	void (*godot_array_new_copy)(godot_array *r_dest, const godot_array *p_src);
	void (*godot_array_new_pool_color_array)(godot_array *r_dest, const godot_pool_color_array *p_pca);
	void (*godot_array_new_pool_vector3_array)(godot_array *r_dest, const godot_pool_vector3_array *p_pv3a);
	void (*godot_array_new_pool_vector2_array)(godot_array *r_dest, const godot_pool_vector2_array *p_pv2a);
	void (*godot_array_new_pool_string_array)(godot_array *r_dest, const godot_pool_string_array *p_psa);
	void (*godot_array_new_pool_real_array)(godot_array *r_dest, const godot_pool_real_array *p_pra);
	void (*godot_array_new_pool_int_array)(godot_array *r_dest, const godot_pool_int_array *p_pia);
	void (*godot_array_new_pool_byte_array)(godot_array *r_dest, const godot_pool_byte_array *p_pba);
	void (*godot_array_set)(godot_array *p_self, const godot_int p_idx, const godot_variant *p_value);
	godot_variant (*godot_array_get)(const godot_array *p_self, const godot_int p_idx);
	godot_variant *(*godot_array_operator_index)(godot_array *p_self, const godot_int p_idx);
	const godot_variant *(*godot_array_operator_index_const)(const godot_array *p_self, const godot_int p_idx);
	void (*godot_array_append)(godot_array *p_self, const godot_variant *p_value);
	void (*godot_array_clear)(godot_array *p_self);
	godot_int (*godot_array_count)(const godot_array *p_self, const godot_variant *p_value);
	godot_bool (*godot_array_empty)(const godot_array *p_self);
	void (*godot_array_erase)(godot_array *p_self, const godot_variant *p_value);
	godot_variant (*godot_array_front)(const godot_array *p_self);
	godot_variant (*godot_array_back)(const godot_array *p_self);
	godot_int (*godot_array_find)(const godot_array *p_self, const godot_variant *p_what, const godot_int p_from);
	godot_int (*godot_array_find_last)(const godot_array *p_self, const godot_variant *p_what);
	godot_bool (*godot_array_has)(const godot_array *p_self, const godot_variant *p_value);
	godot_int (*godot_array_hash)(const godot_array *p_self);
	void (*godot_array_insert)(godot_array *p_self, const godot_int p_pos, const godot_variant *p_value);
	void (*godot_array_invert)(godot_array *p_self);
	godot_variant (*godot_array_pop_back)(godot_array *p_self);
	godot_variant (*godot_array_pop_front)(godot_array *p_self);
	void (*godot_array_push_back)(godot_array *p_self, const godot_variant *p_value);
	void (*godot_array_push_front)(godot_array *p_self, const godot_variant *p_value);
	void (*godot_array_remove)(godot_array *p_self, const godot_int p_idx);
	void (*godot_array_resize)(godot_array *p_self, const godot_int p_size);
	godot_int (*godot_array_rfind)(const godot_array *p_self, const godot_variant *p_what, const godot_int p_from);
	godot_int (*godot_array_size)(const godot_array *p_self);
	void (*godot_array_sort)(godot_array *p_self);
	void (*godot_array_sort_custom)(godot_array *p_self, godot_object *p_obj, const godot_string *p_func);
	godot_int (*godot_array_bsearch)(godot_array *p_self, const godot_variant *p_value, const godot_bool p_before);
	godot_int (*godot_array_bsearch_custom)(godot_array *p_self, const godot_variant *p_value, godot_object *p_obj, const godot_string *p_func, const godot_bool p_before);
	void (*godot_array_destroy)(godot_array *p_self);
	void (*godot_dictionary_new)(godot_dictionary *r_dest);
	void (*godot_dictionary_new_copy)(godot_dictionary *r_dest, const godot_dictionary *p_src);
	void (*godot_dictionary_destroy)(godot_dictionary *p_self);
	godot_int (*godot_dictionary_size)(const godot_dictionary *p_self);
	godot_bool (*godot_dictionary_empty)(const godot_dictionary *p_self);
	void (*godot_dictionary_clear)(godot_dictionary *p_self);
	godot_bool (*godot_dictionary_has)(const godot_dictionary *p_self, const godot_variant *p_key);
	godot_bool (*godot_dictionary_has_all)(const godot_dictionary *p_self, const godot_array *p_keys);
	void (*godot_dictionary_erase)(godot_dictionary *p_self, const godot_variant *p_key);
	godot_int (*godot_dictionary_hash)(const godot_dictionary *p_self);
	godot_array (*godot_dictionary_keys)(const godot_dictionary *p_self);
	godot_array (*godot_dictionary_values)(const godot_dictionary *p_self);
	godot_variant (*godot_dictionary_get)(const godot_dictionary *p_self, const godot_variant *p_key);
	void (*godot_dictionary_set)(godot_dictionary *p_self, const godot_variant *p_key, const godot_variant *p_value);
	godot_variant *(*godot_dictionary_operator_index)(godot_dictionary *p_self, const godot_variant *p_key);
	const godot_variant *(*godot_dictionary_operator_index_const)(const godot_dictionary *p_self, const godot_variant *p_key);
	godot_variant *(*godot_dictionary_next)(const godot_dictionary *p_self, const godot_variant *p_key);
	godot_bool (*godot_dictionary_operator_equal)(const godot_dictionary *p_self, const godot_dictionary *p_b);
	godot_string (*godot_dictionary_to_json)(const godot_dictionary *p_self);
	void (*godot_node_path_new)(godot_node_path *r_dest, const godot_string *p_from);
	void (*godot_node_path_new_copy)(godot_node_path *r_dest, const godot_node_path *p_src);
	void (*godot_node_path_destroy)(godot_node_path *p_self);
	godot_string (*godot_node_path_as_string)(const godot_node_path *p_self);
	godot_bool (*godot_node_path_is_absolute)(const godot_node_path *p_self);
	godot_int (*godot_node_path_get_name_count)(const godot_node_path *p_self);
	godot_string (*godot_node_path_get_name)(const godot_node_path *p_self, const godot_int p_idx);
	godot_int (*godot_node_path_get_subname_count)(const godot_node_path *p_self);
	godot_string (*godot_node_path_get_subname)(const godot_node_path *p_self, const godot_int p_idx);
	godot_string (*godot_node_path_get_concatenated_subnames)(const godot_node_path *p_self);
	godot_bool (*godot_node_path_is_empty)(const godot_node_path *p_self);
	godot_bool (*godot_node_path_operator_equal)(const godot_node_path *p_self, const godot_node_path *p_b);
	void (*godot_plane_new_with_reals)(godot_plane *r_dest, const godot_real p_a, const godot_real p_b, const godot_real p_c, const godot_real p_d);
	void (*godot_plane_new_with_vectors)(godot_plane *r_dest, const godot_vector3 *p_v1, const godot_vector3 *p_v2, const godot_vector3 *p_v3);
	void (*godot_plane_new_with_normal)(godot_plane *r_dest, const godot_vector3 *p_normal, const godot_real p_d);
	godot_string (*godot_plane_as_string)(const godot_plane *p_self);
	godot_plane (*godot_plane_normalized)(const godot_plane *p_self);
	godot_vector3 (*godot_plane_center)(const godot_plane *p_self);
	godot_vector3 (*godot_plane_get_any_point)(const godot_plane *p_self);
	godot_bool (*godot_plane_is_point_over)(const godot_plane *p_self, const godot_vector3 *p_point);
	godot_real (*godot_plane_distance_to)(const godot_plane *p_self, const godot_vector3 *p_point);
	godot_bool (*godot_plane_has_point)(const godot_plane *p_self, const godot_vector3 *p_point, const godot_real p_epsilon);
	godot_vector3 (*godot_plane_project)(const godot_plane *p_self, const godot_vector3 *p_point);
	godot_bool (*godot_plane_intersect_3)(const godot_plane *p_self, godot_vector3 *r_dest, const godot_plane *p_b, const godot_plane *p_c);
	godot_bool (*godot_plane_intersects_ray)(const godot_plane *p_self, godot_vector3 *r_dest, const godot_vector3 *p_from, const godot_vector3 *p_dir);
	godot_bool (*godot_plane_intersects_segment)(const godot_plane *p_self, godot_vector3 *r_dest, const godot_vector3 *p_begin, const godot_vector3 *p_end);
	godot_plane (*godot_plane_operator_neg)(const godot_plane *p_self);
	godot_bool (*godot_plane_operator_equal)(const godot_plane *p_self, const godot_plane *p_b);
	void (*godot_plane_set_normal)(godot_plane *p_self, const godot_vector3 *p_normal);
	godot_vector3 (*godot_plane_get_normal)(const godot_plane *p_self);
	godot_real (*godot_plane_get_d)(const godot_plane *p_self);
	void (*godot_plane_set_d)(godot_plane *p_self, const godot_real p_d);
	void (*godot_rect2_new_with_position_and_size)(godot_rect2 *r_dest, const godot_vector2 *p_pos, const godot_vector2 *p_size);
	void (*godot_rect2_new)(godot_rect2 *r_dest, const godot_real p_x, const godot_real p_y, const godot_real p_width, const godot_real p_height);
	godot_string (*godot_rect2_as_string)(const godot_rect2 *p_self);
	godot_real (*godot_rect2_get_area)(const godot_rect2 *p_self);
	godot_bool (*godot_rect2_intersects)(const godot_rect2 *p_self, const godot_rect2 *p_b);
	godot_bool (*godot_rect2_encloses)(const godot_rect2 *p_self, const godot_rect2 *p_b);
	godot_bool (*godot_rect2_has_no_area)(const godot_rect2 *p_self);
	godot_rect2 (*godot_rect2_clip)(const godot_rect2 *p_self, const godot_rect2 *p_b);
	godot_rect2 (*godot_rect2_merge)(const godot_rect2 *p_self, const godot_rect2 *p_b);
	godot_bool (*godot_rect2_has_point)(const godot_rect2 *p_self, const godot_vector2 *p_point);
	godot_rect2 (*godot_rect2_grow)(const godot_rect2 *p_self, const godot_real p_by);
	godot_rect2 (*godot_rect2_expand)(const godot_rect2 *p_self, const godot_vector2 *p_to);
	godot_bool (*godot_rect2_operator_equal)(const godot_rect2 *p_self, const godot_rect2 *p_b);
	godot_vector2 (*godot_rect2_get_position)(const godot_rect2 *p_self);
	godot_vector2 (*godot_rect2_get_size)(const godot_rect2 *p_self);
	void (*godot_rect2_set_position)(godot_rect2 *p_self, const godot_vector2 *p_pos);
	void (*godot_rect2_set_size)(godot_rect2 *p_self, const godot_vector2 *p_size);
	void (*godot_aabb_new)(godot_aabb *r_dest, const godot_vector3 *p_pos, const godot_vector3 *p_size);
	godot_vector3 (*godot_aabb_get_position)(const godot_aabb *p_self);
	void (*godot_aabb_set_position)(const godot_aabb *p_self, const godot_vector3 *p_v);
	godot_vector3 (*godot_aabb_get_size)(const godot_aabb *p_self);
	void (*godot_aabb_set_size)(const godot_aabb *p_self, const godot_vector3 *p_v);
	godot_string (*godot_aabb_as_string)(const godot_aabb *p_self);
	godot_real (*godot_aabb_get_area)(const godot_aabb *p_self);
	godot_bool (*godot_aabb_has_no_area)(const godot_aabb *p_self);
	godot_bool (*godot_aabb_has_no_surface)(const godot_aabb *p_self);
	godot_bool (*godot_aabb_intersects)(const godot_aabb *p_self, const godot_aabb *p_with);
	godot_bool (*godot_aabb_encloses)(const godot_aabb *p_self, const godot_aabb *p_with);
	godot_aabb (*godot_aabb_merge)(const godot_aabb *p_self, const godot_aabb *p_with);
	godot_aabb (*godot_aabb_intersection)(const godot_aabb *p_self, const godot_aabb *p_with);
	godot_bool (*godot_aabb_intersects_plane)(const godot_aabb *p_self, const godot_plane *p_plane);
	godot_bool (*godot_aabb_intersects_segment)(const godot_aabb *p_self, const godot_vector3 *p_from, const godot_vector3 *p_to);
	godot_bool (*godot_aabb_has_point)(const godot_aabb *p_self, const godot_vector3 *p_point);
	godot_vector3 (*godot_aabb_get_support)(const godot_aabb *p_self, const godot_vector3 *p_dir);
	godot_vector3 (*godot_aabb_get_longest_axis)(const godot_aabb *p_self);
	godot_int (*godot_aabb_get_longest_axis_index)(const godot_aabb *p_self);
	godot_real (*godot_aabb_get_longest_axis_size)(const godot_aabb *p_self);
	godot_vector3 (*godot_aabb_get_shortest_axis)(const godot_aabb *p_self);
	godot_int (*godot_aabb_get_shortest_axis_index)(const godot_aabb *p_self);
	godot_real (*godot_aabb_get_shortest_axis_size)(const godot_aabb *p_self);
	godot_aabb (*godot_aabb_expand)(const godot_aabb *p_self, const godot_vector3 *p_to_point);
	godot_aabb (*godot_aabb_grow)(const godot_aabb *p_self, const godot_real p_by);
	godot_vector3 (*godot_aabb_get_endpoint)(const godot_aabb *p_self, const godot_int p_idx);
	godot_bool (*godot_aabb_operator_equal)(const godot_aabb *p_self, const godot_aabb *p_b);
	void (*godot_rid_new)(godot_rid *r_dest);
	godot_int (*godot_rid_get_id)(const godot_rid *p_self);
	void (*godot_rid_new_with_resource)(godot_rid *r_dest, const godot_object *p_from);
	godot_bool (*godot_rid_operator_equal)(const godot_rid *p_self, const godot_rid *p_b);
	godot_bool (*godot_rid_operator_less)(const godot_rid *p_self, const godot_rid *p_b);
	void (*godot_transform_new_with_axis_origin)(godot_transform *r_dest, const godot_vector3 *p_x_axis, const godot_vector3 *p_y_axis, const godot_vector3 *p_z_axis, const godot_vector3 *p_origin);
	void (*godot_transform_new)(godot_transform *r_dest, const godot_basis *p_basis, const godot_vector3 *p_origin);
	godot_basis (*godot_transform_get_basis)(const godot_transform *p_self);
	void (*godot_transform_set_basis)(godot_transform *p_self, const godot_basis *p_v);
	godot_vector3 (*godot_transform_get_origin)(const godot_transform *p_self);
	void (*godot_transform_set_origin)(godot_transform *p_self, const godot_vector3 *p_v);
	godot_string (*godot_transform_as_string)(const godot_transform *p_self);
	godot_transform (*godot_transform_inverse)(const godot_transform *p_self);
	godot_transform (*godot_transform_affine_inverse)(const godot_transform *p_self);
	godot_transform (*godot_transform_orthonormalized)(const godot_transform *p_self);
	godot_transform (*godot_transform_rotated)(const godot_transform *p_self, const godot_vector3 *p_axis, const godot_real p_phi);
	godot_transform (*godot_transform_scaled)(const godot_transform *p_self, const godot_vector3 *p_scale);
	godot_transform (*godot_transform_translated)(const godot_transform *p_self, const godot_vector3 *p_ofs);
	godot_transform (*godot_transform_looking_at)(const godot_transform *p_self, const godot_vector3 *p_target, const godot_vector3 *p_up);
	godot_plane (*godot_transform_xform_plane)(const godot_transform *p_self, const godot_plane *p_v);
	godot_plane (*godot_transform_xform_inv_plane)(const godot_transform *p_self, const godot_plane *p_v);
	void (*godot_transform_new_identity)(godot_transform *r_dest);
	godot_bool (*godot_transform_operator_equal)(const godot_transform *p_self, const godot_transform *p_b);
	godot_transform (*godot_transform_operator_multiply)(const godot_transform *p_self, const godot_transform *p_b);
	godot_vector3 (*godot_transform_xform_vector3)(const godot_transform *p_self, const godot_vector3 *p_v);
	godot_vector3 (*godot_transform_xform_inv_vector3)(const godot_transform *p_self, const godot_vector3 *p_v);
	godot_aabb (*godot_transform_xform_aabb)(const godot_transform *p_self, const godot_aabb *p_v);
	godot_aabb (*godot_transform_xform_inv_aabb)(const godot_transform *p_self, const godot_aabb *p_v);
	void (*godot_transform2d_new)(godot_transform2d *r_dest, const godot_real p_rot, const godot_vector2 *p_pos);
	void (*godot_transform2d_new_axis_origin)(godot_transform2d *r_dest, const godot_vector2 *p_x_axis, const godot_vector2 *p_y_axis, const godot_vector2 *p_origin);
	godot_string (*godot_transform2d_as_string)(const godot_transform2d *p_self);
	godot_transform2d (*godot_transform2d_inverse)(const godot_transform2d *p_self);
	godot_transform2d (*godot_transform2d_affine_inverse)(const godot_transform2d *p_self);
	godot_real (*godot_transform2d_get_rotation)(const godot_transform2d *p_self);
	godot_vector2 (*godot_transform2d_get_origin)(const godot_transform2d *p_self);
	godot_vector2 (*godot_transform2d_get_scale)(const godot_transform2d *p_self);
	godot_transform2d (*godot_transform2d_orthonormalized)(const godot_transform2d *p_self);
	godot_transform2d (*godot_transform2d_rotated)(const godot_transform2d *p_self, const godot_real p_phi);
	godot_transform2d (*godot_transform2d_scaled)(const godot_transform2d *p_self, const godot_vector2 *p_scale);
	godot_transform2d (*godot_transform2d_translated)(const godot_transform2d *p_self, const godot_vector2 *p_offset);
	godot_vector2 (*godot_transform2d_xform_vector2)(const godot_transform2d *p_self, const godot_vector2 *p_v);
	godot_vector2 (*godot_transform2d_xform_inv_vector2)(const godot_transform2d *p_self, const godot_vector2 *p_v);
	godot_vector2 (*godot_transform2d_basis_xform_vector2)(const godot_transform2d *p_self, const godot_vector2 *p_v);
	godot_vector2 (*godot_transform2d_basis_xform_inv_vector2)(const godot_transform2d *p_self, const godot_vector2 *p_v);
	godot_transform2d (*godot_transform2d_interpolate_with)(const godot_transform2d *p_self, const godot_transform2d *p_m, const godot_real p_c);
	godot_bool (*godot_transform2d_operator_equal)(const godot_transform2d *p_self, const godot_transform2d *p_b);
	godot_transform2d (*godot_transform2d_operator_multiply)(const godot_transform2d *p_self, const godot_transform2d *p_b);
	void (*godot_transform2d_new_identity)(godot_transform2d *r_dest);
	godot_rect2 (*godot_transform2d_xform_rect2)(const godot_transform2d *p_self, const godot_rect2 *p_v);
	godot_rect2 (*godot_transform2d_xform_inv_rect2)(const godot_transform2d *p_self, const godot_rect2 *p_v);
	godot_variant_type (*godot_variant_get_type)(const godot_variant *p_v);
	void (*godot_variant_new_copy)(godot_variant *r_dest, const godot_variant *p_src);
	void (*godot_variant_new_nil)(godot_variant *r_dest);
	void (*godot_variant_new_bool)(godot_variant *r_dest, const godot_bool p_b);
	void (*godot_variant_new_uint)(godot_variant *r_dest, const uint64_t p_i);
	void (*godot_variant_new_int)(godot_variant *r_dest, const int64_t p_i);
	void (*godot_variant_new_real)(godot_variant *r_dest, const double p_r);
	void (*godot_variant_new_string)(godot_variant *r_dest, const godot_string *p_s);
	void (*godot_variant_new_vector2)(godot_variant *r_dest, const godot_vector2 *p_v2);
	void (*godot_variant_new_rect2)(godot_variant *r_dest, const godot_rect2 *p_rect2);
	void (*godot_variant_new_vector3)(godot_variant *r_dest, const godot_vector3 *p_v3);
	void (*godot_variant_new_transform2d)(godot_variant *r_dest, const godot_transform2d *p_t2d);
	void (*godot_variant_new_plane)(godot_variant *r_dest, const godot_plane *p_plane);
	void (*godot_variant_new_quat)(godot_variant *r_dest, const godot_quat *p_quat);
	void (*godot_variant_new_aabb)(godot_variant *r_dest, const godot_aabb *p_aabb);
	void (*godot_variant_new_basis)(godot_variant *r_dest, const godot_basis *p_basis);
	void (*godot_variant_new_transform)(godot_variant *r_dest, const godot_transform *p_trans);
	void (*godot_variant_new_color)(godot_variant *r_dest, const godot_color *p_color);
	void (*godot_variant_new_node_path)(godot_variant *r_dest, const godot_node_path *p_np);
	void (*godot_variant_new_rid)(godot_variant *r_dest, const godot_rid *p_rid);
	void (*godot_variant_new_object)(godot_variant *r_dest, const godot_object *p_obj);
	void (*godot_variant_new_dictionary)(godot_variant *r_dest, const godot_dictionary *p_dict);
	void (*godot_variant_new_array)(godot_variant *r_dest, const godot_array *p_arr);
	void (*godot_variant_new_pool_byte_array)(godot_variant *r_dest, const godot_pool_byte_array *p_pba);
	void (*godot_variant_new_pool_int_array)(godot_variant *r_dest, const godot_pool_int_array *p_pia);
	void (*godot_variant_new_pool_real_array)(godot_variant *r_dest, const godot_pool_real_array *p_pra);
	void (*godot_variant_new_pool_string_array)(godot_variant *r_dest, const godot_pool_string_array *p_psa);
	void (*godot_variant_new_pool_vector2_array)(godot_variant *r_dest, const godot_pool_vector2_array *p_pv2a);
	void (*godot_variant_new_pool_vector3_array)(godot_variant *r_dest, const godot_pool_vector3_array *p_pv3a);
	void (*godot_variant_new_pool_color_array)(godot_variant *r_dest, const godot_pool_color_array *p_pca);
	godot_bool (*godot_variant_as_bool)(const godot_variant *p_self);
	uint64_t (*godot_variant_as_uint)(const godot_variant *p_self);
	int64_t (*godot_variant_as_int)(const godot_variant *p_self);
	double (*godot_variant_as_real)(const godot_variant *p_self);
	godot_string (*godot_variant_as_string)(const godot_variant *p_self);
	godot_vector2 (*godot_variant_as_vector2)(const godot_variant *p_self);
	godot_rect2 (*godot_variant_as_rect2)(const godot_variant *p_self);
	godot_vector3 (*godot_variant_as_vector3)(const godot_variant *p_self);
	godot_transform2d (*godot_variant_as_transform2d)(const godot_variant *p_self);
	godot_plane (*godot_variant_as_plane)(const godot_variant *p_self);
	godot_quat (*godot_variant_as_quat)(const godot_variant *p_self);
	godot_aabb (*godot_variant_as_aabb)(const godot_variant *p_self);
	godot_basis (*godot_variant_as_basis)(const godot_variant *p_self);
	godot_transform (*godot_variant_as_transform)(const godot_variant *p_self);
	godot_color (*godot_variant_as_color)(const godot_variant *p_self);
	godot_node_path (*godot_variant_as_node_path)(const godot_variant *p_self);
	godot_rid (*godot_variant_as_rid)(const godot_variant *p_self);
	godot_object *(*godot_variant_as_object)(const godot_variant *p_self);
	godot_dictionary (*godot_variant_as_dictionary)(const godot_variant *p_self);
	godot_array (*godot_variant_as_array)(const godot_variant *p_self);
	godot_pool_byte_array (*godot_variant_as_pool_byte_array)(const godot_variant *p_self);
	godot_pool_int_array (*godot_variant_as_pool_int_array)(const godot_variant *p_self);
	godot_pool_real_array (*godot_variant_as_pool_real_array)(const godot_variant *p_self);
	godot_pool_string_array (*godot_variant_as_pool_string_array)(const godot_variant *p_self);
	godot_pool_vector2_array (*godot_variant_as_pool_vector2_array)(const godot_variant *p_self);
	godot_pool_vector3_array (*godot_variant_as_pool_vector3_array)(const godot_variant *p_self);
	godot_pool_color_array (*godot_variant_as_pool_color_array)(const godot_variant *p_self);
	godot_variant (*godot_variant_call)(godot_variant *p_self, const godot_string *p_method, const godot_variant **p_args, const godot_int p_argcount, godot_variant_call_error *r_error);
	godot_bool (*godot_variant_has_method)(const godot_variant *p_self, const godot_string *p_method);
	godot_bool (*godot_variant_operator_equal)(const godot_variant *p_self, const godot_variant *p_other);
	godot_bool (*godot_variant_operator_less)(const godot_variant *p_self, const godot_variant *p_other);
	godot_bool (*godot_variant_hash_compare)(const godot_variant *p_self, const godot_variant *p_other);
	godot_bool (*godot_variant_booleanize)(const godot_variant *p_self);
	void (*godot_variant_destroy)(godot_variant *p_self);
	godot_int (*godot_char_string_length)(const godot_char_string *p_cs);
	const char *(*godot_char_string_get_data)(const godot_char_string *p_cs);
	void (*godot_char_string_destroy)(godot_char_string *p_cs);
	void (*godot_string_new)(godot_string *r_dest);
	void (*godot_string_new_copy)(godot_string *r_dest, const godot_string *p_src);
	void (*godot_string_new_with_wide_string)(godot_string *r_dest, const wchar_t *p_contents, const int p_size);
	const wchar_t *(*godot_string_operator_index)(godot_string *p_self, const godot_int p_idx);
	wchar_t (*godot_string_operator_index_const)(const godot_string *p_self, const godot_int p_idx);
	const wchar_t *(*godot_string_wide_str)(const godot_string *p_self);
	godot_bool (*godot_string_operator_equal)(const godot_string *p_self, const godot_string *p_b);
	godot_bool (*godot_string_operator_less)(const godot_string *p_self, const godot_string *p_b);
	godot_string (*godot_string_operator_plus)(const godot_string *p_self, const godot_string *p_b);
	godot_int (*godot_string_length)(const godot_string *p_self);
	signed char (*godot_string_casecmp_to)(const godot_string *p_self, const godot_string *p_str);
	signed char (*godot_string_nocasecmp_to)(const godot_string *p_self, const godot_string *p_str);
	signed char (*godot_string_naturalnocasecmp_to)(const godot_string *p_self, const godot_string *p_str);
	godot_bool (*godot_string_begins_with)(const godot_string *p_self, const godot_string *p_string);
	godot_bool (*godot_string_begins_with_char_array)(const godot_string *p_self, const char *p_char_array);
	godot_array (*godot_string_bigrams)(const godot_string *p_self);
	godot_string (*godot_string_chr)(wchar_t p_character);
	godot_bool (*godot_string_ends_with)(const godot_string *p_self, const godot_string *p_string);
	godot_int (*godot_string_find)(const godot_string *p_self, godot_string p_what);
	godot_int (*godot_string_find_from)(const godot_string *p_self, godot_string p_what, godot_int p_from);
	godot_int (*godot_string_findmk)(const godot_string *p_self, const godot_array *p_keys);
	godot_int (*godot_string_findmk_from)(const godot_string *p_self, const godot_array *p_keys, godot_int p_from);
	godot_int (*godot_string_findmk_from_in_place)(const godot_string *p_self, const godot_array *p_keys, godot_int p_from, godot_int *r_key);
	godot_int (*godot_string_findn)(const godot_string *p_self, godot_string p_what);
	godot_int (*godot_string_findn_from)(const godot_string *p_self, godot_string p_what, godot_int p_from);
	godot_int (*godot_string_find_last)(const godot_string *p_self, godot_string p_what);
	godot_string (*godot_string_format)(const godot_string *p_self, const godot_variant *p_values);
	godot_string (*godot_string_format_with_custom_placeholder)(const godot_string *p_self, const godot_variant *p_values, const char *p_placeholder);
	godot_string (*godot_string_hex_encode_buffer)(const uint8_t *p_buffer, godot_int p_len);
	godot_int (*godot_string_hex_to_int)(const godot_string *p_self);
	godot_int (*godot_string_hex_to_int_without_prefix)(const godot_string *p_self);
	godot_string (*godot_string_insert)(const godot_string *p_self, godot_int p_at_pos, godot_string p_string);
	godot_bool (*godot_string_is_numeric)(const godot_string *p_self);
	godot_bool (*godot_string_is_subsequence_of)(const godot_string *p_self, const godot_string *p_string);
	godot_bool (*godot_string_is_subsequence_ofi)(const godot_string *p_self, const godot_string *p_string);
	godot_string (*godot_string_lpad)(const godot_string *p_self, godot_int p_min_length);
	godot_string (*godot_string_lpad_with_custom_character)(const godot_string *p_self, godot_int p_min_length, const godot_string *p_character);
	godot_bool (*godot_string_match)(const godot_string *p_self, const godot_string *p_wildcard);
	godot_bool (*godot_string_matchn)(const godot_string *p_self, const godot_string *p_wildcard);
	godot_string (*godot_string_md5)(const uint8_t *p_md5);
	godot_string (*godot_string_num)(double p_num);
	godot_string (*godot_string_num_int64)(int64_t p_num, godot_int p_base);
	godot_string (*godot_string_num_int64_capitalized)(int64_t p_num, godot_int p_base, godot_bool p_capitalize_hex);
	godot_string (*godot_string_num_real)(double p_num);
	godot_string (*godot_string_num_scientific)(double p_num);
	godot_string (*godot_string_num_with_decimals)(double p_num, godot_int p_decimals);
	godot_string (*godot_string_pad_decimals)(const godot_string *p_self, godot_int p_digits);
	godot_string (*godot_string_pad_zeros)(const godot_string *p_self, godot_int p_digits);
	godot_string (*godot_string_replace_first)(const godot_string *p_self, godot_string p_key, godot_string p_with);
	godot_string (*godot_string_replace)(const godot_string *p_self, godot_string p_key, godot_string p_with);
	godot_string (*godot_string_replacen)(const godot_string *p_self, godot_string p_key, godot_string p_with);
	godot_int (*godot_string_rfind)(const godot_string *p_self, godot_string p_what);
	godot_int (*godot_string_rfindn)(const godot_string *p_self, godot_string p_what);
	godot_int (*godot_string_rfind_from)(const godot_string *p_self, godot_string p_what, godot_int p_from);
	godot_int (*godot_string_rfindn_from)(const godot_string *p_self, godot_string p_what, godot_int p_from);
	godot_string (*godot_string_rpad)(const godot_string *p_self, godot_int p_min_length);
	godot_string (*godot_string_rpad_with_custom_character)(const godot_string *p_self, godot_int p_min_length, const godot_string *p_character);
	godot_real (*godot_string_similarity)(const godot_string *p_self, const godot_string *p_string);
	godot_string (*godot_string_sprintf)(const godot_string *p_self, const godot_array *p_values, godot_bool *p_error);
	godot_string (*godot_string_substr)(const godot_string *p_self, godot_int p_from, godot_int p_chars);
	double (*godot_string_to_double)(const godot_string *p_self);
	godot_real (*godot_string_to_float)(const godot_string *p_self);
	godot_int (*godot_string_to_int)(const godot_string *p_self);
	godot_string (*godot_string_camelcase_to_underscore)(const godot_string *p_self);
	godot_string (*godot_string_camelcase_to_underscore_lowercased)(const godot_string *p_self);
	godot_string (*godot_string_capitalize)(const godot_string *p_self);
	double (*godot_string_char_to_double)(const char *p_what);
	godot_int (*godot_string_char_to_int)(const char *p_what);
	int64_t (*godot_string_wchar_to_int)(const wchar_t *p_str);
	godot_int (*godot_string_char_to_int_with_len)(const char *p_what, godot_int p_len);
	int64_t (*godot_string_char_to_int64_with_len)(const wchar_t *p_str, int p_len);
	int64_t (*godot_string_hex_to_int64)(const godot_string *p_self);
	int64_t (*godot_string_hex_to_int64_with_prefix)(const godot_string *p_self);
	int64_t (*godot_string_to_int64)(const godot_string *p_self);
	double (*godot_string_unicode_char_to_double)(const wchar_t *p_str, const wchar_t **r_end);
	godot_int (*godot_string_get_slice_count)(const godot_string *p_self, godot_string p_splitter);
	godot_string (*godot_string_get_slice)(const godot_string *p_self, godot_string p_splitter, godot_int p_slice);
	godot_string (*godot_string_get_slicec)(const godot_string *p_self, wchar_t p_splitter, godot_int p_slice);
	godot_array (*godot_string_split)(const godot_string *p_self, const godot_string *p_splitter);
	godot_array (*godot_string_split_allow_empty)(const godot_string *p_self, const godot_string *p_splitter);
	godot_array (*godot_string_split_floats)(const godot_string *p_self, const godot_string *p_splitter);
	godot_array (*godot_string_split_floats_allows_empty)(const godot_string *p_self, const godot_string *p_splitter);
	godot_array (*godot_string_split_floats_mk)(const godot_string *p_self, const godot_array *p_splitters);
	godot_array (*godot_string_split_floats_mk_allows_empty)(const godot_string *p_self, const godot_array *p_splitters);
	godot_array (*godot_string_split_ints)(const godot_string *p_self, const godot_string *p_splitter);
	godot_array (*godot_string_split_ints_allows_empty)(const godot_string *p_self, const godot_string *p_splitter);
	godot_array (*godot_string_split_ints_mk)(const godot_string *p_self, const godot_array *p_splitters);
	godot_array (*godot_string_split_ints_mk_allows_empty)(const godot_string *p_self, const godot_array *p_splitters);
	godot_array (*godot_string_split_spaces)(const godot_string *p_self);
	wchar_t (*godot_string_char_lowercase)(wchar_t p_char);
	wchar_t (*godot_string_char_uppercase)(wchar_t p_char);
	godot_string (*godot_string_to_lower)(const godot_string *p_self);
	godot_string (*godot_string_to_upper)(const godot_string *p_self);
	godot_string (*godot_string_get_basename)(const godot_string *p_self);
	godot_string (*godot_string_get_extension)(const godot_string *p_self);
	godot_string (*godot_string_left)(const godot_string *p_self, godot_int p_pos);
	wchar_t (*godot_string_ord_at)(const godot_string *p_self, godot_int p_idx);
	godot_string (*godot_string_plus_file)(const godot_string *p_self, const godot_string *p_file);
	godot_string (*godot_string_right)(const godot_string *p_self, godot_int p_pos);
	godot_string (*godot_string_strip_edges)(const godot_string *p_self, godot_bool p_left, godot_bool p_right);
	godot_string (*godot_string_strip_escapes)(const godot_string *p_self);
	void (*godot_string_erase)(godot_string *p_self, godot_int p_pos, godot_int p_chars);
	godot_char_string (*godot_string_ascii)(const godot_string *p_self);
	godot_char_string (*godot_string_ascii_extended)(const godot_string *p_self);
	godot_char_string (*godot_string_utf8)(const godot_string *p_self);
	godot_bool (*godot_string_parse_utf8)(godot_string *p_self, const char *p_utf8);
	godot_bool (*godot_string_parse_utf8_with_len)(godot_string *p_self, const char *p_utf8, godot_int p_len);
	godot_string (*godot_string_chars_to_utf8)(const char *p_utf8);
	godot_string (*godot_string_chars_to_utf8_with_len)(const char *p_utf8, godot_int p_len);
	uint32_t (*godot_string_hash)(const godot_string *p_self);
	uint64_t (*godot_string_hash64)(const godot_string *p_self);
	uint32_t (*godot_string_hash_chars)(const char *p_cstr);
	uint32_t (*godot_string_hash_chars_with_len)(const char *p_cstr, godot_int p_len);
	uint32_t (*godot_string_hash_utf8_chars)(const wchar_t *p_str);
	uint32_t (*godot_string_hash_utf8_chars_with_len)(const wchar_t *p_str, godot_int p_len);
	godot_pool_byte_array (*godot_string_md5_buffer)(const godot_string *p_self);
	godot_string (*godot_string_md5_text)(const godot_string *p_self);
	godot_pool_byte_array (*godot_string_sha256_buffer)(const godot_string *p_self);
	godot_string (*godot_string_sha256_text)(const godot_string *p_self);
	godot_bool (*godot_string_empty)(const godot_string *p_self);
	godot_string (*godot_string_get_base_dir)(const godot_string *p_self);
	godot_string (*godot_string_get_file)(const godot_string *p_self);
	godot_string (*godot_string_humanize_size)(uint64_t p_size);
	godot_bool (*godot_string_is_abs_path)(const godot_string *p_self);
	godot_bool (*godot_string_is_rel_path)(const godot_string *p_self);
	godot_bool (*godot_string_is_resource_file)(const godot_string *p_self);
	godot_string (*godot_string_path_to)(const godot_string *p_self, const godot_string *p_path);
	godot_string (*godot_string_path_to_file)(const godot_string *p_self, const godot_string *p_path);
	godot_string (*godot_string_simplify_path)(const godot_string *p_self);
	godot_string (*godot_string_c_escape)(const godot_string *p_self);
	godot_string (*godot_string_c_escape_multiline)(const godot_string *p_self);
	godot_string (*godot_string_c_unescape)(const godot_string *p_self);
	godot_string (*godot_string_http_escape)(const godot_string *p_self);
	godot_string (*godot_string_http_unescape)(const godot_string *p_self);
	godot_string (*godot_string_json_escape)(const godot_string *p_self);
	godot_string (*godot_string_word_wrap)(const godot_string *p_self, godot_int p_chars_per_line);
	godot_string (*godot_string_xml_escape)(const godot_string *p_self);
	godot_string (*godot_string_xml_escape_with_quotes)(const godot_string *p_self);
	godot_string (*godot_string_xml_unescape)(const godot_string *p_self);
	godot_string (*godot_string_percent_decode)(const godot_string *p_self);
	godot_string (*godot_string_percent_encode)(const godot_string *p_self);
	godot_bool (*godot_string_is_valid_float)(const godot_string *p_self);
	godot_bool (*godot_string_is_valid_hex_number)(const godot_string *p_self, godot_bool p_with_prefix);
	godot_bool (*godot_string_is_valid_html_color)(const godot_string *p_self);
	godot_bool (*godot_string_is_valid_identifier)(const godot_string *p_self);
	godot_bool (*godot_string_is_valid_integer)(const godot_string *p_self);
	godot_bool (*godot_string_is_valid_ip_address)(const godot_string *p_self);
	void (*godot_string_destroy)(godot_string *p_self);
	void (*godot_string_name_new)(godot_string_name *r_dest, const godot_string *p_name);
	void (*godot_string_name_new_data)(godot_string_name *r_dest, const char *p_name);
	godot_string (*godot_string_name_get_name)(const godot_string_name *p_self);
	uint32_t (*godot_string_name_get_hash)(const godot_string_name *p_self);
	const void *(*godot_string_name_get_data_unique_pointer)(const godot_string_name *p_self);
	godot_bool (*godot_string_name_operator_equal)(const godot_string_name *p_self, const godot_string_name *p_other);
	godot_bool (*godot_string_name_operator_less)(const godot_string_name *p_self, const godot_string_name *p_other);
	void (*godot_string_name_destroy)(godot_string_name *p_self);
	void (*godot_object_destroy)(godot_object *p_o);
	godot_object *(*godot_global_get_singleton)(const char *p_name);
	godot_method_bind *(*godot_method_bind_get_method)(const char *p_classname, const char *p_methodname);
	void (*godot_method_bind_ptrcall)(godot_method_bind *p_method_bind, godot_object *p_instance, const void **p_args, void *p_ret);
	godot_variant (*godot_method_bind_call)(godot_method_bind *p_method_bind, godot_object *p_instance, const godot_variant **p_args, const int p_arg_count, godot_variant_call_error *p_call_error);
	godot_class_constructor (*godot_get_class_constructor)(const char *p_classname);
	godot_dictionary (*godot_get_global_constants)();
	void (*godot_register_native_call_type)(const char *call_type, native_call_cb p_callback);
	void *(*godot_alloc)(int p_bytes);
	void *(*godot_realloc)(void *p_ptr, int p_bytes);
	void (*godot_free)(void *p_ptr);
	void (*godot_print_error)(const char *p_description, const char *p_function, const char *p_file, int p_line);
	void (*godot_print_warning)(const char *p_description, const char *p_function, const char *p_file, int p_line);
	void (*godot_print)(const godot_string *p_message);
} godot_gdnative_core_api_struct;

typedef struct godot_gdnative_core_1_1_api_struct {
	unsigned int type;
	godot_gdnative_api_version version;
	const godot_gdnative_api_struct *next;
	godot_int (*godot_color_to_abgr32)(const godot_color *p_self);
	godot_int (*godot_color_to_abgr64)(const godot_color *p_self);
	godot_int (*godot_color_to_argb64)(const godot_color *p_self);
	godot_int (*godot_color_to_rgba64)(const godot_color *p_self);
	godot_color (*godot_color_darkened)(const godot_color *p_self, const godot_real p_amount);
	godot_color (*godot_color_from_hsv)(const godot_color *p_self, const godot_real p_h, const godot_real p_s, const godot_real p_v, const godot_real p_a);
	godot_color (*godot_color_lightened)(const godot_color *p_self, const godot_real p_amount);
	godot_array (*godot_array_duplicate)(const godot_array *p_self, const godot_bool p_deep);
	godot_variant (*godot_array_max)(const godot_array *p_self);
	godot_variant (*godot_array_min)(const godot_array *p_self);
	void (*godot_array_shuffle)(godot_array *p_self);
	godot_basis (*godot_basis_slerp)(const godot_basis *p_self, const godot_basis *p_b, const godot_real p_t);
	godot_variant (*godot_dictionary_get_with_default)(const godot_dictionary *p_self, const godot_variant *p_key, const godot_variant *p_default);
	bool (*godot_dictionary_erase_with_return)(godot_dictionary *p_self, const godot_variant *p_key);
	godot_node_path (*godot_node_path_get_as_property_path)(const godot_node_path *p_self);
	void (*godot_quat_set_axis_angle)(godot_quat *p_self, const godot_vector3 *p_axis, const godot_real p_angle);
	godot_rect2 (*godot_rect2_grow_individual)(const godot_rect2 *p_self, const godot_real p_left, const godot_real p_top, const godot_real p_right, const godot_real p_bottom);
	godot_rect2 (*godot_rect2_grow_margin)(const godot_rect2 *p_self, const godot_int p_margin, const godot_real p_by);
	godot_rect2 (*godot_rect2_abs)(const godot_rect2 *p_self);
	godot_string (*godot_string_dedent)(const godot_string *p_self);
	godot_string (*godot_string_trim_prefix)(const godot_string *p_self, const godot_string *p_prefix);
	godot_string (*godot_string_trim_suffix)(const godot_string *p_self, const godot_string *p_suffix);
	godot_string (*godot_string_rstrip)(const godot_string *p_self, const godot_string *p_chars);
	godot_pool_string_array (*godot_string_rsplit)(const godot_string *p_self, const godot_string *p_divisor, const godot_bool p_allow_empty, const godot_int p_maxsplit);
	godot_quat (*godot_basis_get_quat)(const godot_basis *p_self);
	void (*godot_basis_set_quat)(godot_basis *p_self, const godot_quat *p_quat);
	void (*godot_basis_set_axis_angle_scale)(godot_basis *p_self, const godot_vector3 *p_axis, godot_real p_phi, const godot_vector3 *p_scale);
	void (*godot_basis_set_euler_scale)(godot_basis *p_self, const godot_vector3 *p_euler, const godot_vector3 *p_scale);
	void (*godot_basis_set_quat_scale)(godot_basis *p_self, const godot_quat *p_quat, const godot_vector3 *p_scale);
	bool (*godot_is_instance_valid)(const godot_object *p_object);
	void (*godot_quat_new_with_basis)(godot_quat *r_dest, const godot_basis *p_basis);
	void (*godot_quat_new_with_euler)(godot_quat *r_dest, const godot_vector3 *p_euler);
	void (*godot_transform_new_with_quat)(godot_transform *r_dest, const godot_quat *p_quat);
	godot_string (*godot_variant_get_operator_name)(godot_variant_operator p_op);
	void (*godot_variant_evaluate)(godot_variant_operator p_op, const godot_variant *p_a, const godot_variant *p_b, godot_variant *r_ret, godot_bool *r_valid);
} godot_gdnative_core_1_1_api_struct;

typedef struct godot_gdnative_core_1_2_api_struct {
	unsigned int type;
	godot_gdnative_api_version version;
	const godot_gdnative_api_struct *next;
	godot_dictionary (*godot_dictionary_duplicate)(const godot_dictionary *p_self, const godot_bool p_deep);
	godot_vector3 (*godot_vector3_move_toward)(const godot_vector3 *p_self, const godot_vector3 *p_to, const godot_real p_delta);
	godot_vector2 (*godot_vector2_move_toward)(const godot_vector2 *p_self, const godot_vector2 *p_to, const godot_real p_delta);
	godot_int (*godot_string_count)(const godot_string *p_self, godot_string p_what, godot_int p_from, godot_int p_to);
	godot_int (*godot_string_countn)(const godot_string *p_self, godot_string p_what, godot_int p_from, godot_int p_to);
	godot_vector3 (*godot_vector3_direction_to)(const godot_vector3 *p_self, const godot_vector3 *p_to);
	godot_vector2 (*godot_vector2_direction_to)(const godot_vector2 *p_self, const godot_vector2 *p_to);
	godot_array (*godot_array_slice)(const godot_array *p_self, const godot_int p_begin, const godot_int p_end, const godot_int p_step, const godot_bool p_deep);
	godot_bool (*godot_pool_byte_array_empty)(const godot_pool_byte_array *p_self);
	godot_bool (*godot_pool_int_array_empty)(const godot_pool_int_array *p_self);
	godot_bool (*godot_pool_real_array_empty)(const godot_pool_real_array *p_self);
	godot_bool (*godot_pool_string_array_empty)(const godot_pool_string_array *p_self);
	godot_bool (*godot_pool_vector2_array_empty)(const godot_pool_vector2_array *p_self);
	godot_bool (*godot_pool_vector3_array_empty)(const godot_pool_vector3_array *p_self);
	godot_bool (*godot_pool_color_array_empty)(const godot_pool_color_array *p_self);
	void *(*godot_get_class_tag)(const godot_string_name *p_class);
	godot_object *(*godot_object_cast_to)(const godot_object *p_object, void *p_class_tag);
	godot_object *(*godot_instance_from_id)(godot_int p_instance_id);
} godot_gdnative_core_1_2_api_struct;

typedef struct godot_gdnative_core_1_3_api_struct {
	unsigned int type;
	godot_gdnative_api_version version;
	const godot_gdnative_api_struct *next;
	void (*godot_dictionary_merge)(godot_dictionary *p_self, const godot_dictionary *p_dictionary, const godot_bool p_overwrite);
	godot_bool (*godot_pool_byte_array_has)(const godot_pool_byte_array *p_self, const uint8_t p_data);
	void (*godot_pool_byte_array_sort)(godot_pool_byte_array *p_self);
	godot_bool (*godot_pool_int_array_has)(const godot_pool_int_array *p_self, const godot_int p_data);
	void (*godot_pool_int_array_sort)(godot_pool_int_array *p_self);
	godot_bool (*godot_pool_real_array_has)(const godot_pool_real_array *p_self, const godot_real p_data);
	void (*godot_pool_real_array_sort)(godot_pool_real_array *p_self);
	godot_bool (*godot_pool_string_array_has)(const godot_pool_string_array *p_self, const godot_string *p_data);
	godot_string (*godot_pool_string_array_join)(const godot_pool_string_array *p_self, const godot_string *p_delimiter);
	void (*godot_pool_string_array_sort)(godot_pool_string_array *p_self);
	godot_bool (*godot_pool_vector2_array_has)(const godot_pool_vector2_array *p_self, const godot_vector2 *p_data);
	void (*godot_pool_vector2_array_sort)(godot_pool_vector2_array *p_self);
	godot_bool (*godot_pool_vector3_array_has)(const godot_pool_vector3_array *p_self, const godot_vector3 *p_data);
	void (*godot_pool_vector3_array_sort)(godot_pool_vector3_array *p_self);
	godot_bool (*godot_pool_color_array_has)(const godot_pool_color_array *p_self, const godot_color *p_data);
	void (*godot_pool_color_array_sort)(godot_pool_color_array *p_self);
	godot_string (*godot_string_join)(const godot_string *p_self, const godot_array *p_parts);
	godot_string (*godot_string_num_uint64)(uint64_t p_num, godot_int p_base);
	godot_string (*godot_string_num_uint64_capitalized)(uint64_t p_num, godot_int p_base, godot_bool p_capitalize_hex);
} godot_gdnative_core_1_3_api_struct;

// PluginScript
typedef void godot_pluginscript_instance_data;
typedef void godot_pluginscript_script_data;
typedef void godot_pluginscript_language_data;

typedef struct godot_property_attributes {
	godot_method_rpc_mode rset_type;

	godot_int type;
	godot_property_hint hint;
	godot_string hint_string;
	godot_property_usage_flags usage;
	godot_variant default_value;
} godot_property_attributes;

typedef struct godot_pluginscript_instance_desc {
	godot_pluginscript_instance_data *(*init)(godot_pluginscript_script_data *p_data, godot_object *p_owner);
	void (*finish)(godot_pluginscript_instance_data *p_data);
	godot_bool (*set_prop)(godot_pluginscript_instance_data *p_data, const godot_string *p_name, const godot_variant *p_value);
	godot_bool (*get_prop)(godot_pluginscript_instance_data *p_data, const godot_string *p_name, godot_variant *r_ret);
	godot_variant (*call_method)(godot_pluginscript_instance_data *p_data, const godot_string_name *p_method, const godot_variant **p_args, int p_argcount, godot_variant_call_error *r_error);
	void (*notification)(godot_pluginscript_instance_data *p_data, int p_notification);
	godot_method_rpc_mode (*get_rpc_mode)(godot_pluginscript_instance_data *p_data, const godot_string *p_method);
	godot_method_rpc_mode (*get_rset_mode)(godot_pluginscript_instance_data *p_data, const godot_string *p_variable);
	void (*refcount_incremented)(godot_pluginscript_instance_data *p_data);
	bool (*refcount_decremented)(godot_pluginscript_instance_data *p_data); // return true if it can die
} godot_pluginscript_instance_desc;

typedef struct godot_pluginscript_script_manifest {
	godot_pluginscript_script_data *data;
	godot_string_name name;
	godot_bool is_tool;
	godot_string_name base;
	godot_dictionary member_lines;
	godot_array methods;
	godot_array signals;
	godot_array properties;
} godot_pluginscript_script_manifest;

typedef struct godot_pluginscript_script_desc {
	godot_pluginscript_script_manifest (*init)(godot_pluginscript_language_data *p_data, const godot_string *p_path, const godot_string *p_source, godot_error *r_error);
	void (*finish)(godot_pluginscript_script_data *p_data);
	godot_pluginscript_instance_desc instance_desc;
} godot_pluginscript_script_desc;

typedef struct godot_pluginscript_profiling_data {
	godot_string_name signature;
	godot_int call_count;
	godot_int total_time; // In microseconds
	godot_int self_time; // In microseconds
} godot_pluginscript_profiling_data;

typedef struct godot_pluginscript_language_desc {
	const char *name;
	const char *type;
	const char *extension;
	const char **recognized_extensions; // NULL terminated array
	godot_pluginscript_language_data *(*init)();
	void (*finish)(godot_pluginscript_language_data *p_data);
	const char **reserved_words; // NULL terminated array
	const char **comment_delimiters; // NULL terminated array
	const char **string_delimiters; // NULL terminated array
	godot_bool has_named_classes;
	godot_bool supports_builtin_mode;
	godot_string (*get_template_source_code)(godot_pluginscript_language_data *p_data, const godot_string *p_class_name, const godot_string *p_base_class_name);
	godot_bool (*validate)(godot_pluginscript_language_data *p_data, const godot_string *p_script, int *r_line_error, int *r_col_error, godot_string *r_test_error, const godot_string *p_path, godot_pool_string_array *r_functions);
	int (*find_function)(godot_pluginscript_language_data *p_data, const godot_string *p_function, const godot_string *p_code); // Can be NULL
	godot_string (*make_function)(godot_pluginscript_language_data *p_data, const godot_string *p_class, const godot_string *p_name, const godot_pool_string_array *p_args);
	godot_error (*complete_code)(godot_pluginscript_language_data *p_data, const godot_string *p_code, const godot_string *p_path, godot_object *p_owner, godot_array *r_options, godot_bool *r_force, godot_string *r_call_hint);
	void (*auto_indent_code)(godot_pluginscript_language_data *p_data, godot_string *p_code, int p_from_line, int p_to_line);
	void (*add_global_constant)(godot_pluginscript_language_data *p_data, const godot_string *p_variable, const godot_variant *p_value);
	godot_string (*debug_get_error)(godot_pluginscript_language_data *p_data);
	int (*debug_get_stack_level_count)(godot_pluginscript_language_data *p_data);
	int (*debug_get_stack_level_line)(godot_pluginscript_language_data *p_data, int p_level);
	godot_string (*debug_get_stack_level_function)(godot_pluginscript_language_data *p_data, int p_level);
	godot_string (*debug_get_stack_level_source)(godot_pluginscript_language_data *p_data, int p_level);
	void (*debug_get_stack_level_locals)(godot_pluginscript_language_data *p_data, int p_level, godot_pool_string_array *p_locals, godot_array *p_values, int p_max_subitems, int p_max_depth);
	void (*debug_get_stack_level_members)(godot_pluginscript_language_data *p_data, int p_level, godot_pool_string_array *p_members, godot_array *p_values, int p_max_subitems, int p_max_depth);
	void (*debug_get_globals)(godot_pluginscript_language_data *p_data, godot_pool_string_array *p_locals, godot_array *p_values, int p_max_subitems, int p_max_depth);
	godot_string (*debug_parse_stack_level_expression)(godot_pluginscript_language_data *p_data, int p_level, const godot_string *p_expression, int p_max_subitems, int p_max_depth);
	void (*get_public_functions)(godot_pluginscript_language_data *p_data, godot_array *r_functions);
	void (*get_public_constants)(godot_pluginscript_language_data *p_data, godot_dictionary *r_constants);
	void (*profiling_start)(godot_pluginscript_language_data *p_data);
	void (*profiling_stop)(godot_pluginscript_language_data *p_data);
	int (*profiling_get_accumulated_data)(godot_pluginscript_language_data *p_data, godot_pluginscript_profiling_data *r_info, int p_info_max);
	int (*profiling_get_frame_data)(godot_pluginscript_language_data *p_data, godot_pluginscript_profiling_data *r_info, int p_info_max);
	void (*profiling_frame)(godot_pluginscript_language_data *p_data);
	godot_pluginscript_script_desc script_desc;
} godot_pluginscript_language_desc;
]]

local pluginscript_callbacks, in_editor, api, api_1_1, api_1_2, api_1_3, gdnativelibrary = ...

api = ffi.cast('godot_gdnative_core_api_struct *', api)
api_1_1 = ffi.cast('godot_gdnative_core_1_1_api_struct *', api_1_1)
api_1_2 = ffi.cast('godot_gdnative_core_1_2_api_struct *', api_1_2)
api_1_3 = ffi.cast('godot_gdnative_core_1_3_api_struct *', api_1_3)
gdnativelibrary = ffi.cast('godot_object *', gdnativelibrary)
