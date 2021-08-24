-- @file cache_lua_libs.lua  Some Lua globals cached as locals
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

-- Lua globals
local assert, getmetatable, ipairs, pairs, rawget, select, setmetatable, tonumber, tostring, type, xpcall = assert, getmetatable, ipairs, pairs, rawget, select, setmetatable, tonumber, tostring, type, xpcall

-- Lua library functions
local coroutine_resume, coroutine_running, coroutine_status, coroutine_yield = coroutine.resume, coroutine.running, coroutine.status, coroutine.yield
local debug_getinfo, debug_traceback = debug.getinfo, debug.traceback
local package_loadlib = package.loadlib
local string_byte, string_find, string_format, string_gmatch, string_gsub, string_match, string_rep, string_reverse = string.byte, string.find, string.format, string.gmatch, string.gsub, string.match, string.rep, string.reverse
local table_concat, table_insert, table_remove = table.concat, table.insert, table.remove

-- custom globals from `src/language_gdnative.c`
local setthreadfunc, touserdata = setthreadfunc, touserdata

-- Lua globals with fallback for 5.1
local loadstring = loadstring or load
local unpack = table.unpack or unpack

-- FFI
local ffi_cast, ffi_gc, ffi_istype, ffi_metatype, ffi_new, ffi_string, ffi_typeof = ffi.cast, ffi.gc, ffi.istype, ffi.metatype, ffi.new, ffi.string, ffi.typeof

-- Weak tables
local weak_k = { __mode = 'k' }

-- Some useful patterns
local ERROR_LINE_MESSAGE_PATT = ':(%d+):%s*(.*)'
local ERROR_PATH_LINE_MESSAGE_PATT = '"([^"]+)"%D*(%d*):%s*(.+)'