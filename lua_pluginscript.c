#include "hgdn.h"

GDN_EXPORT void godot_gdnative_init(godot_gdnative_init_options *options) {
    hgdn_gdnative_init(options);
}

GDN_EXPORT void godot_gdnative_terminate(godot_gdnative_terminate_options *options) {
    hgdn_gdnative_terminate(options);
}
