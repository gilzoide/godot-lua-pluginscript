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
        -- be garbage-collected or not, since C APIs may require the
        -- caller to clean the memory up or not.
        -- Explicitly track the return in cases where we own the data,
        -- such as this one: in the GDNative API, when a function
        -- returns a struct/union and not a pointer, we own the data.
        ffi.gc(str, api.godot_string_destroy)
        return str
    end,
})
