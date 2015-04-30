-- user_groups
--
-- User groups allow administrators to group users together to determine 
-- which customers appear in that group's default view of GeoNet.
CREATE TABLE user_groups (
  id NUMBER NOT NULL PRIMARY KEY, -- Primary Key comes from user_group_id_seq
  name VARCHAR2(40) NOT NULL,     -- Group Name
  short_name VARCHAR2(5) NOT NULL -- Short Group Name
);
