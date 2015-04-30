CREATE OR REPLACE PROCEDURE pnni_insOrUpd_tid_facility_map
(
xtid_id IN tids.id%TYPE, 
xfacility_id IN facilities.id%TYPE, 
xinterface_id IN interfaces.id%TYPE,
xhop IN NUMBER
)
AS

  CURSOR get_newmapid_cursor IS 
    SELECT tid_id FROM tid_facility_map 
    WHERE tid_id = xtid_id and facility_id = xfacility_id and interface_id = xinterface_id;
  newmapid_cur get_newmapid_cursor%ROWTYPE;

  CURSOR get_pm_info_id_cursor IS 
    SELECT tid_id FROM pm_info 
    WHERE tid_id = xtid_id and interface_id = xinterface_id;
  pm_info_id_cur get_pm_info_id_cursor%ROWTYPE;

  ntid_id tid_facility_map.tid_id%TYPE; -- NUMBER
  pm_info_exist pm_info.tid_id%TYPE;
  
BEGIN
  
    
  -- find the new mapid: if exist, update it, o.w. insert it
  OPEN get_newmapid_cursor;
  FETCH get_newmapid_cursor INTO newmapid_cur;
    ntid_id := newmapid_cur.tid_id;
  CLOSE get_newmapid_cursor;

  IF (ntid_id IS NOT NULL) THEN
    --DELETE tid_facility_map 
    --WHERE tid_id = xtid_id and facility_id = xfacility_id and interface_id = xinterface_id and certified = 'f';

    UPDATE tid_facility_map SET trans_seq = xhop, last_updatedate = SYSDATE 
    WHERE tid_id = xtid_id and facility_id = xfacility_id and interface_id = xinterface_id and certified = 't';
  ELSE  
    INSERT INTO tid_facility_map (trans_seq, recv_seq, tid_id, facility_id, interface_id, certified, last_updatedate) 
      VALUES (xhop, -1, xtid_id, xfacility_id, xinterface_id, 't', SYSDATE);

    -- check we don't already have an entry in pm_info and insert it
    OPEN get_pm_info_id_cursor;
    FETCH get_pm_info_id_cursor INTO pm_info_id_cur;
      pm_info_exist := pm_info_id_cur.tid_id;
    CLOSE get_pm_info_id_cursor;

    IF (pm_info_exist IS NULL) THEN
      INSERT INTO pm_info (tid_id, interface_id, timeentered, c9, a2)
        VALUES (xtid_id, xinterface_id, SYSDATE, 0, 0);
    END IF;

  END IF;
  
END;
/
SHOW ERRORS
