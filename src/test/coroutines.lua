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

function Test:return_yield_numbers(max)
	for i = 1, max do
		GD.yield()
	end
end
function Test:test_yield_more_than_once()
	local max = 10
	local coro = self:call('return_yield_numbers', max)
	local i = 0
	while coro:is_valid() do
		coro:resume()
		i = i + 1
	end
	lu.assert_equals(i, max)
end

return Test
