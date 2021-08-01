local ClassDB = api.godot_global_get_singleton("ClassDB")

ffi.cdef[[
typedef struct lps_method_bind { godot_string method; } lps_method_bind;
]]
local MethodBind = ffi.metatype('lps_method_bind', {
	__new = function(mt, method)
		return ffi.new(mt, String(method))
	end,
	__call = function(self, var, ...)
		return Variant(var):call(self.method, ...)
	end,
})

local class_methods = {
	new = function(self, ...)
		local instance = ffi.gc(ClassDB:instance(self.class_name), MethodBind('unreference'))
		instance:call('_init', ...)
		return instance
	end,
}
local Class = {
	new = function(self, class_name)
		return setmetatable({ class_name = class_name }, self)
	end,
	__index = function(self, key)
		local method = class_methods[key]
		if method then return method end
		local varkey = Variant(key)
		if ClassDB:class_has_integer_constant(self.class_name, varkey) then
			local constant = ClassDB:class_get_integer_constant(self.class_name, varkey)
			rawset(self, key, constant)
			return constant
		end
	end,
}

local instance_methods = {
	tovariant = function(self)
		return Variant(rawget(self, '__owner'))
	end,
}
local Instance = {
	__index = function(self, key)
		local script_value = instance_methods[key] or rawget(self, '__script')[key]
		if script_value ~= nil then return script_value end
		return rawget(self, '__owner')[key]
	end,
}
