#!/usr/bin/perl

my $totalP = 156000000;
#my $totalP = 140000;
use List::Util qw[min max];

sub bayesian_enhancement
{
# P(A|B)/P(A) = P(B|A)/P(B)
# here, A is the representation of the targeted group
# B is the group posessing a list of given attributes
#
# P(B|A) = N(A^B)/N(A)
#
# input:     
#
#


}

sub log_stirling_binomial
{
# use Stirling approximation for factorials, calculate C_n_k
# the number of combination of k elements out of n.

    my $n = $_[0];
    my $k = $_[1];

    if ($k==0) {return 0;}
    if ($n==$k) {return 0;}
#   print "stirling $n $k\n";
    my $twoPi = 2*3.1415926;

#    my $log_r = -0.5*log($twoPi) + 0.5*log($n) - 0.5*log($n-$k) -0.5*log($k) + $n*log($n) - $k*log($k) - ($n-$k)*log($n-$k);
    my $log_r = -0.5*log($twoPi) + (0.5+$n)*log($n) - (0.5+$n-$k)*log($n-$k) - (0.5+$k)*log($k);
    return $log_r;
}

sub probability
{
# arguments: n1, n2, n_inter
# the probability of obtaining n as the intersection of n1 and n2    
    my $n1 = $_[0];
    my $n2 = $_[1];
    my $nInter = $_[2];

    my $lognCombinations1 = &log_stirling_binomial($totalP,$n1);
    my $lognCombinations2 = &log_stirling_binomial($totalP,$n2);

    my $lognTotal = $lognCombinations1+$lognCombinations2;

    my $lognWithIntersect = &log_stirling_binomial($totalP,$nInter)
    +&log_stirling_binomial($totalP-$nInter,$n1-$nInter)
    +&log_stirling_binomial($totalP-$n1,$n2-$nInter);

#    print "log with intersect: $lognWithIntersect log n total: $lognTotal\n";
    my $logProb = $lognWithIntersect-$lognTotal;
    return exp($logProb);
}

sub mean_inter
{
# expectation value of intersection under assumption of independency
# arguments are the length of list 1 and the length of list 2.
# the minimum is always 0, the maximum is the smallest of the two.

    my $n1 = $_[0];
    my $n2 = $_[1];
    my $maxInter = min($n1,$n2);
    my $minInter = max(0,$n1+$n2-$totalP);

#    print $minInter." ".$maxInter."\n";
    my $mean = 0;

    my $pSum = 0;
    for ($i = $minInter; $i<=$maxInter; $i++)
    {

my $p = &probability($n1,$n2,$i);
$pSum += $p;
#	print " mean contibution ".$n1." ".$n2." ".$i." ".$p."\n";
	$mean += $i*$p;
    }
#    print $pSum." must be 1\n";
    return $mean/$pSum;
}



$help =<<"EOF";
On the basis of intersection statistics, calculates correlation coefficient
as the ratio of intersected to independent reference.
The independent reference is constructed analytically using combinatorics.

Usage: $0 --l1=list1 --l2=list2

EOF

use IPC::System::Simple qw(capture);
use Getopt::Long;
GetOptions(
"l1=s" => \$l1,
"l2=s" => \$l2
);

unless (defined $l1 && defined $l2) {die $help;};

my $sortedFile1 = $l1;
my $sortedFile2 = $l2;

#unless (-e glob($sortedFile1)) {print "$sortedFile1 does not exist!\n"; system("sort -o $sortedFile1 $l1");}
#unless (-e glob($sortedFile2)) {print "$sortedFile2 does not exist!\n"; system("sort -o $sortedFile2 $l2");}

if (system("sort -c $l1")) {system("sort -o $sortedFile1 $l1");};
if (system("sort -c $l2")) {system("sort -o $sortedFile2 $l2");};

my $comm12 = "comm -12 $sortedFile1 $sortedFile2 | wc -l";

  my $wcL = capture($comm12);
  chomp($wcL);
  @fields = split('\s',$wcL);
  my $n12 = $fields[0];

 my $wcL1 = capture("wc -l $l1");
  chomp($wcL1);
  @fields = split('\s',$wcL1);
  my $n1 = $fields[0];

 my $wcL2 = capture("wc -l $l2");
  chomp($wcL2);
  @fields = split('\s',$wcL2);
  my $n2 = $fields[0];



my $n12Indep = &mean_inter($n1,$n2);

print $n1.";".$n2.";".$n12.";".$n12Indep.";".$n12/$n12Indep.";\n";
