# Escape backslashes
s/\\/\\\\/g
# Escape quotes
s/"/\\"/g
# Add starting quote
s/^/"/
# Add ending newline, except on last script line
$! s/$/\\n/
# Add ending quote
s/$/"/
