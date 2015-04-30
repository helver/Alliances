-- facilities
--
-- Facilities are customer-based circuits.
CREATE TABLE facilities (
  id NUMBER NOT NULL PRIMARY KEY, -- Primary Key comes from facility_id_seq
  name VARCHAR2(50) NOT NULL,     -- Facility Name
  active CHAR(1) NOT NULL,        -- Boolean - Is the facility active or not
  flag NUMBER(1) NOT NULL,          -- Facility Alarm status
  keephistory CHAR(1) NOT NULL,   -- Keep History for this facility?
  speed_id NUMBER REFERENCES speeds(id),  -- Speed of the facility
  notes VARCHAR2(250),            -- Facility notes
  customer_id NUMBER NOT NULL REFERENCES customers(id) -- The customer riding on this facility
);


ALTER TABLE facilities DROP COLUMN flag;
ALTER TABLE facilities ADD flag NUMBER(1);
UPDATE facilities SET flag = 4;
