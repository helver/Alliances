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
"@(#) $Id: breakdown.c,v 1.1 1992/02/04 08:08:42 jamin Exp jamin $ (USC)";
#endif

#include <stdio.h>
#include <math.h>

#define NUMAPP 7 
#define APPLEN 10
#define DATAFILE "data/breakdown"
#define OUTFILE "app_brkdn.h"

struct Xsite {
  float prob;
  struct Xsite *next;
}

main()
{
  int i, count, ok = 1;
  FILE *ifp, *ofp;
  char appname[NUMAPP][APPLEN];
  struct Xsite *Xi, *Xapp[NUMAPP];
	float Xbar, Var;

  ifp = fopen(DATAFILE, "r");
  if (!ifp) {
    perror(DATAFILE);
    exit(1);
  }

  fscanf(ifp, "%*s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n", 
         appname[0], appname[1], appname[2], appname[3], appname[4], appname[5], appname[6]);
	
	for (i = 0; i < NUMAPP; i++) {
		Xapp[i] = (struct Xsite *) 0;
	}

  while (ok != EOF) {
    for (i = 0; i < NUMAPP; i++) {
      Xi = (struct Xsite *) malloc(sizeof(struct Xsite));
      Xi->next = Xapp[i];
      Xapp[i] = Xi;
    }
    ok = fscanf(ifp, "%*s\t%f\t%f\t%f\t%f\t%f\t%f\t%f\n", 
                &Xapp[0]->prob,  &Xapp[1]->prob,  &Xapp[2]->prob,  &Xapp[3]->prob,  
		&Xapp[4]->prob, &Xapp[5]->prob, &Xapp[6]->prob);
  }
	fclose(ifp);

	ofp = fopen(OUTFILE, "a");
  if (!ofp) {
    perror(OUTFILE);
    exit(1);
  }

	fprintf(ofp, "#define NUMAPP %d\n\n", NUMAPP);
	fprintf(ofp, "static struct app_brkdn apps_brkdn[] = {\n");

	for (i = 0; i < NUMAPP; i++) {

		count = 1; Xbar = 0.0; Xi = Xapp[i];
		while (Xi) {
			if (Xi->prob) {
				Xbar += Xi->prob;
				count++;
			}
			Xi = Xi->next;
		}
		Xbar /= count;

		count = 0; Var = 0.0; Xi = Xapp[i];
		while (Xi) {
			if (Xi->prob) {
				Var += pow((Xi->prob - Xbar), 2.0);
				count++;
			}
			Xi = Xi->next;
		}
		if (count) Var /= count;

		fprintf(ofp, "\t{ \"%s\", %e, %e, %e },\n", 
						appname[i], Xbar, pow(Xbar, 2.0), Var);
	}
	fprintf(ofp, "\t{ 0 },\n};\n\n");
	fclose(ofp);
	exit(0);
}
