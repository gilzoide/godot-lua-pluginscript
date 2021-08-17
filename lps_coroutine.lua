local LuaCoroutine = {
	completed = signal('result'),
}

function LuaCoroutine:is_valid()
	local co = assert(self.coroutine, "no coroutine attached")
	return coroutine.status(co) == 'suspended'
end

function LuaCoroutine:resume(...)
	local co = assert(self.coroutine, "no coroutine attached")
	local _, result = assert(coroutine.resume(co, ...))
	if coroutine.status(co) == 'dead' then
		self:emit_signal('completed', result)
	end
	return result
end

return LuaCoroutine
