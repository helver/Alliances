/* connectTCP.c - connectTCP */

#include "libnet.h"

/*------------------------------------------------------------------------
 * connectTCP - connect to a specified TCP service on a specified host
 *------------------------------------------------------------------------
 */

int
connectTCP( host, service )
char    *host;          /* name of host to which connection is desired  */
char    *service;       /* service associated with the desired port     */
{
        return connectsock( host, service, "tcp");
}
