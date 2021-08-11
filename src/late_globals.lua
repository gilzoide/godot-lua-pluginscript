-- @file late_globals.lua  Add _G metatable, patch some package.* functionality
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

local dirsep, pathsep, path_mark = package.config:match("^([^\n]*)\n([^\n]*)\n([^\n]+)")
local template_pattern = '[^' .. pathsep .. ']+'
local function searchpath(name, path, sep, rep)
	sep = sep or '.'
	rep = rep or '/'
	if sep ~= '' then
		name = name:gsub(sep:gsub('.', '%%%0'), rep)
	end
	local notfound = {}
	local f = File:new()
	for template in path:gmatch(template_pattern) do
		local filename = template:gsub(path_mark, name)
		if f:open(filename, File.READ) == GD.OK then
			return filename, f
		else
			table.insert(notfound, string.format("\n\tno file %q", filename))
		end
	end
	return nil, table.concat(notfound)
end

local function lua_searcher(name)
	local filename, open_file_or_err = searchpath(name, package.path)
	if not filename then
		return nil, open_file_or_err
	end
	local file_len = open_file_or_err:get_len()
	local contents = open_file_or_err:get_buffer(file_len):get_string()
	open_file_or_err:close()
	return assert(loadstring(contents, filename))
end

function package.searchpath(...)
	local filename, open_file_or_err = searchpath(...)
	if not filename then
		return nil, open_file_or_err
	else
		open_file_or_err:close()
		return filename
	end
end

local searchers = package.searchers or package.loaders
searchers[2] = lua_searcher

package.path = 'res://?.lua' .. pathsep .. 'res://?/init.lua' .. pathsep .. package.path
