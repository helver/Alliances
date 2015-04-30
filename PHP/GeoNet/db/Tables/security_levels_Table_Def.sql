-- security_levels
--
-- Security levels give a label to the available security levels in the 
-- system.
CREATE TABLE security_levels (
  id NUMBER NOT NULL PRIMARY KEY, -- Primary Key
  name VARCHAR2(20) NOT NULL      -- Security Level Name
);
