
CC = /usr/local/gnu/gcc
CFLAGS = -O3 -Wall 
LIBS = -lsocket -lnsl -lpthread -lposix4 -Llibnet -lnet -Ltcplib -ltcp -lm 
OBJECTS = y.tab.o lex.yy.o trafgen.o

trafgen : ${OBJECTS} trafgen.h
	cd libnet ; $(MAKE) CC=$(CC) ; cd ..
	cd tcplib ; $(MAKE) CC=$(CC) ; cd ..
	${CC} ${CFLAGS} ${OBJECTS} -o trafgen ${LIBS}

stats : my_stats.o mystats.h
	${CC} ${CFLAGS} my_stats.o -o stats

mysleep : mysleep.o
	${CC} ${CFLAGS} mysleep.o -o mysleep ${LIBS}

y.tab.c : trafgen.parser.y
	yacc -dvt ${YFLAGS} trafgen.parser.y
	cmp -s y.tab.h parser.h || cp y.tab.h parser.h

lex.yy.c : trafgen.scanner.l 
	lex ${LFLAGS} trafgen.scanner.l

trafgen.o : trafgen.parser.y

tcplib2xplt: tcplib2xplt.c
	${CC} -g3 -Wall tcplib2xplt.c -o tcplib2xplt -lm

clean : 
	/bin/rm -f ${OBJECTS} y.tab.h y.tab.c lex.yy.c parser.h y.output trafgen stats my_stats.o mysleep tcplib2xplt
	cd libnet ; $(MAKE) clean ; cd ..
	cd tcplib ; $(MAKE) clean
