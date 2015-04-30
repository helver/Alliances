CREATE OR REPLACE TRIGGER tid_interface_status_bu_row2
BEFORE UPDATE ON tid_interface_Status
FOR EACH ROW
WHEN (
      new.flag <> old.flag
  and new.cause not in ('COM')
)
DECLARE
BEGIN
  --insert into debugging values ('In tid_interface_status_bu_row2 with flag: ' || :new.flag);
  
  IF (:new.flag >= 8) THEN
    --insert into debugging values ('Going to create_alarm_for_interface');
    create_alarm_for_interface(:new.tid_id, :new.interface_id, :new.cause, :new.flag);
  ELSE 
    --insert into debugging values ('Going to clear_alarm_for_interface');
    clear_alarm_for_interface(:new.tid_id, :new.interface_id, :new.flag);
  END IF;
  
  --insert into debugging values ('Going to bubble with flag: ' || :new.flag);
  tid_if_status_api.tis_row_change(:new.tid_id, :new.interface_id);
END;
/
SHOW ERRORS

