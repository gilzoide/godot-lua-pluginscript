# Godot Lua PluginScript


## Design
Check out the [design article](blog/1-design-en.md) for insight in how this project is being designed.


## Goals
- Provide support for the Lua language in Godot in a way that does not require
  compiling the engine from scratch
- Be able to seamlessly communicate with any other language supported by Godot,
  like GDScript, Visual Script and C#, in an idiomatic way
- Simple script definition interface that doesn't need `require`ing anything,
  with an empty file being a valid script
- Support for Lua 5.1+ and LuaJIT
- Have a simple build process, where anyone with the cloned source code and
  installed build system + toolchain can build the project in a single step


## Non-goals
- Provide calls to core Godot classes' methods via native method bindings
- Support multithreading on the Lua side


## Script example
This is an example of how a Lua script will look like. There are comments regarding
some design decisions, which may change during development.

```lua
-- Optional: set class as tool
tool()

-- Optional: set base class by name, defaults to 'Reference'
extends 'Node'

-- Optional: give your class a name
class_name 'MyClass'

-- Declare signals
signal("something_happened")
signal("something_happened_with_args", "arg1", "arg2")

-- Values defined in _ENV are registered as properties of the class
some_prop = 42

-- Local variables and global ones are **not** registered properties
-- Notice that script environment **is not the global _G table**
local some_lua_local = false
_G.some_lua_global = false

-- The `property` function adds metadata to defined properties,
-- like setter and getter functions
some_prop_with_details = property {
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
  export = false,
  -- TODO: usage, hint/hint_text, rset_mode
}
-- `export` is an alias for `property` with `export = true`
some_exported_prop = export { "hello world!" }

-- Functions defined in _ENV are public methods
function some_prop_doubled(self)
  return self.some_prop * 2
end

function _init(self)
  -- Singletons are available globally
  local os_name = OS:get_name()
  print("MyClass instance initialized! Running on a " .. os_name .. " system")
end
```


## Building
This project uses git submodules for some dependencies, so be sure to activate
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

Build using [xmake](https://xmake.io/) from project root:

```sh
xmake
```

The GDNativeLibrary file `lua_pluginscript.gdnlib` is already configured to use
the built files stored in the `build` folder, so that one can use this
repository directly inside a Godot project.
