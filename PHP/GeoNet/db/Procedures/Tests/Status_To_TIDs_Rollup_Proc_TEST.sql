update tid_interface_status set flag = 'g' where tid_id = 1 and interface_id = 1;
EXECUTE status_to_tids_rollup(1);
select * from tid_interface_status;
select * from tids;

