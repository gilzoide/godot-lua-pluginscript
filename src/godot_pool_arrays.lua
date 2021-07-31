local function register_pool_array(kind, element_ctype)
	local name = 'Pool' .. kind:sub(1, 1):upper() .. kind:sub(2) .. 'Array'
	local kind_type = 'pool_' .. kind .. '_array'
	local ctype = 'godot_' .. kind_type
	local godot_array_new_pool_array = 'godot_array_new_' .. kind_type
	local godot_pool_array_new = ctype .. '_new'
	local godot_pool_array_new_copy = ctype .. '_new_copy'
	local godot_pool_array_new_with_array = ctype .. '_new_with_array'
	
	local methods = {
		tovariant = ffi.C['hgdn_new_' .. kind_type .. '_variant'],
		varianttype = GD['TYPE_POOL_' .. kind:upper() .. '_ARRAY'],
		toarray = function(self)
			local array = ffi.new(Array)
			api[godot_array_new_pool_array](array, self)
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
		-- TODO: read/write
		size = function(self)
			return api[ctype .. '_size'](self)
		end,
	}

	if element_ctype == String then
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
				api[godot_pool_array_new_copy](self, value)
			elseif ffi.istype(Array, value) then
				api[godot_pool_array_new_with_array](self, value)
			else
				api[godot_pool_array_new](self)
				local t = type(value)
				for i = 1, select('#', ...) do
					local v = select(i, ...)
					self:append(element_ctype(v))
				end
			end
			return self
		end,
		__gc = api[ctype .. '_destroy'],
		__tostring = GD.tostring,
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
		__len = methods.size,
	})
end

register_pool_array('byte', ffi.typeof('uint8_t'))
register_pool_array('int', int)
register_pool_array('real', float)
register_pool_array('string', String)
register_pool_array('vector2', Vector2)
register_pool_array('vector3', Vector3)
register_pool_array('color', Color)

