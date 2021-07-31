local ClassDB = api.godot_global_get_singleton("ClassDB")

ffi.cdef[[typedef struct lps_class { godot_string class_name; } lps_class]]
local Class = ffi.metatype('lps_class', {
	__index = {
		new = function(self, ...)
			local instance = ClassDB:instance(self.class_name)
			instance:call('_init', ...)
			return instance
		end,
	},
})

