# Format the volume string to be container compliant.
# https://docs.docker.com/storage/volumes/
BEGIN {
	# The fields are separated by colon characters (:)
	FS = ":";
}

NR == 1 {
	if (NF == 1) {
		print $1 ":" $1;
	} else {
		print $0;
	}
}
