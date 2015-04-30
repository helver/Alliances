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
"@(#) $Id: phonetest.c,v 1.1 1992/02/04 08:08:42 jamin Exp jamin $ (USC)";
#endif

#include <stdio.h>
#include "tcpapps.h"

#define SEED 47
#define DATAPOINTS 1000

main()
{
	int i;
	FILE *fp;

	srand48(SEED);

	fp = fopen("phone.talkspurt.v", "w");
  for (i = 0; i < DATAPOINTS; i++) {
    fprintf(fp, "%.3f\n", phone_talkspurt());
		fflush(fp);
  }
	fclose(fp);

	fp = fopen("phone.pause.v", "w");
  for (i = 0; i < DATAPOINTS; i++) {
    fprintf(fp, "%.3f\n", phone_pause());
  }
	fclose(fp);
}
