#!/usr/bin/perl -w

use File::Find;
use Encode;

$pwd = $ENV{PWD};
find(\&filehandler, "de");

sub filehandler {
	if(/\.html$/) {
		$_ = decode_utf8($_);
		if($_ =~ s/(.+?\p{Lu}+.*?)_[a-f0-9]{4}\.html/$1/) {
			$_ = encode_utf8($_);
			rename( "$pwd/$File::Find::name", "$pwd/$File::Find::dir/$_");
		} elsif($_ =~ s/(.+?)\.html/$1/) {
			$_ = encode_utf8($_);
			rename( "$pwd/$File::Find::name", "$pwd/$File::Find::dir/$_");
		} else {
			print "couldn't find filename pattern in $File::Find::name\n";
		}
	}
}

#DONE: richtiges umbenennen der files - siehe mediawiki/trunk/phase3/maintenance/dumpHTML.inc -> function getFriendlyName
