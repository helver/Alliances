package Reports::OST;

use strict;
use vars qw ($VERSION @ISA @EXPORT);

use Reports::Reports;
#use DBI::W32ODBC;
use DBWrapper::ODBC_DBWrapper;
use Spreadsheet::WriteExcel::Big;

$VERSION = 1.0;
@ISA = ("Reports::Reports");
@EXPORT = ();

sub new
{
  my ($class, $name, $fields, $debug, $client) = @_;

  my ($query, $display, @fields) = @{$fields};
  $fields = \@fields;

  print "Query: $query, Display: $display, Fields: $fields\n" if ($debug >= 3);

  my $this = $class->SUPER::new($name, $fields, $debug);

  $this->{displayFunction} = $display;
  $this->{query} = $query;
  $this->{client} = $client;

  #$this->{dbh} = DBI->connect("DSN=foia;");
  $this->{dbh} = DBWrapper::ODBC_DBWrapper->new("", "", "", "foia");
  $this->{dbh}->debug($this->{debug});

  return $this;
}




sub retrieveData
{
  my ($this) = @_;

  my $workbook = Spreadsheet::WriteExcel::Big->new("output/" . $this->{client} . "/" . $this->{name} . ".xls");
  #print "workbook: $workbook\n";

  #my $qry = "select * from " . $this->{query};
  my $res = $this->{dbh}->Select("*", $this->{query});

  my $year = -1;
  my $rowcount;
  my $worksheet;

  print $this->{name} . "\n";

  for(my $i = 0; defined $res->[$i]; $i++) {
    my $row = $res->[$i];
    #print "year: $year -- row{year}: " . $row->{year} . "\n" if ($this->{debug} >= 3);

    if($year ne $row->{year}) {
      $year = $row->{year};

      $worksheet = $workbook->addworksheet($year);

      $worksheet->write(1,1, $this->{name} . " for $year");

      $rowcount = 2;

      my $colcount = 0;
      foreach my $sum (@{$this->{dbh}->{lastColHeaders}}) {
        $worksheet->write($rowcount, $colcount++, $this->{labels}{$sum});
      }

      $rowcount++;
    }

    my $colcount = 0;
    foreach my $sum (@{$this->{dbh}->{lastColHeaders}}) {
      $worksheet->write($rowcount, $colcount++, $row->{$sum});
    }

    $rowcount++;

  }
  #print "end of loop\n";

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
