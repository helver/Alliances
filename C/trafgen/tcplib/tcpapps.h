/*
 * DO NOT MODIFY THIS FILE.  IT IS AUTOMATICALLY GENERATED
 * BY THE TCPLIBGEN PROGRAMS.  ALL CHANGES HERE WILL BE DELETED.
*/

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


/*
 * telnet
*/
extern int telnet_pktsize();
extern float telnet_interarrival();
extern float telnet_duration();

/*
 * ftp
*/
extern int ftp_nitems();
extern int ftp_itemsize();
extern int ftp_ctlsize();

/*
 * nntp
*/
extern int nntp_nitems();
extern int nntp_itemsize();

/*
 * smtp
*/
extern int smtp_itemsize();

/*
 * phone
*/
extern float phone_talkspurt();
extern float phone_pause();

/*
 * http
*/
extern int http_itemsize();

/*
 * conv
*/
extern int conv_conv_time();
