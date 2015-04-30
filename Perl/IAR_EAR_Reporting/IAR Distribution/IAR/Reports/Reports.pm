package Reports::Reports;

use strict;
use vars qw($VERSION @ISA @EXPORT);

$VERSION = 1;
@ISA = ('Exporter');
@EXPORT = ();

sub new
{
  my ($class, $name, $fields, $debug) = @_;

  my $this = { "debug" => $debug,
               "data" => {},
               "fields" => $fields,
               "name" => $name,
             };

  $this->{labels} = {
    "entries" => "Number of Customs Entries",
    "value" => "Entered Value",
    "duties" => "Duties Paid",
    "estduty" => "Estimated Duties",
    "other" => "Other Fees Paid",
    "taxes" => "Taxes Paid",
    "esttax" => "Estimated Taxes",
    "add" => "ADD/CVD Paid",
    "filers" => "Filer",
    "brokers" => "Filer",
    "filercode" => "Filer Code",
    "ports" => "Port",
    "port" => "Port",
    "portcode" => "Port Code",
    "year" => "Year",
    "ior" => "Importer of Record",
    "cons" => "Consignee",
    "consgnee" => "Consignee",
    "role" => "Importer Role",
    "num" => "Entry Number",
    "source" => "Entry Status",
    "entrytype" => "Entry Type",
    "surety" => "Surety Type",
    "refund" => "Refund Amount",
    "entry_date" => "Entry Date",
    "liquidation_date" => "Liquidation Date",
    "liquidation_type" => "Liquidation Type",
    "line_items" => "Number of Customs Line Items",
    "port" => "Port",
    "filer" => "Broker",
    "coo" => "Country of Origin",
    "country" => "Country of Origin",
    "manufacturer" => "Manufacturer",
    "company" => "Manufacturer",
    "mid" => "Manufacturer ID",
    "htsid" => "HTS #",
    "hsusa" => "HTS #",
    "hsusa_base" => "Base HTS #",
    "hsusa_desc" => "HTS Description",
    "transport" => "Transport Mode",
    "pior" => "# as IOR",
    "pcons" => "# as CONS",
    "pliq" => "# Liquid",
    "punliq" => "# Unliquid",
    "iorcount" => "# as IOR",
    "consigneecount" => "# as Consignee",
    "liquidated" => "# Liquidated",
    "unliquidated" => "# Unliquidated",
    "spi" => "Special Trade Program",
    "difference" => "OST vs NFC",
    "nfcvalue" => "NFC Value",
    "ostduties" => "OST Duties",
  };


  $this->{sorting} = {
    "year" => "descending",
    "ior" => "maxentries",
    "portcode" => "maxentries",
    "filercode" => "maxentries",
    "role" => "reverse_alpha",
    "entry_date" => "date_ascending",
    "num" => "alpha",
  };


  print "Here - $class\n" if($debug >= 10);

  return bless($this, $class);
}


sub get_width
{
  my ($this, $field) = @_;

  return $this->{sumlist}{$field}{width};
}


sub get_val
{
  my ($this, $data, $field, $main) = @_;

  if($this->{sumlist}{$main}{"collect"} eq "sum") {
    return int($data->{$field} * 100)/100;

  } elsif ($this->{sumlist}{$main}{"collect"} eq "count") {
    return scalar(keys %{$data->{$field}});

  } elsif ($this->{sumlist}{$main}{"collect"} eq "unique") {
    return $data->{$field};

  }
}


sub get_label
{
  my ($this, $data, $main) = @_;

  print "Looking up $main label - " . $this->{labels}{$main} . "\n" if ($this->{debug} >= 10);

  if($this->{sumlist}{$main}{"collect"} eq "sum") {
    return "Total " . $this->{labels}{$main};

  } elsif ($this->{sumlist}{$main}{"collect"} eq "count") {
    return "Number of " . $this->{labels}{$main} . "s Used";

  } elsif ($this->{sumlist}{$main}{"collect"} eq "unique") {
    return $this->{labels}{$main};

  }
}

sub collect
{
}

sub retrieveData
{
}


1;
