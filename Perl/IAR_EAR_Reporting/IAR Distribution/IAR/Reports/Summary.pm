package Reports::Summary;

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

  $this->{sumlist} = {"entries" => { "collect" => "sum",
                                     "order" => 1,
                                   },
                      "value" => { "collect" => "sum",
                                     "order" => 2,
                                   },
                      "duties" => { "collect" => "sum",
                                     "order" => 3,
                                   },
                      "taxes" => { "collect" => "sum",
                                     "order" => 4,
                                   },
                      "other" => { "collect" => "sum",
                                     "order" => 5,
                                   },
                      "add" => { "collect" => "sum",
                                     "order" => 6,
                                   },
                      "ports" => { "collect" => "count",
                                     "order" => 7,
                                   },
                      "brokers" => { "collect" => "count",
                                     "order" => 8,
                                   },
                     };

  $this->{displayFunction} = "Summary";

  return $this;
}



sub collect
{
  my ($this, $record) = @_;

  my $insert_pos = $this->{data};

  foreach my $constraint (@{$this->{fields}}) {
    print "$constraint = " . $record->{$constraint} . "\n" if($this->{debug} >= 5);

    $insert_pos->{$record->{$constraint}} = {} unless exists $insert_pos->{$record->{$constraint}};
    $insert_pos = $insert_pos->{$record->{$constraint}};
  }

  $insert_pos->{total_entries}++;
  $insert_pos->{"entries_" . lc($record->{role}) . "_" . lc($record->{source})}++;

  $insert_pos->{total_value} += $record->{val};
  $insert_pos->{"value_" . lc($record->{role}) . "_" . lc($record->{source})} += $record->{val};

  $insert_pos->{total_duties} += $record->{duty};
  $insert_pos->{"duties_" . lc($record->{role}) . "_" . lc($record->{source})} += $record->{duty};

  $insert_pos->{total_taxes} += $record->{tax};
  $insert_pos->{"taxes_" . lc($record->{role}) . "_" . lc($record->{source})} += $record->{tax};

  $insert_pos->{total_other} += $record->{other};
  $insert_pos->{"other_" . lc($record->{role}) . "_" . lc($record->{source})} += $record->{other};

  $insert_pos->{total_add} += $record->{add};
  $insert_pos->{"add_" . lc($record->{role}) . "_" . lc($record->{source})} += $record->{add};



  $insert_pos->{total_ports}{$record->{portcode}} = 1;
  $insert_pos->{"ports_" . lc($record->{role}) . "_" . lc($record->{source})}{$record->{portcode}} = 1;

  $insert_pos->{total_brokers}{$record->{filercode}} = 1;
  $insert_pos->{"brokers_" . lc($record->{role}) . "_" . lc($record->{source})}{$record->{filercode}} = 1;

  if($this->{debug} >= 10) {
    foreach my $x (keys %{$insert_pos}) {
      print $record->{year} . " $x -- " . $insert_pos->{$x} . "\n";
    }
  }

}



1;
