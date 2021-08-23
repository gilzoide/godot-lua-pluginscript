# Implementing Godot Lua PluginScript: LuaJIT and FFI
2021-08-17 | `#Godot #LuaJIT #FFI #GDNative #PluginScript` | [*Versão em Português*](3-luajit-callbacks-pt.md)

Last time, [we implemented the skeleton of our GDNative + PluginScript library](2-infrastructure-en.md).
Today we start integrating the Lua VM and implementing those callbacks.

To be able to use GDNative definitions from Lua, we have two options:
implement wrappers for everything using the [Lua/C API](https://www.lua.org/manual/5.4/manual.html#4)
or using raw C declarations via [LuaJIT](https://luajit.org/)'s [FFI](https://luajit.org/ext_ffi.html)
library or another FFI implementation like [cffi-lua](https://github.com/q66/cffi-lua).

Although creating wrappers for Lua is easy by its own, and even
facilitated by helper libraries like [Sol](https://github.com/Rapptz/sol)
and bindings generators like [SWIG](http://swig.org/), using FFI is even
simpler: we copy/paste definitions from the header files and the
definitions are available!
Since LuaJIT is also faster, which is great for real-time applications
like games, I'm going to use LuaJIT + FFI for the first implementation
of our plugin functionality.


## Integrating LuaJIT
First things first: let's add LuaJIT to our build.
Luckily for us, [xmake](https://xmake.io) already knows how to do that,
so we just have to ask for it.
In `xmake.lua`, we require the `luajit` package and then add it in the
target definition:

```lua
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

target("lua_pluginscript")
    -- ...
    -- Add "luajit" as dependency
    add_packages("luajit")
target_end()
```

Rerun the `xmake` command. It will ask for confirmation for installing
the `luajit` package into its cache:

```
note: install or modify (m) these packages (pass -y to skip confirm)?
in xmake-repo:
  -> luajit 2.1.0-beta3 [gc64:y]
please input: y (y/n/m)
```

Confirm by hitting `return`, or `y` and `return` and LuaJIT will be
downloaded and built for your platform.

```
  => download http://luajit.org/download/LuaJIT-2.1.0-beta3.tar.gz .. ok
  => install luajit 2.1.0-beta3 .. ok
[100%]: build ok!
```

Ok, now let's implement the first two callbacks: language initialization and
finalization.
To do that, we include Lua headers in `src/language_gdnative.c` and
initialize/finalize the `lua_State`:

```c
// src/language_gdnative.c
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"

// lua_Alloc function: https://www.lua.org/manual/5.4/manual.html#lua_Alloc
// Use `hgdn_free` and `hgdn_realloc` to make memory requests
// go through Godot, so memory usage is tracked on debug builds
void *lps_alloc(void *userdata, void *ptr, size_t osize, size_t nsize) {
    if (nsize == 0) {
        hgdn_free(ptr);
        return NULL;
    }
    else {
        return hgdn_realloc(ptr, nsize);
    }
}

// Called when our language runtime will be initialized
godot_pluginscript_language_data *lps_language_init() {
    lua_State *L = lua_newstate(&lps_alloc, NULL);
    luaL_openlibs(L);  // Load core Lua libraries
    // TODO: run initialization script using FFI
    return L;
}

// Called when our language runtime will be terminated
void lps_language_finish(godot_pluginscript_language_data *data) {
    lua_close((lua_State *) data);
}
```


## Embedding the initialization script
So far so good. Now, we have to call the Lua code to initialize the FFI
and implement the other callbacks there.
We can write extra files and load them or we can embed the code string
directly in C and compile it altogether with our dynamic library.
Writing separate files is much easier to edit, reason about, and keeps
the project well organized.
Embedding the code makes it much easier to load and run the initialization
code, because we don't have to worry about file paths.
Since we are in control, we'll choose both: write Lua code in one or
more files, then generate a C file defining our script and compile it in
the library.

To test this out, let's build a hello world in Lua:

```lua
-- src/ffi.lua
print "Hello world from Lua! \\o/"
```

The C file needs to declare a global variable containing the script
code, so that we can run it in `lps_language_init`, with a literal C
string, so quotes and backslashes need to be escaped.
The translation for our hello world looks like this:

```c
const char LUA_INIT_SCRIPT[] =
"-- src/ffi.lua\n"
"print \"Hello world from Lua! \\\\o/\"\n"
;
```

To create a C file from one or more Lua files, we'll have to concatenate all
script files, escape quotes and backslashes, add quotes for each line, then add
`LUA_INIT_SCRIPT` definition.
I'll be using the [cat](https://www.man7.org/linux/man-pages/man1/cat.1p.html)
command for concatenating files and
[sed](https://www.gnu.org/software/sed/) for everything else.
One way to make this happen in `xmake` is creating a [custom rule](https://xmake.io/#/manual/custom_rule)
and using it in our target:

```lua
-- xmake.lua
add_requires("luajit", {
    -- ...
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
    -- ...
    add_files("src/ffi.lua", { rule = "generate_init_script" })
target_end()
```

Now all we have to do is run the code defined in
`const char LUA_INIT_SCRIPT[]`:

```c
extern const char LUA_INIT_SCRIPT[];

// Called when our language runtime will be initialized
godot_pluginscript_language_data *lps_language_init() {
    lua_State *L = lua_newstate(&lps_alloc, NULL);
    luaL_openlibs(L);  // Load core Lua libraries
    if (luaL_dostring(L, LUA_INIT_SCRIPT) != LUA_OK) {
        const char *error_msg = lua_tostring(L, -1);
        HGDN_PRINT_ERROR("Error running initialization script: %s", error_msg);
    }
    return L;
}
```

Rebuild with `xmake` and reopen Godot from a terminal and `Hello world
from Lua! \o/` should be printed!

```
Godot Engine v3.3.2.stable.arch_linux - https://godotengine.org

Hello world from Lua! \o/
```


## Interfacing GDNative with Lua: FFI
Now, before start writing PluginScript callbacks, we need a way to call
GDNative functions from Lua.
Here is where the FFI comes in.
Let's modify `src/ffi.lua` with FFI definitions:

```lua
-- src/ffi.lua
-- Full source at: https://github.com/gilzoide/godot-lua-pluginscript/blob/blog-3-luajit-callbacks/src/ffi.lua
local ffi = require 'ffi'

ffi.cdef[[
// Here we paste the C definitions we need
// I'm not putting everything here because it's too long,
// a link to the full source is provided above

// GDNative type definitions
typedef bool godot_bool;
typedef int godot_int;
typedef float godot_real;

typedef struct godot_object {
    uint8_t _dont_touch_that[0];
} godot_object;
typedef struct godot_string {
    uint8_t _dont_touch_that[sizeof(void *)];
} godot_string;
// ...

// Enums
typedef enum godot_error {
    GODOT_OK, // (0)
    GODOT_FAILED, ///< Generic fail error
    // ...
} godot_error;
// ...

// Core API
typedef struct godot_gdnative_api_version {
    unsigned int major;
    unsigned int minor;
} godot_gdnative_api_version;

typedef struct godot_gdnative_api_struct {
    unsigned int type;
    godot_gdnative_api_version version;
    const struct godot_gdnative_api_struct *next;
} godot_gdnative_api_struct;

typedef struct godot_gdnative_core_api_struct {
    unsigned int type;
    godot_gdnative_api_version version;
    const godot_gdnative_api_struct *next;
    unsigned int num_extensions;
    const godot_gdnative_api_struct **extensions;
    void (*godot_color_new_rgba)(godot_color *r_dest, const godot_real p_r, const godot_real p_g, const godot_real p_b, const godot_real p_a);
    void (*godot_color_new_rgb)(godot_color *r_dest, const godot_real p_r, const godot_real p_g, const godot_real p_b);
    godot_real (*godot_color_get_r)(const godot_color *p_self);
    // ...
} godot_gdnative_core_api_struct;
// ...

// Global API pointers
const godot_gdnative_core_api_struct *hgdn_core_api;
]]

-- `hgdn_core_api` will be already initialized at this point
-- by the call to `hgdn_gdnative_init` at `godot_gdnative_init`
local api = ffi.C.hgdn_core_api
```

Using the `api` variable, a pointer to `godot_gdnative_core_api_struct`,
we can call all those core GDNative functions!
Let's write our hello world again, this time using the `api`:

```lua
local ffi = require 'ffi'

ffi.cdef[[
// ...
]]

-- `hgdn_core_api` will be already initialized at this point
-- by the call to `hgdn_gdnative_init` at `godot_gdnative_init`
local api = ffi.C.hgdn_core_api

local message = api.godot_string_chars_to_utf8("Hello world from Lua! \\o/")
api.godot_print(message)
-- We have to destroy all objects that we own, just like in C
api.godot_string_destroy(message)
-- If we don't know exactly when it should be destroyed, register the object
-- in the Garbage Collector (GC): `ffi.gc(message, api.godot_string_destroy)`
-- Ref: https://luajit.org/ext_ffi_api.html#ffi_gc
```

Rebuild the project and reopen the Godot editor.
The message should be printed, just as before \o/


## FFI Metatypes
One caveat of using the FFI is that it is low-level, so we have to be
careful with memory management, SEGFAULTs and other problems commonly faced by
C code.
All other methods for binding C and Lua are susceptible to these, so
going for the FFI is still a good idea.

LuaJIT will track and garbage collect data created from Lua code, e.g.:
`local some_array = ffi.new('int[1024]')`, but to run a custom
destructor, like `api.godot_string_destroy`, we need to either
explicitly call it or register the garbage collection callback with
`ffi.gc`.

Doing this manually is really cumbersome, so we'll bring the GDNative
API closer to the Lua world by declaring [metatypes](https://luajit.org/ext_ffi_api.html#ffi_metatype).
With metatypes, we can define a [metatable](https://www.lua.org/manual/5.4/manual.html#2.4)
for C data, so they can have methods, including a constructor and
destructor, implement arithmetic and comparison operators, among others.

For now, I'll implement the basics of `godot_string` just to be able to
print messages in our callbacks.
I'll create a new file `src/string.lua`, to make our source organized:

```lua
-- src/string.lua

-- Notice that even `api` being declared as a local variable at
-- `src/ffi.lua`, since all files will get concatenated before run, we
-- can access it here

-- String methods, taken from the GDNative API and adjusted to feel
-- more idiomatic to Lua, when necessary
local string_methods = {
    -- Get the String length, in wide characters
    length = api.godot_string_length,
    -- Return the String as a Lua string, encoded as UTF-8
    utf8 = function(self)
        -- `godot_string` holds wide characters, so we need to get a
        -- character string, then create a Lua string from it
        local char_string = api.godot_string_utf8(self)
        local pointer = api.godot_char_string_get_data(char_string)
        local length = api.godot_char_string_length(char_string)
        -- Ref: https://luajit.org/ext_ffi_api.html#ffi_string
        local lua_string = ffi.string(pointer, length)
        -- Just as in C, we need to destroy the objects we own
        api.godot_char_string_destroy(char_string)
        return lua_string
    end,
}

-- String metatype, used to construct instances of `godot_string`
-- Notice that we make this a global variable, so scripts can use it
-- right away
String = ffi.metatype('godot_string', {
    -- Constructor method
    -- Calling `String(value)` will create a string that holds the
    -- contents of `value` after passing it through `tostring`
    __new = function(metatype, value)
        local self = ffi.new(metatype)
        -- if `value` is another String, just create a copy
        if ffi.istype(metatype, value) then
            api.godot_string_new_copy(self, value)
        -- general case
        else
            local str = tostring(value)
            api.godot_string_parse_utf8_with_len(self, str, #str)
        end
        return self
    end,
    -- Destructor method
    __gc = api.godot_string_destroy,
    -- Setting `__index` to the methods table makes methods available
    -- from instances, e.g.: `godot_string:length()`
    __index = string_methods,
    -- Length operation: `#godot_string` returns the String length
    __len = function(self)
        return string_methods.length(self)
    end,
    -- Calling `tostring(string)` will call this metamethod
    __tostring = string_methods.utf8,
    -- Concatenation operation: `godot_string .. godot_string`
    -- will create a new String with both contents concatenated
    __concat = function(a, b)
        -- Converting `a` and `b` to Strings make expressions like
        -- `42 .. some_godot_string .. " some Lua string "` possible
        local str = api.godot_string_operator_plus(String(a), String(b))
        -- LuaJIT can't be sure if data returned from a C function must
        -- be garbage collected or not, since C APIs may require the
        -- caller to clean the memory up or not.
        -- Explicitly track the return in cases where we own the data,
        -- such as this one: in the GDNative API, when a function
        -- returns a struct/union and not a pointer, we own the data.
        ffi.gc(str, api.godot_string_destroy)
        return str
    end,
})
```

Just to make sure our implementation is still working, I'll create a new
file called `src/test.lua` and move the test code from `src/ffi.lua` to
it:

```lua
-- src/test.lua
local message = String("Hello world from Lua! \\o/")
api.godot_print(message)
```

Now that we have more Lua files forming the initialization script, we
need to specify all of them in `xmake.lua` in the right order:

```lua
-- xmake.lua
add_requires("luajit", {
    -- ...
})

rule("generate_init_script")
    -- ...
rule_end()

target("lua_pluginscript")
    -- ...
    add_files(
        -- The order is important!
        -- First, FFI declarations
        "src/ffi.lua",
        -- Then String metatype implementation
        "src/string.lua",
        -- Finally, our test code
        "src/test.lua",
        { rule = "generate_init_script" }
    )
target_end()
```

Rebuilding the project and reopening Godot should display the message
again.


## Running PluginScript callbacks from Lua
Last step for today: let's make the PluginScript callbacks call Lua
code.
The easiest way to do that is declare a global function pointer for each
of them and set them to the Lua implementation via FFI.

In `src/language_gdnative.c`, let's add the function pointers and call
them:

```c
// src/language_gdnative.c

// ...

// Callbacks to be implemented in Lua
void (*lps_language_add_global_constant_cb)(const godot_string *name, const godot_variant *value);
// LuaJIT callbacks cannot return C aggregate types by value, so
// `manifest` will be created in C and passed by reference
// Ref: https://luajit.org/ext_ffi_semantics.html#callback
void (*lps_script_init_cb)(godot_pluginscript_script_manifest *manifest, const godot_string *path, const godot_string *source, godot_error *error);
void (*lps_script_finish_cb)(godot_pluginscript_script_data *data);
godot_pluginscript_instance_data *(*lps_instance_init_cb)(godot_pluginscript_script_data *data, godot_object *owner);
void (*lps_instance_finish_cb)(godot_pluginscript_instance_data *data);
godot_bool (*lps_instance_set_prop_cb)(godot_pluginscript_instance_data *data, const godot_string *name, const godot_variant *value);
godot_bool (*lps_instance_get_prop_cb)(godot_pluginscript_instance_data *data, const godot_string *name, godot_variant *ret);
// Same caveat as `lps_script_init_cb`
void (*lps_instance_call_method_cb)(godot_pluginscript_instance_data *data, const godot_string_name *method, const godot_variant **args, int argcount, godot_variant *ret, godot_variant_call_error *error);
void (*lps_instance_notification_cb)(godot_pluginscript_instance_data *data, int notification);

// Called when Godot registers globals in the language, such as Autoload nodes
void lps_language_add_global_constant(godot_pluginscript_language_data *data, const godot_string *name, const godot_variant *value) {
    lps_language_add_global_constant_cb(name, value);
}

// Called when a Lua script is loaded, e.g.: const SomeScript = preload("res://some_script.lua")
godot_pluginscript_script_manifest lps_script_init(godot_pluginscript_language_data *data, const godot_string *path, const godot_string *source, godot_error *error) {
    godot_pluginscript_script_manifest manifest = {
        .data = NULL,
        .is_tool = false,
    };
    // All Godot objects must be initialized, or else our plugin SEGFAULTs
    hgdn_core_api->godot_string_name_new_data(&manifest.name, "");
    hgdn_core_api->godot_string_name_new_data(&manifest.base, "");
    hgdn_core_api->godot_dictionary_new(&manifest.member_lines);
    hgdn_core_api->godot_array_new(&manifest.methods);
    hgdn_core_api->godot_array_new(&manifest.signals);
    hgdn_core_api->godot_array_new(&manifest.properties);

    // Mark error by default: the implementation is responsible for
    // marking success, when the call has actually succeeded
    godot_error cb_error = GODOT_ERR_SCRIPT_FAILED;
    lps_script_init_cb(&manifest, path, source, &cb_error);
    if (error) {
        *error = cb_error;
    }

    return manifest;
}

// Called when a Lua script is unloaded
void lps_script_finish(godot_pluginscript_script_data *data) {
    lps_script_finish_cb(data);
}

// Called when a Script Instance is being created, e.g.: var instance = SomeScript.new()
godot_pluginscript_instance_data *lps_instance_init(godot_pluginscript_script_data *data, godot_object *owner) {
    return lps_instance_init_cb(data, owner);
}

// Called when a Script Instance is being finalized
void lps_instance_finish(godot_pluginscript_instance_data *data) {
    lps_instance_finish_cb(data);
}

// Called when setting a property on an instance, e.g.: instance.prop = value
godot_bool lps_instance_set_prop(godot_pluginscript_instance_data *data, const godot_string *name, const godot_variant *value) {
    return lps_instance_set_prop_cb(data, name, value);
}

// Called when getting a property on an instance, e.g.: var value = instance.prop
godot_bool lps_instance_get_prop(godot_pluginscript_instance_data *data, const godot_string *name, godot_variant *ret) {
    return lps_instance_get_prop_cb(data, name, ret);
}

// Called when calling a method on an instance, e.g.: instance.method(args)
godot_variant lps_instance_call_method(godot_pluginscript_instance_data *data, const godot_string_name *method, const godot_variant **args, int argcount, godot_variant_call_error *error) {
    godot_variant var = hgdn_new_nil_variant();
    lps_instance_call_method_cb(data, method, args, argcount, &var, error);
    return var;
}

// Called when a notification is sent to instance
void lps_instance_notification(godot_pluginscript_instance_data *data, int notification) {
    lps_instance_notification_cb(data, notification);
}

// ...
```

Now, we add these callbacks in the FFI definition at `src/ffi.lua`:

```lua
-- src/ffi.lua
local ffi = require 'ffi'

ffi.cdef[[
// ...

// Global PluginScript callbacks
void (*lps_language_add_global_constant_cb)(const godot_string *name, const godot_variant *value);
void (*lps_script_init_cb)(godot_pluginscript_script_manifest *manifest, const godot_string *path, const godot_string *source, godot_error *error);
void (*lps_script_finish_cb)(godot_pluginscript_script_data *data);
godot_pluginscript_instance_data *(*lps_instance_init_cb)(godot_pluginscript_script_data *data, godot_object *owner);
void (*lps_instance_finish_cb)(godot_pluginscript_instance_data *data);
godot_bool (*lps_instance_set_prop_cb)(godot_pluginscript_instance_data *data, const godot_string *name, const godot_variant *value);
godot_bool (*lps_instance_get_prop_cb)(godot_pluginscript_instance_data *data, const godot_string *name, godot_variant *ret);
void (*lps_instance_call_method_cb)(godot_pluginscript_instance_data *data, const godot_string_name *method, const godot_variant **args, int argcount, godot_variant *ret, godot_variant_call_error *error);
void (*lps_instance_notification_cb)(godot_pluginscript_instance_data *data, int notification);
]]

-- `hgdn_core_api` will be already initialized at this point
-- by the call to `hgdn_gdnative_init` at `godot_gdnative_init`
local api = ffi.C.hgdn_core_api
```

Finally, add a new file `src/pluginscript_callbacks.lua` to implement
them:

```lua
-- src/pluginscript_callbacks.lua

-- Error printing facility
local function print_error(message)
    local info = debug.getinfo(2, 'nSl')
    api.godot_print_error(message, info.name, info.short_src, info.currentline)
end

-- All callbacks will be run in protected mode, to avoid errors in Lua
-- aborting the game/application
-- If an error is thrown, it will be printed in the output console
local function wrap_callback(f)
    return function(...)
        local success, result = xpcall(f, print_error, ...)
        return result
    end
end

-- void (*lps_language_add_global_constant_cb)(const godot_string *name, const godot_variant *value);
ffi.C.lps_language_add_global_constant_cb = wrap_callback(function(name, value)
    api.godot_print(String('TODO: add_global_constant'))
end)

-- void (*lps_script_init_cb)(godot_pluginscript_script_manifest *manifest, const godot_string *path, const godot_string *source, godot_error *error);
ffi.C.lps_script_init_cb = wrap_callback(function(manifest, path, source, err)
    api.godot_print(String('TODO: script_init ' .. path))
end)

-- void (*lps_script_finish_cb)(godot_pluginscript_script_data *data);
ffi.C.lps_script_finish_cb = wrap_callback(function(data)
    api.godot_print(String('TODO: script_finish'))
end)

-- godot_pluginscript_instance_data *(*lps_instance_init_cb)(godot_pluginscript_script_data *data, godot_object *owner);
ffi.C.lps_instance_init_cb = wrap_callback(function(script_data, owner)
    api.godot_print(String('TODO: instance_init'))
    return nil
end)

-- void (*lps_instance_finish_cb)(godot_pluginscript_instance_data *data);
ffi.C.lps_instance_finish_cb = wrap_callback(function(data)
    api.godot_print(String('TODO: instance_finish'))
end)

-- godot_bool (*lps_instance_set_prop_cb)(godot_pluginscript_instance_data *data, const godot_string *name, const godot_variant *value);
ffi.C.lps_instance_set_prop_cb = wrap_callback(function(data, name, value)
    api.godot_print(String('TODO: instance_set_prop'))
    return false
end)

-- godot_bool (*lps_instance_get_prop_cb)(godot_pluginscript_instance_data *data, const godot_string *name, godot_variant *ret);
ffi.C.lps_instance_get_prop_cb = wrap_callback(function(data, name, ret)
    api.godot_print(String('TODO: instance_get_prop'))
    return false
end)

-- void (*lps_instance_call_method_cb)(godot_pluginscript_instance_data *data, const godot_string_name *method, const godot_variant **args, int argcount, godot_variant *ret, godot_variant_call_error *error);
ffi.C.lps_instance_call_method_cb = wrap_callback(function(data, name, args, argcount, ret, err)
    api.godot_print(String('TODO: instance_call_method'))
end)

-- void (*lps_instance_notification_cb)(godot_pluginscript_instance_data *data, int notification);
ffi.C.lps_instance_notification_cb = wrap_callback(function(data, what)
    api.godot_print(String('TODO: instance_notification'))
end)
```

Once again, add the new file to `xmake.lua` and rebuild:

```lua
-- xmake.lua

-- ...

target("lua_pluginscript")
    -- ...
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
target_end()
```

If we try opening `xmake.lua` in Godot, we should see the message
`TODO: script_init res://addons/godot-lua-pluginscript/xmake.lua` in the
output, since the engine tried initializing it as a script:

![](3-script-init-xmake-lua.png)


## Conclusion
Today we covered how to integrate LuaJIT into our project and how we can
implement the callbacks in Lua via the FFI.
The version of the project build in this article is available [here](https://github.com/gilzoide/godot-lua-pluginscript/tree/blog-3-luajit-callbacks).

In the next article, we'll implement script initialization and
finalization.

Good luck for all of us, and see you next time!
