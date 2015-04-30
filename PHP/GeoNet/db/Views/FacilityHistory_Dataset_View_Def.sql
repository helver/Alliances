CREATE OR REPLACE VIEW FacilityHistory_Dataset_View AS
SELECT
  t.id AS tid_id,
  t.name AS tid,
  ff.name AS flag,
  t.ipaddress AS ipaddress,
  to_char(tis.timeentered, 'MM-DD-YYYY HH24:MI:SS') AS lasttime,
  f.name AS facility,
  f.id AS facility_id,
  tfm.trans_seq AS trans_facility_path,
  tfm.recv_seq AS recv_facility_path,
  c.id AS symbol,
  c.name AS city,
  et.name AS element_type,
  i.name AS ifname,
  i.id AS interface_id,
  i.e1 AS e1_val,
  i.e2 AS e2_val,
  i.e3 AS e3_val,
  i.e4 AS e4_val,
  i.e5 AS e5_val,
  it.namelbl AS ifname_lbl,
  p.e1 AS e1_lbl,
  p.e2 AS e2_lbl,
  p.e3 AS e3_lbl,
  p.e4 AS e4_lbl,
  p.e5 AS e5_lbl,
  f.customer_id AS customer_id
FROM
  tids t,
  tid_facility_map tfm,
  interfaces i,
  tid_interface_status tis,
  interface_types it,
  facilities f,
  cities c,
  element_types et,
  protocols p,
  customers cu,
  flags ff
WHERE
  i.interface_type_id = it.id
  AND ff.id = t.flag
  AND t.id = tfm.tid_id
  AND i.id = tfm.interface_id
  AND tis.tid_id = t.id
  AND tis.interface_id = i.id
  AND f.id = tfm.facility_id
  AND c.id = t.city_id
  AND et.id = t.element_type_id
  AND it.protocol_id = p.id
  AND f.customer_id = cu.id
;
COMMIT;
