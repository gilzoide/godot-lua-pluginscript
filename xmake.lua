-- xmake.lua
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
target_end()
