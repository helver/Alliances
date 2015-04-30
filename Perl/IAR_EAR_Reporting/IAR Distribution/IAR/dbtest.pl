#!d:/perl/bin/perl

use DBWrapper::ODBC_DBWrapper;

my $debug = 0;

my $comp = $ARGV[0];

if(1) {
  my $yyy = time;
  print "--------------------------\n";
  print ("Starting to populate the transfer file.\n");

  $dbi = DBWrapper::ODBC_DBWrapper->new("", "", "localhost", "IARLoad");

  $company = $dbi->SelectSingleValue("id", "public_companies", "name = '$comp'");
  print "$comp - $company\n";

  $dbi->Delete("entries");
  $dbi->Delete("line_items");

  my %lookups = (
    "country" => {"fields" => ["id", "name"], "key" => "coo", "source" => "line_items"},
    "entry_type" => {"fields" => ["id", "name"], "key" => "entry_type_id", "source" => "entries"},
    "filer" => {"fields" => ["id", "name", "address", "address2", "city", "state", "zipcode", "phone", "filer_type"], "key" => "filer_id", "source" => "entries,line_items"},
    "hsusa" => {"fields" => ["id", "description", "fda_flag"], "key" => "hsusa", "source" => "line_items"},
    "mid" => {"fields" => ["id", "name"], "key" => "mid", "source" => "line_items"},
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

    foreach my $source (split ",", $lookups{$lu}->{source}) {
      if(0) {
        my $missingsql = "SELECT DISTINCT p." . $lookups{$lu}->{key} . " FROM public_" . $source . " AS p LEFT JOIN ${lu}_lookup AS c ON c." . $lookups{$lu}->{fields}[0] . "=" . ($lookups{$lu}->{forceint} == 1 ? "int(" : "") . "p." . $lookups{$lu}->{key} . ($lookups{$lu}->{forceint} == 1 ? ")" : "") . " WHERE c." . $lookups{$lu}->{fields}[0] . " is null and p." . $lookups{$lu}->{key} . " is not null;";
        print "$missingsql\n" if($debug >= 2);
        $res = $dbi->DoSQL($missingsql);
        for(my $i = 0; defined($res->[$i]); $i++) {
          print "Missing $lu codes:\n" if ($i==0);
          print $res->[$i]->{0} . "\n";
        }
        print "done\n\n" if($debug >= 2);
      }

      my $backfillsql = "INSERT INTO ${lu}_lookup (" . join(",", @{$lookups{$lu}->{fields}}) . ") SELECT DISTINCT p." . $lookups{$lu}->{key} . ((scalar(@{$lookups{$lu}->{fields}}) - 1) > 0 ? ", " . join(",", ("null") x (scalar(@{$lookups{$lu}->{fields}}) - 1)) : "") . " FROM public_" . $source . " AS p LEFT JOIN ${lu}_lookup AS c ON c." . $lookups{$lu}->{fields}[0] . "=" . ($lookups{$lu}->{forceint} == 1 ? "int(" : "") . "p." . $lookups{$lu}->{key} . ($lookups{$lu}->{forceint} == 1 ? ")" : "") . " WHERE c." . $lookups{$lu}->{fields}[0] . " is null and p." . $lookups{$lu}->{key} . " is not null;";
      print "$backfillsql\n" if($debug >= 2);
      $dbi->DoSQL($backfillsql);
      print "done\n\n" if($debug >= 2);
    }

    print "Done loading $lu information.\n\n";
    $xxx = time() - $xxx;
    print "Elapsed time: $xxx sec.\n";
  }

  my $xxxcomp = time;
  print "--------------------------\n";
  print "Loading Company information.\n";

  my $backfillcompsql = "INSERT INTO companies (id, name) SELECT id, name FROM public_companies where id not in (select id from companies)";
  print "$backfillcompsql\n" if($debug >= 2);
  $dbi->DoSQL($backfillcompsql);
  print "done\n\n" if($debug >= 2);

  print "Done loading Company information.\n\n";
  $xxxcomp = time() - $xxxcomp;
  print "Elapsed time: $xxxcomp sec.\n";


###

  my $xxxior = time;
  print "--------------------------\n";
  print "Loading IOR information.\n";

  $debug = 2;

  my $deliorsql = "DELETE FROM ior_lookup";
  print "$deliorsql\n" if($debug >= 2);
  $dbi->DoSQL($deliorsql);
  print "done\n\n" if($debug >= 2);

  my $backfilliorsql = "INSERT INTO ior_lookup (id, name) SELECT DISTINCT ior, null FROM public_entries where ior is not null";
  print "$backfilliorsql\n" if($debug >= 2);
  $dbi->DoSQL($backfilliorsql);
  print "done\n\n" if($debug >= 2);

  $backfilliorsql = "INSERT INTO ior_lookup (id, name) SELECT DISTINCT consgnee, null FROM public_entries where consgnee is not null and consgnee not in (select id from ior_lookup)";
  print "$backfilliorsql\n" if($debug >= 2);
  $dbi->DoSQL($backfilliorsql);
  print "done\n\n" if($debug >= 2);

  $backfilliorsql = "INSERT INTO ior_lookup (id, name) SELECT DISTINCT ior, null FROM public_line_items where ior is not null and ior not in (select id from ior_lookup)";
  print "$backfilliorsql\n" if($debug >= 2);
  $dbi->DoSQL($backfilliorsql);
  print "done\n\n" if($debug >= 2);

  $backfilliorsql = "INSERT INTO ior_lookup (id, name) SELECT DISTINCT consgnee, null FROM public_line_items where consgnee is not null and consgnee not in (select id from ior_lookup)";
  print "$backfilliorsql\n" if($debug >= 2);
  $dbi->DoSQL($backfilliorsql);
  print "done\n\n" if($debug >= 2);

  print "Done loading IOR information.\n\n";
  $xxxior = time() - $xxxior;
  print "Elapsed time: $xxxior sec.\n";

###

  my $xxx = time;
  print "--------------------------\n";
  print "Starting to load entries into transfer table.\n";

  my $loadentriessql = "INSERT INTO entries (id,company_id,port_id,filer_id,[value],duties,ior,consgnee,entry_date,entry_type_id,nfc,ost,liquid_date,report_date,nfcvalue,ostduties) SELECT id,company_id,port_id,filer_id,[value],duties,ior,consgnee,entry_date,entry_type_id,nfc,ost,liquid_date,report_date,nfcvalue,ostduties FROM public_entries WHERE company_id=$company;";
  print "$loadentriessql\n" if($debug >= 2);
  $dbi->DoSQL($loadentriessql);
  print "done\n\n" if($debug >= 2);

  print "Done loading entries into transfer table.\n\n";
  $xxx = time() - $xxx;
  print "Elapsed time: $xxx sec.\n";

###

  $xxx = time;
  print "--------------------------\n";
  print "Starting to load line items into transfer table.\n";

  my $loadlineitemssql = "INSERT INTO line_items (company_id, id, line_nbr, port_id, filer_id, [value], duties, ior, consgnee, mid, hsusa, coo, spi, entry_date) SELECT company_id, id, line_nbr, port_id, filer_id, value, duties, ior, consgnee, mid, hsusa, coo, spi, entry_date FROM public_line_items WHERE company_id=$company;";
  print "$loadlineitemssql\n" if($debug >= 2);
  $dbi->DoSQL($loadlineitemssql);
  print "done\n\n" if($debug >= 2);

  print "Done loading line items into transfer table.\n\n";
  $xxx = time() - $xxx;
  print "Elapsed time: $xxx sec.\n";


  print("Done populating the transfer file.\n");
  $yyy = time() - $yyy;
  print "Total Elapsed time: $yyy sec.\n";
}

$dbi->Close() if defined($dbi);

