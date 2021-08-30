local co_resume, co_status = coroutine.resume, coroutine.status

local LuaCoroutine = {
	completed = signal('result'),
}

function LuaCoroutine:is_valid()
	local co = assert(self.coroutine, "no coroutine attached")
	return co_status(co) ~= 'dead'
end

function LuaCoroutine:resume(...)
	local co = assert(self.coroutine, "no coroutine attached")
	local _, result = assert(co_resume(co, ...))
	if co_status(co) == 'dead' then
		self:emit_signal('completed', result)
	end
	return result
end

return LuaCoroutine
