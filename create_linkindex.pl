#!/usr/bin/perl -w

use File::Find;
use Encode;

find(\&filehandler, "de");

sub filehandler {
	if(-s $_ < 2048 and /\.html$/) {
		open(BLUB, $_);
		@lines = <BLUB>;
		close(BLUB);
		if($#lines < 4) {
			print "file too small: $File::Find::name\n";
		} else {
			if(($href) = $lines[4] =~ /<meta http-equiv=\"Refresh\" content=\"0;url=..\/..\/..\/.{1,9}\/.{1,9}\/.{1,9}\/(.*?\.html)\" \/>/) {

				$href =~ s/%([0-9A-F]{2})/chr(hex($1))/eg; #clean uri

				$href = decode_utf8($href);
				#if a link has an uppercase letter beyond the first letter it has 4 hex digits on the end wich have to be removed
				unless($href =~ s/^(.+?\p{Lu}+.*?)_[a-f0-9]{4}\.html$/$1/) {
					#if this did not match it's all lowercase and has no hex to be removed
					$href =~ s/^(.+?)\.html/$1/;
				}
				$href = encode_utf8($href);

				$_ = decode_utf8($_);
				#if a filename has an uppercase letter beyond the first letter it has 4 hex digits on the end wich have to be removed
				unless($_ =~ s/^(.+?\p{Lu}+.*?)_[a-f0-9]{4}\.html$/$1/) {
					#if this did not match it's all lowercase and has no hex to be removed
					$_ =~ s/^(.+?)\.html$/$1/;
				}
				$_ = encode_utf8($_);
				
				$links = $ENV{PWD} . "/" . $File::Find::dir . "/links.list";
				open(LIST, ">>$links");
				print LIST "$_ $href\n";
				close(LIST);
			} else {
				print "no match in $File::Find::name\n\$lines[4]: $lines[4]\n\n";
			}
		}
	}
}

#DONE: richtiges umbenennen der files - siehe mediawiki/trunk/phase3/maintenance/dumpHTML.inc -> function getFriendlyName
