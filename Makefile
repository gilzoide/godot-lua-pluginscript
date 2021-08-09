DEBUG ?= 0

CFLAGS += -std=c11 "-I$(CURDIR)/lib/godot-headers" "-I$(CURDIR)/lib/high-level-gdnative" "-I$(CURDIR)/lib/luajit/src"
ifeq ($(DEBUG), 1)
	CFLAGS += -g -O0 -DDEBUG
else
	CFLAGS += -O3 -DNDEBUG
endif

_CC = $(CROSS)$(CC)

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

define COMPILE_O = 
build/%/$(basename $1).o: src/$1 | build/%/
	$$(_CC) -o $$@ $$< -c $$(CFLAGS)
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
	cp $@/src/$(LUAJIT_LIB) $|

build/common/init_script.lua: $(LUA_SRC) | build/common/
	cat $^ > $@

build/%/init_script.c: build/common/init_script.lua src/tools/lua_script_to_c.lua | build/%/luajit
	$(if $(CROSS), lua, build/$*/luajit/src/luajit$(EXE)) $(word 2,$^) LUA_INIT_SCRIPT $< > $@

build/%/init_script.o: build/%/init_script.c
	$(_CC) -o $@ $< -c $(CFLAGS)

build/%/lua_pluginscript.so: TARGET_SYS = Linux
build/%/lua_pluginscript.so: LUAJIT_LIB = libluajit.a
build/%/lua_pluginscript.so: $(BUILT_OBJS) | build/%/luajit
	$(_CC) -o $@ $^ build/$*/$(LUAJIT_LIB) -shared $(CFLAGS) -lm -ldl

build/%/lua_pluginscript.dll: TARGET_SYS = Windows
build/%/lua_pluginscript.dll: EXE = .exe
build/%/lua_pluginscript.dll: LUAJIT_LIB = lua51.dll
build/%/lua_pluginscript.dll: $(BUILT_OBJS) | build/%/luajit
	$(_CC) -o $@ $^ -shared $(CFLAGS) -Lbuild/$* -llua51

build/%/lua_pluginscript.dylib: TARGET_SYS = Darwin
build/%/lua_pluginscript.dylib: LUAJIT_LIB = libluajit.a
build/%/lua_pluginscript.dylib: $(BUILT_OBJS) | build/%/luajit
	$(_CC) -o $@ $^ build/$*/$(LUAJIT_LIB) -shared $(CFLAGS)

.PHONY: clean
clean:
	$(RM) -r build/*/

# Targets by OS + arch
linux32: MAKE_LUAJIT_ARGS += CC="$(CC) -m32 -fPIC"
linux32: CFLAGS += -m32 -fPIC
linux32: build/linux_x86/lua_pluginscript.so

linux64: MAKE_LUAJIT_ARGS += CC="$(CC) -fPIC"
linux64: CFLAGS += -fPIC
linux64: build/linux_x86_64/lua_pluginscript.so

windows32: build/windows_x86/lua_pluginscript.dll
cross-windows32: CROSS = i686-w64-mingw32-
cross-windows32: MAKE_LUAJIT_ARGS += HOST_CC="$(CC) -m32" CROSS="i686-w64-mingw32-" LDFLAGS=-static-libgcc
cross-windows32: windows32

windows64: build/windows_x86_64/lua_pluginscript.dll
cross-windows64: CROSS = x86_64-w64-mingw32-
cross-windows64: MAKE_LUAJIT_ARGS += HOST_CC="$(CC)" CROSS="x86_64-w64-mingw32-" LDFLAGS=-static-libgcc
cross-windows64: windows64

osx: build/osx_x86_64/lua_pluginscript.dylib
