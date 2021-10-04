-- @file plugin/lua_repl.lua  A tool Node for building a Lua REPL in-editor
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

local LuaREPL = {
	is_tool = true,
	extends = "Node",
}

local index_G = { __index = _G }

local function get_error(text)
	text = tostring(text)
	return 'Error: ' .. (text:match(":%d+:%s*(.+)") or text)
end

-- Cache and setup nodes
function LuaREPL:_ready()
	self.output = self:get_node("Output")
	self.line_edit = self:get_node("Footer/LineEdit")
	self.history_button_popup = self:get_node("Header/HistoryButton"):get_popup()
	self.history_button_popup:connect("about_to_show", self, "_on_HistoryButton_popup_about_to_show")
	self.history_button_popup:connect("id_pressed", self, "_on_HistoryButton_popup_id_pressed")
	
	self:reset()
end

-- Resets the Lua environment and REPL history
function LuaREPL:reset()
	-- Local environment, to avoid messing up _G
	self.env = setmetatable({
		print = function(...)
			return self:printf('%s\n', string.join('\t', ...))
		end,
	}, index_G)
	self.history = PoolStringArray()
	self.current_history = 0
	
	self:clear()
end

-- Print content to output
function LuaREPL:print(msg)
	self.output:add_text(msg)
end

function LuaREPL:printn(msg)
	self:print(msg)
	self:print('\n')
end

function LuaREPL:printf(...)
	self:print(string.format(...))
end

-- Runs a line, printing the results/error
function LuaREPL:dostring(text)
	text = text:strip_edges()
	if text:empty() then
		return
	end
	
	self.history:append(text)
	self.current_history = #self.history
	self.line_edit:clear()
	self:printn(text)
	
	text = text:gsub('^=', '', 1)  -- support for "= value" idiom from Lua 5.1 REPL
	local f, err_msg = load('return ' .. text, nil, nil, self.env)
	if not f then
		f, err_msg = load(text, nil, nil, self.env)
	end
	if f then
		local result = table.pack(pcall(f))
		if not result[1] then
			self:printn(get_error(result[2]))
		elseif result.n > 1 then
			local joined_results = string.join('\t', table.unpack(result, 2, result.n))
			self:printf('Out[%d]: %s\n', #self.history, joined_results)
		end
	else
		self:printn(get_error(err_msg))
	end
	self:prompt()
end

function LuaREPL:prompt()
	self:printf('\nIn [%d]: ', #self.history + 1)
end

-- Clear output text
function LuaREPL:clear()
	self.output:clear()
	self:prompt()
end

-- History handlers
function LuaREPL:set_history(index)
	if index >= 0 and index < #self.history then
		self.current_history = index
		local text = self.history[self.current_history]
		self.line_edit.text = text
		self.line_edit.caret_position = #text
	end
end

function LuaREPL:history_up()
	self:set_history(self.current_history - 1)
end

function LuaREPL:history_down()
	self:set_history(self.current_history + 1)
end

-- Signal handlers
function LuaREPL:_on_LineEdit_text_entered(text)
	self:dostring(text)
end

function LuaREPL:_on_RunButton_pressed()
	self:dostring(self.line_edit.text)
end

function LuaREPL:_on_ClearButton_pressed()
	self:clear()
end

function LuaREPL:_on_ResetButton_pressed()
	self:reset()
end

function LuaREPL:_on_LineEdit_gui_input(event)
	if event:is_class("InputEventKey") and event:is_pressed() then
		if event.scancode == GD.KEY_UP then
			self:history_up()
		elseif event.scancode == GD.KEY_DOWN then
			self:history_down()
		end
	end
end

function LuaREPL:_on_HistoryButton_popup_about_to_show()
	self.history_button_popup:clear()
	for i, s in ipairs(self.history) do
		self.history_button_popup:add_item(s)
	end
end

function LuaREPL:_on_HistoryButton_popup_id_pressed(i)
	self:set_history(i)
end

return LuaREPL
