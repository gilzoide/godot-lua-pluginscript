# Remove indentation
s/^[[:space:]]*//
# Remove Lua comments
s/[[:space:]]*--.*$//
# Remove C comments inside ffi.cdef
s/[[:space:]]*\/\/.*$//
# Remove empty lines
/^$/d
