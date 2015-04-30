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
"@(#) $Id: brkdn_dist.c,v 1.1 1992/02/04 08:08:42 jamin Exp jamin $ (USC)";
#endif

#include <math.h>
#include "drand48.h"
#include "distributions.h"

struct app_brkdn {
	char *appname;
	float mean;
	float mean_sqr;
	float var;
};

#include "app_brkdn.h"
#include "brkdn_dist.h"
#include "distributions.h"

struct brkdn_dist *
brkdn_dist()
{
	int i;
	struct brkdn_dist *apps = (struct brkdn_dist *) malloc(NUMAPP*sizeof(struct brkdn_dist));
	float normalizer = 0.0;

	for (i = 0; i < NUMAPP; i++) {
		apps[i].appname = apps_brkdn[i].appname;
		apps[i].cdf = gam_dist(apps_brkdn[i].mean, apps_brkdn[i].mean_sqr, apps_brkdn[i].var);
		normalizer += apps[i].cdf;
	}

	apps[0].cdf /= normalizer;
	for (i = 1; i < NUMAPP; i++) {
		apps[i].cdf /= normalizer;
		apps[i].cdf += apps[i-1].cdf;
	}

	return apps;
}

char *
next_app(brkdn)
	struct brkdn_dist brkdn[];
{
	int i = 0;
	float prob = (float) drand48();

	while (i < NUMAPP && brkdn[i].cdf < prob) i++;
	if (i == NUMAPP)
		{
		/*error("next_app: bad prob %e", prob);*/
		}
	return brkdn[i].appname;
}
