#!/usr/local/bin/perl

use SNMPWrapper;
use ConfigFileReader;
use strict;

# the config file reader is used to retrieve the attributes of the DB
use ConfigFileReader;
my $config = ConfigFileReader->new("GeoNet");

# used for debugging
our $debug = 1;

my $sess = SNMPWrapper->new("127.0.0.1", $debug, "public", 162);

my @trap_args = ($sess->__encode_oid("1.3.6.1.4.1.2789.0.8.15"),
                 $sess->__encode_ip_address(pack "CCCC", split(/\./, "127.0.0.1")),
                 $sess->__encode_int(2),
                 $sess->__encode_int(0),
                );
                
my @traps = ([$sess->__encode_oid("1.3.6.1.4.1.2789.1247.1"), $sess->__encode_int(123456)],
             [$sess->__encode_oid("1.3.6.1.4.1.2789.1247.2"), $sess->__encode_string("Message")],
            );
            
$sess->Trap(@trap_args, @traps);

