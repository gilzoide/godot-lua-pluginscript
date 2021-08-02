#include "language_gdnative.h"

void (*lps_get_template_source_code_cb)(const godot_string *class_name, const godot_string *base_class_name, godot_string *ret);
godot_bool (*lps_validate_cb)(const godot_string *script, int *line_error, int *col_error, godot_string *test_error, const godot_string *path, godot_pool_string_array *functions);

godot_string lps_get_template_source_code(godot_pluginscript_language_data *data, const godot_string *class_name, const godot_string *base_class_name) {
	godot_string ret;
	lps_get_template_source_code_cb(class_name, base_class_name, &ret);
	return ret;
}

godot_bool lps_validate(godot_pluginscript_language_data *data, const godot_string *script, int *line_error, int *col_error, godot_string *test_error, const godot_string *path, godot_pool_string_array *functions) {
	return lps_validate_cb(script, line_error, col_error, test_error, path, functions);
}

void lps_register_in_editor_callbacks(godot_pluginscript_language_desc *desc) {
	desc->get_template_source_code = &lps_get_template_source_code;
	desc->validate = &lps_validate;
}

