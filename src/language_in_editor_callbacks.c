/**
 * @file language_in_editor_callbacks.c  Editor + Debug PluginScript callbacks
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

