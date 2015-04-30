CREATE OR REPLACE TRIGGER pnni_historical_AIU_ROW
AFTER INSERT ON historical
FOR EACH ROW
WHEN ( lower(new.customer) = 'echostar'
  and (
        ( new.currentpath = 1
          and new.hop = 0
          and new.details like '%The number of expected connections (%) is not equal to the number of existing connections%' -- warning -- yellow
        )
       or
        ( new.details like '%No connections were found%'  -- connection down -- red alarm
          or new.details like '%The connection was terminated%'  -- connection down -- red alarm
        )
      )
  )
DECLARE
  CURSOR get_tid_cursor IS 
    SELECT clli, ip, engport, asxport, linerate, bandwidth 
    FROM switchinfo WHERE connection = :new.connection and clli = :new.clli  
      and engport = :new.inport;  
  tid_cur get_tid_cursor%ROWTYPE;

  CURSOR get_red_tid_cursor IS 
    SELECT tid_id, interface_id 
    FROM facilities f, tid_facility_map tfm
    WHERE f.id = tfm.facility_id and f.name = :new.connection and tfm.TRANS_SEQ > -1;  
  red_tid_cur get_red_tid_cursor%ROWTYPE;

  ntid_id tids.id%TYPE; -- NUMBER  
  ninterface_id interfaces.id%TYPE; -- NUMBER
  nc9 NUMBER;
  ncause VARCHAR2(10);
BEGIN
  -- FLAG A PROBLEM: NO CONNECTION
  insert into debugging values('in pnni_historical_AIU_ROW with connection: ' || :new.connection || ', clli: ' || :new.clli || ', inport: '|| :new.inport);
  IF (:new.details like '%No connections were found%'
      or :new.details like '%The connection was terminated%'
      ) THEN
    -- the whole connection is down (there is no CLLI)
    -- put alarms on all access points
    
    nc9 := 8;
    ncause := 'No Conn';

    OPEN get_red_tid_cursor;
    FETCH get_red_tid_cursor INTO red_tid_cur;
        
      -- find all access points and put the new status on all of them
      -- put alarms on all access points
  
      ntid_id := red_tid_cur.tid_id;
      ninterface_id := red_tid_cur.interface_id;
        
      IF (ntid_id != -1 AND ninterface_id != -1) THEN
        UPDATE pm_info SET c9 = nc9, status = 0, cause = ncause, timeentered = SYSDATE 
          WHERE tid_id = ntid_id and interface_id = ninterface_id;
      END IF;
    
    CLOSE get_red_tid_cursor;

  -- FLAG A PROBLEM: MORE CONNECTIONS THAN EXPECTED (yellow)

  ELSIF (:new.details like '%The number of expected connections (%) is not equal to the number of existing connections%') THEN
    -- in this case historical table contains the clli of the access point
    nc9 := 2;
    ncause := 'Diff # con';

    OPEN get_tid_cursor;
    FETCH get_tid_cursor INTO tid_cur;
        
      -- find all access points and put the new status on all of them
      -- put alarms on all access points
  
      ntid_id := pnni_insertOrUpdate_tids(tid_cur.clli, tid_cur.ip);
      ninterface_id := pnni_insertOrUpdate_interfaces(tid_cur.engport, tid_cur.asxport
            , tid_cur.linerate, tid_cur.bandwidth);
        
      IF (ntid_id != -1 AND ninterface_id != -1) THEN
        UPDATE pm_info SET c9 = nc9, status = 0, cause = ncause, timeentered = SYSDATE 
          WHERE tid_id = ntid_id and interface_id = ninterface_id;
      END IF;
      
    CLOSE get_tid_cursor;

  END IF;
END;
/
SHOW ERRORS
