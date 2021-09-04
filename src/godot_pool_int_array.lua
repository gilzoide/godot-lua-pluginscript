-- @file godot_pool_int_array.lua  Wrapper for GDNative's PoolIntArray
-- This file is part of Godot Lua PluginScript: https://github.com/gilzoide/godot-lua-pluginscript
--
-- Copyright (C) 2021 Gil Barbosa Reis.
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

--- PoolIntArray metatype, wrapper for `godot_pool_int_array`
-- @classmod PoolIntArray

--- PoolIntArray.Read access metatype, wrapper for `godot_pool_int_array_read_access`.
-- @type PoolIntArray.Read
local Read = ffi_metatype('godot_pool_int_array_read_access', {
	__index = {
		--- Create a copy of Read access.
		-- @function Read:copy
		-- @treturn Read
		copy = function(self)
			return ffi_gc(api.godot_pool_int_array_read_access_copy(self), godot_pool_int_array_read_access_destroy)
		end,
		--- Destroy a Read access.
		-- Holding a valid access object may lock a PoolIntArray, so this
		-- method should be called manually when access is no longer needed.
		-- @function Read:destroy
		destroy = function(self)
			ffi_gc(self, nil)
			api.godot_pool_int_array_read_access_destroy(self)
		end,
		--- Get Read access pointer.
		-- @function Read:ptr
		-- @return[type=const godot_int *]
		ptr = api.godot_pool_int_array_read_access_ptr,
		--- Assign a new Read access.
		-- @function Read:assign
		-- @tparam Read other
		assign = api.godot_pool_int_array_read_access_operator_assign,
	},
})

--- PoolIntArray.Write access metatype, wrapper for `godot_pool_int_array_write_access`.
-- @type PoolIntArray.Write
local Write = ffi_metatype('godot_pool_int_array_write_access', {
	__index = {
		--- Create a copy of Write access.
		-- @function Write:copy
		-- @treturn Write
		copy = function(self)
			return ffi_gc(api.godot_pool_int_array_write_access_copy(self), self.destroy)
		end,
		--- Destroy a Write access.
		-- Holding a valid access object may lock a PoolIntArray, so this
		-- method should be called manually when access is no longer needed.
		-- @function Write:destroy
		destroy = function(self)
			ffi_gc(self, nil)
			api.godot_pool_int_array_write_access_destroy(self)
		end,
		--- Get Write access pointer.
		-- @function Write:ptr
		-- @return[type=godot_int *]
		ptr = api.godot_pool_int_array_write_access_ptr,
		--- Assign a new Write access.
		-- @function Write:assign
		-- @tparam Write other
		assign = api.godot_pool_int_array_write_access_operator_assign,
	},
})
--- @type end

local methods = {
	fillvariant = api.godot_variant_new_pool_int_array,
	varianttype = GD.TYPE_POOL_INT_ARRAY,

	--- Get the int at `index`.
	-- If `index` is invalid (`index < 0` or `index >= size()`), the application will crash.
	-- For a safe version that returns `nil` if `index` is invalid, use `safe_get` or the idiom `array[index]` instead.
	-- @function get
	-- @tparam int index
	-- @treturn int
	-- @see safe_get
	get = api.godot_pool_int_array_get,
	--- Get the int at `index`.
	-- The idiom `array[index]` also calls this method.
	-- @function safe_get
	-- @tparam int index
	-- @treturn[1] int
	-- @treturn[2] nil  If index is invalid (`index < 0` or `index >= size()`)
	-- @see get
	safe_get = Array.safe_get,
	--- Set a new int for `index`.
	-- If `index` is invalid (`index < 0` or `index >= size()`), the application will crash.
	-- For a safe approach that `resize`s if `index >= size()`, use `safe_set` or the idiom `array[index] = value` instead.
	-- @function set
	-- @tparam int index
	-- @tparam int int
	-- @see safe_set
	set = api.godot_pool_int_array_set,
	--- Set a new int for `index`.
	-- If `index >= size()`, the array is `resize`d first.
	-- The idiom `array[index] = value` also calls this method.
	-- @function safe_set
	-- @tparam int index
	-- @param value
	-- @raise If `index < 0`
	-- @see set
	safe_set = Array.safe_set,
	--- Inserts a new element at a given position in the array.
	-- The position must be valid, or at the end of the array (`index == size()`).
	-- @function insert
	-- @tparam int index
	-- @tparam int int
	insert = api.godot_pool_int_array_insert,
	--- Reverses the order of the elements in the array.
	-- @function invert
	invert = api.godot_pool_int_array_invert,
	--- Append elements at the end of the array.
	-- @function push_back
	-- @param ...  Ints to be appended
	push_back = function(self, ...)
		for i = 1, select('#', ...) do
			local v = select(i, ...)
			api.godot_pool_int_array_push_back(self, v)
		end
	end,
	--- Removes an element from the array by index.
	-- @function remove
	-- @tparam int index
	remove = api.godot_pool_int_array_remove,
	--- Sets the size of the array.
	-- If the array is grown, reserves elements at the end of the array.
	-- If the array is shrunk, truncates the array to the new size.
	-- @function resize
	-- @tparam int size
	resize = api.godot_pool_int_array_resize,
	--- Returns the size of the array.
	-- @function size
	-- @treturn int
	size = api.godot_pool_int_array_size,
	--- Returns `true` if the array is empty.
	-- @function empty
	-- @treturn bool
	empty = function(self)
		return #self == 0
	end,
	--- Returns the [Read](#Class_PoolIntArray_Read) access for the array.
	-- @function read
	-- @treturn Read
	read = function(self)
		return ffi_gc(api.godot_pool_int_array_read(self), Read.destroy)
	end,
	--- Returns the [Write](#Class_PoolIntArray_Write) access for the array.
	-- @function write
	-- @treturn Write
	write = function(self)
		return ffi_gc(api.godot_pool_int_array_write(self), Write.destroy)
	end,
}

--- Alias for `push_back`.
-- @function append
-- @param ...
-- @see push_back
methods.append = methods.push_back

--- Append all ints of `iterable` at the end of Array.
-- @function extend
-- @param iterable  Any object iterable by `ipairs`, including Lua tables, `Array`s and `Pool*Array`s.
methods.extend = function(self, iterable)
	if ffi_istype(PoolIntArray, iterable) then
		api.godot_pool_int_array_append_array(self, iterable)
	else
		for _, b in ipairs(iterable) do
			self:push_back(b)
		end
	end
end

--- Returns array's buffer as a PoolByteArray.
-- @function get_buffer
-- @treturn PoolByteArray
methods.get_buffer = function(self)
	local buffer = PoolByteArray()
	local size = #self * ffi_sizeof(int)
	buffer:resize(size)
	local src = self:read()
	local dst = buffer:write()
	ffi_copy(dst:ptr(), src:ptr(), size)
	dst:destroy()
	src:destroy()
	return buffer
end


--- Static Functions.
-- These don't receive `self` and should be called directly as `PoolIntArray.static_function(...)`
-- @section static_funcs

--- Create a new array with the elements from `iterable`.
-- @usage
--     local array = PoolIntArray.from(some_table_or_other_iterable)
-- @function from
-- @param iterable  If another PoolIntArray is passed, return a copy of it.
--  Otherwise, the new array is `extend`ed with `iterable`.
-- @treturn PoolIntArray
-- @see extend
methods.from = function(value)
	local self = PoolIntArray()
	if ffi_istype(PoolIntArray, value) then
		api.godot_pool_int_array_new_copy(self, value)
	elseif ffi_istype(Array, value) then
		api.godot_pool_int_array_new_with_array(self, value)
	else
		methods.extend(self, value)
	end
	return self
end

--- Metamethods
-- @section metamethods
PoolIntArray = ffi_metatype('godot_pool_int_array', {
	--- PoolIntArray constructor, called by the idiom `PoolIntArray(...)`.
	-- @function __new
	-- @param ...  Initial elements, added with `push_back`
	-- @treturn PoolIntArray
	__new = function(mt, ...)
		local self = ffi.new(mt)
		api.godot_pool_int_array_new(self)
		methods.push_back(self, ...)
		return self
	end,
	__gc = godot_pool_int_array_destroy,
	--- Returns method named `index` or the result of `safe_get`.
	-- @function __index
	-- @param index
	-- @return Method or element or `nil`
	-- @see safe_get
	__index = function(self, index)
		return methods[index] or methods.safe_get(self, index)
	end,
	--- Alias for `safe_set`.
	-- @function __newindex
	-- @tparam int index
	-- @param value
	-- @see safe_set
	__newindex = methods.safe_set,
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
	__len = function(self)
		return methods.size(self)
	end,
	--- Returns an iterator for array's elements, called by the idiom `ipairs(array)`.
	-- @usage
	--     for i, int in ipairs(array) do
	--         -- do something
	--     end
	-- @function __ipairs
	-- @treturn function
	-- @treturn PoolIntArray  self
	__ipairs = array_ipairs,
	--- Alias for `__ipairs`, called by the idiom `pairs(array)`.
	-- @function __pairs
	-- @treturn function
	-- @treturn PoolIntArray  self
	__pairs = array_ipairs,
})

