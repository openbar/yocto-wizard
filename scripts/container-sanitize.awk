# Sanitize a string to be used as a container name or tag
# https://docs.docker.com/engine/reference/commandline/tag/
NR == 1 {
	# No uppercase in docker names
	line = tolower($0);

	# No leading or trailing separator
	sub(/^[^[:lower:][:digit:]]/, "", line);
	sub(/[^[:lower:][:digit:]]$/, "", line);

	# Replace underscores with dashes to bypass the count limitation
	gsub(/_/, "-", line);

	# Replace any other characters by periods
	gsub(/[^[:lower:][:digit:]\-\.]/, ".", line);

	# Do not print more than 128 characters
	print substr(line, 1 ,128);
}
