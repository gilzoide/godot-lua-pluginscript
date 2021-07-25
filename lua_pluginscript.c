#include "hgdn.h"
#include "lua.h"

static void *lps_alloc(void *userdata, void *ptr, size_t osize, size_t nsize) {
    if (nsize == 0) {
        hgdn_free(ptr);
        return NULL;
    }
    else {
        return hgdn_realloc(ptr, nsize);
    }
}

godot_pluginscript_language_data *lps_init() {
    return lua_newstate(&lps_alloc, NULL);
}

void lps_finish(godot_pluginscript_language_data *data) {
    lua_close((lua_State *) data);
}

GDN_EXPORT void godot_gdnative_init(godot_gdnative_init_options *options) {
    hgdn_gdnative_init(options);

    godot_pluginscript_language_desc lua_desc = {
        .name = "lua",
        .type = "lua",
        .extension = "lua",
        .recognized_extensions = (const char *[]){ "lua", NULL },
        .init = &lps_init,
        .finish = &lps_finish,
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

        .script_desc = {
            // TODO
        },
    };

    godot_pluginscript_register_language(&lua_desc);
}

GDN_EXPORT void godot_gdnative_terminate(godot_gdnative_terminate_options *options) {
    hgdn_gdnative_terminate(options);
}
