#include <sys/time.h>
#include <pthread.h>

struct traf_gen {
    int id;
    int type;
    char *address;
    int delay;
    char *control_buf;
    char *traffic_buf;
    int control_size;
    int traffic_size;
    int items;
    int descriptor;
    int ftp_data_descriptor;
    int active_timer;
    int inactive_timer;
    int port;
    int slave_delay;
    int active;
    int rate;
    struct timeval start;
    struct timeval last;
    pthread_t desc_thrd;
    struct traf_gen *master;
    struct traf_gen *next;
};

void quit(int signum, siginfo_t *psiginfo, void *junk);
void Signal(int signum);
void * thread_connectTCP(void *);
void clear_traf(struct traf_gen *this);
int parse_configuration(char *conf_file);
void characterize_traffic();
int sort_schedule_list();
void set_schedule(struct traf_gen *list);
void print_schedule(struct traf_gen *schedule);
void characterize_ftp(struct traf_gen *this);
void characterize_telnet(struct traf_gen *this);
void characterize_nntp(struct traf_gen *this);
void characterize_smtp(struct traf_gen *this);
void characterize_http(struct traf_gen *this);
void * generate_traffic(void *);
int yyerror(char *s);
int yywrap();
struct traf_gen * new_traffic_item(struct traf_gen *loop);
void free_traffic(struct traf_gen *this);
static void SetMaxFiles(int max);

#define TYPE_FTP         0
#define TYPE_FTP_DATA    1
#define TYPE_NNTP        2
#define TYPE_SMTP        3
#define TYPE_TELNET      4
#define TYPE_UDP         5
#define TYPE_HTTP        6
#define TYPE_TCPLIB      7
#define TYPE_TL_FTP      8
#define TYPE_TL_FTP_DATA 9
#define TYPE_TL_NNTP     10
#define TYPE_TL_SMTP     11
#define TYPE_TL_TELNET   12
#define TYPE_TL_UDP      13
#define TYPE_TL_HTTP     14

#define DEFAULT_PORT 9000
#define DEFAULT_HOST "jarok.cs.ohiou.edu"
#define DEFAULT_MTU  512
#define DEFAULT_RATE 1024

#define OPTIMAL_LOOP_TIME 100000
