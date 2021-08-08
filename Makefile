DEBUG ?= 0

SRC = hgdn.c language_gdnative.c language_in_editor_callbacks.c
OBJS = $(addsuffix .o,$(basename $(SRC))) init_script.o

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
	PATH_SEP = ";"
else
	PATH_SEP = ":"
endif

define COMPILE_O = 
build/%/$(basename $1).o: src/$1 | build/%/
	$$(CC) -o $$@ $$< -c $$(CFLAGS)
endef

# Add compile .o
$(foreach f,$(SRC),$(eval $(call COMPILE_O,$f)))

# Avoid removing intermediate files created by chained implicit rules
.PRECIOUS: build/%/ build/%/luajit $(addprefix build/%/,$(OBJS))

build/%/:
	mkdir -p $@

build/%/luajit: | build/%/
	cp -r lib/luajit $@
	$(MAKE) -C $@ $(MAKE_LUAJIT_ARGS)
	cp $@/src/*.$(DLL_SUFFIX) $|

build/common/init_script.lua: $(LUA_SRC) | build/common/
	cat $^ > $@

build/common/init_script.c: build/common/init_script.lua
	env PATH="$(PATH)$(PATH_SEP)$|/src" LUA_PATH=";;./$|/src/?.lua" luajit -b $< $@

build/%/init_script.o: build/common/init_script.c
	$(CC) -o $@ $< -c $(CFLAGS)

build/%/lua_pluginscript.so: DLL_SUFFIX = so
build/%/lua_pluginscript.so: $(addprefix build/%/,$(OBJS)) | build/%/luajit
	$(CC) -o $@ $^ -shared $(CFLAGS) -Lbuild/$* -lluajit

build/%/lua_pluginscript.dll: DLL_SUFFIX = dll
build/%/lua_pluginscript.dll: $(addprefix build/%/,$(OBJS)) | build/%/luajit
	$(CC) -o $@ $^ -shared $(CFLAGS) -Lbuild/$* -llua51

build/%/lua_pluginscript.dylib: DLL_SUFFIX = dylib
build/%/lua_pluginscript.dylib: $(addprefix build/%/,$(OBJS)) | build/%/luajit
	$(CC) -o $@ $^ -shared $(CFLAGS) -Lbuild/$* -lluajit

# Targets by OS + arch
linux32: MAKE_LUAJIT_ARGS += TARGET_SYS=Linux CC="$(CC) -m32 -fPIC"
linux32: CFLAGS += -m32 -fPIC
linux32: build/linux_x86/lua_pluginscript.so

linux64: MAKE_LUAJIT_ARGS += TARGET_SYS=Linux
linux64: CFLAGS += -fPIC
linux64: build/linux_x86_64/lua_pluginscript.so

windows32: MAKE_LUAJIT_ARGS += TARGET_SYS=Windows
windows32: build/windows_x86/lua_pluginscript.dll
cross-windows32: MAKE_LUAJIT_ARGS += HOST_CC="cc -m32" CC="i686-w64-mingw32-cc"
cross-windows32: CC = i686-w64-mingw32-cc
cross-windows32: windows32

windows64: MAKE_LUAJIT_ARGS += TARGET_SYS=Windows
windows64: build/windows_x86_64/lua_pluginscript.dll
cross-windows64: MAKE_LUAJIT_ARGS += HOST_CC="cc" CC="x86_64-w64-mingw32-cc"
cross-windows64: CC = x86_64-w64-mingw32-cc
cross-windows64: windows64

osx: MAKE_LUAJIT_ARGS += TARGET_SYS=Darwin
osx: build/osx_x86_64/lua_pluginscript.dylib

