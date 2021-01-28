
#define GMOD_ALLOW_DEPRECATED

#include "GarrysMod/Lua/Interface.h"

extern "C" {
	int luaopen_ffi(lua_State *L);
}

GMOD_MODULE_OPEN()
{
	luaopen_ffi(state);
	LUA->SetField(GarrysMod::Lua::SPECIAL_GLOB, "ffi");
	return 0;
}

GMOD_MODULE_CLOSE()
{
	return 0;
}
