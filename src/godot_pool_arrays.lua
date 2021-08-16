-- @file godot_pool_arrays.lua  Wrapper for GDNative's Pool Array types
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
local byte = ffi.typeof('uint8_t')

local function register_pool_array(kind, element_ctype)
	local name = 'Pool' .. kind:sub(1, 1):upper() .. kind:sub(2) .. 'Array'
	local kind_type = 'pool_' .. kind .. '_array'
	local ctype = 'godot_' .. kind_type

	local godot_pool_array_read_access_copy = api[ctype .. '_read_access_copy']
	local godot_pool_array_read_access_ptr = api[ctype .. '_read_access_ptr']
	local godot_pool_array_read_access_destroy = api[ctype .. '_read_access_destroy']
	local ReadAccess = ffi.metatype(ctype .. '_read_access', {
		__index = {
			copy = function(self)
				return ffi.gc(godot_pool_array_read_access_copy(self), godot_pool_array_read_access_destroy)
			end,
			ptr = function(self)
				return godot_pool_array_read_access_ptr(self)
			end,
			assign = api[ctype .. '_read_access_operator_assign'],
		},
	})

	local godot_pool_array_write_access_copy = api[ctype .. '_write_access_copy']
	local godot_pool_array_write_access_ptr = api[ctype .. '_write_access_ptr']
	local godot_pool_array_write_access_destroy = api[ctype .. '_write_access_destroy']
	local WriteAccess = ffi.metatype(ctype .. '_write_access', {
		__index = {
			copy = function(self)
				return ffi.gc(godot_pool_array_write_access_copy(self), godot_pool_array_write_access_destroy)
			end,
			ptr = function(self)
				return godot_pool_array_write_access_ptr(self)
			end,
			assign = api[ctype .. '_write_access_operator_assign'],
		},
	})

	local godot_array_new_pool_array = api['godot_array_new_' .. kind_type]
	local godot_pool_array_new = api[ctype .. '_new']
	local godot_pool_array_new_copy = api[ctype .. '_new_copy']
	local godot_pool_array_new_with_array = api[ctype .. '_new_with_array']
	local godot_pool_array_destroy = api[ctype .. '_destroy']
	local godot_pool_array_read = api[ctype .. '_read']
	local godot_pool_array_write = api[ctype .. '_write']
	local methods = {
		fillvariant = api['godot_variant_new_' .. kind_type],
		varianttype = GD['TYPE_POOL_' .. kind:upper() .. '_ARRAY'],
		toarray = function(self)
			local array = ffi.new(Array)
			godot_array_new_pool_array(array, self)
			return array
		end,
		get = api[ctype .. '_get'],
		set = api[ctype .. '_set'],
		append = api[ctype .. '_append'],
		append_array = api[ctype .. '_append_array'],
		insert = api[ctype .. '_insert'],
		invert = api[ctype .. '_invert'],
		push_back = api[ctype .. '_push_back'],
		remove = api[ctype .. '_remove'],
		resize = api[ctype .. '_resize'],
		read = function(self)
			return ffi.gc(godot_pool_array_read(self), godot_pool_array_read_access_destroy)
		end,
		write = function(self)
			return ffi.gc(godot_pool_array_write(self), godot_pool_array_write_access_destroy)
		end,
		size = api[ctype .. '_size'],
	}

	if element_ctype == byte then
		methods.get_string = function(self)
			return ffi.string(self:read():ptr(), #self)
		end
		methods.hex_encode = function(self)
			return String.hex_encode_buffer(self:read():ptr(), #self)
		end
	elseif element_ctype == String then
		methods.join = function(self, delimiter)
			local result = String(self[0])
			delimiter = String(delimiter)
			for i = 1, #self - 1 do
				result = result .. delimiter .. self[i]
			end
			return result
		end
	end

	if api_1_2 then
		methods.empty = api_1_2[ctype .. '_empty']
	end

	_G[name] = ffi.metatype(ctype, {
		__new = function(mt, ...)
			local self = ffi.new(mt)
			local value = ...
			if ffi.istype(mt, value) then
				godot_pool_array_new_copy(self, value)
			elseif ffi.istype(Array, value) then
				godot_pool_array_new_with_array(self, value)
			else
				godot_pool_array_new(self)
				for i = 1, select('#', ...) do
					local v = select(i, ...)
					self:append(element_ctype(v))
				end
			end
			return self
		end,
		__gc = godot_pool_array_destroy,
		__tostring = GD.tostring,
		__concat = concat_gdvalues,
		__index = function(self, key)
			local numeric_index = tonumber(key)
			if numeric_index then
				if numeric_index >= 0 and numeric_index < #self then
					return methods.get(self, numeric_index)
				end
			else
				return methods[key]
			end
		end,
		__newindex = function(self, key, value)
			key = assert(tonumber(key), "Array indices must be numeric")
			if key == #self then
				methods.append(self, value)
			else
				methods.set(self, key, value)
			end
		end,
		__len = function(self)
			return methods.size(self)
		end,
		__ipairs = array_ipairs,
		__pairs = array_ipairs,
	})
end

register_pool_array('byte', byte)
register_pool_array('int', int)
register_pool_array('real', float)
register_pool_array('string', String)
register_pool_array('vector2', Vector2)
register_pool_array('vector3', Vector3)
register_pool_array('color', Color)
