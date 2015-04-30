-- tid_queue
--
-- TID_queue holds all of the active TIDs.  This is the basis for our
-- "one login session per element per polling cycle" approach.
CREATE TABLE tid_queue (
  tid_id NUMBER NOT NULL PRIMARY KEY REFERENCES tids(id),  -- Primary Key comes tids(id)
  timeentered DATE NOT NULL,
  active NUMBER NOT NULL
);
