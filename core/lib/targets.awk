# Use a special output separator to let make(1) evaluate the output
# as the new line characters are substituted
BEGIN				{ ORS = "\v" }

# Explicit targets are defined in the Files section
/^#[[:space:]]+Files$/		{ target_section = 1 }

# Not a target blocks are ignored
/^#[[:space:]]+Not a target:$/	{ notatarget = 1 }
/^$/				{ notatarget = 0 }

# Comments and blank lines are skipped
/^#/ || /^$/			{ next }

# Special targets are ignored
/^\.PHONY:/			|| \
/^\.SUFFIXES:/			|| \
/^\.DEFAULT:/			|| \
/^\.PRECIOUS:/			|| \
/^\.INTERMEDIATE:/		|| \
/^\.SECONDARY:/			|| \
/^\.SECONDEXPANSION:/		|| \
/^\.DELETE_ON_ERROR:/		|| \
/^\.IGNORE:/			|| \
/^\.LOW_RESOLUTION_TIME:/	|| \
/^\.SILENT:/			|| \
/^\.EXPORT_ALL_VARIABLES:/	|| \
/^\.NOTPARALLEL:/		|| \
/^\.ONESHELL:/			|| \
/^\.POSIX:/			{ notatarget = 1 }

# Internal targets are ignored
/^shell:/			{ notatarget = 1 }

# Remaining blocks are printed
{
	if (target_section > 0 && !notatarget) {
		print;
	}
}
