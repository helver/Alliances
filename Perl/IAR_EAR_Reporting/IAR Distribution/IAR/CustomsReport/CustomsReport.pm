package CustomsReport::CustomsReport;

use strict;
use vars qw($VERSION @ISA @EXPORT);

$VERSION = 1;
@ISA = ('Exporter');
@EXPORT = ();

sub new
{
  my ($class, $debug) = @_;

  my $this = { "debug" => $debug,
             };

  $this->{"entrytype"} = read_lookup("LookupTables/EntryTypes.txt",0,1,2);
  $this->{"filer"} = read_lookup("LookupTables/filer601.txt",0,1);
  $this->{"port"} = read_lookup("LookupTables/PortCodes.txt",0,1,2);
  #$this->{"ior"} = read_lookup("PortCodes.txt",0,1,2);
  $this->{"surety"} = read_lookup("LookupTables/SuretyCodes.txt",0,1,2);

  print "Here - $class\n" if($debug >= 10);

  if($debug >= 7) {
    foreach my $x (keys %{$this->{"filer"}}) {
      print "$x -- " . $this->{"filer"}{$x} . "\n";
    }
  }

  return bless($this, $class);
}


sub parse
{
  my ($fh, $data) = @_;

  die("This is a base class.  Use a sub-class.\n");
}


sub read_lookup
{
  my ($filename, $code, $label, $max) = @_;

  open(FH, "< $filename") or die "Can't open lookup file $filename: $!\n";

  my %lookup;

  while(<FH>) {

    s/\s+$//;
    s/"//g; #"

    my @line;

    if(defined $max) {
      @line = split /,\s*/, $_, $max;
    } else {
      @line = split /,\s*/;
    }

    $lookup{code}{$line[$code]} = $line[$label];
    $lookup{label}{$line[$label]} = $line[$code];

    # print "$line[$code] $line[$label]\n";
  }

  close FH;

  return \%lookup;
}


sub lookup
{
  my ($this, $type, $val) = @_;

  my ($code, $label);

  if(exists $this->{$type}{code}{$val}) {
    $code = $val;
    $label = $this->{$type}{code}{$val};
  } elsif (exists $this->{$type}{label}{uc($val)}) {
    $code = $this->{$type}{label}{uc($val)};
    $label = $val;
  } else {
    foreach my $lab (keys %{$this->{$type}{label}}) {
      $val =~ s/([\(\)])/\$1/g;
      if($lab =~ /^$val/i) {
        $label = $lab;
        $code = $this->{$type}{label}{$lab};
        last;
      }
    }
    unless($code) {
      print "Failed lookup of $type $val.\n" if($this->{debug} >= 1);
      $code = $val;
      $label = $val;
    }
  }

  #print "Returning $code, $label\n";

  return ($code, $label);
}

sub lookup_label
{
  my ($this, $type, $val) = @_;

  my (undef, $label) = $this->lookup($type, $val);

  return $label;
}
1;

