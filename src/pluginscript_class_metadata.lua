-- @file pluginscript_class_metadata.lua  Helpers for Script/Class metadata (properties, methods, signals)
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

-- Map names and ctypes to godot_variant_type
local property_types = {
	bool = GD.TYPE_BOOL, [bool] = GD.TYPE_BOOL,
	int = GD.TYPE_INT, [int] = GD.TYPE_INT,
	float = GD.TYPE_FLOAT, [float] = GD.TYPE_FLOAT,
	String = GD.TYPE_STRING, [String] = GD.TYPE_STRING,
	string = GD.TYPE_STRING, [string] = GD.TYPE_STRING,

	Vector2 = GD.TYPE_VECTOR2, [Vector2] = GD.TYPE_VECTOR2,
	Rect2 = GD.TYPE_RECT2, [Rect2] = GD.TYPE_RECT2,
	Vector3 = GD.TYPE_VECTOR3, [Vector3] = GD.TYPE_VECTOR3,
	Transform2D = GD.TYPE_TRANSFORM2D, [Transform2D] = GD.TYPE_TRANSFORM2D,
	Plane = GD.TYPE_PLANE, [Plane] = GD.TYPE_PLANE,
	Quat = GD.TYPE_QUAT, [Quat] = GD.TYPE_QUAT,
	AABB = GD.TYPE_AABB, [AABB] = GD.TYPE_AABB,
	Basis = GD.TYPE_BASIS, [Basis] = GD.TYPE_BASIS,
	Transform = GD.TYPE_TRANSFORM, [Transform] = GD.TYPE_TRANSFORM,

	Color = GD.TYPE_COLOR, [Color] = GD.TYPE_COLOR,
	NodePath = GD.TYPE_NODE_PATH, [NodePath] = GD.TYPE_NODE_PATH,
	RID = GD.TYPE_RID, [RID] = GD.TYPE_RID,
	Object = GD.TYPE_OBJECT, [Object] = GD.TYPE_OBJECT,
	Dictionary = GD.TYPE_DICTIONARY, [Dictionary] = GD.TYPE_DICTIONARY,
	Array = GD.TYPE_ARRAY, [Array] = GD.TYPE_ARRAY,

	PoolByteArray = GD.TYPE_POOL_BYTE_ARRAY, [PoolByteArray] = GD.TYPE_POOL_BYTE_ARRAY,
	PoolIntArray = GD.TYPE_POOL_INT_ARRAY, [PoolIntArray] = GD.TYPE_POOL_INT_ARRAY,
	PoolRealArray = GD.TYPE_POOL_REAL_ARRAY, [PoolRealArray] = GD.TYPE_POOL_REAL_ARRAY,
	PoolStringArray = GD.TYPE_POOL_STRING_ARRAY, [PoolStringArray] = GD.TYPE_POOL_STRING_ARRAY,
	PoolVector2Array = GD.TYPE_POOL_VECTOR2_ARRAY, [PoolVector2Array] = GD.TYPE_POOL_VECTOR2_ARRAY,
	PoolVector3Array = GD.TYPE_POOL_VECTOR3_ARRAY, [PoolVector3Array] = GD.TYPE_POOL_VECTOR3_ARRAY,
	PoolColorArray = GD.TYPE_POOL_COLOR_ARRAY, [PoolColorArray] = GD.TYPE_POOL_COLOR_ARRAY,
}

local function get_property_type(value)
	local t = type(value)
	if t == 'boolean' then
		return GD.TYPE_BOOL
	elseif t == 'string' then
		return GD.TYPE_STRING
	elseif ffi.istype(int, value) then
		return GD.TYPE_INT
	elseif t == 'number' or tonumber(value) then
		return GD.TYPE_REAL
	elseif t == 'table' then
		return GD.TYPE_DICTIONARY
	elseif t == 'cdata' and value.varianttype then
		return value.varianttype
	end
	return GD.TYPE_NIL
end

local Property = {}

local function is_property(value)
	return getmetatable(value) == Property
end

local function property_to_dictionary(prop)
	local dict, default_value = Dictionary(), nil
	if not is_property(prop) then
		default_value = prop
		dict.default_value = prop
		dict.type = get_property_type(prop)
	else
		default_value = prop[1] or prop.default or prop.default_value
		local explicit_type = prop[2] or prop.type
		dict.type = property_types[explicit_type] or explicit_type or get_property_type(default_value) or GD.TYPE_NIL
	end
	dict.default_value = default_value
	return dict, default_value
end

function property(metadata)
	if type(metadata) ~= 'table' then
		metadata = { metadata }
	end
	return setmetatable(metadata, Property)
end

function export(metadata)
	local prop = property(metadata)
	prop.export = true
	return prop
end

local Signal = {}

local function is_signal(value)
	return getmetatable(value) == Signal
end

local function signal_to_dictionary(sig)
	local dict = Dictionary()
	dict.args = Array()
	for i = 1, #sig do
		dict.args:append(Dictionary{ name = String(sig[i]) })
	end
	return dict
end

function signal(...)
	return setmetatable({ ... }, Signal)
end

local function method_to_dictionary(f)
	return Dictionary()
end
