-- portconversion 

-- pnni table
CREATE TABLE PORTCONVERSION
(
   ENGPORT VARCHAR2(15), 
   ASXPORT NUMBER(5)
);

-- link to pnni.portconversion on the ntacdata server is portconversion_old
-- insert into portconversion select * from pnni.portconversion@ntacdata;