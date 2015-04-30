CREATE OR REPLACE PROCEDURE status_to_facilities_rollup
( xtid_id IN tids.id%TYPE,
  xinterface_id IN interfaces.id%TYPE
)
AS
  CURSOR flist_cursor IS 
    SELECT f.active, m.facility_id FROM tid_facility_map m, facilities f WHERE m.facility_id = f.id AND tid_id = xtid_id AND interface_id = xinterface_id;
  flist flist_cursor%ROWTYPE;

  status facilities.flag%TYPE := 4;
BEGIN
  FOR flist IN flist_cursor
  LOOP
    IF (flist.active = 't')
    THEN  
      SELECT MAX(DECODE(DECODE(SIGN(m.recv_seq), -1, 0, 1) + DECODE(SIGN(m.trans_seq), -1, 0, 1), 0, 2, s.flag)) INTO status FROM tid_interface_status s, tid_facility_map m WHERE m.facility_id = flist.facility_id AND s.tid_id = m.tid_id AND s.interface_id = m.interface_id;
    ELSE
      status := 2;
    END IF;
  
    UPDATE facilities SET flag = status WHERE id = flist.facility_id;

    status_to_customers_rollup(flist.facility_id);
  END LOOP;
END;
/
SHOW ERRORS
