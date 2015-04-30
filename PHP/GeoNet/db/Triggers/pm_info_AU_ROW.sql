CREATE OR REPLACE TRIGGER pm_info_au_row
AFTER UPDATE ON pm_info
FOR EACH ROW
WHEN (
 new.agent <> 'sbmtr'
)
DECLARE
  now VARCHAR2(25);
BEGIN
  SELECT to_char(SYSDATE, 'MM/DD/YYYY HH24:MI:SS') INTO now FROM dual;
  
  UPDATE tid_interface_status SET timeentered = to_date(now, 'MM/DD/YYYY HH24:MI:SS') WHERE tid_id = :new.tid_id AND interface_id = :new.interface_id;

  IF :new.status = -1 AND :new.cause = 'COM' AND :new.agent = 'geonet' THEN
    UPDATE tid_interface_status SET error_time = SYSDATE WHERE tid_id = :new.tid_id AND interface_id = :new.interface_id AND error_time IS NULL;
  END IF;
END;
/
SHOW ERRORS

