/cdef\[\[/,/\]\]/ {
	# Remove C comments
	s/[[:space:]]*\/\/.*//
	# Minify unused private fields
	s/_dont_touch_that/_/
	# Remove function parameter names
	/\(\*/ {
		s/[[:space:]]*[_a-zA-Z0-9]*(,|\);)/\1/g
	}
	# Remove unused enum/struct/union names when they're typedef'd
	s/typedef (enum|struct|union) [_a-zA-Z0-9]*/typedef \1/
}

