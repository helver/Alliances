CREATE OR REPLACE TRIGGER tid_interface_status_bu_row
BEFORE UPDATE ON tid_interface_Status
FOR EACH ROW
WHEN (
 (   new.c1 <> old.c1
  or new.c2 <> old.c2
  or new.c3 <> old.c3
  or new.c4 <> old.c4
  or new.c5 <> old.c5
  or new.c6 <> old.c6
  or new.c7 <> old.c7
  or new.c8 <> old.c8
  or new.c9 <> old.c9
  or new.c10 <> old.c10)
)
DECLARE
  status tid_interface_status.flag%TYPE := 4;
  xcause tid_interface_status.cause%TYPE;
BEGIN
--  insert into debugging values ('In tid_interface_status_bu_row');
  
  IF :new.cause = 'COM' THEN
    -- do Nothing
    status := :new.flag;
    xcause := :new.cause;
  ELSE
    determine_tis(:new.tid_id, :new.interface_id, :new.c1, :new.c2, :new.c3, :new.c4, :new.c5, :new.c6, :new.c7, :new.c8, :new.c9, :new.c10, status, xcause, 0);
  
    IF (status >= 8) THEN
      create_alarm_for_interface(:new.tid_id, :new.interface_id, xcause, status);
    ELSE 
      clear_alarm_for_interface(:new.tid_id, :new.interface_id, status);
    END IF;

    :new.flag := status;
    :new.cause := xcause;
  END IF;
      
  IF (:new.flag <> :old.flag) THEN
    tid_if_status_api.tis_row_change(:new.tid_id, :new.interface_id);
  END IF;
  
END;
/
SHOW ERRORS

