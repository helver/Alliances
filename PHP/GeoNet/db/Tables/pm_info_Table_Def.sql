-- pm_info
--
-- PM_info is where we store the results from a single data_gathering run 
-- for a single TID/Interface combination.  We keep only the active records
-- here. All inactive/historical records get moved into pm_history.
CREATE TABLE pm_info (
  timeentered DATE NOT NULL,      -- Timestamp for when this PM information was collected
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
  a1 NUMBER,                      -- PM Accumulator for Counter 1
  a2 NUMBER,                      -- PM Accumulator for Counter 2
  a3 NUMBER,                      -- PM Accumulator for Counter 3
  a4 NUMBER,                      -- PM Accumulator for Counter 4
  a5 NUMBER,                      -- PM Accumulator for Counter 5
  a6 NUMBER,                      -- PM Accumulator for Counter 6
  a7 NUMBER,                      -- PM Accumulator for Counter 7
  a8 NUMBER,                      -- PM Accumulator for Counter 8
  a9 NUMBER,                      -- PM Accumulator for Counter 9
  a10 NUMBER,                     -- PM Accumulator for Counter 10
  tid_id NUMBER NOT NULL REFERENCES tids(id), -- The TID this data is for.
  interface_id NUMBER NOT NULL REFERENCES interfaces(id), -- The Interface this data is for.
  PRIMARY KEY (tid_id, interface_id)
);
