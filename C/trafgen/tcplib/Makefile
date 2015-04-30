#
# Makefile for making tcplib and tcplibgen.  See tcplibgen(1)
# for documentation.
#
# @(#) $Id: Makefile,v 1.4 1991/10/19 17:02:53 jamin Exp jamin $ (USC)
#

.SUFFIXES: .h .tc

DATADIR = data
CC = gcc
CFLAGS = -O3

LIB = libtcp.a
TCPLIBAPI = tcpapps.h
TCPLIBGEN = COPYRIGHT tcplibgenh tcplibgenc $(TCPLIBAPI)

OBJS = tcplib.o tcplibutils.o telnet.o ftp.o nntp.o smtp.o phone.o http.o conv.o brkdn_dist.o distributions.o 
APPHDR = telnet.h ftp.h nntp.h smtp.h phone.h http.h conv.h
APPSRC = telnet.c ftp.c nntp.c smtp.c phone.c http.c conv.c

tcplib: $(LIB)
	touch tcplib

tcplibgen: tcplibgenh tcplibgenc

tcplibtest: tcplibtest.o $(LIB)
	$(CC) -o $@ $(CFLAGS) tcplibtest.o $(LIB) -lm

#
# The source library
#
$(LIB): $(OBJS)
	/usr/ccs/bin/ar rcv $@ $?
	/usr/local/bin/ranlib $@

#
# The traffic characteristic generator
# and the api generator.
#
tcplibgenh: tcplibgen.h tcplib.h tcplibgenh.o tcplibutils.o
	rm -f $(APPHDR)
	$(CC) -o $@ $(CFLAGS) tcplibgenh.o tcplibutils.o -lm

tcplibgenc: tcplibgen.h tcplib.h tcplibgenc.o tcplibutils.o
	rm -f $(APPSRC)
	cp COPYRIGHT $(TCPLIBAPI)
	chmod +w $(TCPLIBAPI)
	$(CC) -o $@ $(CFLAGS) tcplibgenc.o tcplibutils.o -lm

breakdown: breakdown.c
	$(CC) $(CFLAGS) -o breakdown breakdown.c -lm

clean:
	rm *.o $(APPSRC) $(APPHDR) tcplibgenc tcplibgenc tcplibtest breakdown libtcp.a

#
# The traffic characteristics per application.
#
brkdn_dist.o: $(DATADIR)/breakdown brkdn_dist.h brkdn_dist.c breakdown distributions.h
	cp COPYRIGHT app_brkdn.h
	./breakdown
	$(CC) $(CFLAGS) -c brkdn_dist.c 

distributions.o: $(TCPLIBGEN) distributions.h distributions.c
	$(CC) $(CFLAGS) -c distributions.c 

telnet.o: telnet.tc $(TCPLIBGEN) telnet.h telnet.c
	$(CC) $(CFLAGS) -c telnet.c

ftp.o: ftp.tc $(TCPLIBGEN) ftp.h ftp.c
	$(CC) $(CFLAGS) -c ftp.c

smtp.o: smtp.tc $(TCPLIBGEN) smtp.h smtp.c
	$(CC) $(CFLAGS) -c smtp.c

nntp.o: nntp.tc $(TCPLIBGEN) nntp.h nntp.c
	$(CC) $(CFLAGS) -c nntp.c

phone.o: phone.tc $(TCPLIBGEN) phone.h phone.c
	$(CC) $(CFLAGS) -c phone.c

http.o: http.tc $(TCPLIBGEN) http.h http.c
	$(CC) $(CFLAGS) -c http.c

conv.o: conv.tc $(TCPLIBGEN) conv.h conv.c
	$(CC) $(CFLAGS) -c conv.c
#
# The dependency rules for the generators.
#
.tc.h: 
	cp COPYRIGHT $*.h
	chmod +w $*.h
	./tcplibgenh $*

.tc.c:
	cp COPYRIGHT $*.c
	chmod +w $*.c
	./tcplibgenc $*
