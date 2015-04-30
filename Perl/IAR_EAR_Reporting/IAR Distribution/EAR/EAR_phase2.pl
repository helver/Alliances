#!d:/perl/bin/perl

use DBWrapper::ODBC_DBWrapper;
use Spreadsheet::WriteExcel::Big;

my $debug = 0;
$| = 1;

my ($comp, $basedir, $combfile) = @ARGV;
$basedir = "M:/" unless defined $basedir;
my $company;
my $dbi;
my %tabs;

my $xxxx = time;

if(1) {
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

my $xxxcomp = time;
print "--------------------------\n";
print "Loading Company information.\n";


my $backfillcompsql = "INSERT INTO companies (id, name, tid) SELECT id, name, name as tid FROM public_companies where id not in (select id from companies)";
print "$backfillcompsql\n" if($debug >= 2);
$dbi->DoSQL($backfillcompsql);
print "done\n\n" if($debug >= 2);

print "Done loading Company information.\n\n";
$xxxcomp = time() - $xxxcomp;
print "Elapsed time: $xxxcomp sec.\n";

my $x = $dbi->SelectMap("id, 1", "ein_lookup");
$tabs{"ein"} = $x;

$x = $dbi->SelectMap("id, 1", "filer_lookup");
$tabs{"filer"} = $x;

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
#print "--------------------------\n";
#print ("Starting to create output spreadsheet.\n");

#my $workbook = Spreadsheet::WriteExcel::Big->new("output/" . $comp . "/${comp}_EAR.xls");
#my $worksheet = $workbook->addworksheet("EAR");

#my $rowcount = 0;
#my $colcount = 0;

#$worksheet->write($rowcount, $colcount++, "COMPANY");
#$worksheet->write($rowcount, $colcount++, "SOURCE");
#foreach my $col (@cols) {
#  $worksheet->write($rowcount, $colcount++, $col);
#}

#$rowcount++;

#print "Done loading creating output spreadsheet.\n\n";
#$yyy = time() - $yyy;
#print "Elapsed time: $yyy sec.\n";

$yyy = time;
print "--------------------------\n";
print ("Starting to load EAR data.\n");

open FH, "< $combfile" or die "Can't open $combfile: $!\n";
my $headers = <FH>;
chomp $headers;
my @headers = split /\t/, $headers;

while(<FH>) {
  chomp;
  my @vals = split /\t/;

  my %vals;
  @vals{@headers} = @vals;

#  $colcount = 0;
#  foreach my $col (@headers) {
#    $worksheet->write_string($rowcount, $colcount++, $vals{$col});
#  }
#  $rowcount++;

  #$debug = 0;
  #print STDERR $vals{"ITN"} . "\n";
  #next unless $vals{"ITN"} eq "";
  #$debug = 2;

  $vals{'CLEARDATE'} = "#" . $vals{"CLEARMON"} . "/" . $vals{"CLEARDAY"} . "/" . $vals{"CLEARYR"} . "#";

  if($debug >= 6) {
    foreach (keys %vals) {
      print "$_ -- $vals{$_}\n";
    }
    exit;
  }

  if($tabs{"port"}->{int($vals{"DISTPORT"})} != 1) {
    $tabs{"port"}->{int($vals{"DISTPORT"})} = 1;
    #print "port\n";
    print STDERR "Trying to insert a new port:" . int($vals{"DISTPORT"}) . "\n" if($debug >= 2);
    my $ret = $dbi->DoSQL("INSERT INTO port_lookup VALUES ('" . int($vals{"DISTPORT"}) . "', null);");
    exit if $ret == -1;
  }


  if($tabs{"ein"}->{$vals{"EIN"}} != 1) {
    $tabs{"ein"}->{$vals{"EIN"}} = 1;
    #print "ein\n";
    print STDERR "Trying to insert a new ein:" . $vals{"EIN"} . "\n" if($debug >= 2);
    my $ret = $dbi->DoSQL("INSERT INTO ein_lookup VALUES ('" . $vals{"EIN"} . "', null);");
    exit if $ret == -1;
  }


  if($vals{"ISO_CTRY"} ne "" && $tabs{"country"}->{$vals{"ISO_CTRY"}} != 1) {
    $tabs{"country"}->{$vals{"ISO_CTRY"}} = 1;
    #print "country\n";
    print STDERR "Trying to insert a new country:" . $vals{"ISO_CTRY"} . "\n" if($debug >= 2);
    my $ret = $dbi->DoSQL("INSERT INTO country_lookup VALUES ('" . $vals{"ISO_CTRY"} . "', null, 1);");
    exit if $ret == -1;
  }


  if($tabs{"filer"}->{$vals{"FILER_ID"}} != 1) {
    $tabs{"filer"}->{$vals{"FILER_ID"}} = 1;
    #print "filer\n";
    print STDERR "Trying to insert a new filer:" . $vals{"FILER_ID"} . "\n" if($debug >= 2);
    my $ret = $dbi->DoSQL("INSERT INTO filer_lookup VALUES ('" . $vals{"FILER_ID"} . "', null, null, null, null, null, null, null, null);");
    exit if $ret == -1;
  }


  if($tabs{"hsusa"}->{int($vals{"HS"})} != 1) {
    $tabs{"hsusa"}->{int($vals{"HS"})} = 1;
    #print "hts\n";
    print STDERR "Trying to insert a new hsusa:" . $vals{"HS"} . "\n" if($debug >= 2);
    my $ret = $dbi->DoSQL("INSERT INTO hsusa_lookup VALUES ('" . int($vals{"HS"}) . "', null, null);");
    exit if $ret == -1;
  }


  foreach my $x (keys %vals) {
    if($vals{$x} eq "") {
      delete $vals{$x};
      next;
    }

    next if($x eq "CLEARDATE" or $x eq "DISTPORT" or $x eq "QTY1" or $x eq "QTY2");

    $vals{$x} =~ s/'/''/g;
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
  print STDERR "$sqry\n" if($debug >= 2);

  #print "ear\n";
  my $ret = $dbi->DoSQL($sqry);
  print "$ret\n" if $ret < 1;
  exit if $ret == -1;
}

close FH;

print "Done loading EAR data.\n\n";
$yyy = time() - $yyy;
print "Elapsed time: $yyy sec.\n";


print "-----------------------------\n\n";
$xxxx = time() - $xxxx;
print "Total Elapsed time: $xxxx sec.\n";

#$workbook->close();
