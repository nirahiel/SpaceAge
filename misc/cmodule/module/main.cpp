
#define GMOD_ALLOW_DEPRECATED

#include "GarrysMod/Lua/Interface.h"

extern "C" {
	int luaopen_ffi(lua_State *L);
}

GMOD_MODULE_OPEN()
{
	if (luaopen_ffi(state) == 0) {
		return 1;
	}
	LUA->Push(-1);
	LUA->SetField(GarrysMod::Lua::SPECIAL_GLOB, "ffi");

	return 1;
}

GMOD_MODULE_CLOSE()
{
	return 0;
}
