#!/usr/local/bin/perl

#########################################
#
# GTT Parsing
#
# GTTParser.pl
# Initial Creation Date: 11/1/2000
# Initial Creator: eric
#
# Revision: $Revision: 1.2 $
# Last Change Date: $Date: 2001-10-05 20:59:39 $
# Last Editor: $Author: eric $
#
# Development History:
# $Log: GTTParser.pl,v $
# Revision 1.2  2001-10-05 20:59:39  eric
# Adding comments.
#
#
#
# Parses GTT spreadsheets and Identifies discrepancies between the GTT
# and the STP.
#
#########################################

my $debug = 0;

$some_dir = 'G:/network services/user directories/Eric Helvey/GTT Parsing';
print "$some_dir\n" if $debug;

my $info_pattern = '.csv$';

opendir(DIR, $some_dir) || die "can't opendir $some_dir: $!";
@fil = grep { /$info_pattern$/ } readdir(DIR);
closedir DIR;

print "@fil\n" if $debug;
my $count = 0;
my %tot;

my %messages;
$messages{GTT} = "Message : Record Doesn't exist on STP";
$messages{STP} = "Message : Record Doesn't exist on GTT";


foreach my $site (@fil) {

    open (INFA, "<$some_dir/$site") or die "Can't Open $site: $!";

  next unless <INFA>;
  <INFA>;

  while(<INFA>) {
    my ($message, $STP, @key) = reverse(split ",");
    my $key = join ',', reverse @key;
    print "$key -- $STP -- $message\n" if $debug;

    if(exists $tot{$key}) {
      $#{$tot{$key}} = $count - 1 if($count);
      push @{$tot{$key}}, $STP;
      print ((join ",", @{$tot{$key}}) . "\n") if $debug;
    } else {
      my @listy;
      $#listy = $count - 1 if($count);
      push @listy, $STP;
      $tot{$key} = \@listy;
    }
  }

  close INFA;
  $count++;
}

print "$count\n" if $debug;
my $last = 0;
my $first = "GTT";

my @headers = ("FOUND IN","NPA_NXX","FROM","TO","PRI_HLR","LOCATIONS");
$#headers += $count - 1;
push @headers, "MESSAGE";

print ((join ",", @headers) . "\n\n");

foreach my $key (sort {(split(",",$a))[1] <=> (split(",",$b))[1] or (split(",",$a))[0] cmp (split(",",$b))[0]} keys %tot) {
  if($last ne (split(",",$key))[1]) {
    print "\n" if $last;
    $last = (split(",",$key))[1];
    $first = "";
  }
  if($first ne (split(",",$key))[0]) {
    #print "-------\n" if($first eq "GTT");
    $first = (split(",",$key))[0];
  }
  $#{$tot{$key}} = $count - 1;
  my $stps = join ',', @{$tot{$key}};
  my $type = (split(",",$key))[0];
  print "$key,$stps,$messages{$type}\n";
}
