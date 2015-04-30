-- protocols
--
-- Protocols contain labels that match up to Perl Modules that implement a
-- particular communication mechanism to one or more element types.
CREATE TABLE protocols (
  id NUMBER NOT NULL PRIMARY KEY, -- Primary Key comes from protocol_id_seq
  name VARCHAR2(40) NOT NULL,     -- Protocol Name
  e1 VARCHAR2(25),                -- Label for Interface location component 1
  e2 VARCHAR2(25),                -- Label for Interface location component 2
  e3 VARCHAR2(25),                -- Label for Interface location component 3
  e4 VARCHAR2(25),                -- Label for Interface location component 4
  e5 VARCHAR2(25)                 -- Label for Interface location component 5
);
