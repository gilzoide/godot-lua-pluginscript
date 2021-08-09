DEBUG ?= 0

SRC = hgdn.c language_gdnative.c language_in_editor_callbacks.c
OBJS = $(SRC:.c=.o) init_script.o
BUILT_OBJS = $(addprefix build/%/,$(OBJS))

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
.PRECIOUS: build/%/ build/%/luajit build/%/init_script.c $(BUILT_OBJS)

build/%/:
	mkdir -p $@

build/%/luajit: | build/%/
	cp -r lib/luajit $@
	$(MAKE) -C $@ TARGET_SYS=$(TARGET_SYS) $(MAKE_LUAJIT_ARGS)
	cp $@/src/$(LUAJIT_DLL_IN) $|$(or $(LUAJIT_DLL_OUT),$(LUAJIT_DLL_IN))

build/common/init_script.lua: $(LUA_SRC) | build/common/
	cat $^ > $@

build/%/init_script.o: build/common/init_script.lua | build/%/luajit
	$(if $(CROSS), luajit -b -o $(TARGET_SYS) -a $(TARGET_ARCH), env LUA_PATH="./lib/luajit/src/?.lua" build/$*/luajit/src/luajit$(EXE) -b) $< $@

build/%/lua_pluginscript.so: TARGET_SYS = Linux
build/%/lua_pluginscript.so: LUAJIT_DLL_IN = libluajit.so
build/%/lua_pluginscript.so: $(BUILT_OBJS) | build/%/luajit
	$(DYNAMIC_CC) -o $@ $^ -shared $(CFLAGS) -Lbuild/$* -lluajit

build/%/lua_pluginscript.dll: TARGET_SYS = Windows
build/%/lua_pluginscript.dll: EXE = .exe
build/%/lua_pluginscript.dll: LUAJIT_DLL_IN = lua51.dll
build/%/lua_pluginscript.dll: $(BUILT_OBJS) | build/%/luajit
	$(DYNAMIC_CC) -o $@ $^ -shared $(CFLAGS) -Lbuild/$* -llua51

build/%/lua_pluginscript.dylib: TARGET_SYS = Darwin
build/%/lua_pluginscript.dylib: LUAJIT_DLL_IN = libluajit.so
build/%/lua_pluginscript.dylib: LUAJIT_DLL_OUT = libluajit.dylib
build/%/lua_pluginscript.dylib: $(BUILT_OBJS) | build/%/luajit
	$(DYNAMIC_CC) -o $@ $^ -shared $(CFLAGS) -Lbuild/$* -lluajit

# Targets by OS + arch
linux32: TARGET_ARCH = x86
linux32: MAKE_LUAJIT_ARGS += CC="$(CC) -m32 -fPIC"
linux32: CFLAGS += -m32 -fPIC
linux32: build/linux_x86/lua_pluginscript.so

linux64: TARGET_ARCH = x64
linux64: CFLAGS += -fPIC
linux64: build/linux_x86_64/lua_pluginscript.so

windows32: TARGET_ARCH = x86
windows32: build/windows_x86/lua_pluginscript.dll
cross-windows32: CROSS = i686-w64-mingw32-
cross-windows32: MAKE_LUAJIT_ARGS += HOST_CC="cc -m32" CROSS="i686-w64-mingw32-"
cross-windows32: windows32

windows64: TARGET_ARCH = x64
windows64: build/windows_x86_64/lua_pluginscript.dll
cross-windows64: CROSS = x86_64-w64-mingw32-
cross-windows64: MAKE_LUAJIT_ARGS += HOST_CC="cc" CROSS="x86_64-w64-mingw32-"
cross-windows64: windows64

osx: TARGET_ARCH = x64
osx: build/osx_x86_64/lua_pluginscript.dylib

