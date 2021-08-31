local LuaREPL = {
	is_tool = true,
	extends = "Node",
}

local index_G = { __index = _G }

local function get_error(text)
	return 'Error: ' .. text:match(":%d+:%s*(.+)")
end

function LuaREPL:_init()
	self.env = setmetatable({
		print = function(...)
			return self:print(...)
		end,
	}, index_G)
end

function LuaREPL:_ready()
	self.output = self:get_node("Output")
	self.line_edit = self:get_node("Footer/LineEdit")
end

function LuaREPL:print(...)
	local msg = {}
	for i = 1, select('#', ...) do
		table.insert(msg, tostring(select(i, ...)))
	end
	self.output:add_text(table.concat(msg, '\t'))
	self.output:add_text('\n')
end

function LuaREPL:dostring(text)
	self.output:add_text('> ' .. text)
	self.output:add_text('\n')
	text = tostring(text):gsub('^%s*%=', '', 1)
	local f, err_msg = load('return ' .. text, nil, nil, self.env)
	if not f then
		f, err_msg = load(text, nil, nil, self.env)
	end
	if f then
		local success, result = pcall(f)
		if not success then
			result = get_error(result)
		end
		self.output:add_text(String(result))
	else
		self.output:add_text(get_error(err_msg))
	end
	self.output:add_text('\n')
	self.line_edit:clear()
end

function LuaREPL:clear()
	self.output:clear()
end

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