# From GDScript to Lua
Some examples on how to translate GDScript code to Lua.

This document assumes you know how to write GDScript code.
Check out [GDScript Basics](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html) for more detail into the GDScript language.


## Empty script
GDScript:
```gdscript
extends Node
# optionally, give your class a name
class_name MyClass
```

Lua:
```lua
local MyClass = {
  extends = Node,
  -- optionally, give your class a name
  class_name = 'MyClass',
}

-- Returning the class table is mandatory when creating Godot Lua scripts
return MyClass
```


## Declaring methods
GDScript:
```gdscript
extends Node


func _ready():
    print("I'm ready!")

func receives_argument(arg1):
    pass

func returns_value():
    return 42
```

Lua:
```lua
local MyClass = {
  extends = Node,
}

-- Use `:` to declare methods, so the function implicitly
-- declares the `self` argument
function MyClass:_ready()
  print("I'm ready!")
end
-- ^ The above is the same as:
function MyClass._ready(self)
  print("I'm ready!")
end
-- You need the `self` argument to access properties and
-- other methods on the object instance

function MyClass:receives_argument(arg1)
end

function MyClass:returns_value()
  return 42
end

-- Assigning functions to the class table works too
MyClass.another_function = function(self, delta)
end

return MyClass
```


## Calling methods on instance
GDScript:
```gdscript
extends Node

func _ready():
    set_process(true)
```

Lua:
```lua
local MyClass = { extends = Node }

function MyClass:_ready()
  -- Object methods need to be accessed from `self`
  -- Note the method call notation with `:`
  self:set_process(true)

  -- Just like when defining methods, the `:` implicitly
  -- passes `self` to the function, so both are the same
  self:set_process(true)
  self.set_process(self, true)
end

return MyClass
```
Lua function call reference, explaining the method syntax sugar: https://www.lua.org/manual/5.1/manual.html#2.5.8


## Declaring and accessing properties
GDScript:
```gdscript
extends Node


var some_property = "Hello!"


func _ready():
    print(some_property)  #--> "Hello!"
    some_property = "another value"
    print(some_property)  #--> "another value"

    print(property_not_declared)  #--> Error!!!
        # ^ identifier not declared in current scope
    
    another_property_not_declared = "value"  #--> Error!!!
    # ^ identifier not declared in current scope
```

Lua:
```lua
local MyClass = { extends = Node }

MyClass.some_property = "Hello!"

MyClass.some_property_with_metadata = property({
  default = 42,
  type = int,
})

function MyClass:_ready()
  -- object properties need to be accessed from `self`
  print(self.some_property)  --> "Hello!"
  self.some_property = "another value"
  print(self.some_property)  --> "another value"
  
  -- This does not error, you simply get a `nil` value
  print(self.property_not_declared)  --> nil

  -- This does not error, the value is set correctly
  self.another_property_not_declared = "value"
  -- WARNING: properties not declared in `MyClass` are
  -- only available in Lua
  -- GDScript / C# will not be able to access them
end

return MyClass
```


## Declaring exported properties
GDScript
```gdscript
extends Node


export var some_value = ""
export(Array) var some_typed_value
export(int, 1, 10) var some_int_from_1_to_10 = 1
```

Lua:
```lua
local MyClass = { extends = Node }

-- Use the `export` function to export properties
MyClass.some_value = export("")

MyClass.some_typed_value = export({
  type = Array,
})

-- Special export hints need `hint` and optionally `hint_string`
-- It's not a nice API, as it just interfaces directly with GDNative
-- Maybe someday we'll implement something nicer...
MyClass.some_int_from_1_to_10 = export({
  default_value = 1,
  type = int,
  hint = PropertyHint.RANGE,
  hint_string = "1,10",
})

return MyClass
```
As noted in the [limitations document](limitations.md), instances in editor are not reloaded when a script is edited.
That means that adding/removing/updating an exported property won't show in
the editor and `tool` scripts won't be reloaded until the project is reopened.


## Getting nodes
GDScript:
```gdscript
extends Node


func _ready():
    var some_child_node = $child_node
    # `$child_node` is the same as `get_node("child_node")`
    some_child_node = get_node("child_node")
```

Lua:
```lua
local MyClass = { extends = Node }

function MyClass:_ready()
  -- Lua does not have the `$node_path` syntax
  -- Use the `get_node` method explicitly instead
  local some_child_node = self:get_node("child_node")
end

return MyClass
```


## `onready` properties
GDScript:
```gdscript
extends Node


onready var some_child_node = $child_node
# ^ it's the same as getting the value in `_ready` method:
#
# var some_child_node
#
# func _ready():
#     some_child_node = $child_node
```

Lua:
```lua
local MyClass = { extends = Node }

-- Lua does not have the `onready` syntax
-- Just get the value in `_ready` method explicitly
function MyClass:_ready()
  local some_child_node = self:get_node("child_node")
end

return MyClass
```


## Property setter functions
GDScript:
```gdscript
extends Node


# Declaring
var with_setter setget setter_function


func setter_function(new_value):
    print('with_setter new value = ' + new_value)
    # setting value without `self.` bypasses setter
    with_setter = new_value

# Calling
func _ready():
    # using `self.` calls the setter function
    self.with_setter = 'set via setter'
    # without `self.`, setter function won't be called
    with_setter = 'this will not call setter function'
```

Lua:
```lua
local MyClass = { extends = Node }

-- Declaring
MyClass.with_setter = property({
  type = String,
  set = function(self, new_value)
    print('with_setter new value = ' .. new_value)
    -- bypass call to setter function using `rawset`
    self:rawset('with_setter', new_value)
  end,
})

-- Calling
function MyClass:_ready()
  -- using indexing syntax calls the setter functions
  self.with_setter = 'set via setter'
  -- to bypass setter functions, use the `rawset` method
  self:rawset('with_setter', 'this will not call setter function')
end

return MyClass
```


## Property getter functions
GDScript:
```gdscript
extends Node


# Declaring
var with_getter setget , getter_function = 'default value'


func getter_function():
    return 'constant from getter'

# Calling
func _ready():
    # using `self.` calls the getter function
    print(self.with_getter)  #--> 'constant from getter'
    # without `self.`, getter function won't be called
    print(with_getter)  #--> 'default value'
```

Lua:
```lua
local MyClass = { extends = Node }

-- Declaring
MyClass.with_getter = property({
  default = 'default value',
  type = String,
  get = function(self)
    return 'constant from getter'
  end,
})

-- Calling
function MyClass:_ready()
  -- using indexing syntax calls the getter function
  print(self.with_getter)  --> 'constant from getter'
  -- to bypass getter functions, use the `rawget` method
  print(self:rawget('with_getter'))  --> 'default value'
end

return MyClass
```


## Arrays
GDScript:
```gdscript
extends Node

func _ready():
    # Creating an array
    var array = [1, 2, 3]
    
    # Accessing individual elements
    assert(array[0] == 1)
    assert(array[1] == 2)
    assert(array[2] == 3)

    # Setting elements
    array[3] = 4

    # Accessing out of bounds elements
    print(array[10])  #--> Error!!!
        # ^ Invalid get index '10'

    # Get element count
    print(array.size())
    
    # Iterating
    for array_element in array:
        print(array_element)
```

Lua:
```lua
local MyClass = { extends = Node }

function MyClass:_ready()
  -- Creating an array
  local array = Array(1, 2, 3)

  -- Accessing individual elements
  -- In Lua, arrays are indexed from 1 just like Lua tables
  assert(array[1] == 1)
  assert(array[2] == 2)
  assert(array[3] == 3)
  -- To use 0-based indexing, call `get` or `safe_get` directly
  assert(array:get(0) == 1)
  assert(array:safe_get(0) == 1)
  -- !!! WARNING: `get` will crash your game if out of bounds !!!
  -- `safe_get`, on the other hand, will just return `nil`

  -- Setting elements
  array[4] = 4
  -- To use 0-based indexing, call `set` or `safe_set` directly
  -- !!! WARNING: `set` will crash your game if out of bounds !!!
  -- `safe_set` may resize the array before setting the value
  array:safe_set(3, 4)

  -- Accessing out of bounds elements is not an error
  -- `nil` is returned
  print(array[10])  --> nil

  -- Get element count with the length operator `#`
  print(#array)
  -- The `size` method works as well
  print(array:size())

  -- Iterating
  for iteration_index, array_element in ipairs(array) do
    print(iteration_index, array_element)
  end
end

return MyClass
```


## Declaring and emitting signals
GDScript:
```gdscript
extends Node


signal my_signal()
signal my_signal_with_args(arg1, arg2)


func _ready():
    emit_signal('my_signal')
    emit_signal('my_signal_with_args', 'hello', 'world')
```

Lua:
```lua
local MyClass = { extends = Node }

MyClass.my_signal = signal()
MyClass.my_signal_with_args = signal('arg1', 'arg2')

function MyClass:_ready()
  self:emit_signal('my_signal')
  self:emit_signal('my_signal_with_args', 'hello', 'world')
end

return MyClass
```


## Loading Resources
GDScript:
```gdscript
extends Node


func _ready():
    var game_icon = load("res://icon.png")
```

Lua:
```lua
local MyClass = { extends = Node }

function MyClass:_ready()
  local game_icon = GD.load("res://icon.png")
end

return MyClass
```


## Coroutines and signals
GDScript (reference docs: https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html#coroutines-signals):
```gdscript
extends Node


func _ready():
    print('This happens some frame')
    yield(get_tree(), 'idle_frame')  # await for next frame
    print('And this happens in the next frame')
```

Lua:
```lua
local MyClass = { extends = Node }

MyClass.my_signal = signal()
MyClass.my_signal_with_args = signal('arg1', 'arg2')

function MyClass:_ready()
  print('This happens some frame')
  GD.yield(get_tree(), 'idle_frame')  -- await for next frame
  print('And this happens in the next frame')
end

return MyClass
```
`GD.yield` should be used instead of Lua's `coroutine.yield` if you want to wait for Godot Objects' signals.
Lua methods that call `GD.yield` return [LuaCoroutine](../../lps_coroutine.lua) objects, which are analogous to GDScript's [GDScriptFunctionState](https://docs.godotengine.org/en/stable/classes/class_gdscriptfunctionstate.html).


## Tool scripts
GDScript:
```gdscript
tool
extends Node
```

Lua:
```lua
local MyClass = {
  is_tool = true,
  extends = Node,
}

return MyClass
```


TODO: dictionary (mainly `pairs`)