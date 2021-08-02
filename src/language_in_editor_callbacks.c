#include "language_gdnative.h"

void (*lps_get_template_source_code_cb)(const godot_string *class_name, const godot_string *base_class_name, godot_string *ret);

godot_string lps_get_template_source_code(godot_pluginscript_language_data *data, const godot_string *class_name, const godot_string *base_class_name) {
	godot_string ret;
	lps_get_template_source_code_cb(class_name, base_class_name, &ret);
	return ret;
}

void lps_register_in_editor_callbacks(godot_pluginscript_language_desc *desc) {
	desc->get_template_source_code = &lps_get_template_source_code;
}

