CREATE OR REPLACE VIEW USMap_Ifc_Dataset_View AS
SELECT
  t.id AS tid_id,
  ff.name AS flag,
  to_char(tis.timeentered, 'HH24:MI') AS lasttime,
  to_char(tis.timeentered, 'YYYY-MM-DD HH24:MI:SS') AS sorttime,
  tis.cause AS cause,
  tis.c1 AS c1_val,
  tis.c2 AS c2_val,
  tis.c3 AS c3_val,
  tis.c4 AS c4_val,
  tis.c5 AS c5_val,
  tis.c6 AS c6_val,
  tis.c7 AS c7_val,
  tis.c8 AS c8_val,
  tis.c9 AS c9_val,
  tis.c10 AS c10_val,
  it.c1 AS c1_label,
  it.c2 AS c2_label,
  it.c3 AS c3_label,
  it.c4 AS c4_label,
  it.c5 AS c5_label,
  it.c6 AS c6_label,
  it.c7 AS c7_label,
  it.c8 AS c8_label,
  it.c9 AS c9_label,
  it.c10 AS c10_label,
  f.name AS facility,
  i.id AS interface_id,
  i.name AS ifname,
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
  f.customer_id AS customer_id,
  f.notes as notes
FROM
  tids t,
  tid_facility_map tfm,
  interfaces i,
  tid_interface_status tis,
  interface_types it,
  facilities f,
  protocols p,
  flags ff
WHERE
      i.interface_type_id = it.id
  AND ff.id = tis.flag
  AND t.id = tfm.tid_id
  AND i.id = tfm.interface_id
  AND tis.tid_id = t.id
  AND tis.interface_id = i.id
  AND f.id = tfm.facility_id
  AND it.protocol_id = p.id
  AND f.active = 't'
;
COMMIT;
