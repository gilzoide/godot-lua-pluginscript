#ifndef __LPS_LANGUAGE_GDNATIVE_H__
#define __LPS_LANGUAGE_GDNATIVE_H__

#include "hgdn.h"

extern const char LUA_INIT_SCRIPT[];

// Language callbacks, to be patched in Lua via FFI
extern void (*lps_language_add_global_constant_cb)(const godot_string *name, const godot_variant *value);
extern godot_error (*lps_script_init_cb)(godot_pluginscript_script_manifest *data, const godot_string *path, const godot_string *source);
extern void (*lps_script_finish_cb)(godot_pluginscript_script_data *data);
extern godot_pluginscript_instance_data *(*lps_instance_init_cb)(godot_pluginscript_script_data *data, godot_object *owner);
extern void (*lps_instance_finish_cb)(godot_pluginscript_instance_data *data);
extern godot_bool (*lps_instance_set_prop_cb)(godot_pluginscript_instance_data *data, const godot_string *name, const godot_variant *value);
extern godot_bool (*lps_instance_get_prop_cb)(godot_pluginscript_instance_data *data, const godot_string *name, godot_variant *ret);
extern void (*lps_instance_call_method_cb)(godot_pluginscript_instance_data *data, const godot_string_name *method, const godot_variant **args, int argcount, godot_variant *ret, godot_variant_call_error *error);
extern void (*lps_instance_notification_cb)(godot_pluginscript_instance_data *data, int notification);

// In editor callbacks
void lps_register_in_editor_callbacks(godot_pluginscript_language_desc *desc);

extern void (*lps_get_template_source_code_cb)(const godot_string *class_name, const godot_string *base_class_name, godot_string *ret);

#endif
