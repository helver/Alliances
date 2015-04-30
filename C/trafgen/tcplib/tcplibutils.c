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
"@(#) $Id: tcplibutils.c,v 1.2 1992/02/04 08:08:42 jamin Exp jamin $ (USC)";
#endif

#include <stdio.h>
#include <math.h>
#include "tcplibutils.h"

char *
strappend(sp, s1, s2)
  char *sp;
  char *s1;
  char *s2;
{
  char *s = sp;

  while (*s++ = *s1++);
  s--;
  while (*s++ = *s2++);

  return(sp);
}

void
skip_line(fp, n)
  FILE *fp;
  int n;
{
	char c;

  for (n; n > 0; n--)
    while ((c = getc(fp)) != '\n' && c != EOF);
}

