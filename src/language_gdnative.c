/**
 * @file language_gdnative.c  GDNative + PluginScript callbacks
 * This file is part of Godot Lua PluginScript: https://github.com/gilzoide/godot-lua-pluginscript
 *
 * Copyright (C) 2021 Gil Barbosa Reis.
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the “Software”), to
 * deal in the Software without restriction, including without limitation the
 * rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
 * sell copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
 * IN THE SOFTWARE.
 */
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"

#include "language_gdnative.h"

#define HGDN_IMPLEMENTATION
#include "hgdn.h"

#define PLUGINSCRIPT_CALLBACKS_KEY "lps_callbacks"
#define lps_push_callback(L, name) \
	lua_getfield(L, LUA_REGISTRYINDEX, PLUGINSCRIPT_CALLBACKS_KEY), \
	lua_getfield(L, -1, name), \
	lua_remove(L, -2)

// Active shared library path, for loading symbols in FFI
static hgdn_string lps_active_library_path;
static bool in_editor;
static lua_State *lps_L;

// Language functions
static void *lps_alloc(void *userdata, void *ptr, size_t osize, size_t nsize) {
	if (nsize == 0) {
		hgdn_free(ptr);
		return NULL;
	}
	else {
		return hgdn_realloc(ptr, nsize);
	}
}

static int lps_atpanic(lua_State *L) {
	luaL_traceback(L, L, lua_tostring(L, -1), 0);
	const char *error_msg_plus_traceback = lua_tostring(L, -1);
	HGDN_PRINT_ERROR("LUA PANIC: %s", error_msg_plus_traceback);
	return 1;
}

static int lps_lua_touserdata(lua_State *L) {
	const void *ptr = lua_topointer(L, 1);
	lua_pushlightuserdata(L, (void *) ptr);
	return 1;
}

static int lps_lua_setthreadfunc(lua_State *L) {
	lua_State *co = lua_tothread(L, 1);
	if (co) {
		lua_settop(co, 0);
		// return reused thread
		lua_pushvalue(L, 1);
	}
	else {
		co = lua_newthread(L);
	}
	// move callable argument to the new/reused thread
	lua_pushvalue(L, 2);
	lua_xmove(L, co, 1);
	return 1;
}

static int lps_lua_string_replace(lua_State *L) {
	const char *s = luaL_checkstring(L, 1);
	const char *p = luaL_checkstring(L, 2);
	const char *r = luaL_checkstring(L, 3);
	luaL_gsub(L, s, p, r);
	return 1;
}

#ifdef DEBUG
static int lps_pcall_error_handler(lua_State *L) {
	luaL_traceback(L, L, lua_tostring(L, 1), 0);
	return 1;
}
#endif

static godot_pluginscript_language_data *lps_language_init() {
	lua_State *L = lps_L = lua_newstate(&lps_alloc, NULL);
	lua_atpanic(L, &lps_atpanic);
	luaL_openlibs(L);
	lua_register(L, "touserdata", &lps_lua_touserdata);
	lua_register(L, "setthreadfunc", &lps_lua_setthreadfunc);
	// string.replace = &lps_lua_string_replace
	lua_getglobal(L, "string");
	lua_pushcfunction(L, &lps_lua_string_replace);
	lua_setfield(L, -2, "replace");
	lua_pop(L, 1);  // pop string

	if (luaL_loadbufferx(L, LUA_INIT_SCRIPT, LUA_INIT_SCRIPT_SIZE - 1, "lps_init_script", "t") != LUA_OK) {
		const char *error_msg = lua_tostring(L, -1);
		HGDN_PRINT_ERROR("Error loading initialization script: %s", error_msg);
		return L;
	}
#ifdef DEBUG
	lua_pushcfunction(L, &lps_pcall_error_handler);
	const int err_handler_index = lua_gettop(L);
	lua_pushvalue(L, -2);
#else
	const int err_handler_index = 0;
#endif
	lua_createtable(L, 0, 9);
	lua_pushvalue(L, -1);
	lua_setfield(L, LUA_REGISTRYINDEX, PLUGINSCRIPT_CALLBACKS_KEY);

	lua_pushlstring(L, lps_active_library_path.ptr, lps_active_library_path.length);
	lua_pushboolean(L, in_editor);
	if (lua_pcall(L, 3, 1, err_handler_index) != LUA_OK) {
		const char *error_msg = lua_tostring(L, -1);
		HGDN_PRINT_ERROR("Error running initialization script: %s", error_msg);
	}
#ifdef DEBUG
	lua_pop(L, 2);
#endif
	return L;
}

static void lps_language_finish(godot_pluginscript_language_data *data) {
	lua_close((lua_State *) data);
	lps_L = NULL;
}

static void lps_language_add_global_constant(godot_pluginscript_language_data *data, const godot_string *name, const godot_variant *value) {
	lps_push_callback(lps_L, "language_add_global_constant");
	lua_pushlightuserdata(lps_L, (void *) name);
	lua_pushlightuserdata(lps_L, (void *) value);
	lua_pcall(lps_L, 2, 0, 0);
}

// Script manifest
static godot_pluginscript_script_manifest lps_script_init(godot_pluginscript_language_data *data, const godot_string *path, const godot_string *source, godot_error *error) {
	godot_pluginscript_script_manifest manifest = {
		.data = NULL,
		.is_tool = false,
	};
	hgdn_core_api->godot_string_name_new_data(&manifest.name, "");
	hgdn_core_api->godot_string_name_new_data(&manifest.base, "");
	hgdn_core_api->godot_dictionary_new(&manifest.member_lines);
	hgdn_core_api->godot_array_new(&manifest.methods);
	hgdn_core_api->godot_array_new(&manifest.signals);
	hgdn_core_api->godot_array_new(&manifest.properties);

	godot_error cb_error = GODOT_ERR_SCRIPT_FAILED;
	lps_push_callback(lps_L, "script_init");
	lua_pushlightuserdata(lps_L, (void *) &manifest);
	lua_pushlightuserdata(lps_L, (void *) path);
	lua_pushlightuserdata(lps_L, (void *) source);
	lua_pushlightuserdata(lps_L, (void *) &cb_error);
	lua_pcall(lps_L, 4, 0, 0);
	if (error) {
		*error = cb_error;
	}

	return manifest;
}

static void lps_script_finish(godot_pluginscript_script_data *data) {
	lps_push_callback(lps_L, "script_finish");
	lua_pushlightuserdata(lps_L, (void *) data);
	lua_pcall(lps_L, 1, 0, 0);
}


// Instance
static godot_pluginscript_instance_data *lps_instance_init(godot_pluginscript_script_data *data, godot_object *owner) {
	lps_push_callback(lps_L, "instance_init");
	lua_pushlightuserdata(lps_L, (void *) data);
	lua_pushlightuserdata(lps_L, (void *) owner);
	if (lua_pcall(lps_L, 2, 0, 0) == LUA_OK) {
		return owner;
	}
	return NULL;
}

static void lps_instance_finish(godot_pluginscript_instance_data *data) {
	lps_push_callback(lps_L, "instance_finish");
	lua_pushlightuserdata(lps_L, (void *) data);
	lua_pcall(lps_L, 1, 0, 0);
}

static godot_bool lps_instance_set_prop(godot_pluginscript_instance_data *data, const godot_string *name, const godot_variant *value) {
	lps_push_callback(lps_L, "instance_set_prop");
	lua_pushlightuserdata(lps_L, (void *) data);
	lua_pushlightuserdata(lps_L, (void *) name);
	lua_pushlightuserdata(lps_L, (void *) value);
	if (lua_pcall(lps_L, 3, 1, 0) != LUA_OK) {
		return false;
	}
	godot_bool ret = lua_toboolean(lps_L, -1);
	lua_pop(lps_L, 1);
	return ret;
}

static godot_bool lps_instance_get_prop(godot_pluginscript_instance_data *data, const godot_string *name, godot_variant *value_ret) {
	lps_push_callback(lps_L, "instance_get_prop");
	lua_pushlightuserdata(lps_L, (void *) data);
	lua_pushlightuserdata(lps_L, (void *) name);
	lua_pushlightuserdata(lps_L, (void *) value_ret);
	if (lua_pcall(lps_L, 3, 1, 0) != LUA_OK) {
		return false;
	}
	godot_bool ret = lua_toboolean(lps_L, -1);
	lua_pop(lps_L, 1);
	return ret;
}

static godot_variant lps_instance_call_method(godot_pluginscript_instance_data *data, const godot_string_name *method, const godot_variant **args, int argcount, godot_variant_call_error *error) {
	godot_variant var = hgdn_new_nil_variant();
	if (error) {
		error->error = GODOT_CALL_ERROR_CALL_ERROR_INVALID_METHOD;
	}
	lps_push_callback(lps_L, "instance_call_method");
	lua_pushlightuserdata(lps_L, (void *) data);
	lua_pushlightuserdata(lps_L, (void *) method);
	lua_pushlightuserdata(lps_L, (void *) args);
	lua_pushinteger(lps_L, argcount);
	lua_pushlightuserdata(lps_L, (void *) &var);
	lua_pushlightuserdata(lps_L, (void *) error);
	lua_pcall(lps_L, 6, 0, 0);
	return var;
}

static void lps_instance_notification(godot_pluginscript_instance_data *data, int notification) {
	lps_push_callback(lps_L, "instance_notification");
	lua_pushlightuserdata(lps_L, (void *) data);
	lua_pushinteger(lps_L, notification);
	lua_pcall(lps_L, 2, 0, 0);
}

static godot_pluginscript_language_desc lps_language_desc = {
	.name = "Lua",
	.type = "Lua",
	.extension = "lua",
	.recognized_extensions = (const char *[]){ "lua", NULL },
	.init = &lps_language_init,
	.finish = &lps_language_finish,
	.reserved_words = (const char *[]){
		// Lua keywords
		"and", "break", "do", "else", "elseif", "end",
		"false", "for", "function", "goto", "if", "in",
		"local", "nil", "not", "or", "repeat", "return",
		"then", "true", "until", "while",
		// Other remarkable identifiers
		"self", "_G", "_VERSION",
#if LUA_VERSION_NUM >= 502
		"_ENV",
#endif
		"bool", "int", "float",
		NULL
	},
	.comment_delimiters = (const char *[]){ "--", "--[[ ]]", NULL },
	.string_delimiters = (const char *[]){ "' '", "\" \"", "[[ ]]", "[=[ ]=]", NULL },
	.has_named_classes = false,
	.supports_builtin_mode = false,
	.add_global_constant = &lps_language_add_global_constant,

	.script_desc = {
		.init = &lps_script_init,
		.finish = &lps_script_finish,
		.instance_desc = {
			.init = &lps_instance_init,
			.finish = &lps_instance_finish,
			.set_prop = &lps_instance_set_prop,
			.get_prop = &lps_instance_get_prop,
			.call_method = &lps_instance_call_method,
			.notification = &lps_instance_notification,
		},
	},
};

#define PREFIX_SYMBOL(s) lps_ ## s

// GDNative functions
GDN_EXPORT void PREFIX_SYMBOL(gdnative_init)(godot_gdnative_init_options *options) {
	hgdn_gdnative_init(options);

	if (!hgdn_pluginscript_api) {
		HGDN_PRINT_ERROR("PluginScript is not supported!");
		return;
	}

	in_editor = options->in_editor;
	if (in_editor) {
		lps_register_in_editor_callbacks(&lps_language_desc);
	}

	godot_object *OS = hgdn_core_api->godot_global_get_singleton("OS");
	if (hgdn_variant_get_bool_own(hgdn_object_call(OS, "has_feature", "standalone"))) {
		godot_variant exepath_var = hgdn_object_callv(OS, "get_executable_path", NULL);
		godot_string exepath = hgdn_core_api->godot_variant_as_string(&exepath_var);
		godot_string exedir = hgdn_core_api->godot_string_get_base_dir(&exepath);
		godot_string library_filepath = hgdn_core_api->godot_string_get_file(options->active_library_path);
		lps_active_library_path = hgdn_string_get_own(hgdn_core_api->godot_string_plus_file(&exedir, &library_filepath));
		hgdn_core_api->godot_string_destroy(&library_filepath);
		hgdn_core_api->godot_string_destroy(&exedir);
		hgdn_core_api->godot_string_destroy(&exepath);
		hgdn_core_api->godot_variant_destroy(&exepath_var);
	}
	else {
		lps_active_library_path = hgdn_string_get(options->active_library_path);
	}

	hgdn_pluginscript_api->godot_pluginscript_register_language(&lps_language_desc);
}

GDN_EXPORT void PREFIX_SYMBOL(gdnative_terminate)(godot_gdnative_terminate_options *options) {
	hgdn_string_destroy(&lps_active_library_path);
	hgdn_gdnative_terminate(options);
}

GDN_EXPORT void PREFIX_SYMBOL(gdnative_singleton)() {
}
