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
"@(#) $Id: tcplib.c,v 1.2 1992/02/04 08:08:42 jamin Exp jamin $ (USC)";
#endif

#include <stdio.h>
#include <math.h>
#include "tcplib.h"

extern long lrand48();
int nint(n)
double n;
{
	if ((double)(n- (int)n) >= 0.5)
		n++;
	return ((int)n);
}

int
lookup(hmp, h_name)
  struct histmap *hmp;
  char *h_name;
{
  int i;
  struct histmap *p;

  for (i = 0, p = hmp; i < MAXHIST && p->h_name != 0 && strcmp(p->h_name, h_name); i++, ++p);
  if (i == MAXHIST) {
    perror("Too many characteristics.");
    exit(1);
  }
  if (p->h_name == 0) {
    perror("Characteristic not found.");
    exit(1);
  }

  return(i);
}

#define MAXRAND 2147483647
#define uniform_rand(from, to)\
  ((from) + (((double) lrand48()/MAXRAND) * ((to) - (from))))

double
tcplib(hmp, tbl)
  struct histmap *hmp;
  struct entry *tbl;
{
  float prob;
	int maxbin = hmp->nbins-1;
	int base = 0;
	int bound = maxbin;
  int mid = nint((float)maxbin / 2.0);
  
  prob = ((float) (lrand48() % PRECIS)) / (float) PRECIS;

	do {
  while (prob <= tbl[mid-1].prob && mid != 1) {
		bound = mid;
   	mid -= nint(((float)(mid - base)) / 2.0);
	} 
	while (prob > tbl[mid].prob) {
		base = mid;
   	mid += nint(((float)(bound - mid)) / 2.0);
	}
	} while (!(mid == 1 || (prob >= tbl[mid-1].prob && prob <= tbl[mid].prob)));
      
	if (mid == 1 && prob < tbl[0].prob) {
  	return ((double) tbl[0].value);
	} else {
  	return ((double) uniform_rand(tbl[mid-1].value, tbl[mid].value));
	}
}
