-- speed_equivalent_map
--
-- This table contains what users belong in what user groups.
CREATE TABLE speed_equivalent_map (
  speed_id NUMBER NOT NULL REFERENCES speeds(id),
  equivalent_id NUMBER NOT NULL REFERENCES speeds(id),
  PRIMARY KEY(speed_id, equivalent_id)
);
