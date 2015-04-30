-- interfaces
--
-- Interfaces contains information about the default values for each 
-- interface on a particular elmeent type.
CREATE TABLE interfaces (
  id NUMBER NOT NULL PRIMARY KEY, -- Primary Key comes from interface_id_seq
  name VARCHAR2(50) NOT NULL,     -- Interface Name
  e1 VARCHAR2(25),                -- Interface location component 1
  e2 VARCHAR2(25),                -- Interface location component 2
  e3 VARCHAR2(25),                -- Interface location component 3
  e4 VARCHAR2(25),                -- Interface location component 4
  e5 VARCHAR2(25),                -- Interface location component 5
  keephistory CHAR(1) NOT NULL,   -- Keep History for this interface?
  note VARCHAR2(100),             -- Note attached to this interface
  channel_order NUMBER,           -- Which line item matching our criteria actually belongs to this interface?
  interface_type_id NUMBER NOT NULL REFERENCES interface_types(id) -- What element type this interface is for.
);
