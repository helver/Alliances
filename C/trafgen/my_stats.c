/* generic code for breaking apart a tcpdump file */


#include <sys/types.h>
#include <sys/socket.h>
#include <net/if.h>
#include <netinet/in.h>
#include <netinet/in_systm.h>
#include <netinet/if_ether.h>
#include <time.h>
#include <netinet/tcp.h>
#include <netinet/udp.h>
#include <arpa/inet.h>
#include <stdio.h>
#include <sys/uio.h>
#include <stdlib.h>
#include <string.h>
#include <netinet/ip.h>
#include "mystats.h"

int debug = 4;
long current_addr1, current_addr2, current_size;
u_int current_sec, current_usec;

struct converse *table[65536];

/* Reads in the tcpdump header and makes sure that the header is what 
 * it should be.  If the numbers don't match, we stop running
 */
int check_dfh(FILE *dumpfil)
{
   struct dump_file_header dfh;

   fread(&dfh, sizeof(struct dump_file_header), 1, dumpfil);

   if(debug >= 5)
       printf("Checking dump file header - %xd\n", dfh.magic);

   return (dfh.magic == TCPDUMP_MAGIC);
}

long handle_dump_header(FILE *dumpfil)
{
    struct dump_header dh;

    fread(&dh, sizeof(struct dump_header), 1, dumpfil);

    if(debug >= 5)
	printf("Handling a dump header - capture length %d\n", dh.caplen);

    current_size = dh.len;
    current_sec = dh.ts_secs;
    current_usec = dh.ts_usecs;

    /* Anything you want to do to the dump header information should be done here */

    return (long)dh.caplen;
}

int handle_ether_header(FILE *dumpfil)
{
    struct ether_header eh;
    /* The ether header read reads in the ethernet headers. I need to read this
     * information so I can figure out what kind of packet it is. 
     */
    fread(&eh, sizeof(struct ether_header), 1, dumpfil);

    current_size -= sizeof(struct ether_header);

    /* if you want to do anything with the ethernet header information, do it here */

    return eh.ether_type;
}


u_char handle_ip_header(FILE *dumpfil)
{
    struct ip iph;

    /* The ip header read reads in the ip headers. */

    fread(&iph, sizeof(struct ip), 1, dumpfil);

    if(debug >= 5)
	printf("IP: Source %ld  Dest %ld\n", (long)iph.ip_src.s_addr, (long)iph.ip_dst.s_addr);

    current_size -= sizeof(struct ip);
    current_addr1 = (long)iph.ip_src.s_addr;
    current_addr2 = (long)iph.ip_dst.s_addr;

    /* If you want to do anything with the ip header information, do it here */

    return iph.ip_p;
}

struct converse * find_converse(int port, long addr1, long addr2)
{
    struct converse *this;

    this = table[port];

    while(this) {
	if(   (addr1 == this->addr1)
	   && (addr2 == this->addr2)
	   && (!this->finned))
	    return this;
	else if(   (addr1 == this->addr2)
		&& (addr2 == this->addr1)
	        && (!this->finned))
	    return this;
	else
	    this = this->next;
    }

    return NULL;
}

void add_to_list(struct converse *newbie)
{
    struct converse *this;

    this = table[newbie->port];

    while(this && this->next) 
	this = this->next;

    if(this)
	this->next = newbie;
    else
	table[newbie->port] = newbie;

    return;
}


void handle_telnet(struct tcphdr *tcp)
{
    struct converse *conv = NULL;
    int type;

    if(tcp->th_sport < tcp->th_dport)
	type = tcp->th_dport;
    else
	type = tcp->th_sport;

    conv = find_converse(type, current_addr1, current_addr2);

    if(!conv) {
	conv = (struct converse *)malloc(sizeof(struct converse));

	conv->type = IPPORT_TELNET;
	conv->port = type;
	conv->addr1 = current_addr1;
	conv->addr2 = current_addr2;
	conv->finned = FALSE;
	conv->start_sec = current_sec;
	conv->start_usec = current_usec;
	conv->count = 0;
	conv->bytes = 0;
	conv->next = NULL;

	add_to_list(conv);
    }

    if(current_size) {
	conv->count++;
	conv->bytes += current_size;
	conv->last_sec = current_sec;
	conv->last_usec = current_usec;
    }

    if(tcp->th_flags & TH_FIN)
	conv->finned = TRUE;
	

void handle_tcp_header(FILE *fil)
{
    struct tcphdr tcp;
    int type;

    fread(&tcp, sizeof(struct tcphdr), 1, fil);

    current_size -= sizeof(struct tcphdr);

    if(debug >= 5)
	printf("TCP Source %d  Dest %d  Seq %ld\n", tcp.th_sport, tcp.th_dport, tcp.th_seq);

    /* If you want to do anything with the tcp header information, do it here */

    if(tcp.th_flags & TH_SYN) {
	printf("Found the start of a stream\n");
	printf("Source port: %d   Dest port: %d\n", tcp.th_sport, tcp.th_dport);
    }

    if(tcp.th_sport < tcp.th_dport)
	type = tcp.th_sport;
    else
	type = tcp.th_dport;

    if(tcp.th_flags & TH_FIN)
	printf("Found the end of a stram\n");

    switch(type) {
      case IPPORT_TELNET:
      case IPPORT_LOGIN:
      case IPPORT_KLOGIN:
      case IPPORT_OLDLOGIN:
      case IPPORT_FLN_SPX:
      case IPPORT_UUCP_LOGIN:
      case IPPORT_KLOGIN2:
      case IPPORT_NLOGIN:
	if(debug >= 5)
	    printf("Telnet\n");

	handle_telnet(&tcp);
	break;

      case IPPORT_FTP:
      case (IPPORT_FTP - 1):
	printf("FTP\n");
	break;

      case IPPORT_SMTP:
	printf("SMTP\n");
	break;

      case IPPORT_HTTP:
	printf("HTTP\n");
	break;

      case IPPORT_NNTP:
	printf("NTTP\n");
	break;

      default:
	printf("Other\n");
    }

    return;
}

void handle_udp_header(FILE *fil)
{
    return;
}

void dump_split(
    FILE* fil
    )
{
    long end;
    long fp;
    int eh_type;
    int next_packet;

    /* First problem: Get rid of the dump header and verify magic number. */
    if(!check_dfh(fil)) {
	/* Bad Magic number */
	printf("Bad Magic number in dump file.  Processing aborted.\n\n");
	exit(1);
    }

    /* Find the end of the file */
    fp = ftell(fil);
    end = fseek(fil, 0, SEEK_END);
    end = ftell(fil);
    fseek(fil, fp, SEEK_SET);

    /* Do packets until we run out of packets to do */
    while((fp + sizeof(struct ether_header) + sizeof(struct dump_header)) <= end) {

	/* Dump header stuff */
	next_packet = handle_dump_header(fil);
	/* If you want to do anything with the dump header information, go make calls
	 * from inside handle_dump_header.
	 */

	fp = ftell(fil);

	/* Ethernet header stuff */
	eh_type = handle_ether_header(fil);

	if(eh_type == ETHERTYPE_IP) {
	    /* I'm only worried about IP packets here.  If you want to mess with ARP or
	     * RARP stuff, do it up in handle_ether_header
	     */

	    switch(handle_ip_header(fil)) {
	      case IPPROTO_TCP:
		if(debug >= 5)
		    printf("Found tcp packet.\n");
		handle_tcp_header(fil);
		break;

	      case IPPROTO_UDP:
		if(debug >= 5)
		    printf("Found udp packet.\n");
		handle_udp_header(fil);
		break;
	    }
	}

	fseek(fil, fp, SEEK_SET);
	fseek(fil, next_packet, SEEK_CUR);
	fp = ftell(fil);
    }
}
	
int main(
    int argc,
    char *argv[]
    )
{
    FILE* fil;
    int len;

    if(argc < 1) {
	perror("Invalid number of command line arguments");
	exit(1);
    }

    len = strlen(argv[1]);

    if(!strncmp(argv[1], "help", len)) {
	printf("Usage: XXX <filename> where <filename> is the name of a tcpdump file.\n\n");
	exit(1);
    }

    if((fil = fopen(argv[1], "r")) == NULL) {
	printf("Unable to open the tcpdump file: %s\n\n", argv[1]);
	exit(1);
    }

    dump_split(fil);

    return 0;
}
