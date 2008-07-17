# At least ices_get_next must be defined. And, like all perl modules, it
# must return 1 at the end.

# Function called to initialize your python environment.
# Should return 1 if ok, and 0 if something went wrong.
use LWP::Simple;
use XML::Simple;

sub ices_init {
	print "Perl subsystem Initializing:\n";
	return 1;
	my @albums;
	my $song;
}

# Function called to shutdown your python enviroment.
# Return 1 if ok, 0 if something went wrong.
sub ices_shutdown {
	print "Perl subsystem shutting down:\n";
}

sub ices_get_next {
	print "Perl subsystem quering for new track:\n";

	$xml = get "http://localhost:20000/library/next_song?secret=secret";

	$parse = new XML::Simple;
	$data = $parse->XMLin($xml);
	$path = $data->{path};
	$info = $data->{info};

	return $path;
}

# If defined, the return value is used for title streaming (metadata)
sub ices_get_metadata {
	return $info;
}

# Function used to put the current line number of
# the playlist in the cue file. If you don't care
# about cue files, just return any integer.
sub ices_get_lineno {
	return 1;
}

return 1;
