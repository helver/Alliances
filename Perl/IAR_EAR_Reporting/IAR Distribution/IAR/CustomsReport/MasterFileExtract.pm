package CustomsReport::MasterFileExtract;

use vars qw($VERSION @ISA @EXPORT);

use CustomsReport::CustomsReport;

$VERSION = 1;
@ISA = ('CustomsReport::CustomsReport');
@EXPORT = ();


sub new
{
  my ($class, $debug) = @_;

  my $this = $class->SUPER::new($debug);
  $this->{dataSet} = "masterfile";
  $this->{bulkKey} = "role,ior,year";

  $this->{seenImporter} = {};

  $this->{data_definition} = {
  "port" => { name=> "port",
              label => "Port",
              columnHeader => "PORT",
              startAtColumn => 3,
              fieldLength => 18,
            },
  "filer" => { name => "filer",
              label => "Filer",
              columnHeader => "FILER CODE",
              startAtColumn => 22,
              fieldLength => 3,
            },
  "num" => { name => "num",
              label => "Entry ID",
              columnHeader => "ENTRY NUMBER",
              startAtColumn => 25,
              fieldLength => 8,
            },
  "entdate" => { name => "entdate",
              label => "Entry Date",
              columnHeader => "ENTRY DATE",
              startAtColumn => 39,
              fieldLength => 8,
            },
  "entrytype" => { name => "entrytype",
              label => "Entry Type",
              columnHeader => "ENTRY TYPE",
              startAtColumn => 49,
              fieldLength => 4,
            },
  "surety" => { name => "surety",
              label => "Surety",
              columnHeader => "SURETY",
              startAtColumn => 55,
              fieldLength => 3,
            },
  "estduty" => { name => "estduty",
              label => "Estimated Duty",
              columnHeader => "EST. DUTY",
              startAtColumn => 62,
              fieldLength => 9,
              format => "money",
            },
  "esttax" => { name => "esttax",
              label => "Estimated Tax",
              columnHeader => "EST. TAX",
              startAtColumn => 73,
              fieldLength => 12,
              format => "money",
            },
  "duty" => { name => "duty",
              label => "Duty Paid",
              columnHeader => "DUTY PAID",
              startAtColumn => 87,
              fieldLength => 12,
              format => "money",
            },
  "tax" => { name => "tax",
              label => "Tax Paid",
              columnHeader => "TAX PAID",
              startAtColumn => 101,
              fieldLength => 12,
              format => "money",
            },
  "other" => { name => "other",
              label => "Other Fees Paid",
              columnHeader => "OTHER FEES",
              startAtColumn => 115,
              fieldLength => 12,
              format => "money",
            },
  "entries" => { name => "entries",
               label => "Number of Customs Entries",
               columnHeader => "NUMBER OF ENTRIES",
               format => "int",
               summaryOrder => 2,
               collect => "count",
             },
  "year" => { name => "year",
               label => "Year",
               columnHeader => "YEAR",
               format => "int",
               summaryOrder => -1,
               collect => "unique",
             },

  };

  return $this;
}


sub parse
{
  my ($this, $fh, $reports) = @_;

  my ($state, $role, $ior, $year, $report_date) = (0);

  my $count = 0;

  my $last_record;

  while(<$fh>) {
    #last if($count++ > 1000);

    #last if (/^0-/);

    if($this->{debug} >= 10) {
      print "$state\n";
      print "$_\n";
    }

    if(m|RUN DATE (\d\d/\d\d/\d\d)|) {
      $report_date = $1;

      next;
    }

    if(/^0-/) {
      $state = 4;
      next;
    }

    if(/^1/) {
      $state = 1;

      if($this->{debug} >= 5) {
        print "Found report page header.\n";
      }
      next;
    }

    if($state == 1 && /BY( ULTIMATE)? (\w+)/) {
      $role = $2;

      if($this->{debug} >= 5) {
        print "Found Role - $role\n";
      }
      next;
    }

    if($state == 1 && /^0\s+([A-Z0-9\-]+)/) {
      $ior = $1;

      $state = 2;

      if($this->{debug} >= 5) {
        print "Found IOR - $ior\n";
      }

      next;
    }

    if(/UNLIQUIDATED FORMAL ENTRIES/) {
      $state = 3;

      if($this->{debug} >= 5) {
        print "Beginning Data\n";
      }

      next;
    }

    if($state == 3 && /ADD\/CVD PAID:\s+([\d\.]+)/) {
      ($last_record->{add} = $1) =~ s/[,\s]//g if $last_record;
      next;
    }

    if($state == 3 && /^\s+/) {
      if($last_record) {
        if (!exists($this->{seenImporter}{$last_record->{num}})) {
          $this->{seenImporter}{$last_record->{num}} = 1;

          foreach my $report (@{$reports}) {
            if($this->{debug} >= 10) {
              foreach my $key (keys %{$last_record}) {
                print "Key $key -- ". $last_record->{$key} . "\n";
              }
            }
            $report->collect($last_record);
          }
        }
      }

      my %record = ("role" => $role, "ior" => $ior, "year" => $year, "add" => "0.00", "source" => "unliquid", "report_date" => $report_date);

      chomp;

      foreach my $field (keys %{$this->{data_definition}}) {
        next unless(exists $this->{data_definition}{$field}{startAtColumn});

        $field = $this->{data_definition}{$field};

        $record{$field->{name}} = substr($_, $field->{startAtColumn} - 1, $field->{fieldLength});
        $record{$field->{name}} =~ s/\s+$//;
        $record{$field->{name}} =~ s/[,\s]//g if ($field->{format} eq "money");
        print $field->{label} . ": " . $record{$field->{name}} . "\n" if ($this->{debug} >= 10);
      }

      $record{num} =~ s/(\d)$/-$1/;

      # Extract Year
      my $year = $record{"entdate"};
      $record{"entdate"} =~ s/\-/\//g;

      my($month, undef, $year) = split /\-/, $year;

      if(0) {
        $month += 3;
        $year += int($month/12);
      }

      $year = "0$year" if($year < 10);
      $year =~ s/^0(0\d)/$1/;
      $record{year} = ($year < 50 ? "20$year" : "19$year");


      while($record{ior} !~ /^\d{3}\-\d{7}\S{2}/) {
        $record{ior} = "0" . $record{ior};
        last if length($record{ior} > 13);
      }

      ($record{portcode}, $record{port}) = $this->lookup("port", $record{port});
      $record{portcode} = -1 if($record{portcode} eq "");

      while(length($record{filer}) < 3) {
        $record{filer} = "0" . $record{filer};
      }

      ($record{filercode}, $record{filer}) = $this->lookup("filer", $record{filer});
      $record{filercode} = $record{filer} unless($record{filercode} ne "");

      while(length($record{filercode}) < 3) {
        $record{filercode} = "0" . $record{filercode};
      }

      ($record{surety}, $record{suretycode}) = $this->lookup("surety", $record{surety});

      $last_record = \%record;

      next;
    }
  }

  if($last_record) {
    if (!exists($this->{seenImporter}{$last_record->{num}})) {
      $this->{seenImporter}{$last_record->{num}} = 1;

      foreach my $report (@{$reports}) {
        if($this->{debug} >= 10) {
          foreach my $key (keys %{$last_record}) {
            print "Key $key -- ". $last_record->{$key} . "\n";
          }
        }
        $report->collect($last_record);
      }
    }
  }
}



1;
