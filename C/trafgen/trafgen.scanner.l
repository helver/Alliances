%{

    /* This is the trafgen scanner.  It will be used to
       pick tokens out of the trafgen configuration
       files.
    */

#include <string.h>
#include "parser.h"

static int debug = 0;

%}

WHITESPACE [ \t\r]

%%

{WHITESPACE}+ {
    if(debug >= 5)
	printf("Found whitespace.\n");
}

"rate" {
    if(debug >= 5)
	printf("Found rate marker.\n");
    return(RATE);
}

"dur" {
    if(debug >= 5)
	printf("Found duration marker.\n");
    return(DUR);
}

"delay" {
    if(debug >= 5)
	printf("Found delay marker.\n");
    return(DELAY);
}

"streams" {
    if(debug >= 5)
	printf("Found streams marker.\n");
    return(STREAMS);
}

"size" {
    if(debug >= 5)
	printf("Found size marker.\n");
    return (SIZE);
}

"addr" {
    if(debug >= 5)
	printf("Found address marker.\n");
    return(ADDR);
}

"port" {
    if(debug >= 5)
	printf("Found port marker.\n");
    return(PORT);
}

"telnet" {
    if(debug >= 5)
	printf("Found telnet.\n");
    return(TELNET);
}

"ftp" {
    if(debug >= 5)
	printf("Found ftp.\n");
    return(FTP);
}

"udp" {
    if(debug >= 5)
	printf("Found udp.\n");
    return(UDP);
}

"nntp" {
    if(debug >= 5)
	printf("Found nntp.\n");
    return(NNTP);
}

"smtp" {
    if(debug >= 5)
	printf("Found smtp.\n");
    return(SMTP);
}

"http" {
    if(debug >= 5)
	printf("Found http.\n");
    return(HTTP);
}

"tcplib" {
    if(debug >= 5)
	printf("Found tcplib.\n");
    return(TCPLIB);
}

"cbr" {
    if(debug >= 5)
	printf("Found cbr tag.\n");
    return(CBR);
}

[0-9]+ {
    if(debug >= 4) {
	printf("Found a single number.\n");
	printf("%s\n", yytext);
    }
    yylval.number = atoi(yytext);

    if(debug >= 5)
	printf("Int - %d\n", yylval.number);

    return(NUM);
}

[0-9]+[bBgGmMkK] {
    if(debug >= 3) 
	printf("Found a size with units.\n");
    yylval.string = strdup(yytext);
    return (SIZE_STRING);
}

[0-9]+"."[0-9]+"."[0-9]+"."[0-9]+ {
    if(debug >= 3)
	printf("Found a dotted decimal IP address.\n");
    yylval.string = strdup(yytext);
    return(NUM_IP);
}

[a-z0-9]+\.[a-z0-9\.]+ {
    if(debug >= 3)
	printf("Found a potential canonical host name.\n");
    yylval.string = strdup(yytext);
    return(CAN_IP);
}

[^ \n~+]* {
    if(debug >= 3)
	printf("Found a word.\r\n");
    yylval.string = strdup(yytext);
    return (WORD);
}

%%
