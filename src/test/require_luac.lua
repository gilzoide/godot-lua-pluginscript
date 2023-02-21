local lu = require "luaunit"

local Test = {}

function Test:test_require_luac_module()
	lu.assert_true(pcall(require, 'test_cmodule'))
end

return Test
