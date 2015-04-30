-- tid_facility_map
--
-- This table contains what TIDs belong to what facilities and in what 
-- order we should display each TID along the path.
CREATE TABLE tid_facility_map (
  trans_seq NUMBER NOT NULL,    -- The sequence number of this element along the transmit path
  recv_seq NUMBER NOT NULL,     -- The sequence number of this element along the receive path
  certified CHAR(1), -- Is this TID/Port on the certified path?
  certified_recv CHAR(1),
  last_updatedate DATE NOT NULL, -- Time this entry was last updated/inserted
  tid_id NUMBER NOT NULL REFERENCES tids(id), -- The TID associated with this record
  facility_id NUMBER NOT NULL REFERENCES facilities(id), -- The Facility associated with this record
  interface_id NUMBER NOT NULL REFERENCES interfaces(id), -- The interface associated with this record
  PRIMARY KEY(tid_id, interface_id, facility_id)
);
