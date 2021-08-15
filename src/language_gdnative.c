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

// Callbacks definition
void (*lps_language_add_global_constant_cb)(const godot_string *name, const godot_variant *value);
godot_error (*lps_script_init_cb)(godot_pluginscript_script_manifest *data, const godot_string *path, const godot_string *source);
void (*lps_script_finish_cb)(godot_pluginscript_script_data *data);
godot_pluginscript_instance_data *(*lps_instance_init_cb)(godot_pluginscript_script_data *data, godot_object *owner);
void (*lps_instance_finish_cb)(godot_pluginscript_instance_data *data);
godot_bool (*lps_instance_set_prop_cb)(godot_pluginscript_instance_data *data, const godot_string *name, const godot_variant *value);
godot_bool (*lps_instance_get_prop_cb)(godot_pluginscript_instance_data *data, const godot_string *name, godot_variant *ret);
void (*lps_instance_call_method_cb)(godot_pluginscript_instance_data *data, const godot_string_name *method, const godot_variant **args, int argcount, godot_variant *ret, godot_variant_call_error *error);
void (*lps_instance_notification_cb)(godot_pluginscript_instance_data *data, int notification);

// Active shared library path, for loading symbols in FFI
static hgdn_string lps_active_library_path;

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

static int lps_lua_touserdata(lua_State *L) {
	const void *ptr = lua_topointer(L, 1);
	lua_pushlightuserdata(L, (void *) ptr);
	return 1;
}

static int lps_lua_set_thread_func(lua_State *L) {
	lua_State *co;
	if (lua_isthread(L, 1)) {
		co = lua_tothread(L, 1);
		lua_settop(co, 0);
		lua_pushvalue(L, 1);
	}
	else {
		co = lua_newthread(L);
	}
	lua_pushvalue(L, 2);
	lua_xmove(L, co, 1);
	return 1;
}

static godot_pluginscript_language_data *lps_language_init() {
	lua_State *L = lua_newstate(&lps_alloc, NULL);
	lua_register(L, "touserdata", &lps_lua_touserdata);
	lua_register(L, "setthreadfunc", &lps_lua_set_thread_func);
	luaL_openlibs(L);
	if (luaL_loadstring(L, LUA_INIT_SCRIPT) != 0) {
		const char *error_msg = lua_tostring(L, -1);
		HGDN_PRINT_ERROR("Error loading initialization script: %s", error_msg);
		return L;
	}
	lua_pushlstring(L, lps_active_library_path.ptr, lps_active_library_path.length);
	if (lua_pcall(L, 1, 0, 0) != 0) {
		const char *error_msg = lua_tostring(L, -1);
		HGDN_PRINT_ERROR("Error running initialization script: %s", error_msg);
	}
	return L;
}

static void lps_language_finish(godot_pluginscript_language_data *data) {
	lua_close((lua_State *) data);
}

static void lps_language_add_global_constant(godot_pluginscript_language_data *data, const godot_string *name, const godot_variant *value) {
	lps_language_add_global_constant_cb(name, value);
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

	godot_error ret = lps_script_init_cb(&manifest, path, source);
	if (error) {
		*error = ret;
	}

	return manifest;
}

static void lps_script_finish(godot_pluginscript_script_data *data) {
	lps_script_finish_cb(data);
}


// Instance
static godot_pluginscript_instance_data *lps_instance_init(godot_pluginscript_script_data *data, godot_object *owner) {
	return lps_instance_init_cb(data, owner);
}

static void lps_instance_finish(godot_pluginscript_instance_data *data) {
	lps_instance_finish_cb(data);
}

static godot_bool lps_instance_set_prop(godot_pluginscript_instance_data *data, const godot_string *name, const godot_variant *value) {
	return lps_instance_set_prop_cb(data, name, value);
}

static godot_bool lps_instance_get_prop(godot_pluginscript_instance_data *data, const godot_string *name, godot_variant *ret) {
	return lps_instance_get_prop_cb(data, name, ret);
}

static godot_variant lps_instance_call_method(godot_pluginscript_instance_data *data, const godot_string_name *method, const godot_variant **args, int argcount, godot_variant_call_error *error) {
	godot_variant var = hgdn_new_nil_variant();
	lps_instance_call_method_cb(data, method, args, argcount, &var, error);
	return var;
}

static void lps_instance_notification(godot_pluginscript_instance_data *data, int notification) {
	lps_instance_notification_cb(data, notification);
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

// GDNative functions
GDN_EXPORT void godot_gdnative_init(godot_gdnative_init_options *options) {
	hgdn_gdnative_init(options);

	if (!hgdn_pluginscript_api) {
		HGDN_PRINT_ERROR("PluginScript is not supported!");
		return;
	}

	if (options->in_editor) {
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

GDN_EXPORT void godot_gdnative_terminate(godot_gdnative_terminate_options *options) {
	hgdn_string_destroy(&lps_active_library_path);
	hgdn_gdnative_terminate(options);
}

GDN_EXPORT void godot_gdnative_singleton() {
}
