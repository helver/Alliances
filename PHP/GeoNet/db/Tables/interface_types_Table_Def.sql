-- interface_types
--
-- interface_types contains labels for PM counters and interface 
-- parameters.
CREATE TABLE interface_types (
  id NUMBER NOT NULL PRIMARY KEY,-- Primary Key comes from interface_type_id_seq
  name VARCHAR2(50) NOT NULL,    -- Name of this Interface Type
  namelbl VARCHAR2(50) NOT NULL, -- Label for Interface Name
  c1 VARCHAR2(25),               -- Label for PM Counter 1
  c2 VARCHAR2(25),               -- Label for PM Counter 2
  c3 VARCHAR2(25),               -- Label for PM Counter 3
  c4 VARCHAR2(25),               -- Label for PM Counter 4
  c5 VARCHAR2(25),               -- Label for PM Counter 5
  c6 VARCHAR2(25),               -- Label for PM Counter 6
  c7 VARCHAR2(25),               -- Label for PM Counter 7
  c8 VARCHAR2(25),               -- Label for PM Counter 8
  c9 VARCHAR2(25),               -- Label for PM Counter 9
  c10 VARCHAR2(25),              -- Label for PM Counter 10
  c1red NUMBER,                  -- c1 value that will generate a red alarm
  c1yellow NUMBER,               -- c1 value that will generate a yellow alarm
  c1sev FLOAT,                   -- c1 relative severity
  c2red NUMBER,                  -- c2 value that will generate a red alarm
  c2yellow NUMBER,               -- c2 value that will generate a yellow alarm
  c2sev FLOAT,                   -- c1 relative severity
  c3red NUMBER,                  -- c3 value that will generate a red alarm
  c3yellow NUMBER,               -- c3 value that will generate a yellow alarm
  c3sev FLOAT,                   -- c1 relative severity
  c4red NUMBER,                  -- c4 value that will generate a red alarm
  c4yellow NUMBER,               -- c4 value that will generate a yellow alarm
  c4sev FLOAT,                   -- c1 relative severity
  c5red NUMBER,                  -- c5 value that will generate a red alarm
  c5yellow NUMBER,               -- c5 value that will generate a yellow alarm
  c5sev FLOAT,                   -- c1 relative severity
  c6red NUMBER,                  -- c6 value that will generate a red alarm
  c6yellow NUMBER,               -- c6 value that will generate a yellow alarm
  c6sev FLOAT,                   -- c1 relative severity
  c7red NUMBER,                  -- c7 value that will generate a red alarm
  c7yellow NUMBER,               -- c7 value that will generate a yellow alarm
  c7sev FLOAT,                   -- c1 relative severity
  c8red NUMBER,                  -- c8 value that will generate a red alarm
  c8yellow NUMBER,               -- c8 value that will generate a yellow alarm
  c8sev FLOAT,                   -- c1 relative severity
  c9red NUMBER,                  -- c9 value that will generate a red alarm
  c9yellow NUMBER,               -- c9 value that will generate a yellow alarm
  c9sev FLOAT,                   -- c1 relative severity
  c10red NUMBER,                 -- c10 value that will generate a red alarm
  c10yellow NUMBER,              -- c10 value that will generate a yellow alarm
  c10sev FLOAT,                   -- c1 relative severity
  use_accumulators CHAR(1),
  speed_id NUMBER NOT NULL REFERENCES speeds(id),
  protocol_id NUMBER NOT NULL REFERENCES protocols(id), -- The protocol to be used to communicate with this element type
  element_type_id NUMBER NOT NULL REFERENCES element_types(id) -- The type of this element
);
