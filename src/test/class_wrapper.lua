local lu = require "luaunit"

local Test = {}

function Test:test_has_property()
	lu.assert_true(Node:has_property 'name')
	lu.assert_false(Node:has_property 'not_a_property')
end

function Test:test_inherits()
	lu.assert_true(Node:inherits 'Object')
	lu.assert_true(Node2D:inherits 'Object')
	lu.assert_false(Node:inherits 'not_a_class')
end

function Test:test_get_parent_class()
	lu.assert_equals(String 'Object', Node:get_parent_class())
	lu.assert_equals(String 'CanvasItem', Node2D:get_parent_class())
end

function Test:test_ReturnsConstant()
	lu.assert_equals(1, Object.CONNECT_DEFERRED)
	lu.assert_equals(1, File.READ)
	lu.assert_equals(2, File.WRITE)
end

return Test
