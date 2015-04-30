-- receive_channels
--
-- Receive_channels map a receive channel ID to a label representing that 
-- channel.
CREATE TABLE receive_channels (
  id NUMBER NOT NULL PRIMARY KEY, -- Primary Key
  name VARCHAR2(20) NOT NULL      -- Receive Channel Name
);
