CREATE OR REPLACE FUNCTION call_populate_tid_queue
RETURN NUMBER
AS
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  populate_tid_queue();  
  COMMIT;
  RETURN 0;
END;  
/
SHOW ERRORS
