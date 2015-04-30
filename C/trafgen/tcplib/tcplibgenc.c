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
"@(#) $Id: tcplibgenc.c,v 1.2 1992/02/04 08:08:42 jamin Exp jamin $ (USC)";
#endif

#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/stat.h>

#include "tcplibgen.h"
#include "tcplibutils.h"
#include "tcplib.h"

#define TCPLIBFILE "tcplib.h"
#define TCAPIFILE "tcpapps.h"

extern void usage();
extern void init_cfile();
extern void gen_cfile();
extern void init_hfile();
extern void gen_hfile();

main(argc, argv)
  int argc;
  char **argv;
{
  int i = 0;
  FILE *tc_file;
  FILE *c_file;
  FILE *h_file;
  char *filename;
  char h_name[MAXHNAMELEN];
  char type[MAXTYPELEN];

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
   * The Makefile has prepended the copyright notice
   * to the application.c file which will house the
   * traffic characteristics generator.
  */
	filename = (char *) malloc((strlen(argv[1]) + 3) * sizeof(char));
  filename = strappend(filename, argv[1], ".c");
  c_file =  fopen(filename, "a");
  if (!c_file) {
    perror(filename);
    exit(1);
  }
  free(filename);
    
  h_file = fopen(TCAPIFILE, "r+");
  if (!h_file) {
    perror(TCAPIFILE);
    exit(1);
  }

  /*
   * Build the api of the application characteristics
   * one by one, storing as fcns in appname.c.
  */ 
  init_hfile(h_file, argv[1]);
  init_cfile(c_file, argv[1]);

  while(i < MAXHIST &&
        fscanf(tc_file, "%s\t%s\t%*s\n", h_name, type) != EOF) {

    gen_hfile(h_file, type, argv[1], h_name);
    gen_cfile(c_file, type, argv[1], h_name);
  }

  fclose(tc_file);
  fclose(h_file);
  fclose(c_file);

  exit(0);
}

void
init_cfile(fp, app)
  FILE *fp;
  char *app;
{
  fprintf(fp, "#include \"%s\"\n", TCPLIBFILE);
  fprintf(fp, "#include \"%s.h\"\n", app);
}

void
gen_cfile(fp, type, app, hist)
  FILE *fp;
  char *type;
  char *app;
  char *hist;
{
  fprintf(fp, "\n%s\n%s_%s()\n{\n", type, app, hist);
  fprintf(fp, "  return ((%s) tcplib(&%s_histmap[lookup(%s_histmap, \"%s\")], %s));\n",
              type, app, app, hist, hist);
  fprintf(fp, "}\n");
}

void
init_hfile(fp, app)
  FILE *fp;
  char *app;
{
  int i;
  char *bof;
  char *sec;
  struct stat *finfo = (struct stat *) calloc(1,sizeof(struct stat));

  if (fstat(fileno(fp), finfo) == -1) {
		perror("init_hfile fstat");
		exit(1);
	}
  bof = (char *) malloc(finfo->st_size * sizeof(char));
  if (!fread(bof, finfo->st_size, 1, fp)) {
		perror("init_hfile fread"); 
		exit(1);
	}

  /*
   * Find the header of app's section.
   */
  sec = strstr(bof, app);

  if (!sec) {
    fseek(fp, 0L, 2);
  } else {

    /*
     * Chop off the section.
    */
    /* get to the beginning of the section header */
    while (*sec-- != '/');
    fseek(fp, (long) (sec - bof), 0);

    /* find start of next section */
    sec = strstr(sec, app);
    sec = strstr(sec, "\n/*\n *");

    /* spit out next section */
		if (!sec) {
    	while (*sec) {
      	putc(*sec++, fp);
			}
		}

    ftruncate(fileno(fp), ftell(fp));

  }
  fprintf(fp, "\n/*\n * %s\n*/\n", app);
}

void
gen_hfile(fp, type, app, hist)
  FILE *fp;
  char *type;
  char *app;
  char *hist;
{  
  fprintf(fp, "extern %s %s_%s();\n", type, app, hist);
}

void
usage(prog)
	char *prog;
{
  (void)fprintf(stderr, "Usage: %s <appname>\n", prog);
  exit(1);
}
