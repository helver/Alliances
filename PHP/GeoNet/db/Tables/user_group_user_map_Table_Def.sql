-- user_group_user_map
--
-- This table contains what users belong in what user groups.
CREATE TABLE user_group_user_map (
  user_group_id NUMBER NOT NULL REFERENCES user_groups(id), -- The group associated with this record
  user_id NUMBER NOT NULL REFERENCES users(id), -- The user associated with this record
  PRIMARY KEY(user_group_id, user_id)
);
