package OutputFormat::TextOutput;

use strict;
use vars qw ($VERSION @ISA @EXPORT);

use OutputFormat::OutputFormat;

$VERSION = 1.0;
@ISA = ("OutputFormat::OutputFormat");
@EXPORT = ();

sub new
{
  my ($class, $debug, $client, $outdir) = @_;

  my $this = $class->SUPER::new($debug, $client, $outdir);

  $this->{suffix} = ".txt";
  $this->{pageHeaders} = 0;

  return $this;
}


sub display_summary
{
  my ($this, $record, $data, $label, $fh) = @_;

  print "In display_summary\n" if($this->{debug} >= 5);

  print $fh "Summary $label\n";

  foreach my $sum (sort {$record->{sumlist}{$a} <=> $record->{sumlist}{$b}} keys %{$record->{sumlist}}) {
    print $fh "Total " . $record->{labels}{$sum} . ": " . $this->commify($record->get_val($data, "total_$sum", $sum)) . "\n";
    print $fh "\t" . $this->commify($record->get_val($data, "${sum}_importer_liquid", $sum)) . " as Importer Liquidated\n";
    print $fh "\t" . $this->commify($record->get_val($data, "${sum}_consignee_liquid", $sum)) . " as Consignee Liquidated\n";
    print $fh "\t" . $this->commify($record->get_val($data, "${sum}_importer_unliquid", $sum)) . " as Importer Unliquidated\n";
    print $fh "\t" . $this->commify($record->get_val($data, "${sum}_consignee_unliquid", $sum)) . " as Consignee Unliquidated\n";
    print $fh "\n\n";
  }
}


sub recurse_summary
{
  my ($this, $record, $data, $label, $fh, $fields) = @_;

  my @fields = @{$fields};
  print "Sub fields: @fields\n" if($this->{debug} >= 5);

  if(scalar(@fields) == 0) {
    $this->display_summary($record, $data, $label, $fh);
  } else {

    my $field = shift @fields;

    foreach my $val ($this->sort($record, $field, $data)) {
      print "Data for $val: " . $data->{$val} . "\n" if($this->{debug} >= 5);

      $this->recurse_summary($record, $data->{$val}, $label . ($label ? ", " : "by ") . $record->{labels}{$field} . " " . $val, $fh, \@fields);
    }
  }
}
    

sub Summary
{
  my ($this, $report) = @_;

  print "Here\n" if($this->{debug} >= 5);
  print "Using file: " . $this->{outdir} . "/" . $report->{name} . $this->{suffix} . "\n" if($this->{debug} >= 5);

  open(FH, "> " . $this->{outdir} . "/" . $report->{name} . $this->{suffix}) or die "Can't open output file: $!\n";

  my @fields = @{$report->{fields}};

  print "Base Data: " . $report->{data} . "\n" if($this->{debug} >= 5);
  print "Base Fields: " . $report->{fields} . " -- @fields\n" if($this->{debug} >= 5);

  $this->recurse_summary($report, $report->{data}, "", \*FH, \@fields);

  close FH;
  select STDOUT;
}



sub display_usage
{
  my ($this, $record, $data, $label, $fh, $usageby) = @_;

  print "In display_summary - usageby - $usageby\n" if($this->{debug} >= 5);

  print $fh $record->{labels}{$usageby} . " Usage $label\n";
  print $record->{labels}{$usageby} . " Usage $label\n" if($this->{debug} >= 5);

  print $fh $record->get_label($data, $usageby) . ": " . $this->commify(scalar(keys %{$data})) . "\n";

  foreach my $item (sort {$data->{$a}{entries} <=> $record->{$b}{entries}} keys %{$data}) {
    print "item - $item\n" if($this->{debug} >= 5);

    my $label = $usageby;
    $label =~ s/code$//;

    print $fh $record->{labels}{$usageby} . " " . $data->{$item}{$label} . "($item)\n";
    delete $data->{$item}{$label};

    foreach my $sum (sort {$record->{sumlist}{$a}{order} <=> $record->{sumlist}{$b}{order}} keys %{$data->{$item}}) {
      print "sum - $sum\n" if($this->{debug} >= 5);
      print $fh $record->get_label($data, $sum) . "\t" . $this->commify($record->get_val($data->{$item}, $sum, $sum)) . "\n";
    }

    print $fh "\n\n\n";
  }
}


sub recurse_usage
{
  my ($this, $record, $data, $label, $fh, $usageby, $fields) = @_;

  print "Hi: " . join("|", keys %{$data}) . "\n" if($this->{debug} >= 5);

  my @fields = @{$fields};
  print "Sub fields: @fields\n" if($this->{debug} >= 5);

  if(scalar(@fields) == 0) {
    $this->display_usage($record, $data, $label, $fh, $usageby);
  } else {

    my $field = shift @fields;

    print "Field: $field\n" if($this->{debug} >= 5);

    print "HELLO: " . (keys %{$data}) . "\n" if($this->{debug} >= 5);

    foreach my $val ($this->sort($record, $field, $data)) {
      print "Data for $val: " . $data->{$val} . "\n" if($this->{debug} >= 5);

      my $desc = $val;

      if($field =~ /(.*)code$/) {
        $desc = $record->{map}{$field}{$val} . "($val)";
      }

      
      $this->recurse_usage($record, $data->{$val}, $label . ($label ? ", " : "by ") . $record->{labels}{$field} . " " . $desc, $fh, $usageby, \@fields);
    }
  }
}
    

sub Usage
{
  my ($this, $report) = @_;

  print "Here\n" if($this->{debug} >= 5);
  print "Using file: " . $this->{outdir} . "/" . $report->{name} . $this->{suffix} . "\n" if($this->{debug} >= 5);

  open(FH, "> " . $this->{outdir} . "/" . $report->{name} . $this->{suffix}) or die "Can't open output file: $!\n";

  my ($field, @groups) = @{$report->{fields}};

  print "Base Data: " . $report->{data} . "\n" if($this->{debug} >= 5);
  print "Base Fields: $field\n" if($this->{debug} >= 5);
  print "Grouped Fields: -- @groups\n" if($this->{debug} >= 5);

  foreach my $group (@groups) {
    print "Hi: " . join("|", keys %{$report->{data}}) . "\n" if($this->{debug} >= 5);
    my @fields = split /,/, $group;
    $this->recurse_usage($report, $report->{data}{$group}, "", \*FH, $field, \@fields);

    print FH "\n\n\n\n";
  }

  close FH;
}





sub display_entrylog
{
  my ($this, $record, $data, $label, $fh) = @_;

  print "In display_entrylog\n" if($this->{debug} >= 5);

  print $fh "Customs Entries $label\n";
  print "Customs Entries $label\n" if($this->{debug} >= 5);

  print $fh "Total Number of Entries: " . $this->commify(scalar(keys %{$data})) . "\n";

  foreach my $sum (sort {$record->{sumlist}{$a}{order} <=> $record->{sumlist}{$b}{order}} keys %{$data->{(keys %{$data})[0]}}) {
    printf $fh ("%" . $record->get_width($sum) . "s ", substr($record->get_label($data, $sum), 0, $record->get_width($sum)));
  }
  print $fh "\n";

  foreach my $item ($this->sort($record, "entry_date", $data)) {
    print "item - $item\n" if($this->{debug} >= 5);

    foreach my $sum (sort {$record->{sumlist}{$a}{order} <=> $record->{sumlist}{$b}{order}} keys %{$data->{$item}}) {
      print "sum - $sum\n" if($this->{debug} >= 10);
      printf ("%" . (length($record->get_label($data, $sum)) + 1) . "s\n", $record->get_val($data->{$item}, $sum, $sum)) if($this->{debug} >= 10);
      printf $fh ("%" . $record->get_width($sum) . "s ", substr($record->get_val($data->{$item}, $sum, $sum), 0, $record->get_width($sum)));
    }
    print $fh "\n";
  }
}


sub recurse_entrylog
{
  my ($this, $record, $data, $label, $fh, $fields) = @_;

  print "Hi: " . join("|", keys %{$data}) . "\n" if($this->{debug} >= 5);

  my @fields = @{$fields};
  print "Sub fields: @fields\n" if($this->{debug} >= 5);

  if(scalar(@fields) == 0) {
    $this->display_entrylog($record, $data, $label, $fh);
  } else {

    my $field = shift @fields;

    print "Field: $field\n" if($this->{debug} >= 5);

    print "HELLO: " . (keys %{$data}) . "\n" if($this->{debug} >= 5);

    foreach my $val ($this->sort($record, $field, $data)) {
      print "Data for $val: " . $data->{$val} . "\n" if($this->{debug} >= 5);

      my $desc = $val;

      if($field =~ /(.*)code$/) {
        $desc = $record->{map}{$field}{$val} . "($val)";
      }

      
      $this->recurse_entrylog($record, $data->{$val}, $label . ($label ? ", " : "by ") . $record->{labels}{$field} . " " . $desc, $fh, \@fields);
    }
  }
}
    

sub EntryLog
{
  my ($this, $report) = @_;

  print "Here\n" if($this->{debug} >= 5);
  print "Using file: " . $this->{outdir} . "/" . $report->{name} . $this->{suffix} . "\n" if($this->{debug} >= 5);

  open(FH, "> " . $this->{outdir} . "/" . $report->{name} . $this->{suffix}) or die "Can't open output file: $!\n";

  my @fields = @{$report->{fields}};

  print "Base Data: " . $report->{data} . "\n" if($this->{debug} >= 5);
  print "Base Fields: " . $report->{fields} . " -- @fields\n" if($this->{debug} >= 5);

  $this->recurse_entrylog($report, $report->{data}, "", \*FH, \@fields);

  close FH;
}


1;
