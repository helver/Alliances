package OutputFormat::OutputFormat;

use strict;
use vars qw ($VERSION @ISA @EXPORT);

$VERSION = 1.0;
@ISA = ("Exporter");
@EXPORT = ();

sub new
{
  my ($class, $debug, $client, $outdir) = @_;

  my $this = { "debug" => $debug,
               "client" => $client,
               "outdir" => $outdir,
             };

  bless($this, $class);

  return $this;
}


sub commify
{
  my ($this, $val) = @_;

  $val = 0 unless $val;

  while($val =~ /\d{4}/) {
    $val =~ s/(\d+)(\d{3})/$1,$2/;
  }

  return $val;
}


sub sort
{
  my ($this, $record, $field, $data) = @_;

  my @fields;

  print("$field $record $data -- \@fields = \$this->" . $record->{sorting}{$field} . "(\$data);\n") if($this->{debug} >= 5);
  eval("\@fields = \$this->" . $record->{sorting}{$field} . "(\$data);");
  #@fields = $this->descending($data);

  die "OutputFormat.pm - sort() $! -- $@\n" if ($! || $@);

  print "Returning @fields\n" if($this->{debug} >= 5);

  return @fields;
}


sub one_date
{
  my ($this, $date, $num) = @_;

  print "date: $date, $num\n" if($this->{debug} >= 5);

  my ($m, $d, $y);

  if($date =~ /\//) {
    ($m, $d, $y) = split(/\//, $date);
  } elsif($date =~ /^\d{4}\-/) {
    ($y, $m, $d) = split(/\-/, (split(/ /, $date))[0]);
    $y = substr($y, 2);
  } elsif($date =~ /\-/) {
    ($m, $d, $y) = split(/\-/, $date);
  } else {
    ($m, $d, $y) = ($date =~ /(.+)(.{2})(.{2})/);
  }

  print "m - $m, d - $d, y - $y\n" if($this->{debug} >= 5);
  $m-= 1;

  return -1 if ($y <= 69 && $y >= 30);

  $y+= ($y < 70 ? 2000 : 1900);
  print "m - $m, d - $d, y - $y\n" if($this->{debug} >= 5);

  return timelocal(0,0,0,$d,$m,$y);
}

sub date_ascending
{
  my ($this, $data) = @_;

  use Time::Local;

  my @fields = keys %{$data};

  print "Fields: @fields\n" if($this->{debug} >= 5);

  @fields = sort {$this->one_date($data->{$a}{entry_date},$data->{$a}{num}) <=> $this->one_date($data->{$b}{entry_date},$data->{$b}{num})} @fields;

  return @fields;
}


sub reverse_alpha
{
  my ($this, $data) = @_;

  my @fields = keys %{$data};

  print "Fields: @fields\n" if($this->{debug} >= 5);

  @fields = reverse sort @fields;

  return @fields;
}


sub alpha
{
  my ($this, $data) = @_;

  my @fields = keys %{$data};

  print "Fields: @fields\n" if($this->{debug} >= 5);

  @fields = sort @fields;

  return @fields;
}


sub descending
{
  my ($this, $data) = @_;

  my @fields = keys %{$data};

  print "Fields: @fields\n" if($this->{debug} >= 5);

  @fields = sort {$b <=> $a} @fields;

  return @fields;
}


sub maxentries
{
  my ($this, $data) = @_;

  my @fields = keys %{$data};

  @fields = sort {$data->{$a}{total_entries} <=> $data->{$b}{total_entries}} @fields;

  return @fields;
}

1;
