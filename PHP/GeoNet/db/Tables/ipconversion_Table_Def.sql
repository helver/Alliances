-- ipconversion

-- pnni table
CREATE TABLE IPCONVERSION
(
 CLLI VARCHAR2(25) NOT NULL,
 IP VARCHAR2(15) NOT NULL,
 FABRIC VARCHAR2(15),
 PUBLIC_SNMP VARCHAR2(10),
 PRIVATE_SNMP VARCHAR2(10)
);

-- insert into ipconversion select * from pnni.ipconversion@ntacdata;