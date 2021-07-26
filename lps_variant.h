/**
 * Interface between Lua and Godot C data.
 */
#ifndef __LUA_PLUGINSCRIPT_H__
#define __LUA_PLUGINSCRIPT_H__

#include "hgdn.h"
#include "lua.h"

godot_variant lps_tovariant(lua_State *L, int index);
void lps_pushvariant(lua_State *L, const godot_variant *var);

#endif
