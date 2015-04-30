CREATE OR REPLACE VIEW ATMMap_Dataset_View AS
SELECT
  t.id AS tid_id,
  t.name AS tid,
  ff.name AS flag,
  t.ipaddress AS ipaddress,
  c.id AS symbol,
  c.name AS city,
  c.longitude AS longitude,
  c.latitude AS latitude,
  f.id AS facility_id,
  f.name AS facility,
  pmi.cause AS cause,
  pmi.timeentered,
  tis.flag AS conflag,
  f.customer_id AS customer_id,
  tis.interface_id AS interface_id
FROM
  tids t,
  cities c,
  tid_facility_map tfm,
  pm_info pmi,
  tid_interface_status tis,
  facilities f,
  flags ff
WHERE
  c.id = t.city_id
  AND t.id = tfm.tid_id
  AND f.id = tfm.facility_id
  AND tis.tid_id = t.id
  AND tis.interface_id = tfm.interface_id
  AND pmi.tid_id = t.id
  AND pmi.interface_id = tfm.interface_id
  AND ff.id = t.flag
;
COMMIT;
