# Godot Lua PluginScript

<img src="extras/icon.png" alt="Lua PluginScript icon" width="128" height="128"/>

[![Godot Asset Library Icon](https://img.shields.io/static/v1?style=for-the-badge&logo=godotengine&label=asset%20library&color=478CBF&message=0.5.2)](https://godotengine.org/asset-library/asset/1078)
[![Pluginscript Lua](https://img.shields.io/discord/1056941025559588874.svg?label=Discord&logo=Discord&colorB=7289da&style=for-the-badge)](https://discord.gg/rZJbXZXQWe)

> **WARNING**: This does not work with Godot 4, since it relies on GDNative, a Godot 3 only technology.
> 
> To use Lua as a scripting language in Godot 4, use [Lua GDExtension](https://github.com/gilzoide/lua-gdextension) instead.

GDNative + PluginScript library that adds support for [Lua](https://www.lua.org/)
as a scripting language in [Godot](https://godotengine.org/) 3.

Being a GDNative library, recompiling the engine is not required, so anyone
with a built release copied to their project can use it.
Being a PluginScript language, Lua can seamlessly communicate with scripts
written in GDScript / C# / Visual Script and vice-versa.
Since the Godot object model is dynamic at runtime, any Godot objects'
properties/methods can be accessed from Lua, including singletons like `OS`,
`ClassDB` and custom singleton nodes.
This way, one can use the language that best suits the implementation for each
script and all of them can understand each other.

This plugin is available in the Asset Library as [Lua PluginScript](https://godotengine.org/asset-library/asset/1078).

For some usage examples, check out [plugin/lua\_repl.lua](plugin/lua_repl.lua)
and [plugin/export\_plugin.lua](plugin/export_plugin.lua).

Currently, only LuaJIT is supported, since the implementation is based on its
[FFI](https://luajit.org/ext_ffi.html) library.


## Installing

Either:

- In Godot Editor, open the [Asset Library tab](https://docs.godotengine.org/en/stable/tutorials/assetlib/using_assetlib.html#in-the-editor),
  search for the [Lua PluginScript](https://godotengine.org/asset-library/asset/1078)
  asset, download and install it.
- Put a built release of the library into the project folder and restart Godot.
  Make sure the `lua_pluginscript.gdnlib` file is located at the
  `res://addons/godot-lua-pluginscript` folder.
- Clone this repository as the project's `res://addons/godot-lua-pluginscript`
  folder and build for the desired platforms.


## Documentation

- [From GDScript to Lua](extras/docs/from-gdscript-to-lua.md)
- [Lua-specific API reference](https://gilzoide.github.io/godot-lua-pluginscript/topics/README.md.html)
- [Configuring](extras/docs/configuring.md)
- [Editor plugin (REPL and minify on release export)](extras/docs/plugin.md)
- [Using LuaRocks](extras/docs/luarocks.md)
- [Known limitations](extras/docs/limitations.md)
- [Building](extras/docs/building.md)
- [Changelog](CHANGELOG.md)


## Goals

- Provide support for Lua as a scripting language in Godot in a way that does
  not require compiling the engine from scratch
- Be able to seamlessly communicate with any other language supported by Godot,
  like GDScript, Visual Script and C#, in an idiomatic way.
  This includes being able to dynamically access any Godot object's properties
  and methods using Lua's index/method notation
- Have automatic global access to Godot's singleton objects and custom
  singleton nodes
- Simple script description interface that doesn't need `require`ing anything
- Support for LuaJIT and Lua 5.2+
- Support paths relative to `res://*` and exported game/app executable path for
  `require`ing Lua modules
- Have a simple build process, where anyone with the cloned source code and
  installed build system + toolchain can build the project in a single step


## Non-goals

- Provide calls to core Godot classes' methods via native method bindings
- Support multithreading on the Lua side


## Articles

1. [Designing Godot Lua PluginScript](https://github.com/gilzoide/godot-lua-pluginscript/blob/main/extras/articles/1-design-en.md)
2. [Implementing the library's skeleton](https://github.com/gilzoide/godot-lua-pluginscript/blob/main/extras/articles/2-infrastructure-en.md)
3. [Integrating LuaJIT and FFI](https://github.com/gilzoide/godot-lua-pluginscript/blob/main/extras/articles/3-luajit-callbacks-en.md)
4. Initializing and finalizing scripts (TODO)


## Script example

This is an example of how a Lua script looks like.

```lua
-- Class definitions are regular Lua tables, to be returned from the script
local MyClass = {}

-- Optional: set class as tool, defaults to false
MyClass.is_tool = true

-- Optional: set base class by name, defaults to 'Reference'
MyClass.extends = Node

-- Optional: give your class a name
MyClass.class_name = 'MyClass'

-- Declare signals
MyClass.something_happened = signal()
MyClass.something_happened_with_args = signal("arg1", "arg2")

-- Values defined in table are registered as properties of the class
-- By default, properties are not exported to the editor
MyClass.some_prop = 42

-- The `property` function adds metadata to defined properties,
-- like setter and getter functions
MyClass.some_prop_with_details = property {
  -- ["default_value"] or ["default"] or [1] = property default value
  5,
  -- ["type"] or [2] = variant type, optional, inferred from default value
  -- All Godot variant type names are defined globally as written in
  -- GDScript, like bool, int, float, String, Array, Vector2, etc...
  -- Notice that Lua <= 5.2 does not differentiate integers from float
  -- numbers, so we should always specify `int` where appropriate
  -- or use `int(5)` in the default value instead
  type = int,
  -- ["get"] or ["getter"] = getter function or method name, optional
  get = function(self)
    return self.some_prop_with_details
  end,
  -- ["set"] or ["setter"] = setter function or method name, optional
  set = 'set_some_prop_with_details',
  -- ["usage"] = property usage, from `enum godot_property_usage_flags`
  -- optional, default to `PropertyUsage.NOEDITOR`
  usage = PropertyUsage.NOEDITOR,
  -- ["hint"] = property hint, from `enum godot_property_hint`
  -- optional, default to `PropertyHint.NONE`
  hint = PropertyHint.RANGE,
  -- ["hint_string"] = property hint text, only required for some hints
  hint_string = '1,10',
  -- ["rset_mode"] = property remote set mode, from `enum godot_method_rpc_mode`
  -- optional, default to `RPCMode.DISABLED`
  rset_mode = RPCMode.MASTER,
}
-- The `export` function is an alias for `property` that always exports
-- properties to the editor
MyClass.exported_prop = export { "This property appears in the editor" }
MyClass.another_exported_prop = export {
  [[This one also appears in the editor,
now with a multiline TextArea for edition]],
  hint = PropertyHint.MULTILINE_TEXT,
}

-- Functions defined in table are public methods
function MyClass:_ready()  -- `function t:f(...)` is an alias for `function t.f(self, ...)`
  -- Singletons are available globally
  local os_name = OS:get_name()
  print("MyClass instance is ready! Running on a " .. os_name .. " system")

  -- There is no `onready` keyword like in GDScript
  -- Just get the needed values on `_ready` method
  -- Also, Lua doesn't have the `$child_node` syntax, use `get_node` instead
  self.some_grandchild_node = self:get_node("some/grandchild_node")
end

function MyClass:set_some_prop_with_details(value)
    self.some_prop_with_details = value
    -- Indexing `self` with keys undefined in script will search base
    -- class for methods and properties
    self:emit_signal("something_happened_with_args", "some_prop_with_details", value)
end

function MyClass:get_some_prop_doubled()
  return self.some_prop * 2
end

-- In the end, table with class declaration must be returned from script
return MyClass
```


## Status

- [X] LuaJIT support
- [ ] Lua 5.2+ support
- [X] Useful definitions for all GDNative objects, with methods and metamethods
- [X] A `yield` function similar to GDScript's, to resume after a signal is
  emitted (`GD.yield`)
- [X] Working PluginScript language definition
- [X] PluginScript script validation and template source code
- [ ] PluginScript code editor callbacks
- [ ] PluginScript debug callbacks
- [ ] PluginScript profiling callbacks
- [X] Package searcher for Lua and C modules that work with paths relative to
  the `res://` folder and/or exported games' executable path
- [X] Lua REPL
- [X] API documentation
- [ ] Unit tests
- [ ] Example projects
- [X] Export plugin to minify Lua scripts
- [X] Drop-in binary release in GitHub
- [X] Submit to Asset Library


## Third-party software

This project uses the following software:

- [godot-headers](https://github.com/godotengine/godot-headers): headers for
  GDNative, distributed under the MIT license
- [LuaJIT](https://luajit.org/luajit.html): Just-In-Time Compiler (JIT) for the
  Lua programming language, distributed under the MIT license
- [High Level GDNative (HGDN)](https://github.com/gilzoide/high-level-gdnative):
  higher level GDNative API header, released to the Public Domain
- [LuaSrcDiet](https://github.com/jirutka/luasrcdiet): compresses Lua source
  code by removing unnecessary characters, distributed under the MIT license
- [LuaUnit](https://github.com/bluebird75/luaunit): unit-testing framework for
  Lua, distributed under the BSD license
- [debugger.lua](https://github.com/slembcke/debugger.lua): dependency free,
  single file embeddable debugger for Lua, distributed under the MIT license
 

## Other projects for using Lua in Godot

- https://github.com/perbone/luascript
- https://github.com/Trey2k/lua
- https://github.com/zozer/godot-lua-module
