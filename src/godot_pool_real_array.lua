-- @file godot_pool_real_array.lua  Wrapper for GDNative's PoolRealArray
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

--- PoolRealArray metatype, wrapper for `godot_pool_real_array`
-- @classmod PoolRealArray

--- PoolRealArray.Read access metatype, wrapper for `godot_pool_real_array_read_access`.
-- @type PoolRealArray.Read
local Read = ffi_metatype('godot_pool_real_array_read_access', {
	__index = {
		--- Create a copy of Read access.
		-- @function Read:copy
		-- @treturn Read
		copy = function(self)
			return ffi_gc(api.godot_pool_real_array_read_access_copy(self), self.destroy)
		end,
		--- Destroy a Read access.
		-- Holding a valid access object may lock a PoolRealArray, so this
		-- method should be called manually when access is no longer needed.
		-- @function Read:destroy
		destroy = function(self)
			ffi_gc(self, nil)
			api.godot_pool_real_array_read_access_destroy(self)
		end,
		--- Get Read access porealer.
		-- @function Read:ptr
		-- @return[type=const godot_real *]
		ptr = api.godot_pool_real_array_read_access_ptr,
		--- Assign a new Read access.
		-- @function Read:assign
		-- @tparam Read other
		assign = api.godot_pool_real_array_read_access_operator_assign,
	},
})

--- PoolRealArray.Write access metatype, wrapper for `godot_pool_real_array_write_access`.
-- @type PoolRealArray.Write
local Write = ffi_metatype('godot_pool_real_array_write_access', {
	__index = {
		--- Create a copy of Write access.
		-- @function Write:copy
		-- @treturn Write
		copy = function(self)
			return ffi_gc(api.godot_pool_real_array_write_access_copy(self), self.destroy)
		end,
		--- Destroy a Write access.
		-- Holding a valid access object may lock a PoolRealArray, so this
		-- method should be called manually when access is no longer needed.
		-- @function Write:destroy
		destroy = function(self)
			ffi_gc(self, nil)
			api.godot_pool_real_array_write_access_destroy(self)
		end,
		--- Get Write access pointer.
		-- @function Write:ptr
		-- @return[type=godot_real *]
		ptr = api.godot_pool_real_array_write_access_ptr,
		--- Assign a new Write access.
		-- @function Write:assign
		-- @tparam Write other
		assign = api.godot_pool_real_array_write_access_operator_assign,
	},
})
--- @type end

local methods = {
	fillvariant = api.godot_variant_new_pool_real_array,
	varianttype = VariantType.PoolRealArray,

	--- Get the number at `index`.
	-- Unlike Lua tables, indices start at 0 instead of 1.
	-- For 1-based indexing, use the idiom `array[index]` instead.
	--
	-- If `index` is invalid (`index < 0` or `index >= size()`), the application will crash.
	-- For a safe version that returns `nil` if `index` is invalid, use `safe_get` or the idiom `array[index]` instead.
	-- @function get
	-- @tparam int index
	-- @treturn number
	-- @see safe_get
	get = api.godot_pool_real_array_get,
	--- Get the number at `index`.
	-- Unlike Lua tables, indices start at 0 instead of 1.
	-- For 1-based indexing, use the idiom `array[index]` instead.
	--
	-- The idiom `array[index]` also calls this method.
	-- @function safe_get
	-- @tparam int index
	-- @treturn[1] number
	-- @treturn[2] nil  If index is invalid (`index < 0` or `index >= size()`)
	-- @see get
	safe_get = array_safe_get,
	--- Set a new number for `index`.
	-- Unlike Lua tables, indices start at 0 instead of 1.
	-- For 1-based indexing, use the idiom `array[index] = value` instead.
	--
	-- If `index` is invalid (`index < 0` or `index >= size()`), the application will crash.
	-- For a safe approach that `resize`s if `index >= size()`, use `safe_set` or the idiom `array[index] = value` instead.
	-- @function set
	-- @tparam int index
	-- @tparam number value
	-- @see safe_set
	set = api.godot_pool_real_array_set,
	--- Set a new number for `index`.
	-- Unlike Lua tables, indices start at 0 instead of 1.
	-- For 1-based indexing, use the idiom `array[index] = value` instead.
	--
	-- If `index >= size()`, the array is `resize`d first.
	-- The idiom `array[index] = value` also calls this method.
	-- @function safe_set
	-- @tparam int index
	-- @tparam number value
	-- @raise If `index < 0`
	-- @see set
	safe_set = array_safe_set,
	--- Inserts a new element at a given position in the array.
	-- The position must be valid, or at the end of the array (`index == size()`).
	-- @function insert
	-- @tparam int index
	-- @tparam number value
	insert = api.godot_pool_real_array_insert,
	--- Reverses the order of the elements in the array.
	-- @function invert
	invert = api.godot_pool_real_array_invert,
	--- Append elements at the end of the array.
	-- @function push_back
	-- @param ...  Numbers to be appended
	push_back = function(self, ...)
		for i = 1, select('#', ...) do
			local v = select(i, ...)
			api.godot_pool_real_array_push_back(self, v)
		end
	end,
	--- Removes an element from the array by index.
	-- @function remove
	-- @tparam int index
	remove = api.godot_pool_real_array_remove,
	--- Sets the size of the array.
	-- If the array is grown, reserves elements at the end of the array.
	-- If the array is shrunk, truncates the array to the new size.
	-- @function resize
	-- @tparam int size
	resize = api.godot_pool_real_array_resize,
	--- Returns the size of the array.
	-- @function size
	-- @treturn int
	size = api.godot_pool_real_array_size,
	--- Returns `true` if the array is empty.
	-- @function empty
	-- @treturn bool
	empty = array_empty,
	--- Returns the [Read](#Class_PoolRealArray_Read) access for the array.
	-- @function read
	-- @treturn Read
	read = function(self)
		return ffi_gc(api.godot_pool_real_array_read(self), Read.destroy)
	end,
	--- Returns the [Write](#Class_PoolRealArray_Write) access for the array.
	-- @function write
	-- @treturn Write
	write = function(self)
		return ffi_gc(api.godot_pool_real_array_write(self), Write.destroy)
	end,
}

if api_1_3 ~= nil then
	--- Returns true if the array contains the given `value`.
	-- @function has
	-- @tparam real value
	-- @treturn bool
	methods.has = api_1_3.godot_pool_real_array_has
	--- Sorts the elements of the array in ascending order.
	-- @function sort
	methods.sort = api_1_3.godot_pool_real_array_sort
end

--- Alias for `push_back`.
-- @function append
-- @param ...
-- @see push_back
methods.append = methods.push_back

--- Append all numbers of `iterable` at the end of Array.
-- @function extend
-- @param iterable  Any object iterable by `ipairs`, including Lua tables, `Array`s and `Pool*Array`s.
methods.extend = function(self, iterable)
	if ffi_istype(PoolRealArray, iterable) then
		api.godot_pool_real_array_append_array(self, iterable)
	else
		for _, b in ipairs(iterable) do
			self:push_back(b)
		end
	end
end

--- Returns a String with each element of the array joined with the given `delimiter`.
-- @function join
-- @param[opt=""] delimiter  
-- @treturn String
methods.join = array_join

--- Returns array's buffer as a PoolByteArray.
-- @function get_buffer
-- @treturn PoolByteArray
methods.get_buffer = array_generate_get_buffer(float)


--- Static Functions.
-- These don't receive `self` and should be called directly as `PoolRealArray.static_function(...)`
-- @section static_funcs

--- Create a new array with the elements from `iterable`.
-- @usage
--     local array = PoolRealArray.from(some_table_or_other_iterable)
-- @function from
-- @param iterable  If another PoolRealArray is passed, return a copy of it.
--  Otherwise, the new array is `extend`ed with `iterable`.
-- @treturn PoolRealArray
-- @see extend
methods.from = function(value)
	local self = PoolRealArray()
	if ffi_istype(PoolRealArray, value) then
		api.godot_pool_real_array_new_copy(self, value)
	elseif ffi_istype(Array, value) then
		api.godot_pool_real_array_new_with_array(self, value)
	else
		methods.extend(self, value)
	end
	return self
end

--- Metamethods
-- @section metamethods
PoolRealArray = ffi_metatype('godot_pool_real_array', {
	--- PoolRealArray constructor, called by the idiom `PoolRealArray(...)`.
	-- @function __new
	-- @param ...  Initial elements, added with `push_back`
	-- @treturn PoolRealArray
	__new = function(mt, ...)
		local self = ffi_new(mt)
		api.godot_pool_real_array_new(self)
		methods.push_back(self, ...)
		return self
	end,
	__gc = api.godot_pool_real_array_destroy,
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
	--- Returns a Lua string representation of this array.
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
	--- Returns an iterator for array's elements, called by the idiom `ipairs(array)`.
	-- @usage
	--     for i, number in ipairs(array) do
	--         -- do something
	--     end
	-- @function __ipairs
	-- @treturn function
	-- @treturn PoolRealArray  self
	-- @treturn int  0
	__ipairs = array_ipairs,
	--- Alias for `__ipairs`, called by the idiom `pairs(array)`.
	-- @function __pairs
	-- @treturn function
	-- @treturn PoolRealArray  self
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

