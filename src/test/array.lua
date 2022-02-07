local lu = require "luaunit"

local Test = {}

function Test:test_array_index()
	local arr = Array(1, 3.14, 'hello!')
	lu.assert_nil(arr[0])
	lu.assert_equals(1, arr[1])
	lu.assert_equals(3.14, arr[2])
	lu.assert_equals(String 'hello!', arr[3])
	lu.assert_nil(arr[4])
end

function Test:test_array_newindex()
	local arr = Array()
	arr[1] = 1
	arr[2] = '2'

	lu.assert_equals(1, arr[1])
	lu.assert_equals(String '2', arr[2])
	lu.assert_equals(2, #arr)

	arr[1] = 2
	arr[2] = '3'

	lu.assert_equals(2, arr[1])
	lu.assert_equals(String '3', arr[2])
	lu.assert_equals(2, #arr)
end

function Test:sort(a, b)
	return a < b
end
function Test:test_sort()
	local arr = Array(1, 6, 3, 7, 3)
	arr:sort_custom(self, 'sort')
	lu.assert_equals(Array(1, 3, 3, 6, 7), arr)
end

return Test
