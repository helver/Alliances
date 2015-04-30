#!/usr/bin/perl

use CustomsReport::LiquidExtract;
use CustomsReport::MasterFileExtract;


use Reports::Summary;
use Reports::Usage;
use Reports::EntryLog;
use Reports::OST;
use Reports::CombinedEntryLog;
use Reports::CombinedReport;
use Reports::SpecialTradePrograms;

my $debug = 0;

my $client;
#my @formats = ("TextOutput","ExcelOutput");
my @formats = ("ExcelOutput");

foreach my $x (@ARGV) {
  my ($type, $file) = split /=/, $x, 2;

  if($type eq "client") {
    $client = $file;
  }
}

my @reports = &load_reports($client);

# First part, open the files.  Pass file handles off to be parsed.

my $ler = CustomsReport::LiquidExtract->new($debug);
my $mfer = CustomsReport::MasterFileExtract->new($debug);

foreach my $x (@ARGV) {
  my ($type, $file) = split /=/, $x, 2;

  if($type eq "liquid") {
    &process_data_source($ler, \@reports, $file);
  } elsif($type eq "unliquid") {
    &process_data_source($mfer, \@reports, $file);
  } elsif($type eq "client") {
    $client = $file;
  } else {
    print "Unknown file type: $type\n";
    exit;
  }

  close FH;
}

foreach my $report(@reports) {
  $report->retrieveData();
}

my $outdir = "output/$client";
mkdir($outdir) unless(-e $outdir);

print @formats . "\n\n\n";

foreach my $format (@formats) {
  print "Displaying in format: $format\n" if($debug >= 5);
  my $x;

  eval("use OutputFormat::$format;");

  die "Loading $format: $@\n" if ($@);


  eval("\$x = OutputFormat::$format->new($debug, \$client, \$outdir);");

  die "Creating $format object: $@\n" if ($@);

  print "$x is our Format object.\n" if($debug >= 5);

  foreach my $report (@reports) {
    print "Generating the $report report.\n" if($debug >= 5);
    print "Using the " . $report->{"displayFunction"} . " method.\n" if($debug >= 5);

    eval("\$x->" . $report->{"displayFunction"} . "(\$report);");
    die "$@\n" if ($@);
  }
}




sub load_reports
{
  open(RFH, "< reports.conf") or die "Can't open report config file: $!\n";

  my @reports;

  while(<RFH>) {
    next if /^#/;
    my ($name, $format, @fields) = split /\s+/, $_;
    my $rpt;
    eval("\$rpt = Reports::" . ucfirst($format) . "->new(\$name, \\\@fields, $debug, \$client);");
    die "$@\n" if ($@);
    push @reports, $rpt;
  }

  return @reports;
}



sub process_data_source
{
  my ($object, $reports, $filename) = @_;

  if($filename) {
    die "Can't open input file $file: $!\n" unless(open(FH, $filename));
    $object->parse(\*FH, $reports);
    close FH;
  } else {
    $object->parse($reports);
  }
}