CREATE OR REPLACE PROCEDURE reset_inactive_pps
AS
  CURSOR pp IS 
    SELECT tid_id, interface_id, facility_id, c1, c2, c3, c4, c5, c6, c7, c8, c9, c10
    FROM inact_pps;
  pplist pp%ROWTYPE;
 
  status tid_interface_status.flag%TYPE := 4;
  cause tid_interface_status.cause%TYPE;
BEGIN
  INSERT INTO inact_pps SELECT tfm.tid_id, tfm.interface_id, tfm.facility_id, c1, c2, c3, c4, c5, c6, c7, c8, c9, c10 FROM tid_facility_map tfm, tid_interface_status tis WHERE tfm.tid_id = tis.tid_id and tfm.interface_id = tis.interface_id and tfm.trans_seq < 0 and tfm.recv_seq < 0;

  FOR pplist IN pp
    LOOP
      UPDATE alarms SET acknowledge_date = SYSDATE, time_cleared = SYSDATE WHERE tid_id = pplist.tid_id and interface_id = pplist.interface_id;
      
      UPDATE tid_interface_status SET cause = 'InAct', flag = 0 WHERE tid_id = pplist.tid_id and interface_id = pplist.interface_id;
      status_to_tids_rollup(pplist.tid_id);
      status_to_facilities_rollup(pplist.tid_id, pplist.interface_id);
      
  END LOOP;
  
  EXECUTE IMMEDIATE 'TRUNCATE TABLE inact_pps';
END;  
/
SHOW ERRORS
