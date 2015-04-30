
#include <stdio.h>

#include "libnet.h"

/****************************************************************************/
/*                                                                          */
/* This prints a given error message, and then exits with an error (i.e.,   */
/* a non-zero value).                                                       */
/*                                                                          */
/****************************************************************************/

void errexit (format,str1,str2,str3,str4,str5)
char *format;
char *str1, *str2, *str3, *str4, *str5;
{
    fprintf (stderr,format,str1,str2,str3,str4,str5);
    exit (1);
}

