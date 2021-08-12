# Godot Lua PluginScript


## Design
Check out the [design article](blog/1-design-en.md) for insight in how this
project is being designed.


## Goals
- Provide support for Lua as a scripting language in Godot in a way that does
  not require compiling the engine from scratch
- Be able to seamlessly communicate with any other language supported by Godot,
  like GDScript, Visual Script and C#, in an idiomatic way
- Simple script description interface that doesn't need `require`ing anything
- Support for Lua 5.1+ and LuaJIT
- Have a simple build process, where anyone with the cloned source code and
  installed build system + toolchain can build the project in a single step


## Non-goals
- Provide calls to all core Godot classes' methods via native method bindings
- Support multithreading on the Lua side


## Script example
This is an example of how a Lua script looks like. There are comments regarding
some design decisions, which may change during development.

```lua
-- Class definitions are regular Lua tables, to be returned from the script
local MyClass = {}

-- Optional: set class as tool, defaults to false
MyClass.is_tool = true

-- Optional: set base class by name, defaults to 'Reference'
MyClass.extends = 'Node'

-- Optional: give your class a name
MyClass.class_name = 'MyClass'

-- Declare signals
MyClass.something_happened = signal()
MyClass.something_happened_with_args = signal("arg1", "arg2")

-- Values defined in table are registered as properties of the class
MyClass.some_prop = 42

-- The `property` function adds metadata to defined properties,
-- like setter and getter functions
MyClass.some_prop_with_details = property {
  -- [1] or ["default"] or ["default_value"] = property default value
  5,
  -- [2] or ["type"] = variant type, optional, inferred from default value
  -- All Godot variant type names are defined globally as written in
  -- GDScript, like bool, int, float, String, Array, Vector2, etc...
  -- Notice that Lua <= 5.2 does not differentiate integers from float
  -- numbers, so we should always specify `int` where appropriate
  type = int,
  -- ["set"] or ["setter"] = setter function, optional
  set = function(self, value)
    self.some_prop_with_details = value
    -- Indexing `self` with keys undefined in script will search base
    -- class for methods and properties
    self:emit_signal("something_happened_with_args", "some_prop_with_details", value)
  end,
  -- ["get"] or ["getter"] = getter function, optional
  get = function(self)
    return self.some_prop_with_details
  end,
  -- ["export"] = export flag, optional, defaults to false
  -- Exported properties are editable in the Inspector
  export = true,
  -- TODO: usage, hint/hint_text, rset_mode
}
-- `export` is an alias for `property` with `export = true`
MyClass.some_exported_prop = export { "hello world!" }

-- Functions defined in table are public methods
function MyClass:_init()  -- `function t:f(...)` is an alias for `function t.f(self, ...)`
  -- Singletons are available globally
  local os_name = OS:get_name()
  print("MyClass instance initialized! Running on a " .. os_name .. " system")
end

function MyClass:some_prop_doubled()
  return self.some_prop * 2
end

-- In the end, table with class declaration must be returned from script
return MyClass
```


## Building
This project uses git submodules for its dependencies, so be sure to activate
submodules before building.

```sh
# clone this repository and activate submodules in a single command
git clone --recurse-submodules https://github.com/gilzoide/godot-lua-pluginscript.git

# or clone it normally and then activate submodules
git clone https://github.com/gilzoide/godot-lua-pluginscript.git
cd godot-lua-pluginscript
git submodule init
git submodule update
```

Build using [make](https://www.gnu.org/software/make/) from project root,
specifying the system as target:

```sh
# Choose one of the supported platforms, based on your operating system
make windows64  # x86_64
make windows32  # x86
make linux64    # x86_64
make linux32    # x86
make osx64      # "universal" multiarch x86_64 + amd64 dylib
```

The GDNativeLibrary file `lua_pluginscript.gdnlib` is already configured to use
the built files stored in the `build` folder, so that one can use this
repository directly inside a Godot project.


## Third-party software
This project uses the following software:

- [godot-headers](https://github.com/godotengine/godot-headers): headers for
  GDNative, released under the MIT license
- [LuaJIT](https://luajit.org/luajit.html): Just-In-Time Compiler (JIT) for the
  Lua programming language, released under the MIT license
- [High Level GDNative (HGDN)](https://github.com/gilzoide/high-level-gdnative):
  higher level GDNative API header, released to the Public Domain


## Other projects for using Lua in Godot
- https://github.com/perbone/luascript
- https://github.com/Trey2k/lua
- https://github.com/zozer/godot-lua-module
