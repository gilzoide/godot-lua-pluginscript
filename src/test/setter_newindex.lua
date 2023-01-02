local lu = require "luaunit"

local Test = {
	extends = 'Node'
}

Test.custom_prop = property {
	default = false,
	set = function(self, value)
		self:rawset('custom_prop', value)
		self.custom_prop_setter_called = true
	end,
}

function Test:test_WhenSettingPropertyInClass_SetterIsCalled()
	local name = String 'test'
	self.name = name
	lu.assert_equals(self.name, name)
	lu.assert_equals(self:get 'name', name)
	lu.assert_nil(self:rawget 'name')
end

function Test:test_WhenSettingPropertyInScript_SetterIsCalled()
	self.custom_prop = true
	lu.assert_true(self.custom_prop, true)
	lu.assert_true(self.custom_prop_setter_called, true)
end

return Test
