#!/usr/bin/perl -w

use File::Find;
use Encode;

find(\&filehandler, "de");

sub filehandler {
	if(-f $_ and $_ !~ /links\.list/) { #damit keine link.list dateien zerstört werden
		open(BLUB, "$_");
		@lines = <BLUB>;
		close(BLUB);

		#Lazy...
		$lines[$#lines] =~ s/<div id=\"catlinks\">.*//;

		#änderungen speichern
		open(FILE, ">$_") or print "can't write to $File::Find::name\n";
		print FILE @lines;
		close(FILE);
	}
}

#DONE: richtiges umbenennen der files - siehe mediawiki/trunk/phase3/maintenance/dumpHTML.inc -> function getFriendlyName
