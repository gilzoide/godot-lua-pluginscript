-- @file lps_coroutine.lua  LuaCoroutine script
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

--- Godot Reference script that wraps a Lua coroutine with an API similar to `GDScriptFunctionState`.
-- These are created by `GD.yield` and won't work if created manually.
-- @script lps_coroutine.lua

local co_resume, co_status = coroutine.resume, coroutine.status

-- @type LuaCoroutine
local LuaCoroutine = {
	--- `signal completed(result)`: signal emitted by `resume` when the coroutine body is completed.
	completed = signal('result'),
	--- Result of `coroutine.status`
	status = property {
		type = string,
		get = 'get_status',
	},
}

--- Returns the `coroutine.status`.
-- @function get_status
-- @treturn string
-- @see coroutine.status
function LuaCoroutine:get_status()
	local co = assert(self.coroutine, "no coroutine attached")
	return co_status(co)
end

--- Returns whether coroutine is valid (`coroutine.status(self.coroutine) ~= 'dead'`).
-- @function is_valid
-- @treturn bool
function LuaCoroutine:is_valid()
	return self:get_status() ~= 'dead'
end

--- Resume a coroutine, similar to `coroutine.resume`.
-- Emits the `completed` signal if the coroutine body is completed.
-- Differently than `GDScriptFunctionState.resume`, this method accepts
-- multiple arguments.
-- @usage
--     local coro = some_object:method_that_yields()
--     local first_value = coro:resume()
--     local second_value = coro:resume()
--     while coro:is_valid() do
--         local next_value = coro:resume()
--         -- do something
--     end
-- @function resume
-- @param ...
-- @return
-- @raise If `coroutine.resume` returns `false`
function LuaCoroutine:resume(...)
	local co = assert(self.coroutine, "no coroutine attached")
	local _, result = assert(co_resume(co, ...))
	if co_status(co) == 'dead' then
		self:emit_signal('completed', result)
	end
	return result
end

return LuaCoroutine
