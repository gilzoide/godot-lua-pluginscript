# Remove all comment lines but the first license notice and "-- @file ..." lines
25,$ {
	# Ensure there is a new line before "-- @file ..." lines
	s/(-- @file)/\n\1/
	# Skip next command if the previous one substituted anything
	# That is, when current line is a "-- @file ..." line, skip everything below
	t
	# Remove comment lines
	/^[[:space:]]*--/d
}
