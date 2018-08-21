#!/usr/bin/perl

# dropping first digit (7, country code)
while (<>)
{
#    print $_,"\n";
# ($phone) = $_ =~ m/\d{10}\Z/g;

  my $phone = substr($_, 1);
print $phone;  
}
