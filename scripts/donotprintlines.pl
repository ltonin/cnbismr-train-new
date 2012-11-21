#!/usr/bin/perl
# 2010-11-27  Michele Tavella <michele.tavella@epfl.ch>

use strict;

@ARGV >= 2 or die "Error: donotprintlines.pl FILE LINES\n";

my $limit = @ARGV-1;
my @lines = @ARGV[1..$limit];

my $filename = $ARGV[0];
open(FILE, $filename) or die "Error: cannot read $filename";

my $lineno = 1;
while(<FILE>) {
  if(grep $_ == $lineno, @lines) {
  } else {
	  print "$_";
  }
  $lineno++;
}
close FILE;
