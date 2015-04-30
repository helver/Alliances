-- users
--
-- Users contains all the information we want to know about all users of 
-- GeoNet.
CREATE TABLE users (
  id NUMBER NOT NULL PRIMARY KEY,  -- Primary Key comes from user_id_seq
  lastname VARCHAR2(40) NOT NULL,  -- User's Last Name
  firstname VARCHAR2(40) NOT NULL, -- User's First Name
  middlename VARCHAR2(8),          -- User's Middle Name
  email VARCHAR2(70) NOT NULL,     -- User's Email Address
  primususername VARCHAR2(30),     -- User's Primus Username
  acf2id VARCHAR2(10)							 -- User's ACF2 ID
);
