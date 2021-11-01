-- @file plugin/export_plugin.lua  EditorExportPlugin for minifying Lua scripts on release exports
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
local package_path = package.path
package.path = 'res://addons/godot-lua-pluginscript/plugin/?.lua;res://addons/godot-lua-pluginscript/plugin/?/init.lua;' .. package_path
local luasrcdiet = require 'luasrcdiet'
package.path = package_path

local LuaExportPlugin = {
	is_tool = true,
	extends = 'EditorExportPlugin',
}

local SHOULD_MINIFY_RELEASE_SETTING = 'lua_pluginscript/export/minify_on_release_export'

local function add_project_setting(name, initial_value)
	if not ProjectSettings:has_setting(name) then
		ProjectSettings:set_setting(name, initial_value)
	end
	ProjectSettings:set_initial_value(name, initial_value)
end
add_project_setting(SHOULD_MINIFY_RELEASE_SETTING, true)

function LuaExportPlugin:_export_begin(features, is_debug, path, flags)
	self.ignore_path = self:get_script().resource_path:get_base_dir()
	self.should_minify = not is_debug and ProjectSettings:get_setting(SHOULD_MINIFY_RELEASE_SETTING)
	self.file = File:new()
end

function LuaExportPlugin:_export_file(path, type, features)
	if path:begins_with(self.ignore_path) then
		self:skip()
	elseif self.should_minify and path:ends_with('.lua') then
		if self.file:open(path, File.READ) == GD.OK then
			local source = tostring(self.file:get_as_text())
			self.file:close()
			local optsource = luasrcdiet.optimize(luasrcdiet.MAXIMUM_OPTS, source)
			print(string.format('[LuaPluginScript] Minified %s: %s -> %s (%d%% reduction)',
				path,
				String.humanize_size(#source),
				String.humanize_size(#optsource),
				100 - math.floor(#optsource / #source * 100))
			)
			self:add_file(path, PoolByteArray.from(optsource), false)
		end
	end
end

function LuaExportPlugin:_export_end()
	self.ignore_path = nil
	self.file = nil
end

return LuaExportPlugin
