
CC = gcc
CFLAGS = -g -Wall
NETLIB = libnet.a
NETLIBFILES = passivesock.o passiveUDP.o passiveTCP.o \
	connectsock.o connectUDP.o connectTCP.o \
	lport.o errexit.o

default: $(NETLIB)

${NETLIB}: ${NETLIBFILES}
	ar cr ${NETLIB} ${NETLIBFILES}
	ranlib ${NETLIB}
	
clean:
	rm -f $(NETLIB) $(NETLIBFILES) core*

depend:
	maketd $(CFLAGS) *.c

# DO NOT DELETE THIS LINE - maketd DEPENDS ON IT
# Dependencies generated at: Mon Dec 26 02:00:21 EST 1994

connectTCP.o: libnet.h
connectTCP.o: connectTCP.c
connectUDP.o: libnet.h
connectUDP.o: connectUDP.c
connectsock.o: libnet.h
connectsock.o: connectsock.c
errexit.o: libnet.h
errexit.o: errexit.c
lport.o: libnet.h
lport.o: lport.c
passiveTCP.o: libnet.h
passiveTCP.o: passiveTCP.c
passiveUDP.o: libnet.h
passiveUDP.o: passiveUDP.c
passivesock.o: libnet.h
passivesock.o: passivesock.c

# DO NOT ADD ANYTHING HERE - WILL GO AWAY
