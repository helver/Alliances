/* file header */
#define TCPDUMP_MAGIC 0xa1b2c3d4
struct dump_file_header {
        u_int   magic;
        u_short version_major;
        u_short version_minor;
        int     thiszone;       /* gmt to local correction */
        u_int   sigfigs;        /* accuracy of timestamps */
        u_int   snaplen;        /* max length saved portion of each pkt */
        u_int   linktype;       /* data link type (DLT_*) */
};


/*
 * Each packet in the dump file is prepended with this generic header.
 * This gets around the problem of different headers for different
 * packet interfaces.
 */
struct dump_header {
        u_int   ts_secs;        /* time stamp -- seconds */
        u_int   ts_usecs;       /* time stamp -- useconds */
        u_int   caplen;         /* length of portion present */
        u_int   len;            /* length this packet (off wire) */
};


#define IPPORT_HTTP 80
#define IPPORT_NNTP 119

#define IPPORT_LOGIN 513
#define IPPORT_KLOGIN 542
#define IPPORT_OLDLOGIN 49
#define IPPORT_FLN_SPX 221
#define IPPORT_UUCP_LOGIN 541
#define IPPORT_KLOGIN2 543
#define IPPORT_NLOGIN 758

#define IPPORT_NFS 2049


int check_dfh(FILE *dumpfil);
long handle_dump_header(FILE *dumpfil);
int handle_ether_header(FILE *dumpfil);
u_char handle_ip_header(FILE *dumpfil);
void dump_split(FILE* fil);
void handle_tcp_header(FILE* fil);
void handle_udp_header(FILE* fil);


struct converse {
    long addr1;
    long addr2;
    int port;

    int type;
    u_int start_sec;
    u_int start_usec;
    u_int last_sec;
    u_int last_usec;
    long bytes;
    int finned;
    long count;

    struct converse *next;
};
