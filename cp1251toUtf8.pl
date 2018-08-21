#!/usr/bin/perl

$help =<<"EOF";
Read cp1251 and write utf8
Example: $O  --i=file.txt --o=out.txt
EOF

#http://stackoverflow.com/questions/14663545/reading-cyrillic-characters-from-file-in-perl


use Getopt::Long;
use File::Basename;
use Encode qw(encode decode);

GetOptions(
"i=s" => \$filename,
"o=s" => \$outfilename
    );

if (!defined($filename)) {die $help," define --i \n";};
if (!defined($outfilename)) {die $help," define --o \n";};


open(FILE, '<:encoding(cp1251)', glob($filename))    or die $!;
open(OUTFILE, '>:encoding(utf8)', glob($outfilename))    or die $!;


while (<FILE>)
{
    print OUTFILE $_;
}
