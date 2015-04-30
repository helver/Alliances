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
"@(#) $Id: tcplibgenh.c,v 1.3 1992/02/04 08:08:42 jamin Exp jamin $ (USC)";
#endif

#include <stdio.h>
#include <string.h>
#include <errno.h>

#include "tcplibgen.h"
#include "tcplibutils.h"
#include "tcplib.h"

extern long gen_tbl();
extern void gen_histmap();
extern void usage();

main(argc, argv)
  int argc;
  char **argv;
{
  FILE *tc_file;
  FILE *h_file;
  FILE *dist_file;
  char *filename;
  char h_name[MAXHNAMELEN];
  char dist_filename[MAXPATHLEN];

  int i = 0;
  struct histmap *histmap = (struct histmap *) calloc(MAXHIST, sizeof(*histmap));

  /*
   * Name of application to characterize.
  */
  if (!argv[1])
    usage(argv[0]);

  filename = (char *) malloc((strlen(argv[1]) + strlen(EXT) + 1) * sizeof(char));
  filename = strappend(filename, argv[1], EXT);
  tc_file = fopen(filename, "r");
  if (!tc_file) {
    perror(filename);
    exit(1);
  }
  free(filename);

  /*
   * Create application's traffic characteristics file.
   * Prepend the copyright notice.
  */
  filename = (char *) malloc((strlen(argv[1]) + 3) * sizeof(char));
  filename = strappend(filename, argv[1], ".h");
  h_file =  fopen(filename, "a");
  if (!h_file) {
    perror(filename);
    exit(1);
  }
  free(filename);
    
  /*
   * Build the histogram of the application characteristics
   * one by one, storing as struct in appname.h.
  */
  for (i = 0; 
       i < MAXHIST && 
       fscanf(tc_file, "%s %*s %s\n", h_name, dist_filename) != EOF;
       i++) {

    dist_file = fopen(dist_filename, "r");
    if (!dist_file) {
      perror(dist_filename);
      exit(1);
    }
    histmap[i].h_name = (char *) malloc((strlen(h_name)+1)*sizeof(char));
    strcpy(histmap[i].h_name, h_name);
    histmap[i].nbins = gen_tbl(dist_file, h_file, h_name);
    fclose(dist_file);
  }

  if (i == MAXHIST) {
    perror("Too many characteristics.");
    exit(1);
  }

  fclose(tc_file);

  gen_histmap(h_file, argv[1], histmap);
  fclose(h_file);

  exit(0);
}

void
usage(prog)
	char *prog;
{
  (void)fprintf(stderr, "Usage: %s <appname>\n", prog);
  exit(1);
}

long
gen_tbl(ifp, ofp, h_name)
  FILE *ifp;
  FILE *ofp;
  char *h_name;
{
  long n_entries = 0L;
  float val;
	float oval;
	float prob = 1.1;   /* initialize with invalid value */
  float oprob;

  skip_line(ifp, 1);   /* skip title in input file */
  fprintf(ofp, "static struct entry %s[] = {\n", h_name);

	fscanf (ifp, "%f\t%f\t%*f\t%*f\n", &oval, &oprob);
	fscanf (ifp, "%f\t%f\t%*f\t%*f\n", &val, &prob);
  while(!feof(ifp)) {
		if (prob != oprob) {
			n_entries++;
    	fprintf(ofp,"  { %f, %f },\n", oval, oprob);
			oval = val;
			oprob = prob;
			fscanf (ifp, "%f\t%f\t%*f\t%*f\n", &val, &prob);
		} else {
			oval = val;
			fscanf (ifp, "%f\t%f\t%*f\t%*f\n", &val, &prob);
		}
	}
	if (prob != oprob) {
		n_entries++;
   	fprintf(ofp,"  { %f, %f },\n", oval, oprob);
	}
	n_entries++;
  fprintf(ofp,"  { %f, %f },\n", val, prob);
  fprintf(ofp, "};\n\n");

	return(n_entries);
}

void
gen_histmap(fp, appname, hmp)
  FILE *fp;
  char *appname;
  struct histmap *hmp;
{
  int i;

  fprintf(fp, "static struct histmap %s_histmap[] = {\n", appname);
  for (i = 0; i < MAXHIST && hmp[i].h_name != 0; i++) {
    fprintf(fp, "  { \"%s\", %d },\n", hmp[i].h_name, hmp[i].nbins);
	}
  fprintf(fp, "};\n");

  if (i == MAXHIST) {
    perror("Too many characteristics.");
    exit(1);
  }

}
