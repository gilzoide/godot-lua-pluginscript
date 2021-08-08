DEBUG ?= 0

SRC = hgdn.c language_gdnative.c language_in_editor_callbacks.c init_script.c
OBJS = $(addsuffix .o,$(basename $(SRC)))

# Note that the order is important!
LUA_SRC = \
	src/godot_ffi.lua \
	src/godot_class.lua \
	src/godot_globals.lua \
	src/godot_variant.lua \
	src/godot_string.lua \
	src/godot_math.lua \
	src/godot_misc.lua \
	src/godot_dictionary.lua \
	src/godot_array.lua \
	src/godot_pool_arrays.lua \
	src/lps_class_metadata.lua \
	src/lps_callbacks.lua \
	src/late_globals.lua \
	src/in_editor_callbacks.lua

CFLAGS += "-I$(CURDIR)/lib/godot-headers" "-I$(CURDIR)/lib/high-level-gdnative" "-I$(CURDIR)/lib/luajit/src"
ifeq ($(DEBUG), 1)
	CFLAGS += -g -O0 -DDEBUG
else
	CFLAGS += -O3 -DNDEBUG
endif

ifeq ($(OS), Windows_NT)
	PATH_SEP = ;
else
	PATH_SEP = :
endif

DYNAMIC_CC = $(CROSS)$(CC)

define COMPILE_O = 
build/%/$(basename $1).o: src/$1 | build/%/
	$$(DYNAMIC_CC) -o $$@ $$< -c $$(CFLAGS)
endef

# Add compile .o
$(foreach f,$(SRC),$(eval $(call COMPILE_O,$f)))

# Avoid removing intermediate files created by chained implicit rules
.PRECIOUS: build/%/ build/%/luajit build/%/init_script.c $(addprefix build/%/,$(OBJS))

build/%/:
	mkdir -p $@

build/%/luajit: | build/%/
	cp -r lib/luajit $@
	$(MAKE) -C $@ $(MAKE_LUAJIT_ARGS)
	cp $@/src/$(LUAJIT_DLL_IN) $|$(LUAJIT_DLL_OUT)

src/init_script.lua: $(LUA_SRC)
	cat $^ > $@

src/init_script.c: src/init_script.lua
	luajit -b $< $@

build/%/lua_pluginscript.so: LUAJIT_DLL_IN = libluajit.so
build/%/lua_pluginscript.so: LUAJIT_DLL_OUT = libluajit.so
build/%/lua_pluginscript.so: $(addprefix build/%/,$(OBJS)) | build/%/luajit
	$(DYNAMIC_CC) -o $@ $^ -shared $(CFLAGS) -Lbuild/$* -lluajit

build/%/lua_pluginscript.dll: LUAJIT_DLL_IN = lua51.dll
build/%/lua_pluginscript.dll: LUAJIT_DLL_OUT = lua51.dll
build/%/lua_pluginscript.dll: $(addprefix build/%/,$(OBJS)) | build/%/luajit
	$(DYNAMIC_CC) -o $@ $^ -shared $(CFLAGS) -Lbuild/$* -llua51

build/%/lua_pluginscript.dylib: LUAJIT_DLL_IN = libluajit.so
build/%/lua_pluginscript.dylib: LUAJIT_DLL_OUT = libluajit.dylib
build/%/lua_pluginscript.dylib: $(addprefix build/%/,$(OBJS)) | build/%/luajit
	$(DYNAMIC_CC) -o $@ $^ -shared $(CFLAGS) -Lbuild/$* -lluajit

# Targets by OS + arch
linux32: MAKE_LUAJIT_ARGS += TARGET_SYS=Linux CC="$(CC) -m32 -fPIC"
linux32: CFLAGS += -m32 -fPIC
linux32: build/linux_x86/lua_pluginscript.so

linux64: MAKE_LUAJIT_ARGS += TARGET_SYS=Linux
linux64: CFLAGS += -fPIC
linux64: build/linux_x86_64/lua_pluginscript.so

windows32: MAKE_LUAJIT_ARGS += TARGET_SYS=Windows
windows32: build/windows_x86/lua_pluginscript.dll
cross-windows32: CROSS = i686-w64-mingw32-
cross-windows32: MAKE_LUAJIT_ARGS += HOST_CC="cc -m32" CROSS="i686-w64-mingw32-"
cross-windows32: windows32

windows64: MAKE_LUAJIT_ARGS += TARGET_SYS=Windows
windows64: build/windows_x86_64/lua_pluginscript.dll
cross-windows64: CROSS = x86_64-w64-mingw32-
cross-windows64: MAKE_LUAJIT_ARGS += HOST_CC="cc" CROSS="x86_64-w64-mingw32-"
cross-windows64: windows64

osx: MAKE_LUAJIT_ARGS += TARGET_SYS=Darwin
osx: build/osx_x86_64/lua_pluginscript.dylib

