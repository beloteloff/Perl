#!/usr/bin/perl

use warnings;
use strict;
use Getopt::Long;
use File::Find ();
use Cwd;

my $help =<<"EOF";
Usage: $0   --f=file pattern --k=key --c=cost --p=pay back per lead --t=total number --s1=minumum probability --s2=maximum probability --o=out

File content will typically look like:

9000031357;e4-4_d3261;0;0;0;t1:0.0038835;
9003103109;e3-7_d4529;0;0;0;t1:0.00546448;
                            ^ key:probability

--t, total number, includes people that fall into classes with no response estimate
EOF


my $file;
my $key;
my $payBack;
my $cost;

my $safe;
my $top = 1;
my $output;
my $totalPotentialAudience;

my %fOfF; # Good-Turing frequency of frequency
my %signature2Frequency;

GetOptions(
    "f=s" => \$file,
    "k=s" => \$key,
    "p=s" => \$payBack,
    "c=s" => \$cost,
    "s1=s" => \$safe,
    "s2=s" => \$top,
    "o=s" => \$output,
    "t=s" => \$totalPotentialAudience
);

unless (defined($file)) {die $help;}
unless (defined($key)) {die $help;}
unless (defined($payBack)) {die $help;}
unless (defined($cost)) {die $help;}
unless (defined($safe)) 
{
    $safe = 1.2*$cost/$payBack;
    print "setting safe probability cut-off at $safe\n";
}


my $total  = 0;
my $nAudience = 0;
my $nPotentialAudience = 0;

my $meanResponse = 0;


my @fileNames = glob($file);


if (defined ($output)) {open OUTPUT, '>', $output or die $!;}

foreach my $item (@fileNames) 
{

    unless (-d $item) {
	# Add all of the new files from this directory
	# (and its subdirectories, and so on... if any)
	    
#    	print "working on $item\n";
	open INPUT, '<', $item or die $!;
	while (<INPUT>)
	{
	    my $line = $_;
	    $nPotentialAudience++;
	    #			print $line;
	    my @fields = split (';', $line);

	    my $phone = $fields[0];
	    my $signature = $fields[1];
	   
		foreach my $f (@fields)
		{
		    
		    my @fields2 = split('\:',$f);
		    
		    if ($#fields2==1)
		    {
			if ($fields2[0] eq $key)
			{
			    my $responseProb = $fields2[1];

			    if ($responseProb>$safe  && $responseProb<$top)
			    {
				my $pOrL = $responseProb*$payBack - $cost;
				$meanResponse += $responseProb;
				$total += $pOrL;
				if (defined ($output))    {print OUTPUT $phone."\n";}
				$nAudience++;
				#	print $fields2[0]." ".$fields2[1]."\n";
			    }
			}
		    }				
		    
		}
	}
	close (INPUT);
	
    }
}
if (defined($output)) {close (OUTPUT);}

if (defined ($totalPotentialAudience)) {$nPotentialAudience = $totalPotentialAudience;}

if ($nPotentialAudience>0)
{
$meanResponse = $meanResponse/$nAudience;
my $audienceFraction = $nAudience/$nPotentialAudience;
print "will get $total from $nAudience with mean response $meanResponse from $audienceFraction\n";
}
else
{
    print "something is wrong with files, check the wildcard\n";
}


