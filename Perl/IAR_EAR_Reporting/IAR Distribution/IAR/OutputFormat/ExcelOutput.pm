package OutputFormat::ExcelOutput;

use strict;
use vars qw ($VERSION @ISA @EXPORT);

use OutputFormat::OutputFormat;
use Spreadsheet::WriteExcel::Big;
use Data::Dumper;

$VERSION = 1.0;
@ISA = ("OutputFormat::OutputFormat");
@EXPORT = ();

sub new
{
  my ($class, $debug, $client, $outdir) = @_;

  my $this = $class->SUPER::new($debug, $client, $outdir);

  $this->{suffix} = ".xls";

  return $this;
}


sub display_summary
{
  my ($this, $record, $data, $label, $workbook) = @_;

  print "In display_summary\n" if($this->{debug} >= 5);

  my $worksheet = $workbook->addworksheet($label);

  my $titles;
  my @fields = @{$record->{fields}};
  foreach my $xx (@fields) {
    $titles .= "by " . $record->{labels}{$xx};
  }
  $worksheet->write(1,1, "Summary $titles");
  my $_skip = 1;
  foreach my $xxx (split ",", $label) {
    $worksheet->write(1, ++$_skip, $xxx);
  }


  my $rowcount = 3;

  foreach my $sum (sort {$record->{sumlist}{$a}{order} <=> $record->{sumlist}{$b}{order}} keys %{$record->{sumlist}}) {
    print "Working on $sum\n" if ($this->{debug} >= 3);

    $worksheet->write($rowcount, 1, "Total " . $record->{labels}{$sum});
    $worksheet->write($rowcount, 4, $record->get_val($data, "total_$sum", $sum));
    $rowcount++;

    $worksheet->write($rowcount, 2, $record->get_val($data, "${sum}_importer_liquid", $sum));
    $worksheet->write($rowcount, 3, "as Importer Liquidated");
    $rowcount++;

    $worksheet->write($rowcount, 2, $record->get_val($data, "${sum}_consignee_liquid", $sum));
    $worksheet->write($rowcount, 3, "as Consignee Liquidated");
    $rowcount++;

    $worksheet->write($rowcount, 2, $record->get_val($data, "${sum}_importer_unliquid", $sum));
    $worksheet->write($rowcount, 3, "as Importer Unliquidated");
    $rowcount++;

    $worksheet->write($rowcount, 2, $record->get_val($data, "${sum}_consignee_unliquid", $sum));
    $worksheet->write($rowcount, 3, "as Consignee Unliquidated");

    $rowcount+= 2;
  }
}




sub recurse_summary
{
  my ($this, $record, $data, $label, $workbook, $fields) = @_;

  my @fields = @{$fields};
  print "Sub fields: @fields\n" if($this->{debug} >= 5);

  if(scalar(@fields) == 0) {
    $this->display_summary($record, $data, $label, $workbook);
  } else {

    my $field = shift @fields;

    foreach my $val ($this->sort($record, $field, $data)) {
      print "Data for $val: " . $data->{$val} . "\n" if($this->{debug} >= 5);

      $this->recurse_summary($record, $data->{$val}, $label . ($label ? "," : "") . $val, $workbook, \@fields);
    }
  }
}



sub Summary
{
  my ($this, $report) = @_;

  print "Here\n" if($this->{debug} >= 5);
  print "Using file: " . $this->{outdir} . "/" . $report->{name} . $this->{suffix} . "\n" if($this->{debug} >= 5);
  print $report->{name} . "\n";

  my $workbook  = Spreadsheet::WriteExcel::Big->new($this->{outdir} . "/" . $report->{name} . $this->{suffix});

  my @fields = @{$report->{fields}};

  print "Base Data: " . $report->{data} . "\n" if($this->{debug} >= 5);
  print "Base Fields: " . $report->{fields} . " -- @fields\n" if($this->{debug} >= 5);

  $this->recurse_summary($report, $report->{data}, "", $workbook, \@fields);

  $workbook->close();
}





sub display_usage
{
  my ($this, $record, $data, $label, $worksheet, $usageby, $rowcount) = @_;

  print "rowcount $rowcount\n" if($this->{debug} >= 5);

  print "label $label\n" if($this->{debug} >= 5);
  print "usageby $usageby\n" if($this->{debug} >= 5);

  #$worksheet->write($rowcount,1, $record->get_label($data, $usageby));
  #$worksheet->write($rowcount,3, $this->commify(scalar(keys %{$data})));

  foreach my $item (sort {$data->{$a}{entries} <=> $record->{$b}{entries}} keys %{$data}) {

    my $colcount = 0;
    foreach my $thing (split /\|/, $label) {
      $worksheet->write($rowcount, $colcount++, $thing);
    }

    my $lab = $usageby;
    $lab =~ s/code$//;

    $worksheet->write($rowcount, $colcount++, ($record->{map}{$usageby}{$item} ? $record->{map}{$usageby}{$item} . "($item)" : $item));

    delete $data->{$item}{$lab};

    foreach my $sum (sort {$record->{sumlist}{$a}{order} <=> $record->{sumlist}{$b}{order}} keys %{$data->{$item}}) {
      print "sum - $sum - " . $record->get_val($data->{$item}, $sum, $sum) . "\n" if($this->{debug} >= 5);
      $worksheet->write_number($rowcount, $colcount++, $record->get_val($data->{$item}, $sum, $sum)) ;
    }
    $rowcount++;
  }

  return $rowcount;
}



sub recurse_usage
{
  my ($this, $record, $data, $label, $worksheet, $usageby, $rowcount, $fields) = @_;

  my @fields = @{$fields};
  print "Sub fields: @fields\n" if($this->{debug} >= 5);

  if(scalar(@fields) == 0) {
    return $this->display_usage($record, $data, $label, $worksheet, $usageby, $rowcount);
  } else {

    my $field = shift @fields;

    foreach my $val ($this->sort($record, $field, $data)) {
      print "Data for $val: " . $data->{$val} . "\n" if($this->{debug} >= 5);

      my $desc = $val;

      if($field =~ /(.*)code$/) {
        $desc = $record->{map}{$field}{$val} . "($val)";
      }


      print "Rowcount Before - $rowcount\n" if($this->{debug} >= 5);

      $rowcount = $this->recurse_usage($record, $data->{$val}, $label . ($label ? "|" : "") . $desc, $worksheet, $usageby, $rowcount, \@fields);

      print "Rowcount After - $rowcount\n" if($this->{debug} >= 5);
    }

    return $rowcount;
  }
}


sub Usage
{
  my ($this, $report) = @_;

  print "Here\n" if($this->{debug} >= 5);
  print "Using file: " . $this->{outdir} . "/" . $report->{name} . $this->{suffix} . "\n" if($this->{debug} >= 5);
  print $report->{name} . "\n";

  my $workbook = Spreadsheet::WriteExcel::Big->new($this->{outdir} . "/" . $report->{name} . $this->{suffix});

  my ($field, @groups) = @{$report->{fields}};

  print "Base Data: " . $report->{data} . "\n" if($this->{debug} >= 5);
  print "Base Fields: $field\n" if($this->{debug} >= 5);
  print "Grouped Fields: -- @groups\n" if($this->{debug} >= 5);

  foreach my $group (@groups) {
    #print "Hi: " . join("|", keys %{$report->{data}}) . "\n" if($this->{debug} >= 5);
    my @fields = split /,/, $group;

    my $titles;
    foreach my $xx (@fields) {
      next unless $xx;
      $titles .= ($titles ? ", " : "by ") . $report->{labels}{$xx};
    }
    my $worksheet = $workbook->addworksheet($group);

    $worksheet->write(1,1, $report->{labels}{$field} . " Usage $titles");

    my $colcount = 0;
    foreach my $xx (@fields) {
      next unless $xx;
      $worksheet->write(2,$colcount++, $report->{labels}{$xx});
    }

    foreach my $sum (sort {$report->{sumlist}{$a}{order} <=> $report->{sumlist}{$b}{order}} keys %{$report->{sumlist}}) {
      print "2,$colcount -- $sum " . $report->{labels}{$sum} . "\n" if($this->{debug} >= 5);
      $worksheet->write(2, $colcount++, $report->{labels}{$sum});
    }

    $this->recurse_usage($report, $report->{data}{$group}, "", $worksheet, $field, 3, \@fields);
  }

  $workbook->close();
}







sub display_entrylog
{
  my ($this, $record, $data, $label, $workbook) = @_;

  print "In display_entrylog\n" if($this->{debug} >= 5);

  my $worksheet = $workbook->addworksheet($label);

  #print $fh "Customs Entries $label\n";
  print "Customs Entries $label\n" if($this->{debug} >= 5);

  #print $fh "Total Number of Entries: " . $this->commify(scalar(keys %{$data})) . "\n";

  my $i = 0;
  foreach my $sum (sort {$record->{sumlist}{$a}{order} <=> $record->{sumlist}{$b}{order}} keys %{$data->{(keys %{$data})[0]}}) {
    $worksheet->write(0, $i++, $record->get_label($data, $sum));
  }

  my $rowcount = 3;

  foreach my $item ($this->sort($record, "entry_date", $data)) {
    print "item - $item\n" if($this->{debug} >= 5);

    my $colcount = 0;

    foreach my $sum (sort {$record->{sumlist}{$a}{order} <=> $record->{sumlist}{$b}{order}} keys %{$data->{$item}}) {
      print "sum - $sum - " . $record->get_val($data->{$item}, $sum, $sum) . "\n" if($this->{debug} >= 5);
      $worksheet->write($rowcount, $colcount++, $record->get_val($data->{$item}, $sum, $sum)) ;

      print "sum - $sum\n" if($this->{debug} >= 10);
      printf ("%" . (length($record->get_label($data, $sum)) + 1) . "s\n", $record->get_val($data->{$item}, $sum, $sum)) if($this->{debug} >= 10);
      #printf $fh ("%" . $record->get_width($sum) . "s ", substr($record->get_val($data->{$item}, $sum, $sum), 0, $record->get_width($sum)));
    }
    $rowcount++;
  }
}


sub recurse_entrylog
{
  my ($this, $record, $data, $label, $workbook, $fields) = @_;

  print "Hi: " . join("|", keys %{$data}) . "\n" if($this->{debug} >= 5);

  my @fields = @{$fields};
  print "Sub fields: @fields\n" if($this->{debug} >= 5);

  if(scalar(@fields) == 0) {
    $this->display_entrylog($record, $data, $label, $workbook);
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


      $this->recurse_entrylog($record, $data->{$val}, $label . ($label ? " " : "by ") . $desc, $workbook, \@fields);
    }
  }
}


sub EntryLog
{
  my ($this, $report) = @_;

  print "Here\n" if($this->{debug} >= 5);
  print "Using file: " . $this->{outdir} . "/" . $report->{name} . $this->{suffix} . "\n" if($this->{debug} >= 5);
  print $report->{name} . "\n";

  my $workbook = Spreadsheet::WriteExcel::Big->new($this->{outdir} . "/" . $report->{name} . $this->{suffix});

  my @fields = @{$report->{fields}};

  print "Base Data: " . $report->{data} . "\n" if($this->{debug} >= 5);
  print "Base Fields: " . $report->{fields} . " -- @fields\n" if($this->{debug} >= 5);

  $this->recurse_entrylog($report, $report->{data}, "", $workbook, \@fields);

  $workbook->close();
}



sub display_combinedentrylog
{
  my ($this, $record, $data, $label, $workbook) = @_;

  print "In display_entrylog\n" if($this->{debug} >= 5);

  my $worksheet = $workbook->addworksheet($label);

  #print $fh "Customs Entries $label\n";
  print "Customs Entries $label\n" if($this->{debug} >= 5);

  #print $fh "Total Number of Entries: " . $this->commify(scalar(keys %{$data})) . "\n";

  my $i = 0;
  foreach my $sum (sort {$record->{sumlist}{$a}{order} <=> $record->{sumlist}{$b}{order}} keys %{$data->{(keys %{$data})[0]}}) {
    next if(!defined $record->{sumlist}{$sum}{order});
    print("getting label for $sum\n") if($this->{debug} >= 5);
    $worksheet->write(0, $i++, $record->get_label($data, $sum));
  }

  my $rowcount = 3;

  foreach my $item ($this->sort($record, "num", $data)) {
    print "item - $item\n" if($this->{debug} >= 5);

    my $colcount = 0;

    foreach my $sum (sort {$record->{sumlist}{$a}{order} <=> $record->{sumlist}{$b}{order}} keys %{$data->{$item}}) {
      next if(!defined $record->{sumlist}{$sum}{order});
      print "sum - $sum - " . $record->get_val($data->{$item}, $sum, $sum) . "\n" if($this->{debug} >= 5);
      $worksheet->write($rowcount, $colcount++, $record->get_val($data->{$item}, $sum, $sum)) ;

      print "sum - $sum\n" if($this->{debug} >= 10);
      printf ("%" . (length($record->get_label($data, $sum)) + 1) . "s\n", $record->get_val($data->{$item}, $sum, $sum)) if($this->{debug} >= 10);
      #printf $fh ("%" . $record->get_width($sum) . "s ", substr($record->get_val($data->{$item}, $sum, $sum), 0, $record->get_width($sum)));
    }
    $rowcount++;
  }
}


sub recurse_combinedentrylog
{
  my ($this, $record, $data, $label, $workbook, $fields) = @_;

  print "Hi: " . join("|", keys %{$data}) . "\n" if($this->{debug} >= 5);

  my @fields = @{$fields};
  print "Sub fields: @fields\n" if($this->{debug} >= 5);

  if(scalar(@fields) == 0) {
    $this->display_combinedentrylog($record, $data, $label, $workbook);
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


      $this->recurse_combinedentrylog($record, $data->{$val}, $label . ($label ? " " : "by ") . $desc, $workbook, \@fields);
    }
  }
}


sub CombinedEntryLog
{
  my ($this, $report) = @_;

  print "Here\n" if($this->{debug} >= 5);
  print "Using file: " . $this->{outdir} . "/" . $report->{name} . $this->{suffix} . "\n" if($this->{debug} >= 5);
  print $report->{name} . "\n";

  my $workbook = Spreadsheet::WriteExcel::Big->new($this->{outdir} . "/" . $report->{name} . $this->{suffix});

  my @fields = @{$report->{fields}};

  print "Base Data: " . $report->{data} . "\n" if($this->{debug} >= 5);
  print "Base Fields: " . $report->{fields} . " -- @fields\n" if($this->{debug} >= 5);

  $this->recurse_combinedentrylog($report, $report->{data}, "", $workbook, \@fields);

  $workbook->close();
}


sub OST
{
}


sub display_combined
{
  my ($this, $record, $data, $label, $worksheet, $rowcount) = @_;

  print "In display_combined\n" if($this->{debug} >= 5);

  $rowcount = 3 if $rowcount <= 3;
  my $colcount = 0;

  foreach my $sum (sort {$record->{sumlist}{$a}{order} <=> $record->{sumlist}{$b}{order}} keys %{$record->{sumlist}}) {
    print "Working on $sum\n" if ($this->{debug} >= 3);

    print $record->{labels}{$sum} . " -- " . $record->get_val($data, "total_$sum", $sum) . "\n";

    $worksheet->write($rowcount, $colcount++, $record->{labels}{$sum});
  }

  return $rowcount++;
}




sub recurse_combined
{
  my ($this, $record, $data, $label, $worksheet, $fields, $rowcount) = @_;

  my @fields = @{$fields};
  print "Sub fields: @fields\n" if($this->{debug} >= 5);

  if(scalar(@fields) == 0) {
    $rowcount = $this->display_combined($record, $data, $label, $worksheet, $rowcount);
  } else {

    my $field = shift @fields;

    foreach my $val ($this->sort($record, $field, $data)) {
      print "Data for $val: " . $data->{$val} . "\n" if($this->{debug} >= 5);

      $rowcount = $this->recurse_combined($record, $data->{$val}, $label . ($label ? "," : "") . $val, $worksheet, \@fields, $rowcount);
    }
  }

  return $rowcount;
}



sub Combined
{
  my ($this, $report) = @_;

  $this->{debug} = 5;

  print Dumper($report);

  print "Here\n" if($this->{debug} >= 5);
  print "Using file: " . $this->{outdir} . "/" . $report->{name} . $this->{suffix} . "\n" if($this->{debug} >= 5);
  print $report->{name} . "\n";

  my $workbook = Spreadsheet::WriteExcel::Big->new($this->{outdir} . "/" . $report->{name} . $this->{suffix});

  my @fields = @{$report->{fields}};

  print "Base Data: " . $report->{data} . "\n" if($this->{debug} >= 5);
  print "Base Fields: " . $report->{fields} . " -- @fields\n" if($this->{debug} >= 5);

  my $label = "Test";
  my $worksheet = $workbook->addworksheet($label);

  my $titles;
  $worksheet->write(1,1, "Summary $titles");
  my $_skip = 1;
  foreach my $xxx (split ",", $label) {
    $worksheet->write(1, ++$_skip, $xxx);
  }


  $this->recurse_combined($report, $report->{data}, "", $worksheet, \@fields);

  $workbook->close();
}





1;
