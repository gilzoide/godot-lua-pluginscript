// HGDN already includes godot-headers
#include "hgdn.h"

// Called when our language runtime will be initialized
godot_pluginscript_language_data *lps_language_init() {
    // TODO
    return NULL;
}

// Called when our language runtime will be terminated
void lps_language_finish(godot_pluginscript_language_data *data) {
    // TODO
}

// Called when Godot registers globals in the language, such as Autoload nodes
void lps_language_add_global_constant(godot_pluginscript_language_data *data, const godot_string *name, const godot_variant *value) {
    // TODO
}

// Called when a Lua script is loaded, e.g.: const SomeScript = preload("res://some_script.lua")
godot_pluginscript_script_manifest lps_script_init(godot_pluginscript_language_data *data, const godot_string *path, const godot_string *source, godot_error *error) {
    godot_pluginscript_script_manifest manifest = {};
    // All Godot objects must be initialized, or else our plugin SEGFAULTs
    hgdn_core_api->godot_string_name_new_data(&manifest.name, "");
    hgdn_core_api->godot_string_name_new_data(&manifest.base, "");
    hgdn_core_api->godot_dictionary_new(&manifest.member_lines);
    hgdn_core_api->godot_array_new(&manifest.methods);
    hgdn_core_api->godot_array_new(&manifest.signals);
    hgdn_core_api->godot_array_new(&manifest.properties);
    // TODO
    return manifest;
}

// Called when a Lua script is unloaded
void lps_script_finish(godot_pluginscript_script_data *data) {
    // TODO
}


// Called when a Script Instance is being created, e.g.: var instance = SomeScript.new()
godot_pluginscript_instance_data *lps_instance_init(godot_pluginscript_script_data *data, godot_object *owner) {
    // TODO
    return NULL;
}

// Called when a Script Instance is being finalized
void lps_instance_finish(godot_pluginscript_instance_data *data) {
    // TODO
}

// Called when setting a property on an instance, e.g.: instance.prop = value
godot_bool lps_instance_set_prop(godot_pluginscript_instance_data *data, const godot_string *name, const godot_variant *value) {
    // TODO
    return false;
}

// Called when getting a property on an instance, e.g.: var value = instance.prop
godot_bool lps_instance_get_prop(godot_pluginscript_instance_data *data, const godot_string *name, godot_variant *ret) {
    // TODO
    return false;
}

// Called when calling a method on an instance, e.g.: instance.method(args)
godot_variant lps_instance_call_method(godot_pluginscript_instance_data *data, const godot_string_name *method, const godot_variant **args, int argcount, godot_variant_call_error *error) {
    // TODO
    return hgdn_new_nil_variant();
}

// Called when a notification is sent to instance
void lps_instance_notification(godot_pluginscript_instance_data *data, int notification) {
    // TODO
}

// Declared as a global variable, because Godot needs the
// memory to be valid until our plugin is unloaded 
godot_pluginscript_language_desc lps_language_desc = {
    .name = "Lua",
    .type = "Lua",
    .extension = "lua",
    .recognized_extensions = (const char *[]){ "lua", NULL },
    .reserved_words = (const char *[]){
        // Lua keywords
        "and", "break", "do", "else", "elseif", "end",
        "false", "for", "function", "goto", "if", "in",
        "local", "nil", "not", "or", "repeat", "return",
        "then", "true", "until", "while",
        // Other important identifiers
        "self", "_G", "_ENV", "_VERSION",
        NULL
    },
    .comment_delimiters = (const char *[]){ "--", "--[[ ]]", NULL },
    .string_delimiters = (const char *[]){ "' '", "\" \"", "[[ ]]", "[=[ ]=]", NULL },
    // Lua scripts don't care about the class name
    .has_named_classes = false,
    // Builtin scripts didn't work for me, so disable for now...
    .supports_builtin_mode = false,

    // Callbacks
    .init = &lps_language_init,
    .finish = &lps_language_finish,
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

// GDN_EXPORT makes sure our symbols are exported in the way Godot expects
// This is not needed, since symbols are exported by default, but it
// doesn't hurt being explicit about it
GDN_EXPORT void godot_gdnative_init(godot_gdnative_init_options *options) {
	hgdn_gdnative_init(options);
	hgdn_pluginscript_api->godot_pluginscript_register_language(&lps_language_desc);
}

GDN_EXPORT void godot_gdnative_terminate(godot_gdnative_terminate_options *options) {
	hgdn_gdnative_terminate(options);
}

GDN_EXPORT void godot_gdnative_singleton() {
}

