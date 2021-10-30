/cdef\[\[/,/\]\]/ {
	# Remove indentation
	s/^[[:space:]]*//
	# Remove C comments
	s/[[:space:]]*\/\/.*//
	# Minify unused private fields
	s/_dont_touch_that/d/
	# Remove function parameter names
	/\(\*/ {
		s/[_a-zA-Z0-9]*(,|\);)/\1/g
	}
	# Remove spaces before/after punctuation
	s/[[:space:]]*([^_a-zA-Z0-9])[[:space:]]*/\1/g
	# Remove empty lines
	/^$/d
}

