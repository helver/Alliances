#!d:/perl/bin/perl
use File::Copy;
use DBWrapper::ODBC_DBWrapper;

my $dbh = DBWrapper::ODBC_DBWrapper->new("", "", "localhost", "combined");
$dbh->debug(5);
my $val = $dbh->Delete("line_items");
print "Deleted $val line_items\n";
$val = $dbh->Delete("entries");
print "Deleted $val entries\n";

my ($customer, $startdate, $enddate) = @ARGV;
my $basedir = "M:/IARDevelopment/IAR/input";

opendir(DFH, "$basedir/$customer") || die "Can't open $basedir/$customer: $!\n";
my @dirs = readdir DFH;
closedir DFH;

my ($count, $cmd, $res);

foreach my $dir (sort @dirs) {
  print "$dir\n";

  next if ($dir eq "." || $dir eq "..");

  my $do_drop_indexes = ($count ? 0 : 1);
  $count++;
  my $do_ost = 0;

  if(-e "$basedir/$customer/$dir/foia_$customer.mdb") {
    $do_ost = 1;

    print "Copying $basedir/$customer/$dir/foia_$customer.mdb\n";
    copy("$basedir/$customer/$dir/foia_$customer.mdb", "d:/foia.mdb");
    print "Done copying $basedir/$customer/$dir/foia_$customer.mdb\n\n";

    $cmd = "perl load_data_orig.pl $customer $basedir/$customer/$dir/ $do_ost $do_drop_indexes";
    open(FH, "$cmd |");
    while(<FH>) {
      print;
    }
    close FH;
    next;
  }

  if(-e "$basedir/$customer/$dir/foia2_$customer.mdb") {
    $do_ost = 1;

    print "Copying $basedir/$customer/$dir/foia2_$customer.mdb\n";
    copy("$basedir/$customer/$dir/foia2_$customer.mdb", "d:/foia.mdb");
    print "Done copying $basedir/$customer/$dir/foia2_$customer.mdb\n\n";
  }

  $cmd = "perl load_data.pl $customer $basedir/$customer/$dir/ $do_ost $do_drop_indexes";
  open(FH, "$cmd |");
  while(<FH>) {
    print;
  }
  close FH;

}

$cmd = "perl fill_line_items.pl $customer";
open(FH, "$cmd |");
while(<FH>) {
  print;
}
close FH;
