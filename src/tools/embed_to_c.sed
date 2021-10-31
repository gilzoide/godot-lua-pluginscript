# Escape backslashes
s/\\/\\\\/g
# Escape quotes
s/"/\\"/g
# Add starting quote
s/^/"/
# Add ending newline, except inside ffi.cdef
/cdef\[\[/,/\]\]/ {
	/\]\]/! b a
}
$! s/$/\\n/
:a
# Add ending quote
s/$/"/
