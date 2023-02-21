#include "lua.h"

int luaopen_test_luac(lua_State *L) {
	lua_pushboolean(L, 1);
	return 1;
}
