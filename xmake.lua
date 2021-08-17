-- xmake.lua
add_requires("luajit", {
    -- Force xmake to build and embed LuaJIT,
    -- instead of searching for it in the system
    system = false,
    -- Turn on LuaJIT's GC64 mode, enabling full memory range on 64-bit systems,
    -- also allowing custom memory allocation functions to be hooked to Lua
    config = {
        gc64 = true,
    },
})

rule("generate_init_script")
    -- The rule "generate_init_script" builds an object file
    set_kind("object")
    on_buildcmd_files(function(target, batchcmds, sourcebatch, opt)
        -- Path for built Lua script: `build/init_script.lua`
        local full_script_path = vformat("$(buildir)/init_script.lua")
        -- Path for the C file with embedded script will be `build/init_script.c`
        local script_c_path = vformat("$(buildir)/init_script.c")
        -- This is how we add a new object file to a xmake target
        local script_obj_path = target:objectfile(script_c_path)
        table.insert(target:objectfiles(), script_obj_path)

        batchcmds:show_progress(opt.progress, "${color.build.object}embed.lua (%s)", table.concat(sourcebatch.sourcefiles, ', '))
        -- Execute `cat src/*.lua > build/init_script.lua`
        batchcmds:execv("cat", sourcebatch.sourcefiles, { stdout = full_script_path })
        -- Execute `sed -e ↓SED_SCRIPT_BELOW↓ build/init_script.lua > build/init_script.c`
        batchcmds:execv("sed", { "-e", [[
        # Escape backslashes (`s` substitutes content, `g` means change all occurrences in line)
        s/\\/\\\\/g
        # Escape quotes
        s/"/\\"/g
        # Add starting quote (`^` matches the begining of the line)
        s/^/"/
        # Add ending newline and quote (`$` matches the end of the line)
        s/$/\\n"/
        # Add C declaration lines:
        # before first line (`i` inserts a line before `1`, the first line)
        1 i const char LUA_INIT_SCRIPT[] =
        # and after last line (`a` appends a line after `$`, the last line)
        $ a ;
        ]], full_script_path }, { stdout = script_c_path })
        -- Finally, compile the generated C file
        batchcmds:compile(script_c_path, script_obj_path)
        -- The following informs xmake to only rebuild the
        -- object file if source files are changed
        batchcmds:add_depfiles(sourcebatch.sourcefiles)
        batchcmds:set_depmtime(os.mtime(script_obj_path))
    end)
rule_end()

target("lua_pluginscript")
    set_kind("shared")
    -- Set the output name to something easy to find like `build/lua_pluginscript_linux_x86_64.so`
    set_targetdir("$(buildir)")
    set_prefixname("")
    set_suffixname("_$(os)_$(arch)")
    -- Add "-I" flags for locating HGDN and godot-header files
    add_includedirs("lib/godot-headers", "lib/high-level-gdnative")
    -- src/hgdn.c, src/language_gdnative.c
    add_files("src/*.c")
    add_files(
        -- Notice that the order is important!
        -- First, FFI declarations
        "src/ffi.lua",
        -- Then String implementation
        "src/string.lua",
        -- Then PluginScript callbacks
        "src/pluginscript_callbacks.lua",
        -- Finally, our test code
        "src/test.lua",
        { rule = "generate_init_script" }
    )
    -- Add "luajit" as dependency
    add_packages("luajit")
target_end()
