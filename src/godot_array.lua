local methods = {
    tovariant = ffi.C.hgdn_new_array_variant,
    toarray = function(self)
        local clone = ffi.new('godot_array')
        GD.api.godot_array_new_copy(clone, self)
        return clone
    end,
    get = function(self, index)
        return GD.api.godot_array_get(self, index):unbox()
    end,
    set = function(self, index, value)
        GD.api.godot_array_set(self, index, Variant(value))
    end,
    append = function(self, value)
        GD.api.godot_array_append(self, Variant(value))
    end,
    clear = GD.api.godot_array_clear,
    count = function(self, value)
        return GD.api.godot_array_count(self, Variant(value))
    end,
    empty = GD.api.godot_array_empty,
    erase = function(self, value)
        GD.api.godot_array_erase(self, Variant(value))
    end,
    front = function(self)
        return GD.api.godot_array_front(self):unbox()
    end,
    back = function(self)
        return GD.api.godot_array_back(self):unbox()
    end,
    find = function(self, what, from)
        return GD.api.godot_array_find(self, Variant(what), from or 0)
    end,
    find_last = function(self, what)
        return GD.api.godot_array_find_last(self, Variant(what))
    end,
    has = function(self, value)
        return GD.api.godot_array_has(self, Variant(value))
    end,
    hash = GD.api.godot_array_hash,
    insert = function(self, pos, value)
        GD.api.godot_array_insert(self, pos, Variant(value))
    end,
    invert = GD.api.godot_array_invert,
    pop_back = function(self)
        return GD.api.godot_array_pop_back(self):unbox()
    end,
    pop_front = function(self)
        return GD.api.godot_array_pop_front(self):unbox()
    end,
    remove = GD.api.godot_array_remove,
    resize = GD.api.godot_array_resize,
    rfind = function(self, what, from)
        return GD.api.godot_array_rfind(self, Variant(what), from or -1)
    end,
    size = function(self)
        return GD.api.godot_array_size(self)
    end,
    sort = GD.api.godot_array_sort,
    sort_custom = function(self, obj, func)
        GD.api.godot_array_sort_custom(self, obj, String(func))
    end,
    bsearch = function(self, value, before)
        if before == nil then before = true end
        return GD.api.godot_array_bsearch(self, Variant(value), before)
    end,
    bsearch_custom = function(self, value, obj, func, before)
        if before == nil then before = true end
        return GD.api.godot_array_bsearch_custom(self, Variant(value), obj, String(func), before)
    end,
    duplicate = function(self, deep)
        return GD.api.godot_array_duplicate(self, deep or false)
    end,
    slice = function(self, begin, _end, step, deep)
        return GD.api.godot_array_slice(self, begin, _end, step, deep or false)
    end,
    max = GD.api_1_1 and function(self)
        return GD.api_1_1.godot_array_max(self):unbox()
    end,
    min = GD.api_1_1 and function(self)
        return GD.api_1_1.godot_array_min(self):unbox()
    end,
    shuffle = GD.api_1_1 and GD.api_1_1.godot_array_shuffle,
}

Array = ffi.metatype('godot_array', {
    __new = function(mt, value)
        if value and value.toarray then
            return value:toarray()
        end
        local self = ffi.new('godot_array')
        GD.api.godot_array_new(self)
        if value then
            for i, v in ipairs(value) do
                methods.append(self, v)
            end
        end
        return self
    end,
    __gc = GD.api.godot_array_destroy,
    __tostring = GD.str,
    __index = function(self, key)
        local method = methods[key]
        if method then
            return method
        else
            key = assert(tonumber(key),  "Array indices must be numeric")
            if key >= 0 and key < #self then
                return methods.get(self, key)
            end
        end
    end,
    __newindex = function(self, key, value)
        key = assert(key, "Array indices must be numeric")
        if key == #self then
            methods.append(self, value)
        else
            methods.set(self, key, value)
        end
    end,
    __len = methods.size,
})
