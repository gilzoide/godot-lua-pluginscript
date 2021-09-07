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

function LuaREPL:_init()
	-- Local environment, to avoid messing up _G
	self.env = setmetatable({
		print = function(...)
			return self:print(...)
		end,
	}, index_G)
end

-- Cache nodes
function LuaREPL:_ready()
	self.output = self:get_node("Output")
	self.line_edit = self:get_node("Footer/LineEdit")
end

-- Prints a line to output
function LuaREPL:print(...)
	self.output:add_text(string.join('\t', ...))
	self.output:add_text('\n')
end

-- Runs a line, printing the results/error
function LuaREPL:dostring(text)
	self:print('> ' .. text)
	text = tostring(text):gsub('^%s*%=', '', 1)
	local f, err_msg = load('return ' .. text, nil, nil, self.env)
	if not f then
		f, err_msg = load(text, nil, nil, self.env)
	end
	if f then
		local result = table.pack(pcall(f))
		if not result[1] then
			self:print(get_error(result[2]))
		elseif result.n > 1 then
			self:print(table.unpack(result, 2, result.n))
		end
	else
		self:print(get_error(err_msg))
	end
	self.line_edit:clear()
end

-- Clear output text
function LuaREPL:clear()
	self.output:clear()
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

return LuaREPL
