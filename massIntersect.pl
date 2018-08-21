#!/usr/bin/perl

$help =<<"EOF";
Intersect a number of files (with phones in the firts column, ;-separated),
file name matching a pattern, with a filter (another list of phones).
Places the output into a directory specified by the user.

Usage: $0 --f=intersection filter --p=pattern [--m=minimum n lines|1] --d=out dir
EOF

my $minLines = 1;

#use IPC::System::Simple qw(capture);
use Getopt::Long;
GetOptions(
"f=s" => \$filter,
"p=s" => \$pattern,
"m=s" => \$minLines,
"d=s" => \$dir
);

unless (defined $filter) {die $help;}
unless (defined $pattern) {die $help;}
unless (defined $dir) {die $help;}
my $totalLines = 0;

@files = glob($pattern);
#@files = <phones_*.csv>;
#@files = <aidata*.csv>;


#open OUT, '>', "splitCount.csv" or die "Couldn't open file: $!";

#print OUT "fileName;nLines;\n";

mkdir $dir, 0755 or die "Couldn't make directory $dir: $!";

foreach $file (@files) 
{
    if ($file =~ /sorted/) {next;}
    if ($file =~ /splitCount/) {next;}

    my $oldfile = $file;
    $file =~ s/\s//g;
    if ($file ne $oldfile)
    {
	system("mv \'$oldfile\' $file");
    }

  my $sortedFile = "sorted_".$file;
  my $output = $dir."/".$file;
  
  unless (-e glob($sortedFile)) {system("sort -o $sortedFile $file");}
  system("comm -12 $filter $sortedFile > $output");
 # my $wcL = capture("wc -l $output");
  
my $wcL = `wc -l $output`;
chomp($wcL);
  @fields = split('\s',$wcL);

    my $nLines = $fields[0];
    if ($nLines<$minLines)
    {
	system("rm $output");
    }
    else
    {
	$totalLines += $nLines;
#	print OUT "$output;$nLines\n";
    }


}
#close (OUT);
print "$totalLines in total\n";

#system("fromdos $input");



