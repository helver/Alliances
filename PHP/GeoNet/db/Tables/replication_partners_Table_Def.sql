-- replication_partners
--
-- replication_partners maintains a list of SQL servers that 
-- should be used as mirrors for this schema.
CREATE TABLE replication_partners (
  id NUMBER,
  rephost VARCHAR2(100)
);
