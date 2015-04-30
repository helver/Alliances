-- flags
--
-- Receive_channels map a receive channel ID to a label representing that 
-- channel.
CREATE TABLE flags (
  id NUMBER(1) NOT NULL PRIMARY KEY, -- Primary Key
  name CHAR(1) NOT NULL,      -- Flag Name
  description VARCHAR2(200)
);


INSERT INTO flags (id, name) VALUES (0, 'n');
INSERT INTO flags (id, name) VALUES (2, 't');
INSERT INTO flags (id, name) VALUES (4, 'g');
INSERT INTO flags (id, name) VALUES (5, 'e');
INSERT INTO flags (id, name) VALUES (6, 'y');
INSERT INTO flags (id, name) VALUES (8, 'r');
INSERT INTO flags (id, name) VALUES (9, 'R');

COMMIT;