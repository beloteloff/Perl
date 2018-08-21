#!/usr/bin/perl -w
# 
#

$help =<<"EOF";
Problem: typically, an extra-field-based way of storing data in SQL tables does not allow one
to leave empty fields where information is missing, since once an extra field is missing,
not even a NULL is present to preserve information in JOIN. 

Solution: use this scrip for making a join which preserves the key after a missing piece of 
data is encountered. Both sets of data must be indexable by (first column) key -- typically, 
phone. You can apply this script in sequence to join as many sources of data as needed.

EOF
use Getopt::Long;

binmode(STDOUT, ":utf8");
GetOptions(
    "i1=s" => \$i1,
    "i2=s" => \$i2,
    "o=s" => \$output
);
if(!defined($i1) ) { die $help," define --i1 \n";};
if(!defined($i2) ) { die $help," define --i2 \n";};
if(!defined($output) ) { die $help," define --o \n";};

### Perform the connection using the Oracle driver

my %phoneToI1;

open I1, '<:utf8', glob($i1) or die $!;


my $nFields1;

while (<I1>)
{
    my @fields = split (";", $_);

    unless (defined($nFields1)){    $nFields1 =  @fields;}
    
    my $phone = $fields[0];

    $phone =~ s/\s//g;
    if ($phone eq "") {next;}
    my $counter = 0;
    my $theRest;
    foreach $item (@fields)
    {
	chomp($item);
	$counter++;
	if ($counter> 1)
	{

	    if (defined($theRest)) { 	    $theRest = $theRest.";".$item;}
	    else
	    {
		$theRest = $item;
	    }

	}
    }
#    print "1: assigned the rest $theRest to $phone\n";
    $phoneToI1{$phone} = $theRest;
}

close I1;

my $theRestEmpty1 ="";
for ($i=0; $i<$nFields1-1; $i++)
{
    $theRestEmpty1 .= ";";
}

#print "$theRestEmpty1 for $nFields1 fields \n";

my %phoneToI2;

open (OUTFILE, '>:utf8',$output) or die $!;
open I2, '<:utf8', glob($i2) or die $!;

my $nFields2;

while (<I2>)
{
    my @fields = split (";", $_);
    my $phone = $fields[0];
    $phone =~ s/\s//g;
#    unless ($phone ) {next;}
    if ($phone eq "") {next;}
    my $counter = 0;
    my $theRest;

    unless (defined($nFields2)){    $nFields2 =  @fields;}


    foreach $item (@fields)
    {
	chomp($item);
	$counter++;
	if ($counter> 1)
	{
	    if (defined ($theRest)) { 	    $theRest = $theRest.";".$item;}
	    else
	    {
		$theRest = $item;
	    }
	}
    }

#    print "2: assigned the rest $theRest to $phone\n";

    if( exists $phoneToI1{$phone} )
    {
        print OUTFILE $phone.";".$phoneToI1{$phone}.";".$theRest."\n";	
    }
    else
    {
#	print "using $theRestEmpty1 for $phone\n";
	print OUTFILE $phone.$theRestEmpty1.";".$theRest."\n";
    }
    unless (exists $phoneToI2{$phone})
    {
	$phoneToI2{$phone} = 1;
    }
}

my $theRestEmpty2 ="";
for ($i=0; $i<$nFields2-1; $i++)
{
    $theRestEmpty2 .= ";";
}

print "$theRestEmpty2 for $nFields2 fields \n";
# now handle  those from the first list who are not in the second

foreach my $phone ( keys %phoneToI1 )
{

    unless (exists $phoneToI2{$phone})
    {
#	print "extending $phone by $theRestEmpty2\n";
	print OUTFILE $phone.";".$phoneToI1{$phone}.$theRestEmpty2."\n";
    }
}

close  OUTFILE;

exit;

