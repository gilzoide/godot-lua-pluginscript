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

-- Embed any file into a `#include`able .h file
rule("embed_header")
    on_build_file(function(target, sourcefile)
        local header_contents = {}
        for line in io.lines(sourcefile) do
            local escaped_line = line:gsub('"', '\\"')
            table.insert(header_contents, '"' .. escaped_line .. '\\n"')
        end
        header_contents = table.concat(header_contents, '\n')
        io.writefile(path.join("$(buildir)/include", path.filename(sourcefile) .. ".h"), header_contents)
    end)
rule_end()

target("lua_pluginscript")
    set_kind("shared")
    add_files("src/*.c")
    add_files("src/*.lua", { rule = "embed_header" })
    add_includedirs("lib/godot-headers", "lib/high-level-gdnative", "$(buildir)/include")
    add_packages(lua_or_jit)
target_end()
