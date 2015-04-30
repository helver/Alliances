CREATE OR REPLACE PROCEDURE populate_tid_queue
AS
BEGIN
  INSERT INTO tid_queue SELECT * FROM normal_populate_tid_queue_view;
END;
/
SHOW ERRORS
