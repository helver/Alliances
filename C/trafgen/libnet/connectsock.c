/* connectsock.c - connectsock */

#include <sys/types.h>
#include <sys/socket.h>
#include <stdio.h>
#include <unistd.h>


#include <netinet/in.h>
#include <netinet/tcp.h>

#include <netdb.h>

#include "libnet.h"

#ifndef INADDR_NONE
#define INADDR_NONE     0xffffffff
#endif  /* INADDR_NONE */

extern int      errno;
extern char     *sys_errlist[];

/*
u_short htons();
*/
u_long  inet_addr();

/*------------------------------------------------------------------------
 * connectsock - allocate & connect a socket using TCP or UDP
 *------------------------------------------------------------------------
 */
int
connectsock( host, service, protocol )
char    *host;          /* name of host to which connection is desired  */
char    *service;       /* service associated with the desired port     */
char    *protocol;      /* name of protocol to use ("tcp" or "udp")     */
{
        struct hostent  he;   /* pointer to host information entry    */
        struct servent  se;   /* pointer to service information entry */
        struct protoent pre;   /* pointer to protocol information entry*/
        struct sockaddr_in sin; /* an Internet endpoint address         */
        int     s, type;        /* socket descriptor and socket type    */
	char large_buf[1000];
	int errme;
	char val = 1;
	char buffer[2056];
	int buflen = 2056;

        bzero((char *)&sin, sizeof(sin));
        sin.sin_family = AF_INET;

    /* Map service name to port number */
        if ((getservbyname_r(service, protocol, &se, large_buf, sizeof(large_buf))))
                sin.sin_port = se.s_port;
        else if ( (sin.sin_port = htons((u_short)atoi(service))) == 0 )
                errexit("can't get \"%s\" service entry\n", service);

    /* Map host name to IP address, allowing for dotted decimal */
        if ((gethostbyname_r(host, &he, large_buf, sizeof(large_buf), &errme)))
                bcopy(he.h_addr, (char *)&sin.sin_addr, he.h_length);
        else if ( (sin.sin_addr.s_addr = inet_addr(host)) == INADDR_NONE )
                errexit("can't get \"%s\" host entry\n", host);

    /* Map protocol name to protocol number */
/*         if ( (getprotobyname_r(protocol, &pre, buffer, buflen)) == 0) */
/*                 errexit("can't get \"%s\" protocol entry\n", protocol); */

    /* Use protocol to choose a socket type */
        if (strcmp(protocol, "udp") == 0)
                type = SOCK_DGRAM;
        else
                type = SOCK_STREAM;

    /* Allocate a socket */
        s = socket(PF_INET, type, 6);
	
/* 	if(setsockopt(s, pre.p_proto, TCP_NODELAY, &val, sizeof(val)) != 0) { */
/* 	    printf("Error setting socket option NODELAY\n"); */
/* 	    exit(1); */
/* 	} */
	    
        if (s < 0)
                errexit("can't create socket: %s\n", sys_errlist[errno]);

    /* Connect the socket */
        if (connect(s, (struct sockaddr *)&sin, sizeof(sin)) < 0) {
                printf("can't connect to %s.%s: %s  fd:(%d)\n", host, service,
                        sys_errlist[errno], s);
		close(s);
		return -1;
	}

/*	printf("This is s - %d\n", s);*/
        return s;
}
