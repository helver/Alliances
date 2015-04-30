CREATE OR REPLACE VIEW if_status_tid_and_cust_view AS 
SELECT
  tif.interface_id AS interface_id,
  tif.tid_id AS tid_id, 
  to_char(tif.timeentered, 'MM/DD/YYYY HH24:MI:SS') AS timeentered,
  to_char(tif.timeentered, 'YYYY/MM/DD HH24:MI:SS') AS sorttime,
  tif.connect_attempt AS connect_attempts,
  ff.name AS flag,
  tif.cause AS cause,
  d.name AS tid, 
  d.ipaddress AS ipaddress, 
  d.element_type_id AS element_type_id,
  i.e1 AS e1, 
  i.e2 AS e2,
  i.e3 AS e3,
  i.e4 AS e4,
  i.e5 AS e5,
  i.name as interface,
  it.namelbl AS namelbl,
  f.customer_id AS customer_id,
  c.name AS customer,
  f.name AS facility,
  f.id AS facility_id,
  DECODE(f.active, 't', 'Act', 'Inact') AS facility_active,
  tfm.trans_seq as trans_seq,
  tfm.recv_seq as recv_seq,
  e.name as element_type,
  f.notes as notes
FROM
  tids d, 
  interfaces i,
  tid_interface_status tif,
  tid_facility_map tfm,
  facilities f,
  customers c,
  interface_types it,
  element_types e,
  flags ff
WHERE 
      tif.tid_id = d.id 
  AND ff.id = tif.flag
  AND e.id = d.element_type_id
  AND tif.interface_id = i.id
  AND tfm.tid_id = d.id
  AND tfm.interface_id = i.id
  AND tfm.facility_id = f.id
  AND c.id = f.customer_id
  AND it.id = i.interface_type_id
 ;
commit;