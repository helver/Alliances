#!d:/perl/bin/perl

use DBWrapper::ODBC_DBWrapper;
use Date::Manip;

$| = 1;

my $debug = 0;

my $company = $ARGV[0];

my $dbh = DBWrapper::ODBC_DBWrapper->new("", "", "localhost", "combined");
$dbh->debug($debug);

my $comp = $dbh->Select("id", "companies", "name = '$company'");

$comp_id = $comp->[0]->{id};

if(1) {
  $dbh->DoSQL("create index entries_filer_id_index on entries (filer_id);");
  $dbh->DoSQL("create index entries_ior_index on entries (ior);");
  $dbh->DoSQL("create index entries_cons_index on entries (consgnee);");
  $dbh->DoSQL("create index entries_port_id_index on entries (port_id);");
  $dbh->DoSQL("create index entries_company_id_index on entries (company_id);");
  $dbh->DoSQL("create index entries_entry_type_id_index on entries (entry_type_id);");

  $dbh->DoSQL("create index line_items_coo_index on line_items (coo);");
  $dbh->DoSQL("create index line_items_hsusa_index on line_items (hsusa);");
  $dbh->DoSQL("create index line_items_mid_index on line_items (mid);");
  $dbh->DoSQL("create index line_items_company_id_index on line_items (company_id);");
  $dbh->DoSQL("create index line_items_port_id_index on line_items (port_id);");
  $dbh->DoSQL("create index line_items_filer_id_index on line_items (filer_id);");
}

if(1) {
  my $xxx = time;
  print "--------------------------\n";
  print("Loading line items for entries not in OST.\n");

  my $stm = "insert into line_items (id, line_nbr, company_id, old_port_id, filer_id, value, duties, ior, consgnee, entry_date, mid, hsusa, coo, spi, port_id) select e.id, 1, e.company_id, e.port_id, e.filer_id, e.value, e.duties, e.ior, e.consgnee, e.entry_date, 'N/A', 'N/A', '**', NULL, e.port_id from entries e left outer join line_items l on (e.id = l.id) where l.id is null and e.company_id = $comp_id;";

  print "$stm\n" if ($debug >= 0);

  my $sth = $dbh->{theDB}->prepare($stm);
  my $x = $sth->execute;

  if($dbh->{err}) {
    print $dbh->{err}, "\n";
  }

  $sth->finish;

  print($dbh->getErrorMessage() . "\n") if $dbh->getErrorMessage();
  print("Loaded $x entries into line_items for entries not in OST data.\n");
  $xxx = time() - $xxx;
  print "Elapsed time: $xxx sec.\n";
}


if(1) {
  my $xxx = time;
  print "--------------------------\n";
  print("Load NFC value in place of OST value where OST value is 0 or empty.\n");

  my $stm = "UPDATE entries set value = nfcvalue where company_id = $comp_id and (value is null or value < 0.01) and nfcvalue is not null and nfcvalue > 0;";

  print "$stm\n" if ($debug >= 0);

  my $sth = $dbh->{theDB}->prepare($stm);
  my $x = $sth->execute;

  if($dbh->{err}) {
    print $dbh->{err}, ": $stm: x = $x\n";
  }

  $sth->finish;

  print($dbh->getErrorMessage() . "\n") if $dbh->getErrorMessage();
  print("$x entries loaded NFC values where OST values are empty or 0.\n");
  $xxx = time() - $xxx;
  print "Elapsed time: $xxx sec.\n";
}


if(1) {
  my $xxx = time;
  print "--------------------------\n";
  print("Starting DB Maintenance.\n");
  $dbh->DoSQL("vacuum entries;");
  $dbh->DoSQL("vacuum line_items;");

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

  $dbh->DoSQL("create index entries_filer_id_index on entries (filer_id);");
  $dbh->DoSQL("create index entries_ior_index on entries (ior);");
  $dbh->DoSQL("create index entries_cons_index on entries (consgnee);");
  $dbh->DoSQL("create index entries_port_id_index on entries (port_id);");
  $dbh->DoSQL("create index entries_company_id_index on entries (company_id);");
  $dbh->DoSQL("create index entries_entry_type_id_index on entries (entry_type_id);");

  $dbh->DoSQL("create index line_items_coo_index on line_items (coo);");
  $dbh->DoSQL("create index line_items_hsusa_index on line_items (hsusa);");
  $dbh->DoSQL("create index line_items_mid_index on line_items (mid);");
  $dbh->DoSQL("create index line_items_company_id_index on line_items (company_id);");
  $dbh->DoSQL("create index line_items_port_id_index on line_items (port_id);");
  $dbh->DoSQL("create index line_items_filer_id_index on line_items (filer_id);");

  print("Finishing DB Maintenance.\n");
  $xxx = time() - $xxx;
  print "Elapsed time: $xxx sec.\n";
}

$dbh->Close() if defined($dbh);
