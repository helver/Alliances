#!/usr/local/bin/perl -w 

use DBI;
use Proc::Queue size => 12, ':all';
use POSIX;
use Net::SNMP;
use strict;
my $dbh = DBI->connect("dbi:Pg:dbname=opus2", 'postgres', '') || print "$DBI::errstr\n";
my $sort = 'desc';

my $sql = "select distinct(ip), count(distinct(nvcid))
  from switchinfo
  group by ip
  order by count(distinct(nvcid)) $sort";

my $sth = $dbh->prepare($sql);
$sth->execute;
my @sites;
while (my @siteInfo = $sth->fetchrow_array){
  push (@sites, \@siteInfo);
}
$sth->finish;
$dbh->disconnect;

my ($Sec, $Min, $Hr, $Day, $Month, $Year) = (localtime)[1,1,2,3,4,5];
$Month = $Month + 1;
$Year = $Year + 1900;
my $timeStamp .= sprintf("%02d%02d%02d%02d%02d%02d", $Year, $Month, $Day, $Hr, $Min, $Sec);
my $niceVal = -10;

#while(1){
  foreach my $siteInfo (@sites){
    $niceVal++;
    my ($host, $count) = (@{$siteInfo});
    print "$host\n";
    run_back{
      my $ret = `nice -$niceVal /usr/local/apache/htdocs/develOpus/pathTraceFull.pl $host 2>/dev/null`; 
      print "$ret\n" if $ret;
    }
  }
  1 while wait != -1;
#  sleep 300;
#}
#
#      my $ret = `./checkStatus.pl $host`;
#      print "$ret \n" if $ret;
#    }
#  }
#  1 while wait != -1;
#
  
#  die;
#
