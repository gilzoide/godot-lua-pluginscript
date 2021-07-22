# Godot Lua PluginScript


## Script example
```lua
-- Optional: set script as tool
tool()

-- Set base class by name, defaults to 'Reference'
extends 'Node'

-- Declare signals
signal("something_happened")
signal("something_happened_with_args", "arg1", "arg2")

-- Values defined in _ENV are properties
some_prop = 42

-- Define properties with metadata, setter and getter functions
some_prop_with_details = property {
  -- [1] or ["default"] or ["default_value"] = property default value.
  -- If absent, try using some value already defined in _ENV, defaulting to `null`, e.g.: _ENV["some_prop_with_details"]
  5,
  -- [2] or ["type"] = variant type, optional, inferred from default value, if present
  -- All Godot variant type names are defined globally as written in GDScript, like bool, int, float, String, Array, etc...
  type = int,
  -- ["set"] or ["setter"] = setter function, optional
  set = function(value)
    some_prop_with_details = value
    -- Unknown names to _ENV will search base class for methods and properties, respectively
    emit_signal("something_happened_with_args", "some_prop_with_details", value)
  end,
  -- ["get"] or ["getter"] = getter function, optional
  get = function()
    return some_prop_with_details
  end,
  -- ["export"] = export flag, optional
  export = false,
  -- TODO: usage, hint/hint_text, rset_mode
}
-- `export` is an alias for `property` with `export = true`
export {
  "some_exported_prop", "hello world!"
}

-- Functions defined in _ENV are public methods
function some_prop_doubled()
  return some_prop * 2
end
```
