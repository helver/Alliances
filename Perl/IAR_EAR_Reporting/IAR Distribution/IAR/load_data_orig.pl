#!d:/perl/bin/perl

use DBWrapper::PG_DBWrapper;
use DBWrapper::ODBC_DBWrapper;
use CustomsReport::LiquidExtract;
use CustomsReport::MasterFileExtract;
use Reports::LoadData;
use Date::Manip;

$|=1;

my $debug = 1;

my ($company, $input_path, $do_ost, $do_drop_indexes) = @ARGV;
$do_ost = 1 unless defined $do_ost;
$input_path = "M:/" unless defined $input_path;
$do_drop_indexes = 1 unless defined $do_drop_indexes;

my $nuke = 0;

print "Nuking existing data\n" if ($nuke != 0);

#my $dbh = DBWrapper::PG_DBWrapper->new("iar", "", "cache", "iar");
my $dbh = DBWrapper::ODBC_DBWrapper->new("", "", "localhost", "combined");

if($do_drop_indexes == 1) {
  print "Starting to drop indexes.\n";

  $dbh->DoSQL("drop index entries_filer_id_index;");
  $dbh->DoSQL("drop index entries_ior_index;");
  $dbh->DoSQL("drop index entries_cons_index;");
  $dbh->DoSQL("drop index entries_port_id_index;");
  $dbh->DoSQL("drop index entries_company_id_index;");
  $dbh->DoSQL("drop index entries_entry_type_id_index;");

  $dbh->DoSQL("drop index line_items_coo_index;");
  $dbh->DoSQL("drop index line_items_hsusa_index;");
  $dbh->DoSQL("drop index line_items_mid_index;");
  $dbh->DoSQL("drop index line_items_company_id_index;");
  $dbh->DoSQL("drop index line_items_port_id_index;");
  $dbh->DoSQL("drop index line_items_filer_id_index;");

  print "Done dropping indexes.\n";
}

my $comp = $dbh->Select("id", "companies", "name = '$company'");
if(!defined($comp->[0])) {
  $dbh->DoSQL("insert into companies (name) values ('$company');");
  $comp = $dbh->Select("id", "companies", "name = '$company'");
}

$comp_id = $comp->[0]->{id};
print "Company_ID: $comp_id\n";

my $dbi;
my %ost;
my $xx;
my %existing;

if($do_ost) {
  my $xxx = time;
  print "--------------------------\n";
  print ("Starting to load OST Lookup Data.\n");

  #$debug = 3;
  $dbi = DBWrapper::ODBC_DBWrapper->new("", "", "localhost", "foia");
  #$dbi->debug(3);
  #$dbh->debug(3);

  my $filers = $dbi->Select("*", "filer");
  $xx = $dbh->Select("id", "filer_lookup");

  undef %existing;
  for(my $i = 0; defined($xx->[$i]); $i++) {
    $existing{$xx->[$i]->{"id"}} = 1;
  }

  for(my $i = 0; defined($filers->[$i]); $i++) {
    next if defined($existing{$filers->[$i]->{"filer"}});

    my %vals = (
      "id" => "'" . $filers->[$i]->{"filer"} . "'",
      "name" => "'" . $filers->[$i]->{"filer_name"} . "'",
      "address" => "'" . $filers->[$i]->{"filer_addr1"} . "'",
      "address2" => "'" . $filers->[$i]->{"filer_addr2"} . "'",
      "city" => "'" . $filers->[$i]->{"filer_city"} . "'",
      "state" => "'" . $filers->[$i]->{"filer_state"} . "'",
      "zipcode" => "'" . $filers->[$i]->{"filer_zip"} . "'",
      "phone" => "'" . $filers->[$i]->{"contact_phone"} . "'",
      "filer_type" => "'" . "Unknown" . "'",
    );

    foreach my $x (keys %vals) {
      delete $vals{$x} unless ($vals{$x} ne "");
    }

    my ($sdata,$scols,$sqry);

    foreach my $col (keys %vals) {
      $sdata .= ($sdata eq "" ? "" : ", ") . $vals{$col};
      $scols .= ($scols eq "" ? "" : ", ") . $col;
    }

    # Build the rest of the SQL statement.
    $sqry .= "INSERT INTO filer_lookup (" . $scols . ") VALUES (" . $sdata . ")";
    print "$sqry\n" if($debug >= 3);

    $dbh->DoSQL($sqry);
    if($dbh->{theDB}->{err}) {
      print "Error executing: $sqry\n" . $dbh->{theDB}->{errstr} . "\n";
    }

  }

  print "Done loading filers.\n";

  my $filers = $dbi->Select("*", "port", "ctry = 'US'");
  $xx = $dbh->Select("code", "port_lookup");

  undef %existing;
  for(my $i = 0; defined($xx->[$i]); $i++) {
    $existing{int($xx->[$i]->{"code"})} = 1;
  }

  for(my $i = 0; defined($filers->[$i]); $i++) {
    next if defined($existing{int($filers->[$i]->{"port_code"})});

    $filers->[$i]->{"port_name"} =~ s/'+/''/g;

    my %vals = (
      "code" => $filers->[$i]->{"port_code"},
      "name" => "'" . $filers->[$i]->{"port_name"} . "'",
      "old_code" => "'" . $filers->[$i]->{"port_code"} . "'",
    );

    foreach my $x (keys %vals) {
      delete $vals{$x} unless ($vals{$x} ne "");
    }

    my ($sdata,$scols,$sqry);

    foreach my $col (keys %vals) {
      $sdata .= ($sdata eq "" ? "" : ", ") . $vals{$col};
      $scols .= ($scols eq "" ? "" : ", ") . $col;
    }

    # Build the rest of the SQL statement.
    $sqry .= "INSERT INTO port_lookup (" . $scols . ") VALUES (" . $sdata . ")";
    print "$sqry\n" if($debug >= 3);

    my $ret = $dbh->DoSQL($sqry);
    if($ret < 0 || $dbh->{theDB}->{err}) {
      print "Error executing: $sqry\n" . $dbh->{theDB}->{errstr} . "\n";
    }

  }

  print "Done loading ports.\n";

  $dbi->{raise_error} = 0;

  my $filers = $dbi->Select("hsusa, hsusa_desc", "commodity");
  $xx = $dbh->Select("id", "hsusa_lookup");

  undef %existing;
  for(my $i = 0; defined($xx->[$i]); $i++) {
    $existing{int($xx->[$i]->{"id"})} = 1;
  }

  for(my $i = 0; defined($filers->[$i]); $i++) {
    next if defined($existing{int($filers->[$i]->{"hsusa"})});

    $filers->[$i]->{"hsusa_desc"} =~ s/'+/''/g;

    my %vals = (
      "id" => "'" . $filers->[$i]->{"hsusa"} . "'",
      "description" => "'" . $filers->[$i]->{"hsusa_desc"} . "'",
      "fda_flag" => "NULL",
    );

    foreach my $x (keys %vals) {
      delete $vals{$x} unless ($vals{$x} ne "");
    }

    my ($sdata,$scols,$sqry);

    foreach my $col (keys %vals) {
      $sdata .= ($sdata eq "" ? "" : ", ") . $vals{$col};
      $scols .= ($scols eq "" ? "" : ", ") . $col;
    }

    # Build the rest of the SQL statement.
    $sqry .= "INSERT INTO hsusa_lookup (" . $scols . ") VALUES (" . $sdata . ")";
    print "$sqry\n" if($debug >= 3);

    $dbh->DoSQL($sqry);
    if($dbh->{theDB}->{err}) {
      print "Error executing: $sqry\n" . $dbh->{theDB}->{errstr} . "\n";
    }

  }

  print "Done loading hts numbers.\n";



  my $filers = $dbi->Select("ctry_code, country_name", "country");
  $xx = $dbh->Select("id", "country_lookup");

  undef %existing;
  for(my $i = 0; defined($xx->[$i]); $i++) {
    $existing{$xx->[$i]->{"id"}} = 1;
  }

  for(my $i = 0; defined($filers->[$i]); $i++) {
    next if defined($existing{$filers->[$i]->{"ctry_code"}});

    my %vals = (
      "id" => "'" . $filers->[$i]->{"ctry_code"} . "'",
      "name" => "'" . $filers->[$i]->{"country_name"} . "'",
    );

    foreach my $x (keys %vals) {
      delete $vals{$x} unless ($vals{$x} ne "");
    }

    my ($sdata,$scols,$sqry);

    foreach my $col (keys %vals) {
      $sdata .= ($sdata eq "" ? "" : ", ") . $vals{$col};
      $scols .= ($scols eq "" ? "" : ", ") . $col;
    }

    # Build the rest of the SQL statement.
    $sqry .= "INSERT INTO country_lookup (" . $scols . ") VALUES (" . $sdata . ")";
    print "$sqry\n" if($debug >= 3);

    $dbh->DoSQL($sqry);
    if($dbh->{theDB}->{err}) {
      print "Error executing: $sqry\n" . $dbh->{theDB}->{errstr} . "\n";
    }

  }

  print "Done loading countries.\n";



  my $filers = $dbi->Select("entry_type_code, entry_type_desc", "entry_type");
  $xx = $dbh->Select("id", "entry_type_lookup");

  undef %existing;
  for(my $i = 0; defined($xx->[$i]); $i++) {
    $existing{int($xx->[$i]->{"id"})} = 1;
  }

  for(my $i = 0; defined($filers->[$i]); $i++) {
    next if defined($existing{int($filers->[$i]->{"entry_type_code"})});

    my %vals = (
      "id" => $filers->[$i]->{"entry_type_code"},
      "name" => "'" . $filers->[$i]->{"entry_type_desc"} . "'",
      "old_id" => "'" . $filers->[$i]->{"entry_type_code"} . "'",
    );

    foreach my $x (keys %vals) {
      delete $vals{$x} unless ($vals{$x} ne "");
    }

    my ($sdata,$scols,$sqry);

    foreach my $col (keys %vals) {
      $sdata .= ($sdata eq "" ? "" : ", ") . $vals{$col};
      $scols .= ($scols eq "" ? "" : ", ") . $col;
    }

    # Build the rest of the SQL statement.
    $sqry .= "INSERT INTO entry_type_lookup (" . $scols . ") VALUES (" . $sdata . ")";
    print "$sqry\n" if($debug >= 3);

    $dbh->DoSQL($sqry);
    if($dbh->{theDB}->{err}) {
      print "Error executing: $sqry\n" . $dbh->{theDB}->{errstr} . "\n";
    }

  }

  print "Done loading entry_types.\n";


  my $filers = $dbi->Select("id_nbr, acs_name", "mfr");
  $xx = $dbh->Select("id", "mid_lookup");

  undef %existing;
  for(my $i = 0; defined($xx->[$i]); $i++) {
    $existing{$xx->[$i]->{"id"}} = 1;
  }

  for(my $i = 0; defined($filers->[$i]); $i++) {
    next if defined($existing{$filers->[$i]->{"id_nbr"}});

    $filers->[$i]->{"acs_name"} =~ s/'/''/g;

    my %vals = (
      "id" => "'" . $filers->[$i]->{"id_nbr"} . "'",
      "name" => "'" . $filers->[$i]->{"acs_name"} . "'",
    );

    foreach my $x (keys %vals) {
      delete $vals{$x} unless ($vals{$x} ne "");
    }

    my ($sdata,$scols,$sqry);

    foreach my $col (keys %vals) {
      $sdata .= ($sdata eq "" ? "" : ", ") . $vals{$col};
      $scols .= ($scols eq "" ? "" : ", ") . $col;
    }

    # Build the rest of the SQL statement.
    $sqry .= "INSERT INTO mid_lookup (" . $scols . ") VALUES (" . $sdata . ")";
    print "$sqry\n" if($debug >= 3);

    $dbh->DoSQL($sqry);
    if($dbh->{theDB}->{err}) {
      print "Error executing: $sqry\n" . $dbh->{theDB}->{errstr} . "\n";
    }

  }

  print "Done loading mids.\n";


  my $filers = $dbi->Select("surety_code, surety_name", "surety");
  $xx = $dbh->Select("id", "surety_lookup");

  undef %existing;
  for(my $i = 0; defined($xx->[$i]); $i++) {
    $existing{$xx->[$i]->{"id"}} = 1;
  }

  for(my $i = 0; defined($filers->[$i]); $i++) {
    next if defined($existing{$filers->[$i]->{"surety_code"}});

    my %vals = (
      "id" => $filers->[$i]->{"surety_code"},
      "name" => "'" . $filers->[$i]->{"surety_name"} . "'",
    );

    foreach my $x (keys %vals) {
      delete $vals{$x} unless ($vals{$x} ne "");
    }

    my ($sdata,$scols,$sqry);

    foreach my $col (keys %vals) {
      $sdata .= ($sdata eq "" ? "" : ", ") . $vals{$col};
      $scols .= ($scols eq "" ? "" : ", ") . $col;
    }

    # Build the rest of the SQL statement.
    $sqry .= "INSERT INTO surety_lookup (" . $scols . ") VALUES (" . $sdata . ")";
    print "$sqry\n" if($debug >= 3);

    $dbh->DoSQL($sqry);

    if($dbh->{theDB}->{err}) {
      print "Error executing: $sqry\n" . $dbh->{theDB}->{errstr} . "\n";
    }

  }

  print "Done loading surety codes.\n";

  $dbi->Close();
  undef $dbi;

  print("Done loading OST Lookup Data.\n");
  $xxx = time() - $xxx;
  print "Elapsed time: $xxx sec.\n";
}


if($do_ost) {
  my $xxx = time;
  print "--------------------------\n";
  print ("Starting to combine OST data.\n");

  $dbi = DBWrapper::ODBC_DBWrapper->new("", "", "localhost", "foia") unless defined($dbi);

  $dbi->DoSQL("CREATE TABLE SMRY_AND_RLSE (year number, hsusa text, numentries number, [value] number, duty number, filer text, coo text, mid text, port text, imp_nbr text, cgn_nbr text, entry_nbr text, line_nbr number, primary_spi text, source text);");

  my $sql = "INSERT INTO SMRY_AND_RLSE " .
            "(year, hsusa, numentries, [value], duty, filer, coo, mid, port, imp_nbr, cgn_nbr, entry_nbr, line_nbr, primary_spi, source) " .
            "SELECT DatePart('yyyy', iif(e.entry_date is null, e.arvl_date, e.ENTRY_DATE)), " .
            "h.HSUSA, 1 AS [NumEntries], h.value AS [Value], " .
#            "iif(l.calc_duty is null, h.EST_DUTY, l.calc_duty) AS Duty, " .
            "h.EST_DUTY AS Duty, " .
            "h.FILER, l.CTRY_ORIGIN as coo, l.MID, " .
            "e.port_ent as port, e.imp_nbr, l.cgn_nbr, h.ENTRY_NBR, " .
            "h.LINE_NBR, h.PRIMARY_SPI, 'H' as source " .
            "FROM (ENTRY_SMRY_HSUSA AS h LEFT JOIN ENTRY_SMRY_LINE AS l ON (h.filer = l.filer) AND (h.ENTRY_NBR = l.ENTRY_NBR) AND (h.LINE_NBR = l.LINE_NBR)) " .
            "  INNER JOIN entry e ON (e.filer = h.filer and e.entry_nbr = h.entry_nbr);";

  print "$sql\n" if($debug >= 3);

  $dbi->DoSQL($sql);

  my $pql = "INSERT INTO SMRY_AND_RLSE " .
            "(year, hsusa, numentries, [value], duty, filer, coo, mid, port, imp_nbr, cgn_nbr, entry_nbr, line_nbr, primary_spi, source) " .
            "SELECT DatePart('yyyy', iif(er.entry_date is null, er.arvl_date, er.ENTRY_DATE)), crs.hsusa, 1 AS [NumEntries], crs.line_val AS [Value], 0 AS Duty, crs.filer, crs.ctry_code as coo, crs.mid as mid, er.port_ent as port, er.imp_nbr, crs.cgn_nbr, crs.entry_nbr, crs.line_nbr, null as primary_spi, 'C' as source " .
            "FROM (    CARGO_RLSE_LINE crs " .
            "  INNER JOIN entry er ON er.entry_nbr = crs.entry_nbr) " .
            "  LEFT JOIN ENTRY_SMRY_HSUSA shs on (shs.entry_nbr = crs.entry_nbr) " .
            "WHERE shs.entry_nbr is null;";

  print "$pql\n" if($debug >= 3);

  $dbi->DoSQL($pql);
  $dbi->Close();
  undef $dbi;

  print "\n";
  print("Done combining OST data.\n");
  $xxx = time() - $xxx;
  print "Elapsed time: $xxx sec.\n";
}

if($do_ost) {
  my $xxx = time;
  print "--------------------------\n";
  print ("Starting to load OST Entry data.\n");

  $dbi = DBWrapper::ODBC_DBWrapper->new("", "", "localhost", "foia") unless defined($dbi);

  my $rptdate = $dbi->Select("max(date_mainframe_extract)", "contents");

  #my $res = $dbi->Select("*", "CombinedDataQ");

  #print "Num results: " . scalar(@{$res}) . "\n";

  my $res = $dbi->DoSQL(
    "SELECT " .
    "max(sr.imp_nbr) AS ior, max(sr.imp_nbr) AS cons, " .
    "sr.FILER+'-'+Left(sr.ENTRY_NBR,7)+'-'+Right(sr.ENTRY_NBR,1) AS num, " .
    "sr.filer AS filer, max(sr.port) AS port, sum(sr.value) AS [Value], " .
    "sum(sr.DUTY) AS duties, " .
    "max(IIf(e.entry_date Is Null, iif(e.arvl_date is null, #1/1/1970#, e.arvl_date),e.ENTRY_DATE)) AS entry_date, " .
    "max(e.entry_type) AS entrytype, sr.entry_nbr " .
    "FROM SMRY_AND_RLSE AS sr " .
    "LEFT JOIN Entry AS e ON (e.filer = sr.filer) AND (e.entry_nbr = sr.entry_nbr) " .
    "GROUP BY sr.entry_nbr, sr.filer;"
  );

  print "Num results: " . scalar(@{$res}) . "\n";

  if($nuke != 0) {
    $dbh->Delete("entries", "company_id = $comp_id");
  } else {
    $xx = $dbh->SelectMap("id, 1", "entries", "company_id = $comp_id");
    %existing = %{$xx};
  }

  print "Done with delete.\n" if ($nuke != 0);

  for(my $i = 0; defined($res->[$i]); $i++) {

    #print "Done with: $i\n" if ($i % 100 == 0);

    #next if defined($existing{$res->[$i]->{"num"}});

    $res->[$i]->{"filer"} =~ s/ /0/g;

    if(length($res->[$i]->{"ior"}) <= 10) {
      $res->[$i]->{"ior"} .= "00";
    }

    while(length($res->[$i]->{"ior"}) < 12) {
      $res->[$i]->{"ior"} = "0" . $res->[$i]->{"ior"};
    }

    if(length($res->[$i]->{"cons"}) <= 10) {
      $res->[$i]->{"cons"} .= "00";
    }

    while(length($res->[$i]->{"cons"}) < 12) {
      $res->[$i]->{"cons"} = "0" . $res->[$i]->{"cons"};
    }


    my %vals = (
      "id" => "'" . $res->[$i]->{"num"} . "'",
      "company_id" => $comp_id,
      "port_id" => (($res->[$i]->{"port"} !~ /^ *$/) ? $res->[$i]->{"port"} : "-1"),
      "filer_id" => "'" . $res->[$i]->{"filer"} . "'",
      "value" => $res->[$i]->{"value"},
      "duties" => $res->[$i]->{"duties"},
      "ostduties" => $res->[$i]->{"duties"},
      "ior" => "'" . (substr($res->[$i]->{"ior"}, 2, 1) ne "-" ? "0" : "") . uc($res->[$i]->{"ior"}) . "'",
      "consgnee" => "'" . (substr($res->[$i]->{"cons"}, 2, 1) ne "-" ? "0" : "") . uc($res->[$i]->{"cons"}) . "'",
      "entry_date" => "'" . $res->[$i]->{"entry_date"} . "'",
      "entry_type_id" => (($res->[$i]->{"entrytype"} !~ /^ *$/) ? $res->[$i]->{"entrytype"} : "-1"),
      "ost" => "'t'",
      "liquid_date" => "'" . ($res->[$i]->{"liquid_date"} ne "" ? $res->[$i]->{"liquid_date"} : &UnixDate(&DateCalc(&ParseDate($res->[$i]->{"entry_date"}),"+ 314 days",\$err), "%m/%d/%y")) . "'",
      "report_date" => "'" . $rptdate->[0]->{"0"} . "'",
    );

    #if(($nuke == 0) && exists $existing{$vals{$res->[$i]->{"num"}}}) {
    #  $dbh->Delete("entries", "company_id = $comp_id and id = " . $vals{id});
    #}

    foreach my $x (keys %vals) {
      delete $vals{$x} unless ($vals{$x} ne "");
    }

    my $sqry;

    if(defined $existing{$res->[$i]->{"num"}}) {
      my $sdata;

      foreach my $k (keys %vals) {
        $sdata .= ($sdata eq "" ? "" : ",") . "$k = " . $vals{$k};
      }

      $sqry = "UPDATE entries SET " . $sdata . " WHERE " . "company_id = $comp_id and id = " . $vals{id};
    } else {
      my ($sdata,$scols);

      foreach my $col (keys %vals) {
        $sdata .= ($sdata eq "" ? "" : ", ") . $vals{$col};
        $scols .= ($scols eq "" ? "" : ", ") . $col;
      }

      # Build the rest of the SQL statement.
      $sqry .= "INSERT INTO entries (" . $scols . ") VALUES (" . $sdata . ")";
      $existing{$res->[$i]->{"num"}} = 1;
    }

    print "$sqry\n" if($debug >= 3);

    $dbh->DoSQL($sqry);
    $ost{$vals{id}} = 1;
  }

  $dbi->Close();
  undef $dbi;

  print "\n";
  print("Done loading OST Entry data.\n");
  $xxx = time() - $xxx;
  print "Elapsed time: $xxx sec.\n";
}

if($do_ost) {
  my $xxx = time;
  print "--------------------------\n";
  print ("Starting to load OST Line Item data.\n");

  $dbi = DBWrapper::ODBC_DBWrapper->new("", "", "localhost", "foia") unless defined($dbi);

  if($nuke != 0) {
    $dbh->Delete("line_items", "company_id = $comp_id");
  } else {
    $xx = $dbh->SelectMap("id || '_' || line_nbr || '_' || hsusa as key, 1", "line_items", "company_id = $comp_id");
    %existing = %{$xx};
  }

  print "Done with delete.\n" if ($nuke != 0);

  $dbi = DBWrapper::ODBC_DBWrapper->new("", "", "localhost", "foia") unless defined($dbi);

  #my $sth = $dbi->{theDB}->prepare("SELECT * from CombinedByLineDataSet");

  my $sql =
    "SELECT sr.filer AS filer, " .
    "sr.FILER+'-'+Left(sr.ENTRY_NBR,7)+'-'+Right(sr.ENTRY_NBR,1) AS ENTRY_NBR, " .
    "sr.line_nbr, sr.coo, sr.hsusa, sr.imp_nbr, sr.cgn_nbr, sr.mid, " .
    "sr.value AS [Value], sr.DUTY AS duties, sr.port as port_ent, e.liquid_date AS liquid, " .
    "IIf(e.entry_date Is Null, iif(e.arvl_date is null, #1/1/1970#, e.arvl_date),e.ENTRY_DATE) AS entry_date, " .
    "sr.primary_spi AS spi, sr.entry_nbr AS xxx " .
    "FROM SMRY_AND_RLSE AS sr LEFT JOIN Entry AS e ON (e.filer = sr.filer) AND (e.entry_nbr = sr.entry_nbr);";

  print "$sql\n" if($debug >= 3);

  my $sth = $dbi->{theDB}->prepare($sql);
  if($dbi->{theDB}->{err}) {
    print "Error preparing: \n" . $dbi->{theDB}->{errstr} . "\n";
    exit();
  }

  $sth->execute;

  if($dbi->{theDB}->{err}) {
    $sth->finish;
    print "Error executing: \n" . $dbi->{theDB}->{errstr} . "\n";
    exit();
  }

  my $count = 0;

  while(my $rowref = $sth->fetchrow_hashref) {
    # Ensure that each column in the row is identified by at least
    # the lowercase column name - if column names were provided.
    for(my $i = 0; $i < $sth->{NUM_OF_FIELDS}; $i++) {
      $rowref->{lc($sth->{NAME}->[$i])} = $rowref->{$sth->{NAME}->[$i]};
    }

    #print "Done with: $count\n" if ($count % 100 == 0);
    $count++;

    my $key = $rowref->{"entry_nbr"} . "_" . int($rowref->{"line_nbr"}) . "_" . $rowref->{"hsusa"};
    #print "Checking for $key in existing: $existing{$key}\n";
    #next if defined($existing{$key});

    $rowref->{"filer"} =~ s/ /0/g;
    if(length($rowref->{"imp_nbr"}) <= 10) {
      $rowref->{"imp_nbr"} .= "00";
    }

    while(length($rowref->{"imp_nbr"}) < 12) {
      $rowref->{"imp_nbr"} = "0" . $rowref->{"imp_nbr"};
    }

    if(length($rowref->{"cgn_nbr"}) <= 10) {
      $rowref->{"cgn_nbr"} .= "00";
    }

    while(length($rowref->{"cgn_nbr"}) < 12) {
      $rowref->{"cgn_nbr"} = "0" . $rowref->{"cgn_nbr"};
    }


    my %vals = (
      "id" => "'" . $rowref->{"entry_nbr"} . "'",
      "line_nbr" => int($rowref->{"line_nbr"}),
      "company_id" => $comp_id,
      "port_id" => (($rowref->{"port_ent"} !~ /^ *$/) ? $rowref->{"port_ent"} : "-1"),
      "filer_id" => "'" . $rowref->{"filer"} . "'",
      "value" => $rowref->{"value"},
      "duties" => $rowref->{"duties"},
      "ior" => "'" . (substr($rowref->{"imp_nbr"}, 2, 1) ne "-" ? "0" : "") . uc($rowref->{"imp_nbr"}) . "'",
      "consgnee" => "'" . (substr($rowref->{"cgn_nbr"}, 2, 1) ne "-" ? "0" : "") . uc($rowref->{"cgn_nbr"}) . "'",
      "coo" => "'" . ($rowref->{"coo"} ne "" ? $rowref->{"coo"} : "**"). "'",
      "mid" => "'" . $rowref->{"mid"} . "'",
      "hsusa" => "'" . $rowref->{"hsusa"} . "'",
      "spi" => "'" . $rowref->{"spi"} . "'",
      "entry_date" => "'" . $rowref->{"entry_date"} . "'",
    );

    #if(($nuke == 0) && exists $existing{$rowref->{"entry_nbr"} . "_" . int($rowref->{"line_nbr"}) . "_" . $rowref->{"hsusa"}}) {
    #  $dbh->Delete("line_items", "company_id = $comp_id and id = " . $vals{id} . "and line_nbr = " . $vals{line_nbr} . " and hsusa = " . $vals{hsusa});
    #}

    foreach my $x (keys %vals) {
      delete $vals{$x} unless ($vals{$x} ne "" && $vals{$x} ne "''");
    }

    my $sqry;

    if(defined $existing{$key}) {
      my $sdata;

      foreach my $k (keys %vals) {
        $sdata .= ($sdata eq "" ? "" : ",") . "$k = " . $vals{$k};
      }

      $sqry = "UPDATE line_items SET " . $sdata . " WHERE " . "company_id = $comp_id and id = " . $vals{id} . "and line_nbr = " . $vals{line_nbr} . " and hsusa = " . $vals{hsusa};
    } else {
      my ($sdata,$scols);

      foreach my $col (keys %vals) {
        $sdata .= ($sdata eq "" ? "" : ", ") . $vals{$col};
        $scols .= ($scols eq "" ? "" : ", ") . $col;
      }

      # Build the rest of the SQL statement.
      $sqry .= "INSERT INTO line_items (" . $scols . ") VALUES (" . $sdata . ")";
      $existing{$key} = 1;
    }

    print "$sqry\n" if($debug >= 3);

    $dbh->DoSQL($sqry);
  }

  print "\n";

  $sth->finish;
  $dbi->Close();
  undef $dbi;

  print("Done loading OST Line Item data.\n");
  $xxx = time() - $xxx;
  print "Elapsed time: $xxx sec.\n";
}

if(1) {
  my $xxx = time;
  print "--------------------------\n";
  print("Starting to load NFC Entry data.\n");

  my @reports;
  my $rpt = Reports::LoadData->new("", "", $debug, $dbh, $comp_id);
  push @reports, $rpt;

  #$rpt->{ostnums} = $dbh->SelectMap("id, 1", "entries", "company_id = $comp_id");

  my $ler = CustomsReport::LiquidExtract->new($debug);
  my $mfer = CustomsReport::MasterFileExtract->new($debug);

  print("Starting Unliquidated Entries.\n");
  foreach my $xxx (glob("$input_path*_mfx.txt")) {
    print "Running $xxx\n";
    &process_data_source($mfer, \@reports, $xxx);
  }
  print("Done Unliquidated Entries.\n");

  print("Starting with Liquidated Entries.\n");
  foreach my $xxx (glob("$input_path*_liq.txt")) {
    print "Running $xxx\n";
    &process_data_source($ler, \@reports, $xxx);
  }
  print("Done with Liquidated Entries.\n");

  print("Done loading NFC Entry data.\n");
  $xxx = time() - $xxx;
  print "Elapsed time: $xxx sec.\n";
}


if($do_ost) {
  my $xxx = time;
  print "--------------------------\n";
  print("Starting drop SMRY_AND_RLSE table.\n");

  $dbi = DBWrapper::ODBC_DBWrapper->new("", "", "localhost", "foia") unless defined($dbi);

  $dbi->DoSQL("drop table SMRY_AND_RLSE;");

  $dbi->Close();
  undef $dbi;

  print("Done dropping SMRY_AND_RLSE table.\n");
  $xxx = time() - $xxx;
  print "Elapsed time: $xxx sec.\n";
}


$dbh->Close() if defined($dbh);
$dbi->Close() if defined($dbi);

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