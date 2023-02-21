-- @file lua_package_extras.lua  Extra functionality for the `package` library
-- This file is part of Godot Lua PluginScript: https://github.com/gilzoide/godot-lua-pluginscript
--
-- Copyright (C) 2021-2023 Gil Barbosa Reis.
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

--- Extra functionality for Lua's `package` library.
-- Patch the `package.loaders`/`package.searchers` to use `searchpath`,
-- so that `require` can find files relative to the `res://` and
-- executable folder.
-- @module package_extras

local ProjectSettings, OS = ProjectSettings, OS
local execdir_repl =
	OS:has_feature("standalone")
	and OS:get_executable_path():get_base_dir()
	or ProjectSettings:globalize_path("res://")
execdir_repl = tostring(execdir_repl:trim_suffix('/'))

-- Supports "res://" and "user://" paths
-- Replaces "!" for executable path on standalone builds or project path otherwise
local function searchpath(name, path, sep, rep)
	sep = sep or '.'
	rep = rep or '/'
	if sep ~= '' then
		name = name:replace(sep, rep)
	end
	local notfound = {}
	local f = File:new()
	for template in path:gmatch('[^;]+') do
		local filename = template:replace('?', name):replace('!', execdir_repl)
		if f:open(filename, File.READ) == Error.OK then
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
	filename = tostring(open_file_or_err:get_path_absolute())
	open_file_or_err:close()
	local func_suffix = (name_override or name):replace('.', '_')
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

--- Searches for the given `name` in the given path. 
-- Similar to Lua 5.2+ [package.searchpath](https://www.lua.org/manual/5.2/manual.html#pdf-package.searchpath),
-- but using Godot Files instead, so that paths like `res://` and `user://` are
-- supported.
--
-- `!` characters in `path` templates are replaced by the directory of the game/app
-- executable when running a standalone build (when `OS:has_feature("standalone")`)
-- or by the project's resource path otherwise (`ProjectSettings:globalize_path("res://")`).
-- @function package.searchpath
-- @param name
-- @param path
-- @param[opt="."] separator
-- @param[opt="/"] replacement
-- @treturn[1] string  Found file name
-- @treturn[2] nil
-- @treturn[2] string  Error message
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
searchers[3] = c_searcher
searchers[4] = c_root_searcher

local LUA_PATH_BEHAVIOR_SETTING = 'lua_pluginscript/package_path/behavior'
local LUA_PATH_SETTING = 'lua_pluginscript/package_path/templates'
local LUA_CPATH_BEHAVIOR_SETTING = 'lua_pluginscript/package_c_path/behavior'
local LUA_CPATH_SETTING = 'lua_pluginscript/package_c_path/templates'

local function add_project_setting(name, initial_value)
	if not ProjectSettings:has_setting(name) then
		ProjectSettings:set_setting(name, initial_value)
	end
	ProjectSettings:set_initial_value(name, initial_value)
end

local function add_project_setting_enum(name, enum_values)
	add_project_setting(name, 0)
	ProjectSettings:add_property_info {
		name = name,
		type = VariantType.Int,
		hint = PropertyHint.ENUM,
		hint_string = enum_values,
	}
end

add_project_setting_enum(LUA_PATH_BEHAVIOR_SETTING, 'Replace,Append,Prepend')
add_project_setting(LUA_PATH_SETTING, PoolStringArray('res://?.lua', 'res://?/init.lua', 'res://addons/godot-lua-pluginscript/build/?.lua'))
add_project_setting_enum(LUA_CPATH_BEHAVIOR_SETTING, 'Replace,Append,Prepend')
add_project_setting(LUA_CPATH_SETTING, PoolStringArray('!/?.so', '!/loadall.so'))
add_project_setting(LUA_CPATH_SETTING .. '.Windows', PoolStringArray('!/?.dll', '!/loadall.dll'))

local lua_path = ProjectSettings:get_setting(LUA_PATH_SETTING)
local lua_cpath = ProjectSettings:get_setting(LUA_CPATH_SETTING)
local lua_path_behaviour = ProjectSettings:get_setting(LUA_PATH_BEHAVIOR_SETTING)
local lua_cpath_behaviour = ProjectSettings:get_setting(LUA_CPATH_BEHAVIOR_SETTING)

if lua_path_behaviour == 1 then
	lua_path:insert(0, package.path)
elseif lua_path_behaviour == 2 then
	lua_path:append(package.path)
end

if lua_cpath_behaviour == 1 then
	lua_cpath:insert(0, package.cpath)
elseif lua_cpath_behaviour == 2 then
	lua_cpath:append(package.cpath)
end

--- When Lua PluginScript is loaded, `package.path` is either replaced,
-- appended or prepended by the paths in `lua_pluginscript/package_path/templates` project
-- setting.
--
-- The chosen behavior depends on the `lua_pluginscript/package_path/behavior`
-- project setting.
--
-- Default paths are `res://?.lua`, `res://?/init.lua` and 'res://addons/godot-lua-pluginscript/build/?.lua'.
--
-- @see searchpath
package.path = lua_path:join(';')

--- When Lua PluginScript is loaded, `package.cpath` is either replaced,
-- appended or prepended by the paths in `lua_pluginscript/package_c_path/templates` project
-- setting.
--
-- The chosen behavior depends on the `lua_pluginscript/package_c_path/behavior`
-- project setting.
--
-- Default paths are `!/?.dll` and `!/loadall.dll` on Windows, `!/?.so` and `!/loadall.so` elsewhere.
--
-- @see searchpath
package.cpath = lua_cpath:join(';')

--- `dlopen`s the PluginScript library with `RTLD_LAZY | RTLD_GLOBAL`.
-- This is necessary for loading Lua/C modules in POSIX systems.
local function dlopen_self()
	ffi_cdef[[
	void *dlopen(const char *filename, int flags);
	int dlclose(void *handle);
	]]

	local RTLD_LAZY = 0x00001
	local RTLD_GLOBAL = 0x00100
	local currentLibraryPath = tostring(gdnativelibrary:get_current_library_path():replace("res://", execdir_repl .. '/'))
	-- Maintain a reference to dlopened library while PluginScript is loaded
	-- When the Lua state closes, GC will kick in and the library will get dlclosed
	pluginscript_callbacks.__dlopened_self = ffi_gc(ffi.C.dlopen(currentLibraryPath, RTLD_LAZY + RTLD_GLOBAL), ffi.C.dlclose)
end

if Array("Android", "iOS", "OSX", "Server", "X11"):has(OS:get_name()) then
	xpcall(dlopen_self, GD.print_error)
end
