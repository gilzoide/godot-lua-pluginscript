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
	GD[k:ascii()] = v
end

local library_resource_dir = clib.hgdn_library.resource_path:get_base_dir()
local CoroutineObject = GD.load(library_resource_dir:plus_file('lps_coroutine.lua'))

function GD.yield(obj, signal_name)
	local co, is_main = coroutine_running()
	assert(co and not is_main, "GD.yield can be called only from script methods")
	local co_obj = lps_instances[co]
	if not co_obj then
		co_obj = CoroutineObject:new()
		local co_obj_table = get_lua_instance(co_obj)
		co_obj_table.coroutine = co
		lps_instances[co] = co_obj_table
	end
	if obj and signal_name then
		obj:connect(signal_name, co_obj, "resume", Array(), Object.CONNECT_ONESHOT)
	end
	coroutine_yield(co_obj)
end

local Engine = api.godot_global_get_singleton("Engine")
setmetatable(_G, {
	__index = function(self, key)
		if Engine:has_singleton(key) then
			local singleton = api.godot_global_get_singleton(key)
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
_G.ResourceLoader = ResourceLoader
-- These classes are registered with a prepending "_" in ClassDB
File = Class:new("_File")
Directory = Class:new("_Directory")
Thread = Class:new("_Thread")
Mutex = Class:new("_Mutex")
Semaphore = Class:new("_Semaphore")

local active_library_dirsep_pos, dll_ext = active_library_path:match("()[^/]+(%.%w+)$")
local execdir_repl = OS:has_feature("standalone") and active_library_path:sub(1, active_library_dirsep_pos - 1) or tostring(ProjectSettings:globalize_path("res://"))
execdir_repl = execdir_repl:sub(1, -2)  -- Remove trailing slash

-- Supports "res://" and "user://" paths
-- Replaces "!" for executable path on standalone builds or project path otherwise
local function searchpath(name, path, sep, rep)
	sep = sep or '.'
	rep = rep or '/'
	if sep ~= '' then
		name = name:gsub(sep:gsub('.', '%%%0'), rep)
	end
	local notfound = {}
	local f = File:new()
	for template in path:gmatch('[^;]+') do
		local filename = template:gsub('%?', name):gsub('%!', execdir_repl)
		if f:open(filename, File.READ) == GD.OK then
			return filename, f
		else
			table_insert(notfound, string_format("\n\tno file %q", filename))
		end
	end
	return nil, table_concat(notfound)
end

local function lua_searcher(name)
	local filename, open_file_or_err = searchpath(name, package.path)
	if not filename then
		return open_file_or_err
	end
	local file_len = open_file_or_err:get_len()
	local contents = open_file_or_err:get_buffer(file_len):get_string()
	open_file_or_err:close()
	return assert(loadstring(contents, filename))
end

local function c_searcher(name, name_override)
	local filename, open_file_or_err = searchpath(name, package.cpath)
	if not filename then
		return open_file_or_err
	end
	open_file_or_err:close()
	local func_suffix = (name_override or name):gsub('%.', '_')
	-- Split module name if a "-" is found
	local igmark = string_find(func_suffix, '-', 1, false)
	if igmark then
		local funcname = 'luaopen_' .. func_suffix:sub(1, igmark - 1)
		local f = package_loadlib(filename, funcname)
		if f then return f end
		func_suffix = func_suffix:sub(igmark + 1)
	end
	local f, err = package_loadlib(filename, 'luaopen_' .. func_suffix)
	return assert(f, string_format('error loading module %q from file %q:\n\t%s', name_override or name, filename, err))
end

local function c_root_searcher(name)
	local root_name = name:match('^([^.]+)%.')
	if not root_name then
		return nil
	end
	return c_searcher(root_name, name)
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

package.path = 'res://?.lua;res://?/init.lua;' .. package.path
package.cpath = '!/?' .. dll_ext .. ';!/loadall' .. dll_ext .. ';' .. package.cpath

local searchers = package.searchers or package.loaders
searchers[2] = lua_searcher
searchers[3] = c_searcher
searchers[4] = c_root_searcher
