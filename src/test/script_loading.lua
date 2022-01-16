local lu = require "luaunit"

local Test = {}

function Test:get_extra_script(name)
	local script_path = self:get_script().resource_path:get_base_dir():plus_file('extras'):plus_file(name)
	return GD.load(script_path)
end

function Test:test_WhenValidScript_CanInstance()
	local script = self:get_extra_script("valid_script.lua")
	lu.assert_true(script:can_instance())
end

function Test:test_WhenExtendsClassWrapper_IsValidAndCanInstance()
	local script = self:get_extra_script("valid_script_class_wrapper.lua")
	lu.assert_true(script:can_instance())
end

function Test:test_WhenParseError_CantInstance()
	local script = self:get_extra_script("parse_error.lua")
	lu.assert_false(script:can_instance())
end

function Test:test_WhenExtendsIsNotAClassNorScriptPath_CantInstance()
	local script = self:get_extra_script("invalid_extends.lua")
	lu.assert_false(script:can_instance())
end

return Test
