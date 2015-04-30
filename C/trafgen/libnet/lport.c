/* lport.c - lport */

#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>

#include <stdio.h>

#include "libnet.h"

int
lport(fd)
    int fd;
{
    int port;
    struct  sockaddr_in     sin;
    int sinlen;

    sinlen = sizeof(sin);
    if (getsockname(fd, (struct sockaddr *)&sin, &sinlen) != 0) {
	perror("getsockname");
	exit(-1);
    }

    port = ntohs(sin.sin_port);

    return(port);
}
