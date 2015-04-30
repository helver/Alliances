CREATE OR REPLACE TRIGGER pnni_historical_AI_ROW
AFTER INSERT ON historical
FOR EACH ROW
WHEN ( new.currentpath = 1
  and lower(new.customer) = 'echostar'
  and new.hop = 0
  and new.clli is not null
  and new.connection is not null
  and new.inport is not null
)
DECLARE
  CURSOR get_tid_cursor IS 
    SELECT clli, ip, engport, asxport, linerate, bandwidth 
    FROM switchinfo WHERE connection = :new.connection and clli = :new.clli
      and engport = :new.inport;  
  tid_cur get_tid_cursor%ROWTYPE;

  CURSOR get_tid_inactive_cursor IS 
    SELECT clli, ip, engport, asxport, linerate, bandwidth 
    FROM switchinfo WHERE connection = :new.connection and clli != :new.clli
      and cbrnum < 2;  
  tid_inactive_cur get_tid_inactive_cursor%ROWTYPE;

  ntid_id tids.id%TYPE; -- NUMBER  
  ninterface_id interfaces.id%TYPE; -- NUMBER

  ninactivetid_id tids.id%TYPE; -- NUMBER  
  ninactiveinterface_id interfaces.id%TYPE; -- NUMBER
BEGIN
  -- IDENTIFY THE ACTIVE CONNECTION AND SET THEM UP AS REROUTE
  OPEN get_tid_cursor;
  FETCH get_tid_cursor INTO tid_cur;
      
    -- find all access points and put the new status on all of them
    -- put alarms on all access points

    ntid_id := pnni_insertOrUpdate_tids(tid_cur.clli, tid_cur.ip);
    ninterface_id := pnni_insertOrUpdate_interfaces(tid_cur.engport, tid_cur.asxport
          , tid_cur.linerate, tid_cur.bandwidth);
      
    IF (ntid_id != -1 AND ninterface_id != -1) THEN
      
      insert into debugging values('UPDATE pm_info SET c9 = 1 , status = 0, cause = Reroute, timeentered = SYSDATE WHERE tid_id = ' || ntid_id || ' and interface_id = ' || ninterface_id);
      UPDATE pm_info SET c9 = 1 , status = 0, cause = 'Reroute', timeentered = SYSDATE 
        WHERE tid_id = ntid_id and interface_id = ninterface_id;

      -- find the inactive
      OPEN get_tid_inactive_cursor;
      FETCH get_tid_inactive_cursor INTO tid_inactive_cur;
        ninactivetid_id := pnni_insertOrUpdate_tids(tid_inactive_cur.clli, tid_inactive_cur.ip);
        ninactiveinterface_id := pnni_insertOrUpdate_interfaces(tid_inactive_cur.engport, tid_inactive_cur.asxport
              , tid_inactive_cur.linerate, tid_inactive_cur.bandwidth);
        
        IF (ninactivetid_id != -1 AND ninactiveinterface_id != -1) THEN
          UPDATE pm_info SET c9 = 0 , status = 0, cause = 'Inactive', timeentered = SYSDATE 
            WHERE tid_id = ninactivetid_id and interface_id = ninactiveinterface_id;
          
          UPDATE tid_interface_status SET flag = 'n', cause = 'Inactive', timeentered = SYSDATE, connect_attempt = 0 
            WHERE tid_id = ninactivetid_id AND interface_id = ninactiveinterface_id;
          
        END IF;
        
      CLOSE get_tid_inactive_cursor;
    END IF;
  CLOSE get_tid_cursor;
END;
/
SHOW ERRORS
