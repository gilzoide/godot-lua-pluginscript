# Remove indentation
s/^[[:space:]]*//
# Remove Lua comments
s/[[:space:]]*--.*$//
# Remove C comments inside ffi.cdef (only "// " or "///", so "res://" is preserved)
s/[[:space:]]*\/\/[ \/].*//
# Remove empty lines
/^$/d
