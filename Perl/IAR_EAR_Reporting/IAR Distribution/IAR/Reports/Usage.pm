package Reports::Usage;

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

  $this->{displayFunction} = "Usage";

  $this->{sumlist} = {
     $fields->[0] => { "collect" => "count",
                    "order" => 0,
                  },
     "entries" => { "collect" => "sum",
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
  };

  $this->{sorting} = {
    "year" => "descending",
    "ior" => "maxentries",
    "portcode" => "maxentries",
    "filercode" => "maxentries",
  };

  return $this;
}



sub collect
{
  my ($this, $record) = @_;

  my $insert_pos = $this->{data};

  my ($store, @groups) = @{$this->{fields}};

  if($store =~ /(.*)code$/) {
    $this->{map}{$store}{$record->{$store}} = $record->{$1};
    print "Mapping " . $record->{$store} . " to " . $this->{map}{$store}{$record->{$store}} . "\n" if($this->{debug} >= 5);
  }

  foreach my $group (@groups) {
    $this->{data}{$group} = {} unless exists $this->{data}{$group};
    $insert_pos = $this->{data}{$group};

    foreach my $subby (split /,/, $group) {
      print "subby - $subby - " . $record->{$subby} . "\n" if($this->{debug} >= 5);

      if($subby =~ /(.*)code$/) {
        $this->{map}{$subby}{$record->{$subby}} = $record->{$1};
        print "Mapping " . $record->{$subby} . " to " . $this->{map}{$subby}{$record->{$subby}} . "\n" if($this->{debug} >= 5);
      }

      $insert_pos->{$record->{$subby}} = {} unless exists $insert_pos->{$record->{$subby}};
      $insert_pos = $insert_pos->{$record->{$subby}};
    }

    $insert_pos->{$record->{$store}}{entries}++;
    $insert_pos->{$record->{$store}}{value} += $record->{val};
    $insert_pos->{$record->{$store}}{duties} += $record->{duty};
    $insert_pos->{$record->{$store}}{taxes} += $record->{tax};
    $insert_pos->{$record->{$store}}{other} += $record->{other};
    $insert_pos->{$record->{$store}}{add} += $record->{add};

    my $label = $store;
    $label =~ s/code$//;
    $insert_pos->{$record->{$store}}{$label} = $record->{$label};

    if($this->{debug} >= 10) {
      foreach my $x (keys %{$insert_pos}) {
        print "$x -- " . $insert_pos->{$x} . "\n";
      }
    }
  }

}



1;
