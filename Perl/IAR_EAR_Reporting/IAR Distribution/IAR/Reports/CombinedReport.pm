package Reports::CombinedReport;

use strict;
use vars qw ($VERSION @ISA @EXPORT);

use Reports::Reports;
use DBWrapper::PG_DBWrapper;
use Spreadsheet::WriteExcel::Big;

$VERSION = 1.0;
@ISA = ("Reports::Reports");
@EXPORT = ();

sub new
{
  my ($class, $name, $fields, $debug, $client) = @_;

  #$debug = 10;

  my ($query, $display, $bywhat, @fields) = @{$fields};
  $fields = \@fields;

  print "Query: $query, Display: $display, Fields: $fields\n" if ($debug >= 3);

  my $this = $class->SUPER::new($name, $fields, $debug);

  $this->{displayFunction} = $display;
  $this->{query} = $query;
  $this->{client} = $client;
  $this->{bywhat} = $bywhat;

  $this->{dbh} = DBWrapper::PG_DBWrapper->new("iar", "", "cache", "iar");

  return $this;
}




sub retrieveData
{
  my ($this) = @_;

  my $workbook = Spreadsheet::WriteExcel::Big->new("output/" . $this->{client} . "/" . $this->{name} . ".xls");
  #print "workbook: $workbook\n";

  my $sheet_val = -1;
  my $rowcount;
  my $worksheet;
  my $totalsheet = $workbook->addworksheet("Totals");
  my $totalrow = -1;

  $totalrow = 2;
  my $fields = join(",", @{$this->{fields}});
  my @fields = split /,/, $fields;

  my $sql =
    "SELECT " . join(",", @{$this->{fields}}) .
    " FROM " . $this->{query} . ", companies WHERE " . $this->{query} . ".company_id = companies.id and companies.name = '" . $this->{client} . "'";

  print "$sql\n" if($this->{debug} >= 3);

  my $sth = $this->{dbh}->{theDB}->prepare($sql);
  if($this->{dbh}->{theDB}->{err}) {
    print "Error preparing: \n" . $this->{dbh}->{theDB}->{errstr} . "\n";
    exit();
  }

  $sth->execute;

  if($this->{dbh}->{theDB}->{err}) {
    $sth->finish;
    print "Error executing: \n" . $this->{dbh}->{theDB}->{errstr} . "\n";
    exit();
  }

  my $colcount = 0;
  foreach my $sum (@fields) {
    $totalsheet->write($totalrow, $colcount++, $this->{labels}{$sum});
  }

  $totalrow++;
  my $count = 0;

  while(my $row = $sth->fetchrow_hashref) {
    # Ensure that each column in the row is identified by at least
    # the lowercase column name - if column names were provided.
    for(my $i = 0; $i < $sth->{NUM_OF_FIELDS}; $i++) {
      $row->{lc($sth->{NAME}->[$i])} = $row->{$sth->{NAME}->[$i]};
    }

    print "Done with: $count\r" if ($count % 100 == 0);
    $count++;

    if($this->{bywhat} ne "null" && $sheet_val ne $row->{$this->{bywhat}}) {
      $sheet_val = $row->{$this->{bywhat}};
      #print "Adding new sheet for $sheet_val\n";

      $worksheet = $workbook->addworksheet($sheet_val);
      #print "worksheet - $worksheet\n";

      my $x = $worksheet->write(1,1, $this->{name} . " for " . $this->{bywhat} . " $sheet_val");
      #print "x - $x\n";

      $rowcount = 2;

      my $colcount = 0;
      foreach my $sum (@fields) {
        $worksheet->write($rowcount, $colcount++, $this->{labels}{$sum});
      }

      $rowcount++;
    }

    #print "Writing out row $count - num = " . $row->{"num"} . "\n";
    my $colcount = 0;
    foreach my $sum (@fields) {
      #print "Writing out $sum -- " . $row->{$sum} . "\n";
      $worksheet->write($rowcount, $colcount, $row->{$sum}) if($this->{bywhat} ne "null");
      $totalsheet->write($totalrow, $colcount++, $row->{$sum});
    }

    $rowcount++;
    $totalrow++;

    last if $count > 15000;
  }
  #print "end of loop\n";
  $sth->finish;
  $workbook->close();
  $this->{dbh}->Close();
}


sub __insertData
{
  my ($this, $data, $location) = @_;

  push @{$location}, $data;

  if($this->{debug} >= 10) {
    foreach my $x (keys %{$location}) {
      print $data->{year} . " $x -- " . $location->{$x} . "\n";
    }
  }
}


1;
