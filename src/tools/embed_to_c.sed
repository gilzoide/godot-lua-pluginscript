# Escape backslashes
s/\\/\\\\/g
# Escape quotes
s/"/\\"/g
# Add starting quote
s/^/"/
# Add ending newline, except inside ffi.cdef or last script line
/cdef\[\[/,/\]\]/ {
	/\]\]/! b skipNewLine
}
$! s/$/\\n/
:skipNewLine
# Add ending quote
s/$/"/
