CREATE OR REPLACE VIEW get_tidinfo_by_tid_view AS 
SELECT 
  d.id as tidid,
  d.ring_id as ring_id, 
  d.name as tid, 
  d.ipaddress as ipaddress, 
  i.e1,
  i.e2,
  i.e3,
  i.e4,
  i.e5,
  p.name as protocol, 
  e.name as element_type, 
  tm.trans_seq as trans_seq,
  tm.recv_seq as recv_seq, 
  d.city_id as city_id, 
  e.id as element_typeid, 
  d.connect_attempt as connect_attempt, 
  i.channel_order as channel_order
FROM 
  tids d, 
  element_types e, 
  protocols p, 
  facilities f,
  tid_facility_map tm,
  interfaces i,
  interface_types it
WHERE 
      tm.facility_id = f.id
  and tm.interface_id = i.id
  and i.interface_type_id = it.id
  and tm.tid_id = d.id
  and it.element_type_id = e.id
  and it.protocol_id = p.id 
  and (tm.trans_seq > 0 or tm.recv_seq > 0)
  and f.id is not null
  and f.active = 't'
;
commit;
