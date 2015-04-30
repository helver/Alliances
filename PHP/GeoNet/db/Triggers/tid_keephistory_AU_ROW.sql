CREATE OR REPLACE TRIGGER tid_keephistory_AU_ROW
AFTER UPDATE ON tids
FOR EACH ROW
WHEN ( 
  new.keephistory <> old.keephistory
)
DECLARE
  thecause VARCHAR2(10);
BEGIN
  IF :new.keephistory = 't' THEN
    thecause := 'Hist On';
  ELSE
    thecause := 'Hist Off';
  END IF;
  
  INSERT INTO pm_history SELECT
  timeentered, SYSDATE, agent, status, trapnum, thecause,
  c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, tid_id, interface_id
  FROM pm_info WHERE tid_id = :new.id;

END;
/
SHOW ERRORS
