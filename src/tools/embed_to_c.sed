# Escape backslashes
s/\\/\\\\/g
# Escape quotes
s/\"/\\"/g
# Add starting quote
s/^/"/
# Add ending newline and quote
s/$/\\n"/
