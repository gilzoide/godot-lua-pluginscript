-- @file godot_dictionary.lua  Wrapper for GDNative's Dictionary
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
	fillvariant = api.godot_variant_new_dictionary,
	varianttype = GD.TYPE_DICTIONARY,
	duplicate = function(self, deep)
		return api.godot_dictionary_duplicate(self, deep or false)
	end,
	size = function(self)
		return api.godot_dictionary_size(self)
	end,
	empty = api.godot_dictionary_empty,
	clear = api.godot_dictionary_clear,
	has = function(self, key)
		return api.godot_dictionary_has(self, Variant(key))
	end,
	has_all = function(self, ...)
		local keys = Array{ ... }
		return api.godot_dictionary_has_all(self, keys)
	end,
	erase = function(self, key)
		api.godot_dictionary_erase(self, Variant(key))
	end,
	hash = api.godot_dictionary_hash,
	keys = api.godot_dictionary_keys,
	values = api.godot_dictionary_values,
	get = function(self, key)
		local var = ffi_gc(api.godot_dictionary_get(self, Variant(key)), api.godot_variant_destroy)
		return var:unbox()
	end,
	set = function(self, key, value)
		api.godot_dictionary_set(self, Variant(key), Variant(value))
	end,
	next = function(self, key)  -- behave like `next(table [, index])` for __pairs
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
	to_json = api.godot_dictionary_to_json,
}

if api_1_1 then
	methods.erase_with_return = function(self, key)
		return api_1_1.godot_dictionary_erase_with_return(self, Variant(key))
	end
	methods.get_with_default = function(self, key, default)
		local var = ffi_gc(api_1_1.godot_dictionary_get_with_default(self, Variant(key), Variant(default)), api.godot_variant_destroy)
		return var:unbox()
	end
end

Dictionary = ffi_metatype('godot_dictionary', {
	__new = function(mt, value)
		local self = ffi_new('godot_dictionary')
		if ffi_istype(mt, value) then
			api.godot_dictionary_new_copy(self, value)
		else
			api.godot_dictionary_new(self)
			if value then
				for k, v in pairs(value) do
					self[k] = v
				end
			end
		end
		return self
	end,
	__gc = api.godot_dictionary_destroy,
	__tostring = GD.tostring,
	__concat = concat_gdvalues,
	__index = function(self, key)
		return methods[key] or methods.get(self, key)
	end,
	__newindex = function(self, key, value)
		if type(value) == 'nil' then
			api.godot_dictionary_erase(self, Variant(key))
		else
			api.godot_dictionary_set(self, Variant(key), Variant(value))
		end
	end,
	__len = methods.size,
	__pairs = function(self)
		return methods.next, self, nil
	end,
})
