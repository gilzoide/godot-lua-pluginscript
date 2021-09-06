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
	bool = VariantType.Bool, [bool] = VariantType.Bool,
	int = VariantType.Int, [int] = VariantType.Int,
	float = VariantType.Float, [float] = VariantType.Float,
	String = VariantType.String, [String] = VariantType.String,
	string = VariantType.String, [string] = VariantType.String,

	Vector2 = VariantType.Vector2, [Vector2] = VariantType.Vector2,
	Rect2 = VariantType.Rect2, [Rect2] = VariantType.Rect2,
	Vector3 = VariantType.Vector3, [Vector3] = VariantType.Vector3,
	Transform2D = VariantType.Transform2D, [Transform2D] = VariantType.Transform2D,
	Plane = VariantType.Plane, [Plane] = VariantType.Plane,
	Quat = VariantType.Quat, [Quat] = VariantType.Quat,
	AABB = VariantType.AABB, [AABB] = VariantType.AABB,
	Basis = VariantType.Basis, [Basis] = VariantType.Basis,
	Transform = VariantType.Transform, [Transform] = VariantType.Transform,

	Color = VariantType.Color, [Color] = VariantType.Color,
	NodePath = VariantType.NodePath, [NodePath] = VariantType.NodePath,
	RID = VariantType.RID, [RID] = VariantType.RID,
	Object = VariantType.Object, [Object] = VariantType.Object,
	Dictionary = VariantType.Dictionary, [Dictionary] = VariantType.Dictionary,
	Array = VariantType.Array, [Array] = VariantType.Array,

	PoolByteArray = VariantType.PoolByteArray, [PoolByteArray] = VariantType.PoolByteArray,
	PoolIntArray = VariantType.PoolIntArray, [PoolIntArray] = VariantType.PoolIntArray,
	PoolRealArray = VariantType.PoolRealArray, [PoolRealArray] = VariantType.PoolRealArray,
	PoolStringArray = VariantType.PoolStringArray, [PoolStringArray] = VariantType.PoolStringArray,
	PoolVector2Array = VariantType.PoolVector2Array, [PoolVector2Array] = VariantType.PoolVector2Array,
	PoolVector3Array = VariantType.PoolVector3Array, [PoolVector3Array] = VariantType.PoolVector3Array,
	PoolColorArray = VariantType.PoolColorArray, [PoolColorArray] = VariantType.PoolColorArray,
}

local function get_property_type(value)
	local t = type(value)
	if t == 'boolean' then
		return VariantType.Bool
	elseif t == 'string' then
		return VariantType.String
	elseif ffi_istype(int, value) then
		return VariantType.Int
	elseif t == 'number' or tonumber(value) then
		return VariantType.Real
	elseif t == 'table' then
		return VariantType.Dictionary
	elseif t == 'cdata' and value.varianttype then
		return value.varianttype
	end
	return VariantType.Nil
end

local Property = {}

local function is_property(value)
	return getmetatable(value) == Property
end

local function property_to_dictionary(prop)
	local dict, default_value, get, set = Dictionary(), nil, nil, nil
	if not is_property(prop) then
		default_value = prop
		dict.type = get_property_type(prop)
	else
		default_value = prop[1] or prop.default or prop.default_value
		local explicit_type = prop[2] or prop.type
		dict.type = property_types[explicit_type] or explicit_type or get_property_type(default_value)
		dict.hint = prop.hint
		dict.hint_string = prop.hint_string
		dict.usage = prop.usage
		dict.rset_mode = prop.rset_mode
		get = prop.get or prop.getter
		set = prop.set or prop.setter
	end
	dict.default_value = default_value
	return dict, default_value, get, set
end

function property(metadata)
	if type(metadata) ~= 'table' then
		metadata = { metadata }
	end
	return setmetatable(metadata, Property)
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
