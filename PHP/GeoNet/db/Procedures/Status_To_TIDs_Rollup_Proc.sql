CREATE OR REPLACE PROCEDURE status_to_tids_rollup
( xtid_id IN tids.id%TYPE )
AS
  status tids.flag%TYPE := 4;
  xcause tids.cause%TYPE := NULL;
BEGIN
  SELECT flag INTO status FROM tid_interface_status WHERE tid_id = xtid_id AND flag = (SELECT max(flag) FROM tid_interface_status WHERE tid_id = xtid_id) AND rownum = 1;
  SELECT cause INTO xcause FROM tid_interface_status WHERE tid_id = xtid_id AND flag = (SELECT max(flag) FROM tid_interface_status WHERE tid_id = xtid_id) AND rownum = 1;

  UPDATE tids SET flag = status, cause = xcause WHERE id = xtid_id;
END;
/
SHOW ERRORS
