-- pm_history
--
-- PM_histor is where we store the historical results from a single data 
-- gathering run for a TID/Interface combination.  We keep only the 
-- historical records here.  All active records are in pm_info.
CREATE TABLE pm_history (
  timeentered DATE NOT NULL,      -- Timestamp for when this PM information was collected
  archivetime DATE NOT NULL,      -- Timestamp for when this PM info was moved to history
  agent VARCHAR2(15),             -- IP Address of the server that gathered this data
  status NUMBER,                  -- Status code for this interface as collected from the element
  trapnum NUMBER,                 -- Trap Number if this information was received as an SNMP trap
  cause VARCHAR2(10),             -- Cause Code
  c1 NUMBER,                      -- PM Counter 1
  c2 NUMBER,                      -- PM Counter 2
  c3 NUMBER,                      -- PM Counter 3
  c4 NUMBER,                      -- PM Counter 4
  c5 NUMBER,                      -- PM Counter 5
  c6 NUMBER,                      -- PM Counter 6
  c7 NUMBER,                      -- PM Counter 7
  c8 NUMBER,                      -- PM Counter 8
  c9 NUMBER,                      -- PM Counter 9
  c10 NUMBER,                     -- PM Counter 10
  tid_id NUMBER NOT NULL REFERENCES tids(id), -- The TID this data is for.
  interface_id NUMBER NOT NULL REFERENCES interfaces(id), -- The Interface this data is for.
  PRIMARY KEY (tid_id, interface_id, timeentered, archivetime)
);
