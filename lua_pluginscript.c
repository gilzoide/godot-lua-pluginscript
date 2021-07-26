#define HGDN_STATIC
#define HGDN_IMPLEMENTATION
#include "hgdn.h"
#include "lua.h"

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

godot_pluginscript_language_data *lps_language_init() {
    return lua_newstate(&lps_alloc, NULL);
}

void lps_language_finish(godot_pluginscript_language_data *data) {
    lua_close((lua_State *) data);
}

void lps_language_add_global_constant(godot_pluginscript_language_data *p_data, const godot_string *p_variable, const godot_variant *p_value) {
    // TODO
}

// Script manifest
godot_pluginscript_script_manifest lps_script_init(godot_pluginscript_language_data *data, const godot_string *path, const godot_string *source, godot_error *error) {
    godot_pluginscript_script_manifest manifest;
    manifest.data = data;
    hgdn_core_api->godot_string_name_new_data(&manifest.name, "");
    hgdn_core_api->godot_string_name_new_data(&manifest.base, "Reference");
    hgdn_core_api->godot_dictionary_new(&manifest.member_lines);
    hgdn_core_api->godot_array_new(&manifest.methods);
    hgdn_core_api->godot_array_new(&manifest.signals);
    hgdn_core_api->godot_array_new(&manifest.properties);

    // TODO

    return manifest;
}

void lps_script_finish(godot_pluginscript_script_data *data) {
    // TODO
}


// Instance
godot_pluginscript_instance_data *lps_instance_init(godot_pluginscript_script_data *data, godot_object *owner) {
    // PluginScript system assumes NULL is an error
    return data;
}

void lps_instance_finish(godot_pluginscript_instance_data *data) {
}

godot_bool lps_instance_set_prop(godot_pluginscript_instance_data *data, const godot_string *name, const godot_variant *value) {
    // TODO
    return false;
}

godot_bool lps_instance_get_prop(godot_pluginscript_instance_data *data, const godot_string *name, godot_variant *ret) {
    // TODO
    return false;
}

godot_variant lps_instance_call_method(godot_pluginscript_instance_data *p_data,
        const godot_string_name *p_method, const godot_variant **p_args,
        int p_argcount, godot_variant_call_error *r_error) {
    // TODO
    return hgdn_new_nil_variant();
}

void lps_instance_notification(godot_pluginscript_instance_data *p_data, int p_notification) {
    // TODO
}

// GDNative functions

    godot_pluginscript_language_desc lua_desc = {
        .name = "Lua",
        .type = "Lua",
        .extension = "lua",
        .recognized_extensions = (const char *[]){ "lua", NULL },
        .init = &lps_language_init,
        .finish = &lps_language_finish,
        .reserved_words = (const char *[]){
            "and", "break", "do", "else", "elseif", "end",
            "false", "for", "function", "goto", "if", "in",
            "local", "nil", "not", "or", "repeat", "return",
            "then", "true", "until", "while",
            NULL
        },
        .comment_delimiters = (const char *[]){ "--", "--[[ ]]", NULL },
        .string_delimiters = (const char *[]){ "' '", "\" \"", "[[ ]]", "[=[ ]=]", NULL },
        .has_named_classes = false,
        .supports_builtin_mode = true,
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
GDN_EXPORT void godot_gdnative_init(godot_gdnative_init_options *options) {
    hgdn_gdnative_init(options);

    if (!hgdn_pluginscript_api) {
        HGDN_PRINT_ERROR("PluginScript is not supported!");
        return;
    }

    hgdn_pluginscript_api->godot_pluginscript_register_language(&lua_desc);
}

GDN_EXPORT void godot_gdnative_terminate(godot_gdnative_terminate_options *options) {
    hgdn_gdnative_terminate(options);
}

GDN_EXPORT void godot_gdnative_singleton() {
}
