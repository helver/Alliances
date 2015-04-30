/*
 * Copyright (c) 1991 University of Southern California.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms are permitted
 * provided that the above copyright notice and this paragraph are
 * duplicated in all such forms and that any documentation,
 * advertising materials, and other materials related to such
 * distribution and use acknowledge that the software was developed
 * by the University of Southern California. The name of the University 
 * may not be used to endorse or promote products derived from this 
 * software without specific prior written permission.
 * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
 * WARRANTIES OF MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.
 *
*/
#ifndef lint
static char rcsid[] =
"@(#) $Id: tcplibtest.c,v 1.2 1992/02/04 08:08:42 jamin Exp jamin $ (USC)";
#endif

#include <stdio.h>
#include "tcpapps.h"

#define SEED 467
extern void srand48();

main(argc, argv)
  int argc;
  char **argv;
{
  int i;
  int n;
	unsigned long seconds;

  switch(argc) {
  case 1:
    n = 2;
    srand48(SEED);
    break;
  case 2:
    n = isdigit(*argv[1]) ? atoi(argv[1]) : 2;
    srand48(SEED);
    break;
  case 3:
    n = isdigit(*argv[1]) ? atoi(argv[1]) : 2;
    srand48(isdigit(*argv[1]) ? atoi(argv[2]) : SEED);
    break;
  }

  for (i = 0; i < n; i++) {
    printf("\nTelnet:\n");
    printf("  pktsize:  %d\n", telnet_pktsize());
		seconds = ((unsigned long) telnet_interarrival()) * 1000L;
    printf("  interarrival: %d s %d us\n", seconds / 1000000, seconds % 1000000);
		seconds = ((unsigned long) telnet_duration()) * 1000L;
    printf("  duration: %d s %d us\n", seconds / 1000000, seconds % 1000000);
  
    printf("\nFTP:\n");
    printf("  ctlsize:  %d\n", ftp_ctlsize());
    printf("  nitems:   %d\n", ftp_nitems());
    printf("  itemsize: %d\n", ftp_itemsize());
  
    printf("\nNNTP:\n");
    printf("  nitems:   %d\n", nntp_nitems());
    printf("  itemsize: %d\n", nntp_itemsize());

    printf("\nSMTP:\n");
    printf("  itemsize: %d\n", smtp_itemsize());

    printf(">\n");
  }
}
