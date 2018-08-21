#!/usr/bin/perl

$help =<<"EOF";

Takes a list of files matching a pattern, adds town and oblast name on each line, 
and dumps into standard output.
Town and oblast name are parts of the file name.

Example: ТОВАРКОВО.КАЛУЖСКАЯ_ОБЛ.csv contains phones only.

Output will be
9999999999;ТОВАРКОВО;КАЛУЖСКАЯ_ОБЛ;

Usage: $0 --p=pattern --o=out

EOF

use Getopt::Long;
GetOptions(
"p=s" => \$pattern,
"o=s" => \$out
);


unless (defined $pattern) {die $help;}
unless (defined $out) {die $help;}

my $totalLines = 0;

my @files = glob($pattern);


open OUTFILE, '>', glob($out) or die $!;

foreach $file (@files) 
{
    if ($file =~ /sorted/) {next;}
    if ($file =~ /splitCount/) {next;}
    if ($file eq $out) {next;}

    my @fileNameParts =  split ('\.', $file); 
    my $town = @fileNameParts[0];
    my $oblast = @fileNameParts[1];

    open INFILE, '<', glob($file) or die $!;
    while (<INFILE>)
    {
	chomp($_);
	print OUTFILE $_.";".$town.";".$oblast."\n";
    }
    close (INFILE);
}

close (OUTFILE);
