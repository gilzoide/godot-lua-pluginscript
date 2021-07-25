add_requires("lua")

target("lua_pluginscript")
    set_kind("shared")
    add_includedirs("lib/godot-headers")
    add_includedirs("lib/high-level-gdnative")
    add_files("lua_pluginscript.c")
    add_packages("lua")
