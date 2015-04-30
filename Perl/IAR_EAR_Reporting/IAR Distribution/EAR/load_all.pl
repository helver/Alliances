#!d:/perl/bin/perl
use File::Copy;

my ($customer, $startdate, $enddate) = @ARGV;
my $basedir = "M:/IARDevelopment/IAR/input";

mkdir("output/$customer") unless -e "output/$customer";
unlink("output/$customer/combined_export.txt") if(-e "output/$customer/combined_export.txt");

opendir(DFH, "$basedir/$customer") || die "Can't open $basedir/$customer: $!\n";
my @dirs = readdir DFH;
closedir DFH;

my ($count, $cmd, $res);

foreach my $dir (sort @dirs) {
  print "$dir\n";

  next if ($dir eq "." || $dir eq "..");

  opendir(DFH, "$basedir/$customer/$dir") || die "Can't open $basedir/$customer/$dir: $!\n";
  my @subdirs = readdir DFH;
  closedir DFH;

  foreach my $subdir (sort @subdirs) {
    print "$subdir\n";

    next if ($subdir eq "." || $subdir eq "..");
    next unless ($subdir =~ /((AES)|(SED)).*\.xls$/);

    $cmd = "perl EAR.pl $customer $basedir/$customer/$dir/$subdir output/$customer/combined_export.txt";
    open(FH, "$cmd |");
    while(<FH>) {
      print;
    }
    close FH;
  }
}

$cmd = "transfer $customer output/$customer/ output/$customer/combined_export.txt";
open(FH, "$cmd |");
while(<FH>) {
  print;
}
close FH;
