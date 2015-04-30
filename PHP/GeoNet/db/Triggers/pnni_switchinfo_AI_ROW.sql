CREATE OR REPLACE TRIGGER pnni_switchinfo_AI_ROW
AFTER INSERT OR UPDATE OR DELETE ON switchinfo
FOR EACH ROW
WHEN (lower(new.customer) = 'echostar'
  and lower(new.connection) != 'end_point'
)
DECLARE
  CURSOR get_old_facilityid_cursor IS 
    SELECT id FROM facilities 
    WHERE name = upper(:old.connection);
  old_facilityid_cur get_old_facilityid_cursor%ROWTYPE;

  CURSOR get_old_tidid_cursor IS 
    SELECT id FROM tids WHERE name = :old.clli AND ipaddress = :old.ip;
  old_tidid_cur get_old_tidid_cursor%ROWTYPE;

  CURSOR get_old_interfaceid_cursor IS 
    SELECT id FROM interfaces WHERE name = :old.engport and e1 = :old.engport;
  old_interfaceid_cur get_old_interfaceid_cursor%ROWTYPE;

  old_facility_id facilities.id%TYPE; -- NUMBER
  old_tid_id tids.id%TYPE; -- NUMBER
  old_interface_id interfaces.id%TYPE; -- NUMBER
  
  new_facility_id facilities.id%TYPE; -- NUMBER
  new_tid_id tids.id%TYPE; -- NUMBER
  new_interface_id interfaces.id%TYPE; -- NUMBER
  
BEGIN

  -- get rid of the old values
  IF (:old.connection IS NOT NULL 
      AND :old.clli IS NOT NULL
      AND :old.engport IS NOT NULL
     ) THEN

    -- get the previous facilityid 
    OPEN get_old_facilityid_cursor;
    FETCH get_old_facilityid_cursor INTO old_facilityid_cur;
      old_facility_id := old_facilityid_cur.id;
    CLOSE get_old_facilityid_cursor;

    IF (old_facility_id IS NOT NULL) THEN
    
      -- get the previous tidid
      OPEN get_old_tidid_cursor;
      FETCH get_old_tidid_cursor INTO old_tidid_cur;
        old_tid_id := old_tidid_cur.id;
      CLOSE get_old_tidid_cursor;
  
      IF (old_tid_id IS NOT NULL) THEN
      
        OPEN get_old_interfaceid_cursor;
        FETCH get_old_interfaceid_cursor INTO old_interfaceid_cur;
          old_interface_id := old_interfaceid_cur.id;
        CLOSE get_old_interfaceid_cursor;
    
        IF (old_interface_id IS NOT NULL) THEN
          
          DELETE tid_facility_map 
            WHERE tid_id = old_tid_id and interface_id = old_interface_id and facility_id = old_facility_id;
          DELETE tid_interface_status
            WHERE tid_id = old_tid_id and interface_id = old_interface_id;
          DELETE pm_info
            WHERE tid_id = old_tid_id and interface_id = old_interface_id; 
          
        END IF;
      
      END IF;

    END IF;

     
  END IF;
  


  -- insert the new values
  IF (:new.connection IS NOT NULL 
      AND :new.clli IS NOT NULL
      AND :new.engport IS NOT NULL
     ) THEN
    new_tid_id := pnni_insertOrUpdate_tids(:new.clli, :new.ip);
    new_facility_id := pnni_insertOrUpdate_facilities(:new.connection);
    new_interface_id := pnni_insertOrUpdate_interfaces(:new.engport, :new.asxport, :new.linerate, :new.bandwidth);
    
    IF (new_tid_id != -1 AND new_facility_id != -1 AND new_interface_id != -1) THEN
      
      pnni_insOrUpd_tid_facility_map(new_tid_id, new_facility_id, new_interface_id, 1);
      pnni_insOrUpd_tid_intf_status(new_tid_id, new_interface_id, 'g', NULL); 
      
    END IF;
  END IF;
END;
/
SHOW ERRORS
