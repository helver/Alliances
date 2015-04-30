-- tids
--
-- TIDs represent a physical network element.
CREATE TABLE tids (
  id NUMBER NOT NULL PRIMARY KEY,      -- Primary Key comes from tid_id_seq
  name VARCHAR2(17) NOT NULL,          -- TID name
  ipaddress VARCHAR2(16) NOT NULL,     -- IP Address of the element
  flag NUMBER(1) NOT NULL,               -- Status flag - rolled up from tid_interface_status.flag
  cause VARCHAR2(20),                  -- Cause Code - rolled up from tid_interface_status.cause
  grouping_name VARCHAR2(14) NOT NULL, -- DWDM Grouping Name from FMS
  dwdm_facility VARCHAR2(8) NOT NULL,  -- DWDM Facility ID from FMS
  keephistory CHAR(1) NOT NULL,        -- Keep History for this TID?
  connect_attempt NUMBER,              -- Number of failed connection attempts  
  management_port NUMBER,			   -- Port Number to connect to.  If empty, use the element type default
  directionality NUMBER REFERENCES receive_channels(id), -- Directionality of the element
  city_id NUMBER NOT NULL REFERENCES cities(id), -- The city where this element is located
  element_type_id NUMBER NOT NULL REFERENCES element_types(id), -- The type of this element
  is_ring CHAR(1), -- Is this TID record actually a Ring Placeholder?
  ring_id NUMBER REFERENCES tids(id) -- Ring ID that this TID is on
);


ALTER TABLE tids DROP COLUMN flag;
ALTER TABLE tids ADD flag NUMBER(1);
UPDATE tids SET flag = 4;
