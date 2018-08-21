#!/usr/bin/perl

#This is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.

#This is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.

#You should have received a copy of the GNU General Public License
#along with code.  If not, see .

my $Help =<<"EOF";
Subsample some random lines from a text file.

perl randomLines.pl [PARAM]

    Parameter      Description                Value         Default
    -i --in        Input file                 File            STDIN
    -o --out       Output file                File           STDOUT
    -n --num       Number of lines to sample  Integer          1000
    -t --total     Total lines in file        Integer       1000000
    -f --first     Include first line         Bool               No
    
    -h --help      Print this screen and exit
    -v --verbose   Verbose mode
    --version      Print version number and exit

    1. Sample 100 lines from a 1000 lines file
    perl randomLines.pl -n 100 -t 1000 < file.in > file.out
   
    2. Sample 1000 lines and the header (first line)
    perl randomLines.pl -f -n 1000 -i file.in -o file.out

EOF


use strict;
use warnings;
use Getopt::Long;
use Pod::Usage;

# Default parameters
my $help     = undef;         # Print help
my $verbose  = undef;         # Verbose mode
my $version  = undef;         # Version call flag
my $in       = undef;
my $out      = undef;
my $num      =   1e3;
my $total    =   1e6;
my $first    = undef;

# Main variables
my $our_version = 0.1;        # Script version number
my %sel = ();
my $ln  =  0;

# Calling options
GetOptions(
    'h|help'           => \$help,
    'v|verbose'        => \$verbose,
    'version'          => \$version,
    'i|in:s'           => \$in,
    'o|out:s'          => \$out,
    'n|num:i'          => \$num,
    't|total:i'        => \$total,
    'f|first'          => \$first
) or pod2usage(-verbose => 2);
    
#pod2usage(-verbose => 2) if (defined $help || !(defined $in));

if (defined $help || !(defined $in) || !(defined $out) || !(defined $num) || !(defined $total)) {die $Help;}

printVersion() if (defined $version);

getPos($num, $total, \%sel);

if (defined $in) {
    warn "opening file $in\n" if (defined $verbose);
    open STDIN, "$in" or die "cannot open file $in\n";
}


if (defined $out) {
    warn "creating file $out\n" if (defined $verbose);
    open STDOUT, ">$out" or die "cannot open file $out\n";
}

if (defined $first) {
    warn "First line will be included\n" if (defined $verbose);
    $sel{0} = 1;
}

warn "Extracting lines\n" if (defined $verbose);
while (<>) {
    print if (defined $sel{$ln});
    $ln++;
}

###################################
####   S U B R O U T I N E S   ####
###################################

sub printVersion {
    print "$0 $our_version\n";
    exit 1;
}

sub getPos {
    my ($n, $t, $s_href) = @_;
    warn "Selecting $n positions from $t total\n" if (defined $verbose); 
    for (my $i = 1; $i <= $n; $i++) {
        my $p = int(rand $t);
        if (defined $$s_href{$p}) {
            $i--;
        }
        else {
            warn " $p\n" if (defined $verbose);
            $$s_href{$p} = 1;
        }
    }
}
