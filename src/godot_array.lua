-- @file godot_array.lua  Wrapper for GDNative's Array
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

--- Array metatype, wrapper for `godot_array`.
-- Construct using the idiom `Array(...)`, which calls `__new`.
-- @classmod Array

local methods = {
	fillvariant = api.godot_variant_new_array,
	varianttype = VariantType.Array,

	--- Returns the value at `index`.
	-- Unlike Lua tables, indices start at 0 instead of 1.
	-- For 1-based indexing, use the idiom `array[index]` instead.
	--
	-- If `index` is invalid (`index < 0` or `index >= size()`), the application will crash.
	-- For a safe version that returns `nil` if `index` is invalid, use `safe_get` or the idiom `array[index]` instead.
	-- @function get
	-- @tparam int index
	-- @return Value
	-- @see safe_get
	get = function(self, index)
		return ffi_gc(api.godot_array_get(self, index), api.godot_variant_destroy):unbox()
	end,
	--- Set a new `value` for `index`.
	-- Unlike Lua tables, indices start at 0 instead of 1.
	-- For 1-based indexing, use the idiom `array[index] = value` instead.
	--
	-- If `index` is invalid (`index < 0` or `index >= size()`), the application will crash.
	-- For a safe approach that `resize`s if `index >= size()`, use `safe_set` or the idiom `array[index] = value` instead.
	-- @function set
	-- @tparam int index
	-- @param value
	-- @see safe_set
	set = function(self, index, value)
		api.godot_array_set(self, index, Variant(value))
	end,
	--- Clears the Array.
	-- This is equivalent to using `resize` with a size of 0.
	-- @function clear
	-- @see resize
	clear = api.godot_array_clear,
	--- Returns the number of times an element is in the Array.
	-- @function count
	-- @param value
	-- @treturn int
	count = function(self, value)
		return api.godot_array_count(self, Variant(value))
	end,
	--- Returns `true` if the Array is empty.
	-- @function empty
	empty = array_empty,
	--- Removes the first occurrence of a value from the array.
	-- To remove an element by index, use `remove` instead.
	-- @function erase
	-- @param value
	-- @see remove
	erase = function(self, value)
		api.godot_array_erase(self, Variant(value))
	end,
	--- Returns the first element of the Array.
	-- Prints an error and returns `nil` if the Array is empty.
	-- @function front
	-- @return First element
	front = function(self)
		return ffi_gc(api.godot_array_front(self), api.godot_variant_destroy):unbox()
	end,
	--- Returns the last element of the Array.
	-- Prints an error and returns `nil` if the Array is empty.
	-- @function back
	-- @return Last element
	back = function(self)
		return ffi_gc(api.godot_array_back(self), api.godot_variant_destroy):unbox()
	end,
	--- Searches the Array for a `value` and returns its index or -1 if not found.
	-- @function find
	-- @param value
	-- @tparam[opt=0] int from  Index to start the search from
	-- @treturn[1] int  Index where `value` was found
	-- @treturn[2] int  -1 if `value` was not found
	find = function(self, what, from)
		return api.godot_array_find(self, Variant(what), from or 0)
	end,
	--- Searches the Array in reverse order for a `value` and returns its index or -1 if not found.
	-- @function find_last
	-- @param value
	-- @treturn[1] int  Index where `value` was found
	-- @treturn[2] int  -1 if `value` was not found
	find_last = function(self, what)
		return api.godot_array_find_last(self, Variant(what))
	end,
	--- Returns `true` if the Array contains the given value.
	-- @function has
	-- @param value
	-- @treturn bool
	has = function(self, value)
		return api.godot_array_has(self, Variant(value))
	end,
	--- Returns a hashed integer value representing the Array and its contents.
	-- @function hash
	hash = api.godot_array_hash,
	--- Inserts a new element at a given position in the Array.
	-- The position must be valid, or at the end of the Array (`pos == size()`).
	insert = function(self, pos, value)
		api.godot_array_insert(self, pos, Variant(value))
	end,
	--- Reverses the order of the elements in the Array.
	-- @function invert
	invert = api.godot_array_invert,
	--- Append elements at the end of the Array.
	-- @function push_back
	-- @param ...
	-- @see push_front
	push_back = function(self, ...)
		for i = 1, select('#', ...) do
			local value = select(i, ...)
			api.godot_array_push_back(self, Variant(value))
		end
	end,
	--- Add elements at the beginning of the Array.
	-- @function push_front
	-- @param ...
	-- @see push_back
	push_front = function(self, ...)
		for i = select('#', ...), 1, -1 do
			local value = select(i, ...)
			api.godot_array_push_front(self, Variant(value))
		end
	end,
	--- Removes and returns the last element of the Array, if there is any.
	-- @function pop_back
	-- @return[1] Last element
	-- @treturn[2] nil  If array is empty.
	pop_back = function(self)
		return ffi_gc(api.godot_array_pop_back(self), api.godot_variant_destroy):unbox()
	end,
	--- Removes and returns the first element of the Array, if there is any.
	-- @function pop_front
	-- @return[1] First element
	-- @treturn[2] nil  If array is empty.
	pop_front = function(self)
		return ffi_gc(api.godot_array_pop_front(self), api.godot_variant_destroy):unbox()
	end,
	--- Removes an element from the Array by `index`.
	-- If the `index` does not exist in the Array, nothing happens.
	-- To remove an element by searching for its value, use `erase` instead.
	-- @function remove
	-- @tparam int index
	-- @see erase
	remove = api.godot_array_remove,
	--- Resizes the Array to contain a different number of elements.
	-- If the Array size is smaller, elements are cleared, if bigger, new elements are `null`.
	-- @function resize
	-- @tparam int size
	resize = api.godot_array_resize,
	--- Searches the Array in reverse order.
	-- @function rfind
	-- @param value
	-- @tparam[opt=-1] int from  Starting search index.
	--  If negative, the start index is considered relative to the end of the Array.
	-- @treturn[1] int  Index where `value` was found
	-- @treturn[2] int  -1 if `value` was not found
	rfind = function(self, what, from)
		return api.godot_array_rfind(self, Variant(what), from or -1)
	end,
	--- Returns the number of elements in the Array.
	-- @function size
	-- @treturn int
	size = api.godot_array_size,
	--- Sorts the Array.
	-- Note: Strings are sorted in alphabetical order (as opposed to natural order).
	-- @function sort
	sort = api.godot_array_sort,
	--- Sorts the Array using a custom method.
	-- The arguments are an `object` that holds the method and the name of such method.
	-- The custom method receives two arguments (a pair of elements from the Array) and must return either `true` or `false`.
	-- @function sort_custom
	-- @tparam Object object
	-- @param func  Method name
	sort_custom = function(self, obj, func)
		api.godot_array_sort_custom(self, _Object(obj), str(func))
	end,
	--- Finds the index of an existing value (or the insertion index that maintains sorting order, if the value is not yet present in the Array) using binary search.
	-- @function bsearch
	-- @param value
	-- @param[opt=true] before  If `false`, the returned index comes after all existing entries of the value in the Array.
	-- @treturn int
	bsearch = function(self, value, before)
		return api.godot_array_bsearch(self, Variant(value), before == nil or before)
	end,
	--- Finds the index of an existing value (or the insertion index that maintains sorting order, if the value is not yet present in the Array) using binary search and a custom comparison method declared in the `object`.
	--  The custom method receives two arguments (an element from the array and the value searched for) and must return `true` if the first argument is less than the second, and return `false` otherwise.
	-- @function bsearch_custom
	-- @param value
	-- @tparam Object object
	-- @param func  Method name
	-- @param[opt=true] before  If `false`, the returned index comes after all existing entries of the value in the Array.
	-- @treturn int
	bsearch_custom = function(self, value, obj, func, before)
		return api.godot_array_bsearch_custom(self, Variant(value), obj, str(func), before == nil or before)
	end,
	--- Duplicates the subset described in the function and returns it in an Array, deeply copying the values if `deep` is `true`.
	-- Lower and upper index are inclusive, with the `step` describing the change between indices while slicing.
	-- @function slice
	-- @tparam int begin  Lower index
	-- @tparam int end  Upper index
	-- @tparam[opt=1] int step
	-- @param[opt=false] deep
	-- @treturn Array
	slice = function(self, begin, _end, step, deep)
		return ffi_gc(api.godot_array_slice(self, begin, _end, step or 1, deep or false), api.godot_array_destroy)
	end,
}

--- Returns the value at `index`.
-- Unlike Lua tables, indices start at 0 instead of 1.
-- For 1-based indexing, use the idiom `array[index]` instead.
--
-- The idiom `array[index]` also calls this method.
-- @function safe_get
-- @tparam int index
-- @return[1] Value
-- @treturn[2] nil  If index is invalid (`index < 0` or `index >= size()`)
-- @see get
methods.safe_get = array_safe_get

--- Set a new `value` for `index`.
-- Unlike Lua tables, indices start at 0 instead of 1.
-- For 1-based indexing, use the idiom `array[index]` instead.
--
-- If `index >= size()`, the Array is `resize`d first.
-- The idiom `array[index] = value` also calls this method.
-- @function safe_set
-- @tparam int index
-- @param value
-- @raise If `index < 0`
-- @see set
methods.safe_set = array_safe_set

--- Alias of `push_back`.
-- @function append
-- @param ...
-- @see push_back
methods.append = methods.push_back

--- Append all values of `iterable` at the end of Array.
-- @function extend
-- @param iterable  Any object iterable by `ipairs`, including Lua tables, `Array`s and `Pool*Array`s.
methods.extend = function(self, iterable)
	for _, value in ipairs(iterable) do
		self:push_back(value)
	end
end

--- Returns a String with each element of the array joined with the given `delimiter`.
-- @function join
-- @param[opt=""] delimiter  
-- @treturn String
methods.join = array_join

if api_1_1 ~= nil then
	--- Returns a copy of the Array.
	-- @function duplicate
	-- @param[opt=false] deep  If `true`, a deep copy is performed: all nested arrays and dictionaries are duplicated and will not be shared with the original Array.
	--  If `false`, a shallow copy is made and references to the original nested arrays and dictionaries are kept, so that modifying a sub-array or dictionary in the copy will also impact those referenced in the source array.
	-- @treturn Array
	methods.duplicate = function(self, deep)
		return ffi_gc(api_1_1.godot_array_duplicate(self, deep or false), api.godot_array_destroy)
	end
	--- Returns the maximum value contained in the Array if all elements are of comparable types.
	-- @function max
	-- @return[1] Maximum value
	-- @treturn[2] nil  If the elements can't be compared 
	methods.max = function(self)
		return ffi_gc(api_1_1.godot_array_max(self), api.godot_variant_destroy):unbox()
	end
	--- Returns the minimum value contained in the Array if all elements are of comparable types.
	-- @function min
	-- @return[1] Minimum value
	-- @treturn[2] nil  If the elements can't be compared 
	methods.min = function(self)
		return ffi_gc(api_1_1.godot_array_min(self), api.godot_variant_destroy):unbox()
	end
	--- Shuffles the array such that the items will have a random order.
	-- @function shuffle
	methods.shuffle = api_1_1.godot_array_shuffle
end

--- Static Functions.
-- These don't receive `self` and should be called directly as `Array.static_function(...)`
-- @section static_funcs

--- Create a new Array with the elements from `iterable` by calling `extend`.
-- @usage
--     local array = Array.from(some_table_or_other_iterable)
-- @function from
-- @param iterable  Any object iterable by `ipairs`, including Lua tables, `Array`s and `Pool*Array`s.
-- @treturn Array
-- @see extend
methods.from = function(iterable)
	local arr = Array()
	arr:extend(iterable)
	return arr
end

--- Metamethods
-- @section metamethods
Array = ffi_metatype('godot_array', {
	--- Array constructor, called by the idiom `Array(...)`.
	-- @function __new
	-- @param ...  Initial elements, added with `push_back`
	__new = function(mt, ...)
		local self = ffi_new(mt)
		api.godot_array_new(self)
		methods.push_back(self, ...)
		return self
	end,
	__gc = api.godot_array_destroy,
	--- Returns method named `index` or the result of `safe_get(index - 1)`.
	-- 
	-- Like Lua tables, indices start at 1. For 0-based indexing, call `get` or
	-- `safe_get` directly.
	-- @function __index
	-- @param index
	-- @return Method or element or `nil`
	-- @see safe_get
	__index = array_generate__index(methods),
	--- Alias for `safe_set(index - 1, value)`.
	--
	-- Like Lua tables, indices start at 1. For 0-based indexing, call `set` or
	-- `safe_set` directly.
	-- @function __newindex
	-- @tparam int index
	-- @param value
	-- @see safe_set
	__newindex = array__newindex,
	--- Returns a Lua string representation of this Array.
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
	__len = array__len,
	--- Returns an iterator for Array's elements, called by the idiom `ipairs(array)`.
	-- @usage
	--     for i, v in ipairs(array) do
	--         -- do something
	--     end
	-- @function __ipairs
	-- @treturn function
	-- @treturn Array  self
	-- @treturn int  0
	__ipairs = array_ipairs,
	--- Alias for `__ipairs`, called by the idiom `pairs(array)`.
	-- @function __pairs
	-- @treturn function
	-- @treturn Array  self
	-- @treturn int  0
	-- @see __ipairs
	__pairs = array_ipairs,
	--- Equality operation
	-- @function __eq
	-- @tparam Array|PoolByteArray|PoolIntArray|PoolRealArray|PoolStringArray|PoolVector2Array|PoolVector3Array|PoolColorArray|table a
	-- @tparam Array|PoolByteArray|PoolIntArray|PoolRealArray|PoolStringArray|PoolVector2Array|PoolVector3Array|PoolColorArray|table b
	-- @treturn bool
	__eq = array__eq,
})
