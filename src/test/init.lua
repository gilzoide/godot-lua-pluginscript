-- @file test/init.lua  Unit test runner
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
local TestRunner = {
	extends = 'SceneTree',
}

local function error_handler(msg)
	if os.getenv('DEBUG_INTERACTIVE') then
		local have_dbg, dbg = pcall(require, 'debugger')
		if have_dbg then
			return dbg()
		end
	end
	GD.print_error(msg)
end

function TestRunner:setup_luapath(current_script_base_dir)
	local additional_paths = { '../../lib/luaunit', '../../lib/debugger_lua' }
	for _, path in ipairs(additional_paths) do
		local additional_path = current_script_base_dir:plus_file(path)
		package.path = string.format('%s/?.lua;%s/?/init.lua;%s', additional_path, additional_path, package.path)
	end
end

function TestRunner:setup_cpath()
	local additional_paths
	if OS:get_name() == 'Windows' then
		additional_paths = {
			'!/addons/godot-lua-pluginscript/build/windows_x86/?.dll',
			'!/addons/godot-lua-pluginscript/build/windows_x86_64/?.dll',
		}
	elseif OS:get_name() == 'OSX' then
		additional_paths = {
			'!/addons/godot-lua-pluginscript/build/osx_arm64_x86_64/?.dylib',
		}
	else
		additional_paths = {
			'!/addons/godot-lua-pluginscript/build/linux_x86/?.so',
			'!/addons/godot-lua-pluginscript/build/linux_x86_64/?.so',
		}
	end

	for _, path in ipairs(additional_paths) do
		package.cpath = string.format('%s;%s', path, package.cpath)
	end
end

function TestRunner:_init()
	local current_script_path = self:get_script().resource_path
	local current_script_filename = current_script_path:get_file()
	local current_script_base_dir = current_script_path:get_base_dir()

	self:setup_luapath(current_script_base_dir)
	self:setup_cpath()

	local dir, all_passed = Directory:new(), true
	assert(dir:open(current_script_base_dir) == GD.OK)
	dir:list_dir_begin(true)
	repeat
		local filename = dir:get_next()
		if filename:ends_with('.lua') and filename ~= current_script_filename then
			local script = GD.load(current_script_base_dir:plus_file(filename))
			local instance = script:new()
			if instance:is_class('Node') then
				self.root:add_child(instance)
			end
			local lua_instance = GD.get_lua_instance(instance)
			print(string.format('> %s:', filename))
			for i, method in ipairs(script:get_script_method_list()) do
				if method.name:begins_with("test") then
					local success = xpcall(lua_instance[tostring(method.name)], error_handler, lua_instance)
					print(string.format('  %s %s: %s', success and '✓' or '🗴', method.name, success and 'passed' or 'failed'))
					all_passed = all_passed and success
				end
			end
			instance:pcall('queue_free')
		end
	until filename == ''
	dir:list_dir_end()

	self:quit(all_passed and 0 or 1)
end

return TestRunner
