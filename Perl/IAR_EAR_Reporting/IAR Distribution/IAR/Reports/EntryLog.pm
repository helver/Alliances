package Reports::EntryLog;

use strict;
use vars qw ($VERSION @ISA @EXPORT);

use Reports::Reports;

$VERSION = 1.0;
@ISA = ("Reports::Reports");
@EXPORT = ();

sub new
{
  my ($class, $name, $fields, $debug) = @_;

  my $this = $class->SUPER::new($name, $fields, $debug);

  $this->{sumlist} = {"num" => { "collect" => "unique",
                                 "order" => 1,
                                 "width" => 10,
                                   },
                      "entry_date" => { "collect" => "unique",
                                        "order" => 2,
                                        "width" => 8,
                                   },
                      "port" => { "collect" => "unique",
                                  "order" => 3,
                                  "width" => 20,
                                   },
                      "filer" => { "collect" => "unique",
                                   "order" => 4,
                                   "width" => 20,
                                   },
                      "value" => { "collect" => "unique",
                                   "order" => 5,
                                   "width" => 10,
                                   },
                      "duties" => { "collect" => "unique",
                                    "order" => 6,
                                    "width" => 10,
                                   },
                      "estduty" => { "collect" => "unique",
                                     "order" => 7,
                                     "width" => 10,
                                   },
                      "taxes" => { "collect" => "unique",
                                   "order" => 8,
                                   "width" => 10,
                                   },
                      "esttax" => { "collect" => "unique",
                                    "order" => 9,
                                    "width" => 10,
                                   },
                      "refund" => { "collect" => "unique",
                                    "order" => 10,
                                    "width" => 10,
                                   },
                      "other" => { "collect" => "sum",
                                   "order" => 11,
                                   "width" => 10,
                                   },
                      "add" => { "collect" => "unique",
                                 "order" => 12,
                                 "width" => 10,
                                   },
                      "entrytype" => { "collect" => "unique",
                                       "order" => 13,
                                       "width" => 10,
                                   },
                      "liquidation_date" => { "collect" => "unique",
                                              "order" => 14,
                                              "width" => 8,
                                   },
                      "liquidation_type" => { "collect" => "unique",
                                              "order" => 15,
                                              "width" => 10,
                                   },
                      "source" => { "collect" => "unique",
                                    "order" => 16,
                                    "width" => 8,
                                   },
                      "surety" => { "collect" => "unique",
                                    "order" => 17,
                                    "width" => 4,
                                   },
                     };

  $this->{displayFunction} = "EntryLog";

  return $this;
}



sub collect
{
  my ($this, $record) = @_;

  my $insert_pos = $this->{data};

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

  $insert_pos->{$record->{num}}{num} = $record->{filercode} . "-" . $record->{num} unless defined $insert_pos->{$record->{num}}{num};
  $insert_pos->{$record->{num}}{entry_date} = $record->{entdate} unless defined $insert_pos->{$record->{num}}{entdate};
  $insert_pos->{$record->{num}}{port} = $record->{portcode} unless defined $insert_pos->{$record->{num}}{port};
  $insert_pos->{$record->{num}}{filer} = $record->{filercode} unless defined $insert_pos->{$record->{num}}{filer};
  $insert_pos->{$record->{num}}{entrytype} = $record->{entrytypecode} unless defined $insert_pos->{$record->{num}}{entrytype};
  $insert_pos->{$record->{num}}{liquidation_date} = $record->{liqdate} unless defined $insert_pos->{$record->{num}}{liqdate};
  $insert_pos->{$record->{num}}{liquidation_type} = $record->{liqtyp} unless defined $insert_pos->{$record->{num}}{liqtyp};
  $insert_pos->{$record->{num}}{refund} = $record->{rfnd} unless defined $insert_pos->{$record->{num}}{rfnd};
  $insert_pos->{$record->{num}}{value} = $record->{val} unless defined $insert_pos->{$record->{num}}{val};
  $insert_pos->{$record->{num}}{duties} = $record->{duty} unless defined $insert_pos->{$record->{num}}{duty};
  $insert_pos->{$record->{num}}{add} = $record->{add} unless defined $insert_pos->{$record->{num}}{add};
  $insert_pos->{$record->{num}}{taxes} = $record->{tax} unless defined $insert_pos->{$record->{num}}{tax};
  $insert_pos->{$record->{num}}{other} = $record->{other} unless defined $insert_pos->{$record->{num}}{other};
  $insert_pos->{$record->{num}}{source} = $record->{source} unless defined $insert_pos->{$record->{num}}{source};
  $insert_pos->{$record->{num}}{surety} = $record->{surety} unless defined $insert_pos->{$record->{num}}{surety};
  $insert_pos->{$record->{num}}{esttax} = $record->{esttax} unless defined $insert_pos->{$record->{num}}{esttax};
  $insert_pos->{$record->{num}}{estduty} = $record->{estduty} unless defined $insert_pos->{$record->{num}}{estduty};

  if($this->{debug} >= 10) {
    foreach my $x (keys %{$insert_pos->{$record->{num}}}) {
      print $record->{year} . " $x -- " . $insert_pos->{$record->{num}}{$x} . "\n";
    }
  }

}



1;
