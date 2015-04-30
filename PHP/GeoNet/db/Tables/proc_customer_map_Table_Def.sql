-- proc_customer_map
--
-- This table contains what users belong in what user groups.
CREATE TABLE proc_customer_map (
  outage_proc_id NUMBER NOT NULL REFERENCES outage_procedure(id), -- The group associated with this record
  customer_id NUMBER NOT NULL REFERENCES customers(id), -- The user associated with this record
  PRIMARY KEY(outage_proc_id, customer_id)
);
