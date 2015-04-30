#!d:/perl/bin/perl

use DBWrapper::ODBC_DBWrapper;
use Spreadsheet::WriteExcel::Big;
use Spreadsheet::ParseExcel::Simple;

my $debug = 0;

my ($comp, $basedir) = @ARGV;
$basedir = "M:/" unless defined $basedir;
my $company;
my $dbi;
my %tabs;

my $xxxx = time;

if(0) {
  my $yyy = time;
  print "--------------------------\n";
  print ("Starting to populate the transfer file.\n");

  $dbi = DBWrapper::ODBC_DBWrapper->new("", "", "localhost", "EARLoad");

  $company = $dbi->SelectSingleValue("id", "public_companies", "name = '$comp'");
  print "$comp - $company\n";

  my %lookups = (
    "country" => {"fields" => ["id", "name", "countrygroupid"], "key" => "coo", "source" => "line_items"},
    #"filer" => {"fields" => ["id", "name", "address", "address2", "city", "state", "zipcode", "phone", "filer_type"], "key" => "filer_id", "source" => "entries,line_items"},
    "hsusa" => {"fields" => ["id", "description", "fda_flag"], "key" => "hsusa", "source" => "line_items"},
    "port" => {"fields" => ["code", "name"], "key" => "port_id", "source" => "entries,line_items"}
  );

  foreach my $lu (keys %lookups) {
    my $xxx = time;
    print "--------------------------\n";
    print "Loading $lu information.\n";

    my $delsql = "DELETE FROM ${lu}_lookup"; # WHERE " . $lookups{$lu}->{fields}[0] . " IN (SELECT " . $lookups{$lu}->{fields}[0] . " FROM public_${lu}_lookup);";
    print "$delsql\n" if($debug >= 2);
    $dbi->DoSQL($delsql);
    print "done\n\n" if($debug >= 2);

    my $loadsql = "INSERT INTO ${lu}_lookup SELECT " . join(",", @{$lookups{$lu}->{fields}}) . " FROM public_${lu}_lookup;";
    print "$loadsql\n" if($debug >= 2);
    $dbi->DoSQL($loadsql);
    print "done\n\n" if($debug >= 2);

    my $x = $dbi->SelectMap($lookups{$lu}->{fields}[0] . ", 1", "${lu}_lookup");
    $tabs{$lu} = $x;

    print "Done loading $lu information.\n\n";
    $xxx = time() - $xxx;
    print "Elapsed time: $xxx sec.\n";
  }
}

my $x = $dbi->SelectMap("id, 1", "ein_lookup");
$tabs{"ein"} = $x;

$x = $dbi->SelectMap("id, 1", "filer_lookup");
$tabs{"filer"} = $x;

my @sources = ("aes", "sed");

my %cols = (
  "AES_OPT" => {"aes" => "AES_OPT",
      "sed" => "AES_OPT",
           },
  "CLEARDAY" => {"aes" => "CLEARDAY",
      "sed" => "CLEARDAY",
           },
  "CLEARMON" => {"aes" => "CLEARMON",
      "sed" => "CARTRIDG_MON",
           },
  "CLEARYR" => {"aes" => "CLEARYR",
      "sed" => "STAT_YR",
           },
  "DF" => {"aes" => "DF",
      "sed" => "DF",
           },
  "DISTPORT" => {"aes" => "DISTPORT",
      "sed" => "DISTPORT",
           },
  "ECCN" => {"aes" => "ECCN",
      "sed" => "ECCN",
           },
  "EIN" => {"aes" => "EIN",
      "sed" => "EIN",
           },
  "FILER_ID" => {"aes" => "FILER_ID",
      "sed" => "FILER_ID",
           },
  "FRGNPORT" => {"aes" => "FRGNPORT",
      "sed" => "FRGNPORT",
           },
  "FTZ" => {"aes" => "FTZ",
      "sed" => "FTZ",
           },
  "HS" => {"aes" => "HS",
      "sed" => "HS",
           },
  "ISO_CTRY" => {"aes" => "ISO_CTRY",
      "sed" => "ISO_CTRY",
           },
  "LIC_TYPE" => {"aes" => "LIC_TYPE",
      "sed" => "LIC_TYPE",
           },
  "LICENSE" => {"aes" => "LICENSE",
      "sed" => "LICENSE",
           },
  "LINE_NO" => {"aes" => "LINENO",
      "sed" => "LINE_NO",
           },
  "MANIFEST" => {"aes" => "MANIFEST",
      "sed" => "MANIFEST",
           },
  "MOT" => {"aes" => "MOT",
      "sed" => "MOT",
           },
  "QTY1" => {"aes" => "QTY1",
      "sed" => "QTY1",
           },
  "QTY2" => {"aes" => "QTY2",
      "sed" => "QTY2",
           },
  "RELATED" => {"aes" => "RELATED",
      "sed" => "RELATED",
           },
  "ROUTED" => {"aes" => "ROUTED",
      "sed" => "ROUTED",
           },
  "SHIPPER" => {"aes" => "SHIPPER",
      "sed" => "SHIPPER",
           },
  "SWT" => {"aes" => "SWT",
      "sed" => "SWT",
           },
  "TRAN_REF" => {"aes" => "TRANREFNO",
      "sed" => "TRAN_REF",
           },
  "VALUE" => {"aes" => "VALUE",
      "sed" => "VALUE",
           },
  "VESSNAME" => {"aes" => "VESSNAME",
      "sed" => "VESSNAME",
           },
  "ZIPCODE" => {"aes" => "ZIPCODE",
      "sed" => "ZIPCODE",
           },
);
my @cols = ("AES_OPT","CLEARDAY","CLEARMON","CLEARYR","DF","DISTPORT","ECCN",
            "EIN","FILER_ID","FRGNPORT","FTZ","HS","ISO_CTRY","LIC_TYPE",
            "LICENSE","LINE_NO","MANIFEST","MOT","QTY1","QTY2","RELATED",
            "ROUTED","SHIPPER","SWT","TRAN_REF","VALUE","VESSNAME","ZIPCODE",
);


my $yyy = time;
print "--------------------------\n";
print ("Starting to populate country and zipcode tables.\n");

my %ccs;
open FH, "< m:/IARDevelopment/IAR/LookupTables/country_codes.txt";
while(<FH>) {
  chomp;
  my @line = split /\s*\t\s*/;
  $ccs{$line[0]} = $line[2];
}
close FH;

my %zips;
open FH, "< m:/IARDevelopment/IAR/LookupTables/zip_codes.txt";
while(<FH>) {
  chomp;
  my @line = split /\s*\t\s*/;
  $zips{$line[0]} = ($line[1] && $line[2] ? $line[1] . ", " . $line[2] : undef);
}
close FH;

print "Done loading populating country and zipcode tables.\n\n";
$yyy = time() - $yyy;
print "Elapsed time: $yyy sec.\n";

$yyy = time;
print "--------------------------\n";
print ("Starting to create output spreadsheet.\n");

my $workbook = Spreadsheet::WriteExcel::Big->new("output/" . $comp . "/${comp}_EAR.xls");
my $worksheet = $workbook->addworksheet("EAR");

my $rowcount = 0;
my $colcount = 0;

$worksheet->write($rowcount, $colcount++, "COMPANY");
$worksheet->write($rowcount, $colcount++, "SOURCE");
foreach my $col (@cols) {
  $worksheet->write($rowcount, $colcount++, $col);
}

$rowcount++;

print "Done loading creating output spreadsheet.\n\n";
$yyy = time() - $yyy;
print "Elapsed time: $yyy sec.\n";

$yyy = time;
print "--------------------------\n";
print ("Starting to load EAR data.\n");

foreach my $export_file (glob("$basedir*AES*.xls"), glob("$basedir*SED*.xls")) {
  print "Starting to process $export_file\n";
  my $source = ($export_file =~ /\dAES[A-Z].*\.xls/i ? "sed" : "aes");
  print "Source - $source\n";

  exit;

  my $xls = Spreadsheet::ParseExcel::Simple->read('spreadsheet.xls');
  foreach my $sheet ($xls->sheets) {
     while ($sheet->has_data) {
         my @data = $sheet->next_row;
     }
  }  open(FH, "m:/${comp}_$source.txt") or die "Can't open m:/${comp}_$source.txt: $!\n";

  my @headers = split /\t/, <FH>;

  while(<FH>) {
    my @vals = split /\t/;

    my %row;
    @row{@headers} = @vals;

    &{"manip_$source"}(\%row);

    $colcount = 0;
    $worksheet->write_string($rowcount, $colcount++, $comp);
    $worksheet->write_string($rowcount, $colcount++, $source);
    foreach my $col (@cols) {
      $worksheet->write_string($rowcount, $colcount++, $row{$cols{$col}{$source}});
      #print $row{$cols{$col}{$source}} . ",";
    }
    #print "\n";
    $rowcount++;

    my %vals = ('COMPANY' => $company,
                'SOURCE' => $source,
                'CLEARDATE' => "#" . $row{"CLEARMON"} . "/" . $row{"CLEARDAY"} . "/" . $row{"CLEARYR"} . "#",
               );

    foreach my $col (@cols) {
      $vals{$col} = $row{$cols{$col}{$source}};
    }

    if($tabs{"port"}->{$row{$cols{"DISTPORT"}{$source}}} != 1) {
      $tabs{"port"}->{$row{$cols{"DISTPORT"}{$source}}} = 1;
      print "Trying to insert a new port:" . $row{$cols{"DISTPORT"}{$source}} . "\n" if($debug >= 2);
      $dbi->DoSQL("INSERT INTO port_lookup VALUES ('" . $row{$cols{"DISTPORT"}{$source}} . "', null);");
    }


    if($tabs{"ein"}->{$row{$cols{"EIN"}{$source}}} != 1) {
      $tabs{"ein"}->{$row{$cols{"EIN"}{$source}}} = 1;
      print "Trying to insert a new ein:" . $row{$cols{"EIN"}{$source}} . "\n" if($debug >= 2);
      $dbi->DoSQL("INSERT INTO ein_lookup VALUES ('" . $row{$cols{"EIN"}{$source}} . "', null);");
    }


    if($tabs{"country"}->{$row{$cols{"ISO_CTRY"}{$source}}} != 1) {
      $tabs{"country"}->{$row{$cols{"ISO_CTRY"}{$source}}} = 1;
      print "Trying to insert a new country:" . $row{$cols{"ISO_CTRY"}{$source}} . "\n" if($debug >= 2);
      $dbi->DoSQL("INSERT INTO country_lookup VALUES ('" . $row{$cols{"ISO_CTRY"}{$source}} . "', null, 1);");
    }


    if($tabs{"filer"}->{$row{$cols{"FILER_ID"}{$source}}} != 1) {
      $tabs{"filer"}->{$row{$cols{"FILER_ID"}{$source}}} = 1;
      print "Trying to insert a new filer:" . $row{$cols{"FILER_ID"}{$source}} . "\n" if($debug >= 2);
      $dbi->DoSQL("INSERT INTO filer_lookup VALUES ('" . $row{$cols{"FILER_ID"}{$source}} . "', null, null, null, null, null, null, null, null);");
    }


    if($tabs{"hsusa"}->{$row{$cols{"HS"}{$source}}} != 1) {
      $tabs{"hsusa"}->{$row{$cols{"HS"}{$source}}} = 1;
      print "Trying to insert a new hsusa:" . $row{$cols{"HS"}{$source}} . "\n" if($debug >= 2);
      $dbi->DoSQL("INSERT INTO hsusa_lookup VALUES ('" . $row{$cols{"HS"}{$source}} . "', null, null);");
    }


    foreach my $x (keys %vals) {
      if($vals{$x} eq "") {
        delete $vals{$x};
        next;
      }

      next if($x eq "CLEARDATE" or $x eq "DISTPORT" or $x eq "QTY1" or $x eq "QTY2");

      $vals{$x} = "'" . $vals{$x} . "'";
    }

    $vals{"[VALUE]"} = $vals{"VALUE"};
    delete $vals{"VALUE"};

    my ($sdata,$scols,$sqry);

    foreach my $col (keys %vals) {
      $sdata .= ($sdata eq "" ? "" : ", ") . $vals{$col};
      $scols .= ($scols eq "" ? "" : ", ") . $col;
    }

    # Build the rest of the SQL statement.
    $sqry .= "INSERT INTO ear_data (" . $scols . ") VALUES (" . $sdata . ");";
    print "$sqry\n" if($debug >= 2);

    $dbi->DoSQL($sqry);
  }

  close FH;
}

print "Done loading EAR data.\n\n";
$yyy = time() - $yyy;
print "Elapsed time: $yyy sec.\n";


print "-----------------------------\n\n";
$xxxx = time() - $xxxx;
print "Elapsed time: $xxxx sec.\n";

sub manip_aes
{
  my ($row) = @_;

  $row->{SWT} = int($row->{SWT});
  $row->{QTY1} = int($row->{QTY1});
  $row->{QTY2} = int($row->{QTY2});
  $row->{ZIPCODE} = (defined $zips{$row->{ZIPCODE}} ? $zips{$row->{ZIPCODE}} : $row->{ZIPCODE});
}

sub manip_sed
{
  my ($row) = @_;

  $row->{"ISO_CTRY"} = $ccs{$row->{COUNTRY}};
  $row->{"DISTPORT"} = $row->{DIST_EXP} . (int($row->{PORT_EXP}) < 10 ? "0" . int($row->{PORT_EXP}) : int($row->{PORT_EXP}));

  while(length($row->{"CARTRIDG"}) < 8) {
    $row->{"CARTRIDG"} = "0" . $row->{"CARTRIDG"};
  }

  $row->{"CARTRIDG_MON"} = substr($row->{"CARTRIDG"}, 0, 2);
  $row->{"CLEARYR"} = ($row->{"CLEARYR"} eq "" ? $row->{"STAT_YR"} : $row->{"CLEARYR"});
  $row->{"CLEARDAY"} = ($row->{"CLEARDAY"} eq "" ? 1 : $row->{"CLEARDAY"});
  $row->{"CLEARMON"} = (int($row->{CLEARMON}) < 10 ? "0" . int($row->{CLEARMON}) : int($row->{CLEARMON}));
  $row->{ZIPCODE} = (defined $zips{$row->{ZIPCODE}} ? $zips{$row->{ZIPCODE}} : $row->{ZIPCODE});
}

$workbook->close();
