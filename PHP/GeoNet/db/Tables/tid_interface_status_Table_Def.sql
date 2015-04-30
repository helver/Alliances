-- tid_interface_status
--
-- This table represents the current status of a channel (or inteface) on a
-- TID. We maintain the interface status, cause of the status and time of 
-- last update. The actual values that went into this status are stored in 
-- the pms table and the pm_history table.
CREATE TABLE tid_interface_status (
  flag NUMBER(1) NOT NULL,        -- The status of this interface
  timeentered DATE NOT NULL,    -- The last time this interface was updated
  cause VARCHAR2(20),           -- Cause code for any non-green status
  connect_attempt NUMBER,       -- Number of times we've failed to pull PM data from this interface
  c1 NUMBER,
  c2 NUMBER,
  c3 NUMBER,
  c4 NUMBER,
  c5 NUMBER,
  c6 NUMBER,
  c7 NUMBER,
  c8 NUMBER,
  c9 NUMBER,
  c10 NUMBER,
  tid_id NUMBER NOT NULL REFERENCES tids(id), -- The TID associated with this interface
  interface_id NUMBER NOT NULL REFERENCES interfaces(id), -- The interface on the TID that we're looking at
  PRIMARY KEY(tid_id, interface_id)
);


ALTER TABLE tid_interface_status DROP COLUMN flag;
ALTER TABLE tid_interface_status ADD flag NUMBER(1);
UPDATE tid_interface_status SET flag = 4;

alter table tid_interface_status add c1 NUMBER;
alter table tid_interface_status add c2 NUMBER;
alter table tid_interface_status add c3 NUMBER;
alter table tid_interface_status add c4 NUMBER;
alter table tid_interface_status add c5 NUMBER;
alter table tid_interface_status add c6 NUMBER;
alter table tid_interface_status add c7 NUMBER;
alter table tid_interface_status add c8 NUMBER;
alter table tid_interface_status add c9 NUMBER;
alter table tid_interface_status add c10 NUMBER;
