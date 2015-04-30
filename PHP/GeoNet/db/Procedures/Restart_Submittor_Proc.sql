CREATE OR REPLACE PROCEDURE restart_submittor
AS
BEGIN
  EXECUTE IMMEDIATE 'DROP INDEX pm_history_tid_id_index';
  EXECUTE IMMEDIATE 'DROP INDEX pm_history_interface_id_index';
  EXECUTE IMMEDIATE 'DROP INDEX pm_history_timeentered_index';
  EXECUTE IMMEDIATE 'DROP INDEX pm_history_archivetime_index';

  INSERT INTO pm_history 
    (timeentered, archivetime, agent, status, trapnum, cause, c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, tid_id, interface_id)
  SELECT timeentered + .0000115, SYSDATE, agent, status, trapnum, cause,
     c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, tid_id, interface_id
  FROM pm_info 
  WHERE (tid_id, interface_id) in 
    (SELECT tid_id, interface_id 
     FROM tid_facility_map, facilities 
     WHERE facility_id = id AND active = 't' AND (trans_seq > 0 OR recv_seq > 0)
    )
  ; 
    
  INSERT INTO pm_history 
    (timeentered, archivetime, agent, status, trapnum, cause, c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, tid_id, interface_id)
  SELECT timeentered + .000023, SYSDATE, 'sbmtr', NULL, NULL, 'Restart',
     -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, tid_id, interface_id
  FROM pm_info 
  WHERE (tid_id, interface_id) in 
    (SELECT tid_id, interface_id 
     FROM tid_facility_map, facilities 
     WHERE facility_id = id AND active = 't' AND (trans_seq > 0 OR recv_seq > 0)
    )
  ; 
    
  EXECUTE IMMEDIATE 'CREATE INDEX pm_history_tid_id_index on pm_history (tid_id)';
  EXECUTE IMMEDIATE 'CREATE INDEX pm_history_timeentered_index on pm_history (timeentered)';
  EXECUTE IMMEDIATE 'CREATE INDEX pm_history_interface_id_index on pm_history (interface_id)';
  EXECUTE IMMEDIATE 'CREATE INDEX pm_history_archivetime_index on pm_history (archivetime)';

  UPDATE pm_info SET
    timeentered = timeentered + .0000345,
    agent = 'sbmtr', 
    c1 = -1
  WHERE (tid_id, interface_id) in 
    (SELECT tid_id, interface_id 
     FROM tid_facility_map, facilities 
     WHERE facility_id = id AND active = 't' AND (trans_seq > 0 OR recv_seq > 0)
    )
  ;
END;
/
SHOW ERRORS
