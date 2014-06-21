#!/usr/bin/perl -w

$test = "%6d%69%74%73%75%68%69%6b%6f%40%75%62%75%6e%74%75%2e%63%6f%6d";

$test =~ s/%([0-9a-f]{2})/chr(hex($1))/eg;

print $test;
