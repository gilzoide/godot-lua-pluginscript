-- @file godot_dictionary.lua  Wrapper for GDNative's Dictionary
-- This file is part of Godot Lua PluginScript: https://github.com/gilzoide/godot-lua-pluginscript
--
-- Copyright (C) 2021-2023 Gil Barbosa Reis.
-- 
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the “Software”), to
-- deal in the Software without restriction, including without limitation the
-- rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
-- sell copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
-- 
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
-- 
-- THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
-- FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
-- IN THE SOFTWARE.

--- Dictionary metatype, wrapper for `godot_dictionary`.
-- Construct using the idiom `Dictionary(from)`, which calls `__new`.
-- @classmod Dictionary

local Dictionary_erase = api_1_1 ~= nil and api_1_1.godot_dictionary_erase_with_return or api.godot_dictionary_erase

local methods = {
	fillvariant = api.godot_variant_new_dictionary,
	varianttype = VariantType.Dictionary,

	--- Returns the number of keys in the Dictionary.
	-- @function size
	-- @treturn int
	size = api.godot_dictionary_size,
	--- Returns `true` if the Dictionary is empty.
	-- @function empty
	-- @treturn bool
	empty = api.godot_dictionary_empty,
	--- Clear the Dictionary, removing all key/value pairs.
	-- @function clear
	clear = api.godot_dictionary_clear,
	--- Returns `true` if the Dictionary has a given key.
	-- @function has
	-- @param key
	-- @treturn bool
	has = function(self, key)
		return api.godot_dictionary_has(self, Variant(key))
	end,
	--- Returns `true` if the dictionary has all the given keys.
	-- @function has_all
	-- @param ...  If only a table or Array value is passed, its values are used as search keys.
	--   Otherwise, all passed arguments will be used as search keys.
	-- @treturn bool
	has_all = function(self, keys, ...)
		if select('#', ...) > 0 or not ffi_istype(Array, keys) then
			keys = Array(keys, ...)
		end
		return api.godot_dictionary_has_all(self, keys)
	end,
	--- Erase a dictionary key/value pair by key.
	-- Returns `true` if the given key was present in the Dictionary, `false` otherwise.
	-- Does not erase elements while iterating over the dictionary.
	-- @function erase
	-- @param key  Key, boxed with `Variant.__new`
	-- @treturn bool
	erase = function(self, key)
		return Dictionary_erase(self, Variant(key))
	end,
	--- Returns a hashed integer value representing the Dictionary contents.
	-- This can be used to compare Dictionaries by value.
	-- Note: Dictionaries with the same keys/values but in a different order will have a different hash.
	-- @function hash
	-- @treturn int
	hash = api.godot_dictionary_hash,
	--- Returns the list of keys in the Dictionary.
	-- @function keys
	-- @treturn Array
	keys = function(self)
		return ffi_gc(api.godot_dictionary_keys(self), api.godot_array_destroy)
	end,
	--- Returns the list of values in the Dictionary.
	-- @function values
	-- @treturn Array
	values = function(self)
		return ffi_gc(api.godot_dictionary_values(self), api.godot_array_destroy)
	end,
	--- Returns the current value for the specified `key` in the Dictionary.
	-- If the key does not exist, the method returns the value of the optional `default` argument, or `nil` if it is omitted.
	-- @function get
	-- @param key
	-- @param[opt] default  Default value to be returned if key doesn't exist in Dictionary
	-- @return Unboxed value or `default` or nil
	get = function(self, key, default)
		if default ~= nil and api_1_1 ~= nil then
			return ffi_gc(api_1_1.godot_dictionary_get_with_default(self, Variant(key), Variant(default)), api.godot_variant_destroy):unbox()
		else
			return ffi_gc(api.godot_dictionary_get(self, Variant(key)), api.godot_variant_destroy):unbox()
		end
	end,
	--- Set a new value for the specified `key` in the Dictionary.
	-- @function set
	-- @param key
	-- @param value
	set = function(self, key, value)
		api.godot_dictionary_set(self, Variant(key), Variant(value))
	end,
	--- Returns the next key/value pair Dictionary's, similar to Lua's [next](https://www.lua.org/manual/5.1/manual.html#pdf-next).
	-- This is used to iterate over Dictionaries in `__pairs`. 
	-- @usage
	--     local key, value = nil  -- First key being `nil`, the iteration begins
	--     while true do
	--	       key, value = dict:next(key)
	--	       if key == nil then break end
	--	       -- do something
	--	   end
	-- @function next
	-- @param key  If `nil`, returns the first key/value pair.
	--   Otherwise, returns the next key/value pair.
	-- @return[1] Key
	-- @return[1] Value
	-- @treturn[2] nil  If there are no more keys
	-- @see __pairs
	next = function(self, key)
		if key ~= nil then
			key = Variant(key)
		end
		local next_key = api.godot_dictionary_next(self, key)
		if next_key ~= nil then
			return next_key:unbox(), self:get(next_key)
		else
			return nil
		end
	end,
	--- Returns a String with JSON representation of the Dictionary's contents.
	-- @function to_json
	-- @treturn String
	to_json = function(self)
		return ffi_gc(api.godot_dictionary_to_json(self), api.godot_string_destroy)
	end,
}

if api_1_2 ~= nil then
	--- Creates a copy of the dictionary, and returns it.
	-- The `deep` parameter causes inner Dictionaries and Arrays to be copied recursively, but does not apply to Objects.
	-- @function duplicate
	-- @param[opt=false] deep
	-- @treturn Dictionary
	methods.duplicate = function(self, deep)
		return ffi_gc(api_1_2.godot_dictionary_duplicate(self, deep or false), api.godot_dictionary_destroy)
	end
end

if api_1_3 ~= nil then
	--- Adds elements from `dictionary` to this Dictionary.
	-- By default, duplicate keys will not be copied over, unless `overwrite` is `true`.
	-- @function merge
	-- @tparam Dictionary dictionary
	-- @param[opt=false] overwrite
	methods.merge = function(self, dictionary, overwrite)
		api_1_3.godot_dictionary_merge(self, dictionary, overwrite or false)
	end
end

Dictionary = ffi_metatype('godot_dictionary', {
	--- Dictionary constructor, called by the idiom `Dictionary(value)`.
	-- @function __new
	-- @param[opt] value  If passed, the key/value pairs will be iterated with
	--  `pairs` and inserted into the new Dictionary using `set`.
	--  Notice that both tables and userdata/cdata with a `__pairs` metamethod
	--  are valid, including another Dictionary.
	-- @treturn Dictionary
	__new = function(mt, value)
		local self = ffi_new('godot_dictionary')
		api.godot_dictionary_new(self)
		if value then
			for k, v in pairs(value) do
				self[k] = v
			end
		end
		return self
	end,
	__index = function(self, key)
		return methods[key] or methods.get(self, key)
	end,
	--- Set a value to Dictionary.
	-- If `value` is `nil`, the `key` will be `erase`d, similarly to Lua tables.
	-- To insert a Nil Variant into Dictionary, use `set` instead.
	-- @function __newindex
	-- @param key
	-- @param value
	__newindex = function(self, key, value)
		if type(value) == 'nil' then
			api.godot_dictionary_erase(self, Variant(key))
		else
			api.godot_dictionary_set(self, Variant(key), Variant(value))
		end
	end,
	__gc = api.godot_dictionary_destroy,
	--- Returns a Lua string representation of this Dictionary.
	-- @function __tostring
	-- @treturn string
	__tostring = gd_tostring,
	--- Concatenates values.
	-- @function __concat
	-- @param a  First value, stringified with `GD.str`
	-- @param b  First value, stringified with `GD.str`
	-- @treturn String
	__concat = concat_gdvalues,
	--- Alias for `size`.
	-- @function __len
	-- @treturn int
	-- @see size
	__len = function(self)
		return methods.size(self)
	end,
	--- Returns the `next` iterator and `self`, called by the idiom `pairs(dictionary)`.
	-- @usage
	--     for k, v in pairs(dictionary) do
	--         -- do something
	--     end
	-- @function __pairs
	-- @treturn function
	-- @treturn Dictionary  self
	__pairs = function(self)
		return methods.next, self
	end,
})

