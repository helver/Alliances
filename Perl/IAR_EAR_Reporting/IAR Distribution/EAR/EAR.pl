#!d:/perl/bin/perl

use DBWrapper::ODBC_DBWrapper;
use Spreadsheet::ParseExcel::Simple;

$|=1;

my $debug = 5;

my ($comp, $export_file, $combfile) = @ARGV;

my $xxxx = time;

my @cols = (
  "AES_OPT",
  "CLEARDAY",
  "CLEARMON",
  "CLEARYR",
  "DF",
  "DISTPORT",
  "ECCN",
  "EIN",
  "FILER_ID",
  "FRGNPORT",
  "FTZ",
  "HS",
  "ISO_CTRY",
  "LIC_TYPE",
  "LICENSE",
  "LINE_NO",
  "MANIFEST",
  "MOT",
  "QTY1",
  "QTY2",
  "RELATED",
  "ROUTED",
  "SHIPPER",
  "SWT",
  "TRAN_REF",
  "VALUE",
  "VESSNAME",
  "ZIPCODE",
  "COMPANY",
  "SOURCE",
  "ITN",
);

$yyy = time;
print "--------------------------\n";
print ("Starting to load EAR data.\n");

if(-s $combfile) {
  open FH, "< $combfile";
  my @cols = split /\t/, <FH>;
  close FH;

  open FH, ">> $combfile" or die "Can't open $combfile for appending: $!\n";
} else {
  open FH, ">> $combfile" or die "Can't open $combfile for appending: $!\n";
  print FH join("\t", @cols), "\n";
}

#foreach my $export_file (glob("$basedir*AES*.xls"), glob("$basedir*SED*.xls")) {
  my $xtime = time;
  print "----------------------------------\n";
  print "Starting to process $export_file\n";
  my $source = ($export_file =~ /[\d\-]AES[A-Z\-].*\.xls/i ? "aes" : "sed");
  #print "Source - $source\n";

  my $xls = Spreadsheet::ParseExcel::Simple->read($export_file);
  foreach my $sheet ($xls->sheets) {
    my @headers = $sheet->next_row;

    while ($sheet->has_data) {
      my @vals = $sheet->next_row;

      my %row;
      @row{@headers} = @vals;
      $row{COMPANY} = $comp;
      $row{SOURCE} = $source;

      &manip(\%row);

      print FH join("\t", map {$row{$_}} @cols), "\n";
    }
  }

  print "Done processing $export_file.\n\n";
  $xtime = time() - $xtime;
  print "Elapsed time: $xtime sec.\n";

#}

close FH;

print "Done loading EAR data.\n\n";
$yyy = time() - $yyy;
print "Elapsed time: $yyy sec.\n";


print "-----------------------------\n\n";
$xxxx = time() - $xxxx;
print "Total Elapsed time: $xxxx sec.\n";

sub manip
{
  my ($row) = @_;

  while(length($row->{CARTRIDG}) < 8) {
    $row->{CARTRIDG} = "0" . $row->{CARTRIDG};
  }

  $row->{CARTRIDG_MON} = substr($row->{CARTRIDG}, 0, 2);
  $row->{CLEARMON} = $row->{CARTRIDG_MON} unless (defined $row->{CLEARMON} && $row->{CLEARMON} ne "");

  $row->{CLEARMON} = (int($row->{CLEARMON}) < 10 ? "0" . int($row->{CLEARMON}) : int($row->{CLEARMON}));
  $row->{CLEARYR} = $row->{STAT_YR} unless (defined $row->{CLEARYR} && $row->{CLEARYR} ne "");
  $row->{CLEARDAY} = 1 unless (defined $row->{CLEARDAY} && $row->{CLEARDAY} ne "");

  $row->{LINE_NO} = $row->{LINENO} unless (defined $row->{LINE_NO} && $row->{LINE_NO} ne "");
  $row->{TRAN_REF} = $row->{TRANREFNO} unless (defined $row->{TRAN_REF} && $row->{TRAN_REF} ne "");

  $row->{ISO_CTRY} = $ccs{$row->{COUNTRY}} if ((!defined $row->{ISO_CTRY} || $row->{ISO_CTRY} eq "") && defined $row->{COUNTRY});
  $row->{DISTPORT} = $row->{DIST_EXP} . (int($row->{PORT_EXP}) < 10 ? "0" . int($row->{PORT_EXP}) : int($row->{PORT_EXP}))  if ((!defined $row->{DISTPORT} || $row->{DISTPORT} eq "") && defined $row->{PORT_EXP} && defined $row->{DIST_EXP});

  $row->{SWT} = int($row->{SWT});
  $row->{QTY1} = int($row->{QTY1});
  $row->{QTY2} = int($row->{QTY2});
  $row->{ZIPCODE} = (defined $zips{$row->{ZIPCODE}} ? $zips{$row->{ZIPCODE}} : $row->{ZIPCODE});

  foreach my $x (keys %{$row}) {
    $row->{$x} =~ s/^\s+//;
  }

  if($row->{EXPRTR_ID} ne "") {
    $row->{EIN} = $row->{EXPRTR_ID};
  }

  print "--" . $row->{EIN} . "--";

  #$row->{EIN} =~ s/^0+//;

  if(length($row->{EIN}) <= 9) {
    $row->{EIN} .= "00";
  }

  while(length($row->{EIN}) < 11) {
    $row->{EIN} = "0" . $row->{EIN};
  }

  print $row->{EIN} . "--\n";
}

