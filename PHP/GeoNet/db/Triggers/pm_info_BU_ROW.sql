CREATE OR REPLACE TRIGGER pm_info_bu_row
BEFORE UPDATE ON pm_info
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
  or new.c10 <> old.c10
  or new.cause = 'RESET')
 and new.agent <> 'sbmtr'
)
DECLARE
  status tid_interface_status.flag%TYPE;
  xcause tid_interface_status.cause%TYPE;
  now VARCHAR2(25);
  xerror_time DATE := NULL;
BEGIN
  SELECT to_char(SYSDATE, 'MM/DD/YYYY HH24:MI:SS') INTO now FROM dual;

  IF :new.status = -1 AND :new.cause = 'COM' THEN
    xcause := :new.cause;
    IF :new.agent = 'geonet' THEN
      status := 5;
      SELECT error_time INTO xerror_time FROM tid_interface_status WHERE tid_id = :new.tid_id AND interface_id = :new.interface_id;
    ELSE
      :new.c1 := -1;
      status := 8;  
    END IF;
  ELSIF :new.cause = 'RESET' THEN
    status := 4;
  ELSE
    SELECT flag INTO status FROM tid_interface_status WHERE tid_id = :new.tid_id AND interface_id = :new.interface_id;
  END IF;

  --insert into debugging values ('status: ' || status  || '  -- xcause: ' || xcause);
  
  INSERT INTO pm_history VALUES
  (SYSDATE - (1/(24*60*60)), SYSDATE - (1/(24*60*60)), :old.agent, :old.status, :old.trapnum, :old.cause,
   :old.c1, :old.c2, :old.c3, :old.c4, :old.c5, :old.c6, :old.c7,
   :old.c8, :old.c9, :old.c10, :old.tid_id, :old.interface_id
  );

  INSERT INTO pm_history VALUES
  (SYSDATE, SYSDATE, :new.agent, :new.status, :new.trapnum, :new.cause,
   :new.c1, :new.c2, :new.c3, :new.c4, :new.c5, :new.c6, :new.c7,
   :new.c8, :new.c9, :new.c10, :new.tid_id, :new.interface_id
  );

  UPDATE tid_interface_status SET flag = status, cause = xcause, 
    timeentered = SYSDATE, connect_attempt = 0, 
    c1 = :new.c1, c2 = :new.c2, c3 = :new.c3, c4 = :new.c4, 
    c5 = :new.c5, c6 = :new.c6, c7 = :new.c7, c8 = :new.c8, 
    c9 = :new.c9, c10 = :new.c10, error_time = xerror_time WHERE tid_id = :new.tid_id 
    AND interface_id = :new.interface_id;
END;
/
SHOW ERRORS

