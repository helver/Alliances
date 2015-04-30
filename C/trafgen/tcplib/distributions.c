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
*/
#ifndef lint
static char rcsid[] =
"@(#) $Id: distributions.c,v 1.1 1992/02/04 08:08:42 jamin Exp jamin $ (USC)";
#endif

#include <math.h>
#include "drand48.h"
#include "distributions.h"

/* Numerical Recipes in C, p. 220. */
float
gam_dist(n, n2, s) 
	float n; 
	float n2; 
	float s;
{
    int i, r;
    double g, rm, rs, v1, v2, y, e;

    if (!s) return 0.0;

    r = nint((double) n2/s); /* Kleinrock, p. 124 */
    if (r < 1) { 
	/*perror("gam_dist: bad r\n");*/
	/*exit(1);*/
	r = 1;
    }

    if (r < 6) { 
	g = 1.0;
	for (i = 0; i <= r; i++)  {
	    g *= (float) drand48();
	}
	g = -log((double) g);
    } else {
	do {
	    do {
		do {
		    v1 = 2.0*drand48()-1.0;
		    v2 = 2.0*drand48()-1.0;
		} while (v1*v2+v1*v2 > 1.0);
		y = v2/v1;
		rm = r - 1;
		rs = sqrt(2.0*rm+1.0);
		g = rs*y+rm;
	    } while (g <= 0.0);
	    e = (1.0+y*y)*exp(rm*log((double) g/rm)-rs*y);
	} while (drand48() > e);
    }
    g = (double) ((g*(double)n)/(double)r);
    return((float) g);
} 
