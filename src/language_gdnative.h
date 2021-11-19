#ifndef __LPS_LANGUAGE_GDNATIVE_H__
#define __LPS_LANGUAGE_GDNATIVE_H__

#define HGDN_STATIC
#define HGDN_NO_EXT_NATIVESCRIPT
#define HGDN_NO_EXT_ANDROID
#define HGDN_NO_EXT_ARVR
#define HGDN_NO_EXT_VIDEOCODER
#define HGDN_NO_EXT_NET
#include "hgdn.h"

extern const char LUA_INIT_SCRIPT[];
extern const size_t LUA_INIT_SCRIPT_SIZE;

// In editor callbacks
void lps_register_in_editor_callbacks(godot_pluginscript_language_desc *desc);

extern void (*lps_get_template_source_code_cb)(const godot_string *class_name, const godot_string *base_class_name, godot_string *ret);
extern godot_bool (*lps_validate_cb)(const godot_string *script, int *line_error, int *col_error, godot_string *test_error, const godot_string *path, godot_pool_string_array *functions);
// Same caveat as `lps_script_init_cb`
extern void (*lps_make_function_cb)(const godot_string *class_name, const godot_string *name, const godot_pool_string_array *args, godot_string *ret);
extern int (*lps_find_function_cb)(const godot_string *function_name, const godot_string *code);

#endif
