option("use-luajit")
    set_description("Use LuaJIT instead of vanilla Lua")
    set_default(true)
    set_showmenu(true)
option("system-lua")
    set_description("Use Lua/LuaJIT system package, if available")
    set_default(false)
    set_showmenu(true)
option_end()

local lua_or_jit = has_config("use-luajit") and "luajit" or "lua"
add_requires(lua_or_jit, {
    system = has_config("system-lua") or false,
    config = {
        gc64 = true,
    },
})

target("lua_pluginscript")
    set_kind("shared")
    add_includedirs("lib/godot-headers")
    add_includedirs("lib/high-level-gdnative")
    add_files("src/*.c")
    add_packages(lua_or_jit)
target_end()
