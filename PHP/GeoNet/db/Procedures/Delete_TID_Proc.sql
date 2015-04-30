CREATE OR REPLACE PROCEDURE delete_tid
( xx_tid IN NUMBER)
AS
BEGIN
  delete from tid_queue where tid_id = xx_tid;
  delete from pm_history where tid_id = xx_tid;
  delete from pm_info where tid_id = xx_tid;
  delete from tid_interface_status where tid_id = xx_tid;
  delete from tid_facility_map where tid_id = xx_tid;
  delete from alarms where tid_id = xx_tid;
  delete from fiber_segments where asite_id = xx_tid or zsite_id = xx_tid or fiber_route_id in (select id from fiber_routes where asite_id = xx_tid or zsite_id = xx_tid);
  delete from fiber_routes where asite_id = xx_tid or zsite_id = xx_tid;
  delete from tids where id = xx_tid;
END;  
/
SHOW ERRORS
