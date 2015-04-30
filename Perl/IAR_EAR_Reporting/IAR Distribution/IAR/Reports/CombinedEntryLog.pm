package Reports::CombinedEntryLog;

use strict;
use vars qw ($VERSION @ISA @EXPORT);

use Reports::Reports;
use DBWrapper::ODBC_DBWrapper;

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

  $this->{sumlist} = {"num" => { "collect" => "unique",
                                 "order" => 1,
                                 "width" => 10,
                                   },
                      "entry_date" => { "collect" => "unique",
                                        "order" => 2,
                                        "width" => 8,
                                   },
                      "value" => { "collect" => "unique",
                                   "order" => 3,
                                   "width" => 10,
                                   },
                      "entrytype" => { "collect" => "unique",
                                       "order" => 4,
                                       "width" => 10,
                                   },
                      "ior" => { "collect" => "unique",
                                       "order" => 5,
                                       "width" => 10,
                                   },
                      "cons" => { "collect" => "unique",
                                       "order" => 6,
                                       "width" => 10,
                                   },
                      "source" => { "collect" => "unique",
                                       "order" => 7,
                                       "width" => 4,
                                   },
                     };

  $this->{displayFunction} = $display;
  $this->{query} = $query;
  $this->{client} = $client;

  $this->{dbh} = DBWrapper::ODBC_DBWrapper->new("", "", "", "foia");
  $this->{dbh}->debug($this->{debug});

  return $this;
}


sub retrieveData
{
  my ($this) = @_;

  my $res = $this->{dbh}->Select("*", $this->{query});

  my $year = -1;
  my $rowcount;
  my $worksheet;

  for(my $i = 0; defined $res->[$i]; $i++) {
    my $row = $res->[$i];
    print "EntryNum: " . $row->{num} . "\n" if($this->{debug} >= 4);

    my $insert_pos = $this->{data};

    foreach my $constraint (@{$this->{fields}}) {
      $insert_pos->{$row->{$constraint}} = {} unless exists $insert_pos->{$row->{$constraint}};
      $insert_pos = $insert_pos->{$row->{$constraint}};
    }

    if(exists $insert_pos->{$row->{num}}) {
      #print("Replacing existing record:<br>\n");
      #foreach my $x (keys %{$insert_pos->{$row->{num}}}) {
      #  print("$x: " . $insert_pos->{$row->{num}}{$x} . "\n");
      #}
      #exit();
    } else {
      $insert_pos->{$row->{num}} = {};
    }

    foreach my $sum (@{$this->{dbh}->{lastColHeaders}}) {
      #print "$sum: " . $row->{$sum} . "\n";
      $row->{$sum} =~ s|(\d{4})-(\d{2})-(\d{2}).*|$2/$3/$1| if($sum eq "entrydate");
      $insert_pos->{$row->{num}}{($sum eq "entrydate" ? "entry_date" : lc($sum))} = $row->{$sum};
    }

    if($insert_pos->{$row->{num}}{source} eq "NFC") {
      $insert_pos->{$row->{num}}{source} = "BOTH";
    } else {
      $insert_pos->{$row->{num}}{source} = "OST";
    }

    #print "--------------\n";
    #foreach my $x (keys %{$insert_pos->{$row->{num}}}) {
    #  print "$x: " . $insert_pos->{$row->{num}}{$x} . "\n";
    #}
    #exit;

  }
  $this->{dbh}->Close();
}


sub collect
{
  my ($this, $record) = @_;

  my $insert_pos = $this->{data};

  $record->{num} = $record->{filercode} . "-" . $record->{num};

  foreach my $constraint (@{$this->{fields}}) {
    $insert_pos->{$record->{$constraint}} = {} unless exists $insert_pos->{$record->{$constraint}};
    $insert_pos = $insert_pos->{$record->{$constraint}};
  }

  $insert_pos->{$record->{num}} = {} unless exists $insert_pos->{$record->{entry_number}};

  if($this->{debug} >= 10) {
    foreach my $x (keys %{$record}) {
      print $record->{year} . " $x -- " . $record->{$x} . "\n";
    }
    print "------------------\n";
  }

  $insert_pos->{$record->{num}}{num} = $record->{num} unless defined $insert_pos->{$record->{num}}{num};
  $insert_pos->{$record->{num}}{entry_date} = $record->{entdate} unless defined $insert_pos->{$record->{num}}{entdate};
  $insert_pos->{$record->{num}}{port} = $record->{portcode} unless defined $insert_pos->{$record->{num}}{port};
  $insert_pos->{$record->{num}}{filer} = $record->{filercode} unless defined $insert_pos->{$record->{num}}{filer};
  $insert_pos->{$record->{num}}{entrytype} = $record->{entrytypecode} unless defined $insert_pos->{$record->{num}}{entrytype};
  $insert_pos->{$record->{num}}{value} = $record->{val} unless defined $insert_pos->{$record->{num}}{val};
  $insert_pos->{$record->{num}}{cons} = $record->{ior} unless defined $insert_pos->{$record->{num}}{cons};
  if($record->{role} eq "IMPORTER") {
    $insert_pos->{$record->{num}}{ior} = $record->{ior};
  } else {
    $insert_pos->{$record->{num}}{ior} = "N/A";
  }

  $insert_pos->{$record->{num}}{source} = "NFC";

  if($this->{debug} >= 10) {
    foreach my $x (keys %{$insert_pos->{$record->{num}}}) {
      print $record->{year} . " $x -- " . $insert_pos->{$record->{num}}{$x} . "\n";
    }
  }

}



1;
