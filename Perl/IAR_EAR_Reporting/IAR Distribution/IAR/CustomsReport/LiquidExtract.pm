package CustomsReport::LiquidExtract;

use vars qw($VERSION @ISA @EXPORT);

use CustomsReport::CustomsReport;

$VERSION = 1;
@ISA = ('CustomsReport::CustomsReport');
@EXPORT = ();


sub new
{
  my ($class, $debug) = @_;

  my $this = $class->SUPER::new($debug);
  $this->{dataSet} = "liquid";
  $this->{bulkKey} = "role,ior,year";

  $this->{data_definition} = {
  "filer" => { name=> "filer",
               label => "Broker ID",
               columnHeader => "FILER CODE",
               startAtColumn => 2,
               fieldLength => 3,
               summaryOrder => -1,
               collect => "unique",
             },
  "num" => { name => "num",
               label => "Entry ID",
               columnHeader => "ENTRY NUMBER",
               startAtColumn => 6,
               fieldLength => 8,
               summaryOrder => -1,
               collect => "unique",
             },
  "port" => { name => "port",
               label => "Port ID",
               columnHeader => "REGION PORT DISTRICT",
               startAtColumn => 17,
               fieldLength => 4,
               summaryOrder => -1,
               collect => "count",
             },
  "entdate" => { name => "entdate",
               label => "Entry Date",
               columnHeader => "ENTRY DATE",
               startAtColumn => 22,
               fieldLength => 6,
               summaryOrder => -1,
               collect => "unique",
             },
  "entrytype" => { name => "entrytype",
               label => "Entry Type",
               columnHeader => "ENTRY TYPE",
               startAtColumn => 29,
               fieldLength => 2,
               summaryOrder => -1,
               collect => "count",
             },
  "liqdate" => { name => "liqdate",
               label => "Liquid Date",
               columnHeader => "LIQUIDATION DATE",
               startAtColumn => 32,
               fieldLength => 6,
               summaryOrder => -1,
               collect => "unique",
             },
  "liqtyp" => { name => "liqtyp",
               label => "Liquid Type",
               columnHeader => "LIQUIDATION TYPE",
               startAtColumn => 39,
               fieldLength => 6,
               summaryOrder => -1,
               collect => "count",
             },
  "recntyp" => { name => "recntyp",
               label => "RECN Type",
               columnHeader => "RECN TYPE",
               startAtColumn => 46,
               fieldLength => 4,
               summaryOrder => -1,
               collect => "count",
               skip => 1,
             },
  "rfnd" => { name => "rfnd",
               label => "Refund Amt",
               columnHeader => "BILL/REFUND AMOUNT",
               startAtColumn => 52,
               fieldLength => 12,
               format => "money",
               summaryOrder => 3,
               collect => "sum",
             },
  "val" => { name => "val",
               label => "Entered Value",
               columnHeader => "ENTER VALUE",
               startAtColumn => 65,
               fieldLength => 13,
               format => "money",
               summaryOrder => 4,
               collect => "sum",
             },
  "duty" => { name => "duty",
               label => "Duty Paid",
               columnHeader => "DUTY PAID",
               startAtColumn => 80,
               fieldLength => 12,
               format => "money",
               summaryOrder => 5,
               collect => "sum",
             },
  "add" => { name => "add",
               label => "ADD/CVD Paid",
               columnHeader => "ADD/CVD PAID",
               startAtColumn => 94,
               fieldLength => 12,
               format => "money",
               summaryOrder => 6,
               collect => "sum",
             },
  "tax" => { name => "tax",
               label => "Tax Paid",
               columnHeader => "TAX PAID",
               startAtColumn => 108,
               fieldLength => 12,
               format => "money",
               summaryOrder => 7,
               collect => "sum",
             },
  "other" => { name => "other",
               label => "Other Fees Paid",
               columnHeader => "OTHER FEES",
               startAtColumn => 122,
               fieldLength => 12,
               format => "money",
               summaryOrder => 8,
               collect => "sum",
             },
  "entries" => { name => "entries",
               label => "Number of Customs Entries",
               columnHeader => "NUMBER OF ENTRIES",
               format => "int",
               summaryOrder => 2,
               collect => "increment",
             },
  "year" => { name => "year",
               label => "Year",
               columnHeader => "YEAR",
               format => "int",
               summaryOrder => -1,
               collect => "unique",
             },
  "ior" => { name => "ior",
               label => "Importer of Record Number",
               columnHeader => "IOR",
               format => "int",
               summaryOrder => -1,
               collect => "count",
             },
  "role" => { name => "role",
               label => "Importing Role",
               columnHeader => "ROLE",
               format => "int",
               summaryOrder => -1,
               collect => "count",
             },
  };

  return $this;
}

sub parse
{
  my ($this, $fh, $reports) = @_;

  my ($state, $role, $ior, $year, $report_date) = (0);

  my $count = 0;

  while(<$fh>) {
    print $_ if($this->{debug} >= 5);

    #last if($count++ > 10);

    if(/CUSTOMS SERVICE/) {
      $state = 1;

      m|(\d\d/\d\d/\d\d)|;

      $report_date = $1;

      if($this->{debug} >= 5) {
        print "Found report page header.\n";
      }
      next;
    }

    if(/(\w+)\s+EXTRACT FOR FY (\d+)/) {
      $role = $1;
      $year = $2;

      if($this->{debug} >= 5) {
        print "Found Role - $role and Year - $year\n";
      }

      next;
    }

    if(/^(\d{3}\-\S+)/) {
      $ior = $1;
      $state = 2;

      if($this->{debug} >= 5) {
        print "Found IOR Number: $ior\n";
      }

      next;
    }

    if($state == 2 && /^[A-Z0-9]{4} /) {
      my %record = ("role" => $role, "year" => $year, "ior" => $ior, "source" => "liquid", "report_date" => $report_date);

      chomp;

      foreach my $field (keys %{$this->{data_definition}}) {
        print "field: $field\n" if ($this->{debug} >= 5);

        next unless(exists $this->{data_definition}{$field}->{startAtColumn});

        $field = $this->{data_definition}{$field};

        $record{$field->{name}} = substr($_, $field->{startAtColumn} - 1, $field->{fieldLength});

        $record{$field->{name}} =~ s/[,\s]//g if ($field->{format} eq "money");
        print $field->{label} . ": " . $record{$field->{name}} . "\n" if ($this->{debug} >= 5);
      }

      $record{num} =~ s/(\d)$/-$1/;
      $record{entdate} =~ s/(.+)(.{2})(.{2})/$1\/$2\/$3/;

      # Extract Year
      my $year = $record{"entdate"};

      my($month, undef, $year) = split /\//, $year;

      if(0) {
        $month += 3;
        $year += int($month/12);
      }

      $year = "0$year" if($year < 10);
      $year =~ s/^0(0\d)/$1/;
      $record{year} = ($year < 50 ? "20$year" : "19$year");


      print "port: $record{port}\n" if($this->{debug} >= 5);

      ($record{portcode}, $record{port}) = $this->lookup("port", $record{port});

      if($this->{debug} >= 5) {
        print "port: $record{port}\n";
        print "portcode: $record{portcode}\n";
        print "-------------\n\n";
      }

      while(length($record{filer}) < 3) {
        $record{filer} = "0" . $record{filer};
      }

      ($record{filercode}, $record{filer}) = $this->lookup("filer", $record{filer});

      while(length($record{filercode}) < 3) {
        $record{filercode} = "0" . $record{filercode};
      }

      ($record{entrytypecode}, $record{entrytype}) = $this->lookup("entrytype", $record{entrytype});
      ($record{liqtypecode}, $record{liqtyp}) = $this->lookup("entrytype", $record{liqtyp});

      foreach my $report (@{$reports}) {
        $report->collect(\%record);
      }

      next;
    }
  }
}




1;
