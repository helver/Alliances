package Reports::LoadData;

use strict;
use vars qw ($VERSION @ISA @EXPORT);

use Reports::Reports;

$VERSION = 1.0;
@ISA = ("Reports::Reports");
@EXPORT = ();

sub new
{
  my ($class, $name, $fields, $debug, $dbh, $comp) = @_;

  my $this = $class->SUPER::new($name, $fields, $debug);

  $this->{dbh} = $dbh;
  $this->{comp} = $comp;

  return $this;
}



sub collect
{
  my ($this, $record) = @_;

  if($this->{debug} >= 4) {
    foreach my $x (keys %{$record}) {
      print "$x -- " . $record->{$x} . "\n";
    }
  }

  $record->{"liqdate"} =~ s|(\d\d)(\d\d)(\d\d)|$1/$2/$3|;
  $record->{"filercode"} =~ s/ /0/g;
  $record->{"ior"} =~ s/^0+//;
  $record->{"cons"} =~ s/^0+//;

  if(length($record->{"ior"}) <= 10) {
    $record->{"ior"} .= "00";
  }

  while(length($record->{"ior"}) < 12) {
    $record->{"ior"} = "0" . $record->{"ior"};
  }

  if(length($record->{"cons"}) <= 10) {
    $record->{"cons"} .= "00";
  }

  while(length($record->{"cons"}) < 12) {
    $record->{"cons"} = "0" . $record->{"cons"};
  }


  $record->{"portcode"} = $record->{"portcode"} % 10000;

  my %vals = (
    "id" => $record->{"filercode"} . "-" . $record->{"num"},
    "company_id" => $this->{comp},
    "port_id" => (($record->{"portcode"} !~ /^(( *)|0)$/) ? $record->{portcode} : "-1"),
    "filer_id" => "'" . ($record->{"filercode"} ne "" ? $record->{"filercode"} : "") . "'",
    "value" => ($record->{"val"} == 0 ? "0.00" : int($record->{"val"} * 100) / 100),
    "nfcvalue" => ($record->{"val"} == 0 ? "0.00" : int($record->{"val"} * 100) / 100),
    "duties" => ($record->{"duty"} == 0 ? "0.00" : int($record->{"duty"} * 100) / 100),
    "ior" => "'" . ($record->{"role"} eq "IMPORTER" ? uc($record->{"ior"}) : "N/A") . "'",
    "consgnee" => "'" . uc($record->{"ior"}) . "'",
    "entry_date" => "'" . $record->{"entdate"} . "'",
    "liquid_date" => ($record->{"liqdate"} eq "" ? "NULL" : "'" . $record->{"liqdate"} . "'"),
    "entry_type_id" => (($record->{"entrytypecode"} !~ /^ *$/) ? $record->{"entrytypecode"} : "-1"),
    "nfc" => "'t'",
    "report_date" => "'" . $record->{"report_date"} . "'",
  );

  foreach my $x (keys %vals) {
    delete $vals{$x} unless ($vals{$x} ne "");
  }

  my $x;
  my $sql = "SELECT ior FROM entries WHERE id = '" . $vals{id} . "';";
  print "$sql\n" if($this->{debug} >= 4);
  $x = $this->{dbh}->DoSQL($sql) unless exists($this->{ostnums}{$vals{id}});

  my $ret;

  $this->{dbh}->debug(5) if($this->{debug} >= 4);

  if(exists($this->{ostnums}{$vals{id}}) || defined $x->[0]) {
    delete $vals{"value"};
    delete $vals{"ior"} if($vals{"ior"} eq "'N/A'" && $x->[0]->{"ior"} ne '');

    $vals{"id"} = "'" . $vals{"id"} . "'";

    my ($sdata,$sqry);

    foreach my $k (keys %vals) {
      $sdata .= ($sdata eq "" ? "" : ",") . "$k = " . $vals{$k};
    }

    # Assemble the rest of the statement.
    $sqry = "UPDATE entries SET " . $sdata . " WHERE id = " . $vals{id} . ";";
    print "$sqry\n" if($this->{debug} >= 4);

    $this->{dbh}->DoSQL($sqry);
  } else {
    my ($sdata,$scols,$sqry);

    $vals{"id"} = "'" . $vals{"id"} . "'";

    foreach my $col (keys %vals) {
      $sdata .= ($sdata eq "" ? "" : ", ") . $vals{$col};
      $scols .= ($scols eq "" ? "" : ", ") . $col;
    }

    # Build the rest of the SQL statement.
    $sqry .= "INSERT INTO entries (" . $scols . ") VALUES (" . $sdata . ")";
    print "$sqry\n" if($this->{debug} >= 4);

    $this->{dbh}->DoSQL($sqry);
  }

  print $this->{dbh}->getErrorMessage() . "\n" if $ret <= -1;

  exit() if($this->{debug} >= 4);
}



1;
