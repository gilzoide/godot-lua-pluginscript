option("use-luajit")
    set_showmenu(true)
    set_default(true)
option_end()

local lua_or_jit
if has_config("use-luajit") then
    lua_or_jit = "luajit"
    add_defines("USE_LUAJIT")
else
    lua_or_jit = "lua"
end

add_requires(lua_or_jit)

target("lua_pluginscript")
    set_kind("shared")
    add_includedirs("lib/godot-headers")
    add_includedirs("lib/high-level-gdnative")
    add_files("lps_gdnative.c", "lps_variant.c", "hgdn.c")
    add_packages(lua_or_jit)
