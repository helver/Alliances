CREATE OR REPLACE VIEW USMap_Dataset_View AS
SELECT
  t.id AS tid_id,
  t.name AS tid,
  ff.name AS flag,
  t.ipaddress AS ipaddress,
  to_char(tis.timeentered, 'MM-DD-YYYY HH24:MI:SS') AS lasttime,
  to_char(tis.timeentered, 'YYYY-MM-DD HH24:MI:SS') AS sorttime,
  f.name AS facility,
  f.id AS facility_id,
  c.name || ', ' || c.state AS city,
  c.longitude AS longitude,
  c.latitude AS latitude,
  et.name AS element_type,
  f.customer_id AS customer_id
FROM
  tids t,
  tid_facility_map tfm,
  tid_interface_status tis,
  facilities f,
  cities c,
  element_types et,
  flags ff
WHERE
      t.id = tfm.tid_id
  AND ff.id = tis.flag
  AND f.id = tfm.facility_id
  AND tis.tid_id = tfm.tid_id
  AND tis.interface_id = tfm.interface_id
  AND c.id = t.city_id
  AND et.id = t.element_type_id
;
COMMIT;
