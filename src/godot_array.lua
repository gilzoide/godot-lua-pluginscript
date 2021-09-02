-- @file godot_array.lua  Wrapper for GDNative's Array
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
local methods = {
	fillvariant = api.godot_variant_new_array,
	varianttype = GD.TYPE_ARRAY,
	get = function(self, index)
		local var = ffi_gc(api.godot_array_get(self, index), api.godot_variant_destroy)
		return var:unbox()
	end,
	set = function(self, index, value)
		api.godot_array_set(self, index, Variant(value))
	end,
	append = function(self, value)
		api.godot_array_append(self, Variant(value))
	end,
	clear = api.godot_array_clear,
	count = function(self, value)
		return api.godot_array_count(self, Variant(value))
	end,
	empty = api.godot_array_empty,
	erase = function(self, value)
		api.godot_array_erase(self, Variant(value))
	end,
	front = function(self)
		local var = ffi_gc(api.godot_array_front(self), api.godot_variant_destroy)
		return var:unbox()
	end,
	back = function(self)
		local var = ffi_gc(api.godot_array_back(self), api.godot_variant_destroy)
		return var:unbox()
	end,
	find = function(self, what, from)
		return api.godot_array_find(self, Variant(what), from or 0)
	end,
	find_last = function(self, what)
		return api.godot_array_find_last(self, Variant(what))
	end,
	has = function(self, value)
		return api.godot_array_has(self, Variant(value))
	end,
	hash = api.godot_array_hash,
	insert = function(self, pos, value)
		api.godot_array_insert(self, pos, Variant(value))
	end,
	invert = api.godot_array_invert,
	push_back = function(self, value)
		api.godot_array_push_back(self, Variant(value))
	end,
	push_front = function(self, value)
		api.godot_array_push_front(self, Variant(value))
	end,
	pop_back = function(self)
		local var = ffi_gc(api.godot_array_pop_back(self), api.godot_variant_destroy)
		return var:unbox()
	end,
	pop_front = function(self)
		local var = ffi_gc(api.godot_array_pop_front(self), api.godot_variant_destroy)
		return var:unbox()
	end,
	remove = api.godot_array_remove,
	resize = api.godot_array_resize,
	rfind = function(self, what, from)
		return api.godot_array_rfind(self, Variant(what), from or -1)
	end,
	size = api.godot_array_size,
	sort = api.godot_array_sort,
	sort_custom = function(self, obj, func)
		api.godot_array_sort_custom(self, obj, String(func))
	end,
	bsearch = function(self, value, before)
		if before == nil then before = true end
		return api.godot_array_bsearch(self, Variant(value), before)
	end,
	bsearch_custom = function(self, value, obj, func, before)
		if before == nil then before = true end
		return api.godot_array_bsearch_custom(self, Variant(value), obj, String(func), before)
	end,
	duplicate = function(self, deep)
		return api.godot_array_duplicate(self, deep or false)
	end,
	slice = function(self, begin, _end, step, deep)
		return api.godot_array_slice(self, begin, _end, step, deep or false)
	end,
}

if api_1_1 then
	methods.max = function(self)
		local var = ffi_gc(api_1_1.godot_array_max(self), api.godot_variant_destroy)
		return var:unbox()
	end
	methods.min = function(self)
		local var = ffi_gc(api_1_1.godot_array_min(self), api.godot_variant_destroy)
		return var:unbox()
	end
	methods.shuffle = api_1_1.godot_array_shuffle
end

local function array_next(self, index)
	index = index + 1
	if index < #self then
		return index, self:get(index)
	end
end

local function array_ipairs(self)
	return array_next, self, -1
end

Array = ffi_metatype('godot_array', {
	__new = function(mt, ...)
		local self = ffi_new(mt)
		api.godot_array_new(self)
		local argc = select('#', ...)
		if argc == 1 and type(...) == 'table' then
			for _, v in ipairs(...) do
				self:append(v)
			end
		else
			for i = 1, select('#', ...) do
				local v = select(i, ...)
				self:append(v)
			end
		end
		return self
	end,
	__gc = api.godot_array_destroy,
	__tostring = gd_tostring,
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
	__concat = concat_gdvalues,
	__len = function(self)
		return methods.size(self)
	end,
	__ipairs = array_ipairs,
	__pairs = array_ipairs,
})
