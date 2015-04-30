-- currently this trigger has been dropped 
-- because it's not the way trace path does reroute

CREATE OR REPLACE TRIGGER pnni_historical_AU_ROW
AFTER UPDATE ON historical
FOR EACH ROW
WHEN ( new.currentpath = 0
  and old.currentpath = 1
  and lower(new.customer) = 'echostar'
  and new.hop = 0
)

DECLARE
  CURSOR get_tid_cursor IS 
    SELECT clli, ip, engport, asxport, linerate, bandwidth 
    FROM switchinfo WHERE connection = :new.connection and clli = :new.clli;  
  tid_cur get_tid_cursor%ROWTYPE;

  ntid_id tids.id%TYPE; -- NUMBER  
  ninterface_id interfaces.id%TYPE; -- NUMBER

BEGIN

  -- IDENTIFY THE INACTIVE CONNECTION
  
  OPEN get_tid_cursor;
  FETCH get_tid_cursor INTO tid_cur;
      
    -- find all access points and put the new status on all of them
    -- put alarms on all access points

    ntid_id := pnni_insertOrUpdate_tids(tid_cur.clli, tid_cur.ip);
    ninterface_id := pnni_insertOrUpdate_interfaces(tid_cur.engport, tid_cur.asxport
          , tid_cur.linerate, tid_cur.bandwidth);
      
    IF (ntid_id != -1 AND ninterface_id != -1) THEN
      UPDATE pm_info SET c9 = 0 , status = 0, cause = NULL, timeentered = SYSDATE 
        WHERE tid_id = ntid_id and interface_id = ninterface_id;
      
      UPDATE tid_interface_status SET flag = 'n', cause = 'Inactive', timeentered = SYSDATE, connect_attempt = 0 
        WHERE tid_id = ntid_id AND interface_id = ninterface_id;
      
    END IF;
    
  CLOSE get_tid_cursor;
    
END;
/
SHOW ERRORS
