CREATE OR REPLACE TRIGGER tids_to_update_view_IOU
INSTEAD OF UPDATE ON tids_to_update_view
BEGIN
  --DBMS_OUTPUT.PUT_LINE('In tids_to_update_view_IOU_STM: status - ' || status || ' cause - ' || xcause);
  
  UPDATE pm_info SET c1 = -1, c2 = -1, c3 = -1, c4 = -1, c5 = -1, 
                     c6 = -1, c7 = -1, c8 = -1, c9 = -1, c10 = -1, 
                     timeentered = SYSDATE, agent = 'geonet', status = -1, cause = :new.cause
  WHERE tid_id = :new.tid_id AND interface_id in (SELECT tfm.interface_id FROM tid_facility_map tfm, facilities f WHERE tfm.tid_id = :new.tid_id AND tfm.facility_id = f.id AND f.active = 't');
END;
/
SHOW ERRORS
