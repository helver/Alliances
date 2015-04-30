#include <ctype.h>
#include <string.h>
#include <stdio.h>
#include <sys/uio.h>
#include <time.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>


int debug = 0;                       /* Debugger Level - currently 0      */
static unsigned long crc_table[256]; /* CRC Table - used to generate ints */
                                     /*             from strings.         */
long diff;                           /* Current Packet Length (bytes)     */
struct eth_src_dest *top_eth;        /* Most used EtherNet Address        */
struct ip_src_dest *top_ip;          /* Most used IP Address              */


/* The following three functions deal with the tcpdump packet headers.
 *
 * do_check_dfh check the dumpfile header, and verifies the MAGIC number.
 *
 * packet_dumpheader_read reads in the tcpdump header and extracts the
 * information it needs from it.
 *
 * packet_dumpheader_print prints the information gleaned from the 
 * tcpdump header.
*/

int do_check_dfh(FILE *dumpfil)
{
   /* Checking the dump file header, or dfh, involves reading in the
    * dump file header from the standard input, as specified in the 
    * project guidelines, and verifying the "magic" field.  This function
    * will return TRUE if the magic field checks out correctly.
   */

   struct dump_file_header dfh;

   fread(&dfh, sizeof(struct dump_file_header), 1, dumpfil);

   /* Real basic debugging garbage. */
   if (debug >= 5) {
      printf("In do_check_dfh -\n");
      printf("Magic - %d\n", dfh.magic);
      printf("%d %d\n",
             (TCPDUMP_MAGIC == dfh.magic),
             (TCPDUMP_MAGIC - dfh.magic));
   }

   return (dfh.magic == TCPDUMP_MAGIC);
}

int packet_dumpheader_read(int fp, struct dump_header *dh, FILE *dumpfil)
{
   /* This should read in our lovely dump header, fill in the data into
    * the dump header struct, and return the length of the packet.
   */

   fread(dh, sizeof(struct dump_header), 1, dumpfil);

   if (debug >= 5) {
      printf("Capture Length - %d\n", dh->caplen);
   }

   return dh->caplen;
}

void packet_ethheader_read(struct ether_header *eh, FILE *dumpfil)
{
   /* The ether header read reads in the ethernet headers. */

   fread(eh, sizeof(struct ether_header), 1, dumpfil);

   return;
}


void do_ipheader_read(struct ip *ip, FILE *dumpfil)
{
   /* The ip header read reads in the ip headers. */

   fread(ip, sizeof(struct ip), 1, dumpfil);

   return;
}

struct hostent * copy_host_stuff(struct hostent *temp)
{
   struct hostent *new;

   new = (struct hostent*)malloc(sizeof(struct hostent));

   new->h_name = (char*)strdup(temp->h_name);
   new->h_addrtype = temp->h_addrtype;
   new->h_length = temp->h_length;
   new->h_aliases[0] = (char*)strdup(temp->h_aliases[0]);
   new->h_addr_list[0] = (char*)strdup(*temp->h_addr_list);

   return new;
}

void do_arpheader_read(struct ether_arp *arp, FILE *dumpfil)
{
   /* The arp header read reads in the arp headers. -- SHOCKER!  */

   fread(arp, sizeof(struct ether_arp), 1, dumpfil);

   return;
}


void do_packet_stuff(FILE *dumpfil, int options, struct host_list *hosts) 
{
   /* The packet stuff involves checking for eof, reading in a packet, and
    * printing out the header.  If we're at eof, we're done, so quit. 
    * Otherwise, we're not done, so grab a packet and do it up.
   */

   long fp, skipper, end;
   struct dump_header dh;
   struct ether_header eh;
   struct ip ip;
   struct ether_arp arp;
   struct ether_count *ether_tally;
   struct ip_count *ip_tally;
   struct proto_count *tcp_tally, *udp_tally;
   struct eth_addr_count *ether_hosts_tally;
   struct ip_addr_count *ip_hosts_tally;
   int i;

   /* Where in the file are we?  I MUST have this information! */
   fp = ftell(dumpfil);
   end = fseek(dumpfil, 0, SEEK_END);
   end = ftell(dumpfil);
   skipper = fseek(dumpfil, fp, SEEK_SET);
   
   if(   IS_SET(options, OPT_ETHER)
      || IS_SET(options, OPT_ETH_SOUR)
      || IS_SET(options, OPT_ETH_DEST)) {
      ether_tally = (struct ether_count *)malloc(sizeof(struct ether_count));
      ether_tally->total=0;
      if(debug >= 5) printf("%ld\r\n", ether_tally->total);
      ether_tally->ip=0;
      ether_tally->arp=0;
      ether_tally->rarp=0;
   }

   if(   IS_SET(options, OPT_IP)
      || IS_SET(options, OPT_IP_SOUR)
      || IS_SET(options, OPT_IP_DEST)) {
      ip_tally = (struct ip_count*)malloc(sizeof(struct ip_count));
      ip_tally->total = 0;
      for(i=0;i<256;i++) ip_tally->types[i] = 0;
   }

   if(IS_SET(options, OPT_TCP)) {
      tcp_tally = (struct proto_count*)malloc(sizeof(struct proto_count));
      tcp_tally->total=0;
      for(i=0;i<1024;i++) tcp_tally->types[i] = 0;
   }

   if(IS_SET(options, OPT_UDP)) {
      udp_tally = (struct proto_count*)malloc(sizeof(struct proto_count));
      udp_tally->total=0;
      for(i=0;i<1024;i++) udp_tally->types[i] = 0;
   }

   if(IS_SET(options, OPT_ETH_SOUR) || IS_SET(options, OPT_ETH_DEST)) {
      ether_hosts_tally = (struct eth_addr_count*)malloc(sizeof(struct eth_addr_count));
      ether_hosts_tally->total = 0;
      for(i=0;i<1024;i++) ether_hosts_tally->hosts[i] = NULL;
   }

   if(IS_SET(options, OPT_IP_SOUR) || IS_SET(options, OPT_IP_DEST)) {
      ip_hosts_tally = (struct ip_addr_count*)malloc(sizeof(struct ip_addr_count));
      ip_hosts_tally->total = 0;
      for(i=0;i<1024;i++) ip_hosts_tally->hosts[i] = NULL;
   }

   /* According to the assignment, if the amount left in the file is ever less 
    * than the length of a dump header, then we're essentially at the end of the
    * file.  And since the dump header is 14 bytes long...  Well... You're a 
    * smart guy, you figure * it out.
   */

   while (fp + 14 < end) {

      if (debug >= 5) {
         printf("FP of first lseek - should give current position - %ld\n", fp);
      }

      /* packet_dumpheader_read will return to me the length of this dump 
       * packet.  This length, is therefore the amount I'll need to skip to hit
       * the next packet.  Pretty spiffy, eh?
      */
      skipper = packet_dumpheader_read(fp, &dh, dumpfil);
      diff = dh.len;
      if(debug >= 5) printf("%ld\r\n", diff);

      /* Packet counter - ala Osterman. */
      if(   IS_SET(options, OPT_ETHER)
         || IS_SET(options, OPT_ETH_SOUR)
         || IS_SET(options, OPT_ETH_DEST))
         if(IS_SET(options, OPT_PACKETS))
            ether_tally->total++;
         else
            ether_tally->total += diff - SIZE_DH; 
            
      if(IS_SET(options, OPT_PRINT))
         printf("Packet %ld  %ld\n", ether_tally->total, diff);
      
      /* We read it, so print it. */
      packet_dumpheader_print(&dh, options);
      
      fp = ftell(dumpfil);

      /* Read in and print the ethernet stuff. */
      packet_ethheader_read(&eh, dumpfil);
      if(   IS_SET(options, OPT_ETHER)
         || IS_SET(options, OPT_ETH_SOUR)
         || IS_SET(options, OPT_ETH_DEST))
         packet_ethheader_print(&eh, hosts, options, ether_hosts_tally);

      /* Figure out what type of packet is being carried by the ethernet packet,
       * and then read and print it out.
      */
      switch (eh.ether_type) {
         case ETHERTYPE_IP:
            do_ipheader_read(&ip, dumpfil);
            if(   IS_SET(options, OPT_IP)
               || IS_SET(options, OPT_TCP)
               || IS_SET(options, OPT_IP_SOUR)
               || IS_SET(options, OPT_IP_DEST)
               || IS_SET(options, OPT_UDP))
               do_ipheader_print(&ip, options, ip_tally, tcp_tally, udp_tally,
                                 ip_hosts_tally, dumpfil);
            if(IS_SET(options, OPT_ETHER))
               if(IS_SET(options, OPT_PACKETS))
                  ether_tally->ip++;
               else
                  ether_tally->ip += diff - SIZE_DH;
            break;
         case ETHERTYPE_ARP:
            if(IS_SET(options, OPT_ETHER)) {
               if(IS_SET(options, OPT_PACKETS))
                  ether_tally->arp++;
               else
                  ether_tally->arp += diff - SIZE_DH;
               if(IS_SET(options, OPT_PACKETS))
                  ether_tally->rarp--;
               else
                  ether_tally->rarp -= diff - SIZE_DH;
            }
         case ETHERTYPE_RARP:
            if(IS_SET(options, OPT_PRINT)) {
               do_arpheader_read(&arp, dumpfil);
               do_arpheader_print(&arp, hosts, options);
            }
            if(IS_SET(options, OPT_ETHER))
               if(IS_SET(options, OPT_PACKETS))
                  ether_tally->rarp++;
               else
                  ether_tally->rarp += diff - SIZE_DH;
            break;
         default:
            ;
      }

      /* Skip to the end of the packet */
      fseek(dumpfil, fp, SEEK_SET);
      fseek(dumpfil, skipper, SEEK_CUR);
      fp = ftell(dumpfil);
   }
   
   do_histo_print(options, ether_tally, ip_tally, tcp_tally, udp_tally,
                  ether_hosts_tally, ip_hosts_tally, hosts);

   return;
}

int main(argc, argv)
   int argc;
   char *argv[];
{
   struct host_list *hosts;   /* Our ethernet host table           */
   int options = 1;           /* What information do we want?      */
   int clo_done = FALSE;      /* Done reading Commandline options? */
   int i;                     /* Looper variable                   */
   FILE *dumpfil;             /* File we're reading from com-line  */
   int argv_counter = 1;      /* Number of com-line arguments      */
                              /* already parsed.  Default is 1     */

   while (   !clo_done 
          && (argv_counter < argc)) {
      if(argv[argv_counter][0] == '-') {
         i = 1;
         while(argv[argv_counter][i] && !isspace(argv[argv_counter][i])) {
            switch (argv[argv_counter][i]) {
               case 'p':
                  SET_BIT(options, OPT_PACKETS);
                  break;
               case 'b':
                  REMOVE_BIT(options, OPT_PACKETS);
                  break;
               case 'e':
                  SET_BIT(options, OPT_ETHER);
                  break;
               case 'i':
                  SET_BIT(options, OPT_IP);
                  break;
               case 't':
                  SET_BIT(options, OPT_TCP);
                  break;
               case 'u':
                  SET_BIT(options, OPT_UDP);
                  break;
               case 'd':
                  SET_BIT(options, OPT_ETH_DEST);
                  break;
               case 's':
                  SET_BIT(options, OPT_ETH_SOUR);
                  break;
               case 'D':
                  SET_BIT(options, OPT_IP_DEST);
                  break;
               case 'S':
                  SET_BIT(options, OPT_IP_SOUR);
                  break;
               case 'P':
                  SET_BIT(options, OPT_PRINT);
                  break;
               case 'N':
                  SET_BIT(options, OPT_NONAMES);
                  break;
               case 'T':
                  SET_BIT(options, OPT_TIMED);
                  break;
               case 'a':
                  SET_BIT(options, OPT_ETHER);
                  SET_BIT(options, OPT_IP);
                  SET_BIT(options, OPT_TCP);
                  SET_BIT(options, OPT_UDP);
                  SET_BIT(options, OPT_ETH_DEST);
                  SET_BIT(options, OPT_ETH_SOUR);
                  SET_BIT(options, OPT_IP_DEST);
                  SET_BIT(options, OPT_IP_SOUR);
                  break;
               default:
                  printf("Invalid command flags.\r\n");
                  printf("Options: -[pbeitudsDSa] infile\r\n\r\n");
                  exit(1);
            }
            i++;
         }
         argv_counter++;
      } else
         clo_done = TRUE;
   }  
 
   /* Open up the file we're reading in. */
   if (argv_counter >= argc) {
      printf("Invalid call to netlook.  Must supply a dump file name on the command line.\r\n");
      printf("Options: -[pbeitudsDSa] infile\r\n\r\n");
      exit(1);
   } else {
      dumpfil = fopen(argv[argv_counter], "r");

      if (!dumpfil) {
         perror("Unable to open infile");
      }
   }

   gen_crc_table();

   /* Fill the host table */
   hosts = NULL;
   if(   IS_SET(options, OPT_ETH_SOUR)
      || IS_SET(options, OPT_ETH_DEST))
      hosts = fill_host_table(hosts);

   /* Check the tcpdumpfile magic number.  If the magic number is wrong, quit 
    * out.  Otherwise do all that voodoo that I do that you want me to do, but I
    * do it so it well.  Ain't that swell?
   */

   if (do_check_dfh(dumpfil)) {
      do_packet_stuff(dumpfil, options, hosts);
   } else {
      printf("Error - Magic field is invalid.\n");
      exit(1);
   }
   fclose(dumpfil);
   exit(0);
}
