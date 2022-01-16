local lu = require "luaunit"

local Test_setter_newindex = {
	extends = 'Node'
}

function Test_setter_newindex:test_WhenSettingPropertyInClass_SetterIsCalled()
	local name = String 'test'
	self.name = name
	lu.assert_equals(self.name, name)
	lu.assert_equals(self:get 'name', name)
end

return Test_setter_newindex
