%{

#include <stdlib.h>
#include <stdio.h>
#include <stdarg.h>
#include "trafgen.h"

extern char* yytext;
extern struct traf_gen *schedule;
extern char* default_host;
extern int default_port[];
extern int default_offset; 

static int debug = 6;

%}

%union {
    char *string;
    int number;
    struct traf_gen *line;
}

%token NUM NUM_IP CAN_IP WORD TELNET FTP HTTP SMTP NNTP UDP TCPLIB ADDR PORT STREAMS DUR DELAY
%token SIZE SIZE_STRING CBR RATE
 
%type <string> NUM_IP CAN_IP WORD TELNET FTP HTTP SMTP NNTP UDP address addr ADDR PORT STREAMS DUR DELAY
%type <string> SIZE SIZE_STRING CBR RATE
%type <number> time NUM streams dur size rate port
%type <line> ftpline udpline telnetline nntpline smtpline httpline trafgen_file trafgen_line tcplibline trafgen

%start trafgen

%%
trafgen : trafgen_file
{
    ;
}
;

trafgen_file : trafgen_line
{
/*    $1->next = NULL;*/
    set_schedule($1);

    if(debug >= 3)
	print_schedule($1);
}
| trafgen_line trafgen_file
{
    /* $1->next = $2;*/
    set_schedule($1);

    if(debug >= 3)
	print_schedule($1);
    $$ = $1;
}
;

trafgen_line : telnetline
{
    if(debug >= 3)
	printf("Got a telnet line.\n");

    $$ = $1;
}
| tcplibline
{
    if(debug >= 3)
	printf("Got a tcplib line.\n");
    
    $$ = $1;
}
| ftpline
{
    if(debug >= 3)
	printf("Got an ftp line.\n");

    $$ = $1;
}
| udpline
{
    if(debug >= 3)
	printf("Got a udp line.\n");

    $$ = $1;
}
| nntpline
{
    if(debug >= 3)
	printf("Got an nntp line.\n");

    $$ = $1;
}
| smtpline
{
    if(debug >= 3)
	printf("Got an smtp line.\n");

    $$ = $1;
}
| httpline
{
    if(debug >= 3)
	printf("Got an http line.\n");

    $$ = $1;
}
;

tcplibline : TCPLIB addr port streams dur rate time
{
    struct traf_gen *new;

    if(debug >= 3)
	printf("Tcplib # only line.\n");

    new = (struct traf_gen *)malloc(sizeof(struct traf_gen));
    clear_traf(new);

    new->type = TYPE_TCPLIB;
    new->delay = $7;
    new->active_timer = $5;
    new->items = $4;
    new->address = $2;
    new->port = $3;
    new->rate = $6;

    $$ = new;
}

;

telnetline : TELNET addr port dur time 
{
    struct traf_gen *new;

    if(debug >= 3)
	printf("Telnet line.\n");

    new = (struct traf_gen *)malloc(sizeof(struct traf_gen));
    clear_traf(new);

    new->type = TYPE_TELNET;
    new->address = $2;
    new->delay = $5;
    new->port = $3;
    new->active_timer = $4;

    if(new->port == -1)
	new->port = default_port[new->type] + default_offset;

    $$ = new;
}
;

ftpline : FTP addr port size time
{
    struct traf_gen *new;

    if(debug >= 3)
	printf("FTP line.\n");

    new = (struct traf_gen *)malloc(sizeof(struct traf_gen));
    clear_traf(new);

    new->type = TYPE_FTP;
    new->address = $2;
    new->delay = $5;
    new->port = $3;
    new->traffic_size = $4;

    if(new->port == -1)
	new->port = default_port[new->type] + default_offset;

    $$ = new;
}
;

udpline : UDP addr port CBR dur time
{
    struct traf_gen *new;

    if(debug >= 3)
	printf("UDP line.\n");

    new = (struct traf_gen *)malloc(sizeof(struct traf_gen));
    clear_traf(new);

    new->type = TYPE_UDP;
    new->address = $2;
    new->delay =$6;
    new->port = $3;
    new->active_timer = $5;

    if(new->port == -1)
	new->port = default_port[new->type] + default_offset;

    $$ = new;
}
| UDP addr port size time
{
    struct traf_gen *new;

    if(debug >= 3)
	printf("UDP line.\n");

    new = (struct traf_gen *)malloc(sizeof(struct traf_gen));
    clear_traf(new);

    new->type = TYPE_UDP;
    new->address = $2;
    new->delay =$5;
    new->port = $3;
    new->traffic_size = $4;

    if(new->port == -1)
	new->port = default_port[new->type] + default_offset;

    $$ = new;
}
;

httpline : HTTP addr port size streams time
{
    struct traf_gen *new;

    if(debug >= 3)
	printf("HTTP line.\n");

    new = (struct traf_gen *)malloc(sizeof(struct traf_gen));
    clear_traf(new);

    new->type = TYPE_HTTP;
    new->address = $2;
    new->delay = $6;
    new->port = $3;
    new->traffic_size = $4;
    new->items = $5;

    if(new->port == -1)
	new->port = default_port[new->type] + default_offset;

    $$ = new;
}
;

smtpline : SMTP addr port size time
{
    struct traf_gen *new;

    if(debug >= 3)
	printf("SMTP line.\n");

    new = (struct traf_gen *)malloc(sizeof(struct traf_gen));
    clear_traf(new);

    new->type = TYPE_SMTP;
    new->address = (char *)$2;
    new->delay = $5;
    new->port = $3;
    new->traffic_size = $4;

    if(new->port == -1)
	new->port = default_port[new->type] + default_offset;

    $$ = new;
}
;

nntpline : NNTP addr port size time
{
    struct traf_gen *new;

    if(debug >= 3)
	printf("NNTP line.\n");

    new = (struct traf_gen *)malloc(sizeof(struct traf_gen));
    clear_traf(new);

    new->type = TYPE_NNTP;
    new->address = (char *)$2;
    new->delay = $5;
    new->port = $3;
    new->traffic_size = $4;

    if(new->port == -1)
	new->port = default_port[new->type] + default_offset;

    $$ = new;
}
;

size : SIZE SIZE_STRING
{
    int len;
    char factor;
    char *temp;

    temp = (char *)strdup($2);

    len = strlen(temp);
    factor = temp[len-1];

    temp[len-1] = '\0';

    if(debug >= 5)
	printf("factor - %c, temp - %s\n", factor, temp);

    len = atoi(temp);

    switch (factor) {
      case 'g':
      case 'G':
	len *= 1024;

      case 'm':
      case 'M':
	len *= 1024;

      case 'k':
      case 'K':
	len *= 1024;

      case 'b':
      case 'B':
	break;

    }

    if(debug >= 5)
	printf("size %d\n", len);

    $$ = len;
}
| SIZE NUM
{
    $$ = $2;
}
|
{
    $$ = -1;
}
;

rate : RATE NUM
{
    $$ = $2;
}
|
{
    $$ = DEFAULT_RATE;
}
;

port : PORT WORD
{
    $$ = atoi($2);
}
|
{
    $$ = -1;
}
;

addr : ADDR address
{
    $$ = (char *)strdup($2);
}
|
{
    $$ = (char *)strdup(default_host);
}
;

address : NUM_IP
{
    if(debug >= 3) {
	printf("Dotted decimal address.\n");
	printf("%s\n", $1);
    }

    $$ = (char *)strdup($1);
}
| CAN_IP
{
    if(debug >= 3) {
	printf("Canonical address.\n");
	printf("%s\n", $1);
    }

    $$ = (char *)strdup($1);
}
;

dur : DUR NUM
{
    $$ = $2 * 1000;
}
|
{
    $$ = -1;
}
;

streams : STREAMS NUM
{
    $$ = $2;
}
|
{
    $$ = 1;
}
;

time : DELAY NUM
{
    if(debug >= 3)
	printf("Time.\n");

    if(debug >= 5)
	printf("I got a %d.\n", $2);

    $$ = $2;
}
|
{
    $$ = 0;
}
;
