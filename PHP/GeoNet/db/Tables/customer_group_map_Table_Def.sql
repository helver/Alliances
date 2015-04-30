-- customer_group_map
--
-- This table contains what customers belong in what user groups.
CREATE TABLE customer_group_map (
  user_group_id NUMBER NOT NULL REFERENCES user_groups(id), -- The group associated with this record
  customer_id NUMBER NOT NULL REFERENCES customers(id), -- The customer associated with this record
  display_order NUMBER,
  PRIMARY KEY(user_group_id, customer_id)
);
