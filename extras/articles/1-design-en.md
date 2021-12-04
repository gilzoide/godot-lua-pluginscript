# Designing a Godot PluginScript for Lua
2021-07-28 | `#Godot #Lua #GDNative #PluginScript #languageBindings` | [*Versão em Português*](1-design-pt.md)

This is the first article in a series about how I'm approaching the development
of a plugin for using the [Lua](https://www.lua.org/) language in
[Godot game engine](https://godotengine.org/).

Lua is a simple and small, yet powerful and flexible, scripting language.
Although it [isn't fit for every scenario](https://docs.godotengine.org/en/stable/about/faq.html#what-were-the-motivations-behind-creating-gdscript),
it is certainly a great tool for scripting.
Combining that with the power of [LuaJIT](https://luajit.org/),
one of the fastest dynamic language implementations out there, we can also
[call external C functions via the Foreign Function Interface (FFI)](https://luajit.org/ext_ffi.html)!

With the dynamic nature of scripting in Godot, all supported languages
can seamlessly communicate with each other and thus we can choose to use the
language that best fits the task in hand for each script.
By the means of [signals](https://docs.godotengine.org/en/stable/getting_started/step_by_step/signals.html)
and the methods [call](https://docs.godotengine.org/en/stable/classes/class_object.html#class-object-method-call),
[get](https://docs.godotengine.org/en/stable/classes/class_object.html#id1)
and [set](https://docs.godotengine.org/en/stable/classes/class_object.html#id4),
any object can communicate with another one, regardless of the
source language.

To make Lua be recognized as one of the supported scripting languages for Godot
objects, we will create a PluginScript, which is one of the uses of
[GDNative](https://docs.godotengine.org/en/stable/getting_started/step_by_step/scripting.html#gdnative-c),
the native plugin C API provided by the engine to extend all sorts of
engine systems, such as the scripting one.
One pro of this approach is that only the plugin have to be compiled,
so anyone with a standard prebuilt version of Godot can use it! =D


## Goals
- Provide support for the Lua language in Godot in a way that does not require
  compiling the engine from scratch
- Be able to seamlessly communicate with any other language supported by Godot,
  like GDScript, Visual Script and C#, in an idiomatic way
- Simple script description interface that doesn't need `require`ing anything
- Support for Lua 5.2+ and LuaJIT
- Have a simple build process, where anyone with the cloned source code and
  installed build system + toolchain can build the project in a single step


## Non-goals
- Provide calls to core Godot classes' methods via native method bindings
- Support multithreading on the Lua side


## Script example
This is an example of how a Lua script will look like. There are comments regarding
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
  -- or use `int(5)` in the default value instead
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
  -- ["usage"] = property usage, from enum godot_property_usage_flags
  -- optional, default to GD.PROPERTY_USAGE_DEFAULT
  usage = GD.PROPERTY_USAGE_DEFAULT,
  -- ["hint"] = property hint, from enum godot_property_hint
  -- optional, default to GD.PROPERTY_HINT_NONE
  hint = GD.PROPERTY_HINT_RANGE,
  -- ["hint_string"] = property hint text, only required for some hints
  hint_string = '1,10',
  -- ["rset_mode"] = property remote set mode, from enum godot_method_rpc_mode
  -- optional, default to GD.RPC_MODE_DISABLED
  rset_mode = GD.RPC_MODE_MASTER,
}

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


## Implementation design details
PluginScripts have three important concepts: the Language Description,
Script Manifest and Instances.

Let's check out what each layer is and how they will behave from a high
level perspective:


### Language description
The language description tells Godot how to initialize and finalize our
language runtime, as well as how to load script manifests from source
files.

When initializing the runtime, a new [lua_State](https://www.lua.org/manual/5.4/manual.html#lua_State)
will be created and Godot functionality setup in it.
The Lua Virtual Machine (VM) will use engine memory management routines, so
that memory is tracked by the performance monitors in debug builds of the
game/application.
All scripts will share this same state.

There will be a global table named `GD` with some Godot specific
functions, such as [load](https://docs.godotengine.org/en/stable/classes/class_%40gdscript.html#class-gdscript-method-load),
[print](https://docs.godotengine.org/en/stable/classes/class_%40gdscript.html#class-gdscript-method-print),
[push_error](https://docs.godotengine.org/en/stable/classes/class_%40gdscript.html#class-gdscript-method-push-error),
[push_warning](https://docs.godotengine.org/en/stable/classes/class_%40gdscript.html#class-gdscript-method-push-warning)
and [yield](https://docs.godotengine.org/en/stable/classes/class_%40gdscript.html#class-gdscript-method-yield).
Lua's global `print` function will be set to `GD.print` and
[Lua 5.4 warning function](https://www.lua.org/manual/5.4/manual.html#lua_WarnFunction)
will behave like a `push_warning` call.

Functions that expect file names, like [loadfile](https://www.lua.org/manual/5.4/manual.html#pdf-loadfile)
and [io.open](https://www.lua.org/manual/5.4/manual.html#pdf-io.open),
will be patched to accept paths in the format [`res://*`](https://docs.godotengine.org/en/stable/tutorials/io/data_paths.html#resource-path)
and [`user://*`](https://docs.godotengine.org/en/stable/tutorials/io/data_paths.html#user-path-persistent-data).
Also, a [package searcher](https://www.lua.org/manual/5.4/manual.html#pdf-package.searchers)
will be added so that Lua can [require](https://www.lua.org/manual/5.4/manual.html#pdf-require)
modules from paths relative to `res://`.

Language finalization will simply [lua_close](https://www.lua.org/manual/5.4/manual.html#lua_close) the state.


### Script manifest
Script manifests hold metadata about classes, such as defined signals,
properties and methods, whether class is [tool](https://docs.godotengine.org/en/stable/tutorials/misc/running_code_in_the_editor.html)
and its base class name.

In Lua, this information will be stored in Lua tables indexed by the
scripts' path.

When initializing a script, its source code will be loaded and executed.
Scripts must return a table, which defines the class metadata.
Functions declared in the table are registered as class methods and
other variables are declared as properties or signals.

Script finalization will destroy the manifest table.


### Instances
When a script is attached to an object, the engine will call our
PluginScript to initialize the instance data and when the object gets
destroyed or gets the script removed, we get to finalize the data.

In Lua, instance data will be stored in Lua tables indexed by the
instance owner object's memory address.

When instances are indexed with a key that is not present, methods and
property default values will be searched in the script manifest and its
base class, in that order.
This table will be passed to methods as their first argument, as if
using Lua's method call notation: `instance:method(...)`.

Instance finalization will destroy the data table.


## Wrapping up
With this high level design in place, we can now start implementing the
plugin! I have created a Git repository for it hosted at
[https://github.com/gilzoide/godot-lua-pluginscript](https://github.com/gilzoide/godot-lua-pluginscript).

In the [next post](2-infrastructure-en.md) I'll discuss how to build the
necessary infrastructure for the PluginScript to work, with stubs to the
necessary callbacks and a build system that compiles the project in a
single step.

See you there ;D
