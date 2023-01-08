# On empty lines, do:
/^$/ {
	: remove-empty-line
	# Load the next input line
	N
	# Remove last line, if it is empty
	s/\n$//
	# In case last line was empty, repeat the process to squeeze multiple empty lines into a single one
	t remove-empty-line
}

