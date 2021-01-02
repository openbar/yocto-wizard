# Use a special output separator to let make(1) evaluate the output
# as the new line characters are substituted
BEGIN				{ ORS = "\v" }

# Use colon as field separator to extract the targets
BEGIN				{ FS = ":" }

# Variables are defined in a dedicated section surrounded by blank lines
/^#[[:space:]]+Variables$/	{ variable_section = 2 }
/^$/				{ variable_section-- }

# Only explicit variables are valid
/^#[[:space:]]+makefile \(from '[[:print:]]+', line [[:digit:]]+\)$/	{ variable = 1 }

# Explicit targets are defined in the Files section
/^#[[:space:]]+Files$/		{ target_section = 1 }

# Not a target blocks are ignored
/^#[[:space:]]+Not a target:$/	{ notatarget = 1 }
/^$/				{ notatarget = 0 }

# Comments and blank lines are skipped
/^#/ || /^$/			{ next }

# Special variables are ignored
/^\.DEFAULT_GOAL/		|| \
/^\.EXTRA_PREREQS/		|| \
/^\.FEATURES/			|| \
/^\.INCLUDE_DIRS/		|| \
/^\.LIBPATTERNS/		|| \
/^\.LOADED/			|| \
/^\.RECIPEPREFIX/		|| \
/^\.SHELLFLAGS/			|| \
/^\.VARIABLES/			|| \
/^COMSPEC/			|| \
/^CURDIR/			|| \
/^DESTDIR/			|| \
/^GPATH/			|| \
/^MAKE/				|| \
/^MAKECMDGOALS/			|| \
/^MAKEFILES/			|| \
/^MAKEFILE_LIST/		|| \
/^MAKELEVEL/			|| \
/^MAKESHELL/			|| \
/^MAKE_HOST/			|| \
/^MAKE_RESTARTS/		|| \
/^MAKE_TERMERR/			|| \
/^MAKE_TERMOUT/			|| \
/^MAKE_VERSION/			|| \
/^MFLAGS/			|| \
/^OUTPUT_OPTION/		|| \
/^SHELL/			|| \
/^SUFFIXES/			|| \
/^VPATH/			{ variable = 0 }

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

# Recipes are skipped
/^\t/				{ next }

{
	# Remaining variables are printed
	if (variable_section > 0 && variable) {
		print;
	}

	# The next variable must be validated again
	variable = 0;

	# Remaining targets are saved
	if (target_section > 0 && !notatarget) {
		targets[i++] = $1;
	}
}

# The saved targets are printed in a dedicated variable
END {
	printf "ALL_TARGETS :=";

	for (i in targets) {
		printf " %s", targets[i];
	}

	print;
}
