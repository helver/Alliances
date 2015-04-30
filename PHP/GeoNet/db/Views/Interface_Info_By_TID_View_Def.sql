CREATE OR REPLACE VIEW interface_info_by_tid_view AS 
SELECT
  tfm.interface_id AS interface_id,
  tfm.tid_id AS tid_id, 
  d.name AS tid, 
  DECODE(ring.id, NULL, d.ipaddress, ring.ipaddress) AS ipaddress, 
  d.element_type_id AS element_type_id,
  d.directionality AS directionality,
  i.e1 AS e1, 
  i.e2 AS e2,
  i.e3 AS e3,
  i.e4 AS e4,
  i.e5 AS e5,
  i.name as interface,
  i.interface_type_id AS interface_type,
  p.name AS protocol,
  tfm.trans_seq AS trans_seq,
  tfm.recv_seq AS recv_seq,
  DECODE(ring.id, NULL, d.management_port, ring.management_port) AS port,
  d.ring_id AS ring_id
FROM
  tids d, 
  interfaces i,
  tid_facility_map tfm,
  interface_types it,
  protocols p,
  facilities f,
  tids ring
WHERE 
      tfm.tid_id = d.id 
  AND tfm.interface_id = i.id
  AND it.id = i.interface_type_id
  AND p.id = it.protocol_id
  AND f.id = tfm.facility_id
  AND d.ring_id = ring.id(+)
  AND f.active = 't'
  AND (tfm.trans_seq >= 0 OR tfm.recv_seq >= 0)
 ;
COMMIT;
