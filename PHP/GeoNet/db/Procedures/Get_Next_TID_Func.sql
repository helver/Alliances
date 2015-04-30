CREATE OR REPLACE FUNCTION get_next_tid
RETURN VARCHAR2
AS
  PRAGMA AUTONOMOUS_TRANSACTION;
  CURSOR tid_cursor IS 
    SELECT tid_id FROM tid_queue WHERE active = 0 ORDER BY timeentered;
  techlist tid_cursor%ROWTYPE;
 
  tidid NUMBER; 
BEGIN
  OPEN tid_cursor;
  FETCH tid_cursor INTO tidid;
  CLOSE tid_cursor;
  
  UPDATE tid_queue SET active = 1 WHERE tid_id = tidid;
  COMMIT;
  
  RETURN tidid;
END;  
/
SHOW ERRORS
