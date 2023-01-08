-- @file godot_array_commons.lua  Common functionality between Array and Pool*Arrays
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

local function array_empty(self)
	return #self == 0
end

local function array_safe_get(self, index)
	if index >= 0 and index < #self then
		return self:get(index)
	end
end

local function array_safe_set(self, index, value)
	assert(index >= 0, "Array index must be non-negative")
	if index >= #self then
		self:resize(index + 1)
	end
	self:set(index, value)
end

local function array_join(self, delimiter)
	if #self == 0 then
		return String()
	end
	local result = str(self:get(0))
	delimiter = str(delimiter or "")
	for i = 1, #self - 1 do
		result = result .. delimiter .. self:get(i)
	end
	return result
end

local function array_next(self, index)
	index = index + 1
	if index > 0 and index <= #self then
		return index, self:get(index - 1)
	end
end

local function array_ipairs(self)
	return array_next, self, 0
end

local function array_generate__index(methods)
	return function(self, index)
		return methods[index] or array_safe_get(self, index - 1)
	end
end

local function array__newindex(self, index, value)
	array_safe_set(self, index - 1, value)
end

local function array__len(self)
	return self:size()
end

local function array__eq(a, b)
	if not has_length(a) or not has_length(b) or #a ~= #b then
		return false
	end
	for i = 1, #a do
		if a[i] ~= b[i] then
			return false
		end
	end
	return true
end

local function array_generate_get_buffer(ctype)
	local element_size = ffi_sizeof(ctype)
	return function(self)
		local buffer = PoolByteArray()
		local size = #self * element_size
		buffer:resize(size)
		local src = self:read()
		local dst = buffer:write()
		ffi_copy(dst:ptr(), src:ptr(), size)
		dst:destroy()
		src:destroy()
		return buffer
	end
end
