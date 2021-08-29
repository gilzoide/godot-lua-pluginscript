# NOTE: using actual newlines instead of "\n" for BSD/OSX version of sed
# Text before first line
1 i\
#include<stdlib.h>\
const char LUA_INIT_SCRIPT[] =
# Text after last line
$ a\
;\
const size_t LUA_INIT_SCRIPT_SIZE = sizeof(LUA_INIT_SCRIPT);
