#!/usr/bin/perl
use warnings;
use strict;
use utf8;
use Getopt::Long;
GetOptions(
"i=s" => \my $input,
"o=s" => \my $output

);
if(!defined($input) ) { die my $help," define --input_file \n";};
if(!defined($output) ) { die my $help," define --output_file \n";};

open INPUT, '<:utf8', glob($input) or die $!;
open(OUTPUT, '>:utf8', glob($output)) or die;

#start at 1-st column, not zero.



my $first_line = <INPUT>;
my @fields = split (';', $first_line);
my $size = @fields;
print "see $size fields\n";

my $fn; my $ln; my $pas; my $ph; my $pin;
for (my $i=0; $i<$size; $i++)
{
print $fields[$i]."\n";

if ($fields[$i] eq "MGT_first_name") {$fn = $i;}
if ($fields[$i] eq "MGT_last_name") {$ln = $i;}
if ($fields[$i] eq "MGT_passport") {$pas = $i;}
if ($fields[$i] eq "MGT_phone") {$ph = $i;}
if ($fields[$i] eq "MGT_order") {$pin = $i;}


}

print "$fn,$ln,$pas,$ph,$pin\n";

while (<INPUT>)
{
my @fields = split (';', $_);
my $FirstName = $fields[$fn];
my $LastName =  $fields[$ln];
my $passport =  $fields[$pas];
my $phone =  $fields[$ph];
my $pinCode = $fields[$pin];
if (defined($FirstName) && $FirstName ne "NULL" && defined($LastName) && $LastName ne "NULL" && defined($passport) && $passport ne "NULL" && defined($phone) && $phone ne "NULL" && defined($pinCode)) {
     print OUTPUT "$FirstName;$LastName;$passport;$phone;$pinCode\n";
}

else {
print "$FirstName;$LastName;$passport;$phone;$pinCode\n";
}
}
close (INPUT);
close (OUTPUT);
