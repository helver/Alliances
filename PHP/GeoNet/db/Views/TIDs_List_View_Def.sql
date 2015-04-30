CREATE OR REPLACE VIEW tids_list_view AS
SELECT
  t.id AS id, 
  t.id AS tid_id, 
  t.name AS tid, 
  t.ipaddress AS ipaddress,
  t.grouping_name AS grouping_name,
  t.dwdm_facility AS dwdm_facility,
  ff.name AS flag, 
  c.name || ', ' || c.state AS city,
  c.state AS state,
  c.id AS customer_id,
  c.clli_tid AS clli_tid,
  e.id AS element_type_id,
  e.name AS element_type
FROM
  tids t, 
  cities c,
  element_types e,
  flags ff
WHERE
      c.id = t.city_id
  AND ff.id = t.flag
  AND e.id = t.element_type_id
WITH READ ONLY;
COMMIT;
