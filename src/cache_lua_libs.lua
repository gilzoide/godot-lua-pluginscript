-- Lua globals
local assert, getmetatable, ipairs, pairs, select, setmetatable, tonumber, tostring, type, xpcall = assert, getmetatable, ipairs, pairs, select, setmetatable, tonumber, tostring, type, xpcall
-- Lua library functions
local coroutine_resume, coroutine_running, coroutine_status, coroutine_yield = coroutine.resume, coroutine.running, coroutine.status, coroutine.yield
local debug_getinfo = debug.getinfo
local package_loadlib = package.loadlib
local string_byte, string_find, string_format, string_gmatch, string_gsub, string_match, string_rep, string_reverse = string.byte, string.find, string.format, string.gmatch, string.gsub, string.match, string.rep, string.reverse
local table_concat, table_insert = table.concat, table.insert
-- custom globals from `src/language_gdnative.c`
local setthreadfunc, touserdata = setthreadfunc, touserdata
-- Lua globals with fallback for 5.1
local loadstring = loadstring or load
local unpack = table.unpack or unpack
-- Weak tables
local weak_k = { __mode = 'k' }
-- FFI
local ffi_cast, ffi_gc, ffi_istype, ffi_metatype, ffi_new, ffi_string, ffi_typeof = ffi.cast, ffi.gc, ffi.istype, ffi.metatype, ffi.new, ffi.string, ffi.typeof
