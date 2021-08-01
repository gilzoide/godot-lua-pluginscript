for k, v in pairs(api.godot_get_global_constants()) do
	GD[tostring(k)] = v
end

local Engine = api.godot_global_get_singleton("Engine")
setmetatable(_G, {
	__index = function(self, key)
		key = String(key)
		if Engine:has_singleton(key) then
			local singleton = Engine:get_singleton(key)
			rawset(self, key, singleton)
			return singleton
		end
		if ClassDB:class_exists(key) then
			local cls = Class:new(key)
			rawset(self, key, cls)
			return cls
		end
	end,
})

-- References are already got, just register them globally
_G.Engine = Engine
_G.ClassDB = ClassDB
-- These classes are registered with a prepending "_" in ClassDB
File = Class:new("_File")
Directory = Class:new("_Directory")
Thread = Class:new("_Thread")
Mutex = Class:new("_Mutex")
Semaphore = Class:new("_Semaphore")

