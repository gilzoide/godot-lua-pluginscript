# @file plugin/plugin.gd  EditorPlugin registering REPL
# This file is part of Godot Lua PluginScript: https://github.com/gilzoide/godot-lua-pluginscript
#
# Copyright (C) 2021 Gil Barbosa Reis.
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the “Software”), to
# deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.
tool
extends EditorPlugin

var _lua_repl
var _lua_export_plugin

func _enter_tree() -> void:
	_lua_repl = preload("lua_repl.tscn").instance()
	add_control_to_bottom_panel(_lua_repl, "Lua REPL")

	_lua_export_plugin = preload("export_plugin.lua").new()
	add_export_plugin(_lua_export_plugin)


func _exit_tree() -> void:
	if _lua_repl:
		remove_control_from_bottom_panel(_lua_repl)
		_lua_repl.free()
		_lua_repl = null
	if _lua_export_plugin:
		remove_export_plugin(_lua_export_plugin)
		_lua_export_plugin.unreference()
		_lua_export_plugin = null
