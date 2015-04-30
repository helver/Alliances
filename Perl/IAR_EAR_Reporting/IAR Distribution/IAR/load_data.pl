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

my $comp_id = $dbh->SelectSingleValue("id", "companies", "name = '$company'");
if(!defined($comp_id) || $comp_id eq "") {
  $dbh->DoSQL("insert into companies (name) values ('$company');");
  $comp_id = $dbh->SelectSingleValue("id", "companies", "name = '$company'");
}

print "Company_ID: $comp_id\n";

my $dbi;
my %ost;
my $existing;

if($do_ost) {
  my $xxx = time;
  print "--------------------------\n";
  print ("Starting to load OST Lookup Data.\n");

  #$debug = 3;
  $dbi = DBWrapper::ODBC_DBWrapper->new("", "", "localhost", "foia");
  #$dbi->debug(3);
  #$dbh->debug(3);

  my $filers = $dbi->Select("*", "filer");
  $existing = $dbh->SelectMap("id, 1", "filer_lookup");

  for(my $i = 0; defined($filers->[$i]); $i++) {
    next if defined($existing->{$filers->[$i]->{"filer_id"}});

    my %vals = (
      "id" => "'" . $filers->[$i]->{"filer_id"} . "'",
      "name" => "'" . $filers->[$i]->{"name"} . "'",
      "address" => "'" . $filers->[$i]->{"address1"} . "'",
      "address2" => "'" . $filers->[$i]->{"address2"} . "'",
      "city" => "'" . $filers->[$i]->{"city"} . "'",
      "state" => "'" . $filers->[$i]->{"state"} . "'",
      "zipcode" => "'" . $filers->[$i]->{"zip"} . "'",
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

  undef $existing;
  print "Done loading filers.\n";

  my $filers = $dbi->Select("*", "us_port");
  $existing = $dbh->SelectMap("code, 1", "port_lookup");

  for(my $i = 0; defined($filers->[$i]); $i++) {
    next if defined($existing->{int($filers->[$i]->{"port_code"})});

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

  undef $existing;
  print "Done loading ports.\n";

  $dbi->{raise_error} = 0;

  my $filers = $dbi->Select("hts_code, hts_description", "tariff_classification");
  $existing = $dbh->SelectMap("id, 1", "hsusa_lookup");

  for(my $i = 0; defined($filers->[$i]); $i++) {
    next if defined($existing->{int($filers->[$i]->{"hts_code"})});

    $filers->[$i]->{"hts_description"} =~ s/'+/''/g;
    $filers->[$i]->{"hts_code"} =~ s/ +//g;

    my %vals = (
      "id" => "'" . $filers->[$i]->{"hts_code"} . "'",
      "description" => "'" . $filers->[$i]->{"hts_description"} . "'",
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

  undef $existing;
  print "Done loading hts numbers.\n";



  my $filers = $dbi->Select("iso_country_code, iso_country_description", "country");
  $existing = $dbh->SelectMap("id, 1", "country_lookup");

  for(my $i = 0; defined($filers->[$i]); $i++) {
    next if defined($existing->{$filers->[$i]->{"iso_country_code"}});

    my %vals = (
      "id" => "'" . $filers->[$i]->{"iso_country_code"} . "'",
      "name" => "'" . $filers->[$i]->{"iso_country_description"} . "'",
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

  undef $existing;
  print "Done loading countries.\n";



  my $filers = $dbi->Select("entry_type_code, entry_type_description", "entry_type");
  $existing = $dbh->SelectMap("id, 1", "entry_type_lookup");

  for(my $i = 0; defined($filers->[$i]); $i++) {
    next if defined($existing->{int($filers->[$i]->{"entry_type_code"})});

    my %vals = (
      "id" => $filers->[$i]->{"entry_type_code"},
      "name" => "'" . $filers->[$i]->{"entry_type_description"} . "'",
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

  undef $existing;
  print "Done loading entry_types.\n";


  my $filers = $dbi->Select("mfr_id, name", "manufacturer");
  $existing = $dbh->SelectMap("id, 1", "mid_lookup");

  for(my $i = 0; defined($filers->[$i]); $i++) {
    next if defined($existing->{$filers->[$i]->{"mfr_id"}});

    $filers->[$i]->{"name"} =~ s/'/''/g;

    my %vals = (
      "id" => "'" . $filers->[$i]->{"mfr_id"} . "'",
      "name" => "'" . $filers->[$i]->{"name"} . "'",
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

  undef $existing;
  print "Done loading mids.\n";


  my $filers = $dbi->Select("surety_code, surety_name", "surety");
  $existing = $dbh->SelectMap("id, 1", "surety_lookup");

  for(my $i = 0; defined($filers->[$i]); $i++) {
    next if defined($existing->{$filers->[$i]->{"surety_code"}});

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

  undef $existing;
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
  print ("Starting to load OST Entry data.\n");

  $dbi = DBWrapper::ODBC_DBWrapper->new("", "", "localhost", "foia") unless defined($dbi);

  my $rptdate = $dbi->Select("max(date_range_stop)", "contents");

  #my $res = $dbi->Select("*", "CombinedDataQ");

  #print "Num results: " . scalar(@{$res}) . "\n";

  my $big_select_query =
    "SELECT " .
    "max(sr.importer_id) AS ior, " .
    "max(sr.consignee_id) AS cons, " .
    "sr.entry_number AS num, " .
    "sr.filer AS filer, " .
    "max(sr.port_of_entry) AS port, " .
    "sum(sr.line_value) AS [Value], " .
#    "sum(iif(sr.duty_paid_amount is null, sr.estimated_duty_amount, sr.duty_paid_amount)) AS duties, " .
    "sum(sr.estimated_duty_amount) AS duties, " .
    "max(IIf(sr.date_of_entry Is Null, iif(sr.date_of_import is null, '19700101', sr.date_of_import),sr.date_of_entry)) AS entry_date, " .
    "max(sr.entry_type) AS entrytype, " .
    "max(sr.liquidated_date) as liquid_date, " .
    "sr.entry_number " .
    "FROM SENSE_US AS sr " .
    "GROUP BY sr.entry_number, sr.filer;"
  ;

  print "$big_select_query\n" if($debug >= 0);

  my $res = $dbi->DoSQL($big_select_query);

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
    #$res->[$i]->{"ior"} =~ s/^0+//;
    #$res->[$i]->{"cons"} =~ s/^0+//;

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

    $res->[$i]->{"num"} =~ s/^(.*?)(.{7})(.)$/$1-$2-$3/;
    $res->[$i]->{"entry_date"} = int($res->[$i]->{"entry_date"});
    $res->[$i]->{"entry_date"} =~ s/(.{4})(..)(..)/$2\/$3\/$1/;
    $res->[$i]->{"liquid_date"} = (int($res->[$i]->{"liquid_date"}) == -1 ? "" : int($res->[$i]->{"liquid_date"}));
    $res->[$i]->{"liquid_date"} =~ s/(.{4})(..)(..)/$2\/$3\/$1/;

    my %vals = (
      "id" => "'" . $res->[$i]->{"num"} . "'",
      "company_id" => $comp_id,
      "port_id" => (($res->[$i]->{"port"} !~ /^ *$/) ? $res->[$i]->{"port"} : "-1"),
      "filer_id" => "'" . $res->[$i]->{"filer"} . "'",
      "value" => $res->[$i]->{"value"},
      "duties" => $res->[$i]->{"duties"},
      "ostduties" => $res->[$i]->{"duties"},
      "ior" => "'" . uc($res->[$i]->{"ior"}) . "'",
      "consgnee" => "'" . uc($res->[$i]->{"cons"}) . "'",
      "entry_date" => "'" . $res->[$i]->{"entry_date"} . "'",
      "entry_type_id" => (($res->[$i]->{"entrytype"} !~ /^ *$/) ? $res->[$i]->{"entrytype"} : "-1"),
      "ost" => "'t'",
      "liquid_date" => "'" . ($res->[$i]->{"liquid_date"} ? $res->[$i]->{"liquid_date"} :
                             ($res->[$i]->{"entry_date"}  ? &UnixDate(&DateCalc(&ParseDate($res->[$i]->{"entry_date"}),"+ 314 days",\$err), "%m/%d/%y") :
                                                            "1/1/1970")) . "'",
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

    my $ret = $dbh->DoSQL($sqry);

    if($ret <= 1) {
      #print "$sqry\n";
    }

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

  my $sql =
    "SELECT " .
    "sr.filer AS filer, " .
    "sr.Entry_number AS ENTRY_NBR, " .
    "sr.line_number as line_nbr, " .
    "sr.country_of_origin as coo, " .
    "sr.tariff_classification as hsusa, " .
    "sr.importer_id as imp_nbr, " .
    "sr.consignee_id as cgn_nbr, " .
    "sr.manufacturer_id as mid, " .
    "sr.line_value AS [Value], " .
#    "iif(sr.duty_paid_amount is null, sr.estimated_duty_amount, sr.duty_paid_amount) AS duties, " .
    "sr.estimated_duty_amount AS duties, " .
    "sr.port_of_entry as port_ent, " .
    "sr.liquidated_date AS liquid, " .
    "iif(sr.date_of_entry Is Null, iif(sr.date_of_import is null, '19700101', sr.date_of_import),sr.date_of_entry) AS entry_date, " .
    "sr.special_program AS spi, " .
    "sr.entry_number AS xxx " .
    "FROM SENSE_US AS sr;";

  print "$sql\n" if($debug >= 0);

  my $res = $dbi->DoSQL($sql);

  print "Num results: " . scalar(@{$res}) . "\n";

  for(my $j = 0; defined($res->[$j]); $j++) {
    my $rowref = $res->[$j];

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

    $rowref->{"entry_nbr"} =~ s/^(.*?)(.{7})(.)$/$1-$2-$3/;
    $rowref->{"entry_date"} = int($rowref->{"entry_date"});
    $rowref->{"entry_date"} =~ s/(.{4})(..)(..)/$2\/$3\/$1/;

    my %vals = (
      "id" => "'" . $rowref->{"entry_nbr"} . "'",
      "line_nbr" => int($rowref->{"line_nbr"}),
      "company_id" => $comp_id,
      "port_id" => (($rowref->{"port_ent"} !~ /^ *$/) ? $rowref->{"port_ent"} : "-1"),
      "filer_id" => "'" . $rowref->{"filer"} . "'",
      "value" => $rowref->{"value"},
      "duties" => $rowref->{"duties"},
      "ior" => "'" . uc($rowref->{"imp_nbr"}) . "'",
      "consgnee" => "'" . uc($rowref->{"cgn_nbr"}) . "'",
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