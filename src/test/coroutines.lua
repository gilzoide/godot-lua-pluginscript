local lu = require "luaunit"

local Test = {}

function Test:return_yield()
	return GD.yield()
end

function Test:test_yield_results()
	local coro = self:call('return_yield')
	lu.assert_nil(coro:resume())

	local coro = self:call('return_yield')
	lu.assert_equals(coro:resume(42), 42)
end

return Test
