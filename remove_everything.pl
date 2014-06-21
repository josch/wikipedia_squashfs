#!/usr/bin/perl -w

use File::Find;
use Encode;

find(\&filehandler, "de");

sub filehandler {
	if(/\.html$/) { #damit keine link.list dateien zerstört werden
		open(BLUB, "$_");
		@lines = <BLUB>;
		close(BLUB);
		$i=0;
		$title="";
		$beginning=0;
		$ending=0;
		while(!$title && $i<=$#lines) {
			($title) = $lines[$i] =~ /<h1.*?>(.+)<\/h1>$/;
			$i++
		}
		
		if(!$title) { #TODO detect if $title == "0"
			print "title not found in $File::Find::name\n";
		}

		#Beginn suchen
		while(!$beginning && $i<=$#lines) {
			if($lines[$i] =~ /<!-- start content -->/) {
				$beginning = $i;
			}
			$i++
		}
		#Ende suchen
		while(!$ending && $i<=$#lines) {
			if($lines[$i] =~ s/<!-- end content -->//) {
				$ending = $i;
			}
			$i++
		}
		#ersetzten
		splice(@lines,$ending+1, $#lines-$ending, "");
		splice(@lines,0,$beginning+1, "$title\n");
			#vorletzte zeile löschen da diese seperat angefügt werden wird
		splice(@lines,$#lines-2, 1, "");

		$i=0;
		while($i<=$#lines) {
			#a *very* dirty way to get rid of unicode chars in URLs
			$lines[$i] =~ s/%([0-9A-F]{2})/chr(hex($1))/eg;

			#needed for proper uppercase detection
			$lines[$i] = decode_utf8($lines[$i]);

			#removing double spaces
			$lines[$i] =~ s/[ ]{2,}//g;

			#removing tabs
			$lines[$i] =~ s/\t//g;

			#removing empty lines
			$lines[$i] =~ s/^\n$//g;

			#removing the comment block on the end of some aricles
			if($lines[$i] =~ /^<!-- $/) {
				if($lines[$i+5] =~ /^-->$/) {
					splice(@lines, $i, 6, "");
				}
			}

			#removing editsection links
			$lines[$i] =~ s/<span class=\"editsection\">.+?<\/span> //g;

			#converting tex images to tex inside of code tags
			$lines[$i] =~ s/<img class=\"tex\" alt=\"(.*?)\".*?\/>/<code>$1<\/code>/g;

			#delete all title attributes
			$lines[$i] =~ s/ title=\".*?\"//g;

			#remove rel attributes
			$lines[$i] =~ s/ rel=\"nofollow\"//g;

			#if a link has an uppercase letter beyond the first letter it has 4 hex digits on the end wich have to be removed
			$lines[$i] =~ s/<a href=\"\.\.\/\.\.\/\.\.\/.{1,9}\/.{1,9}\/.{1,9}\/([^\"]+?\p{Lu}+[^\"]*?)_[a-f0-9]{4}\.html(#?[^\"]*?)\">/<a href=\"$1$2\">/g;

			#all remaining links only need to be cleaned up
			$lines[$i] =~ s/<a href=\"\.\.\/\.\.\/\.\.\/.{1,9}\/.{1,9}\/.{1,9}\/([^\"]+?)\.html(#?[^\"]*?)\">/<a href=\"$1$2\">/g;
			
			#delete all thumbnail boxes
			if($lines[$i] =~ /<div class=\"thumb t(right|left)\">/) {
				splice(@lines,$i,7, "");
			}

			#delete all spans
			$lines[$i] =~ s/<span .*?>(.*?)<\/span>/$1/g;

			#delete all class and style attr.
			$lines[$i] =~ s/ class=\".*?\"//g;
			$lines[$i] =~ s/ style=\".*?\"//g;

			#delete alle remaining images
			$lines[$i] =~ s/<a .*?><img .*?\/><\/a>//g;
			$lines[$i] =~ s/<img .*?\/>//g;

			$lines[$i] = encode_utf8($lines[$i]);
			$i++;
		}

		#änderungen speichern
		open(FILE, ">$_") or print "can't write to $File::Find::name\n";
		print FILE @lines;
		close(FILE);
	}
}

#DONE: richtiges umbenennen der files - siehe mediawiki/trunk/phase3/maintenance/dumpHTML.inc -> function getFriendlyName
