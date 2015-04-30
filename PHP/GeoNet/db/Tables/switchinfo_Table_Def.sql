-- switchinfo
-- pnni table
--
CREATE TABLE SWITCHINFO (
  CUSTOMER VARCHAR2(100), 
  CONNECTION VARCHAR2(50), 
  CONNECTIONALIAS VARCHAR2(50), 
  NVCID VARCHAR2(15), 
  LINERATE VARCHAR2(5), 
  CLLI VARCHAR2(15), 
  ENCID NUMBER(10), 
  IP VARCHAR2(15), 
  ASXPORT NUMBER(5), 
  ENGPORT VARCHAR2(15), 
  VP NUMBER(8), 
  CBRNUM NUMBER(10), 
  QOS NUMBER(10), 
  BANDWIDTH NUMBER(3), 
  ENDCLLI VARCHAR2(15), 
  ENDPORT VARCHAR2(15), 
  ENDVP NUMBER(8),
  ENDPOINT VARCHAR2(25),
  VC NUMBER(8),
  ENDVC NUMBER(8),
  POLLFREQUENCY NUMBER(2),
  CONNECTIONTYPE VARCHAR2(15),
  TESTTYPE VARCHAR2(20),
  NSAP VARCHAR2(40)
);
