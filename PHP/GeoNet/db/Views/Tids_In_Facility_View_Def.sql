CREATE OR REPLACE VIEW Tids_In_Facility_View AS
SELECT 
  a.facility_id AS facility_id, 
  a.tid_id || ',' || i.id AS tid_id,
  a.trans_seq AS trans_seq,
  a.recv_seq AS recv_seq,
  a.certified AS certified,
  a.certified_recv AS certified_recv,
  t.name || ' - ' || it.namelbl || ' ' || i.name  AS tid
FROM
  tid_facility_map a,
  tids t,
  interfaces i,
  interface_types it
WHERE
  i.interface_type_id = it.id
  AND i.id = a.interface_id
  AND t.id = a.tid_id
;
COMMIT;