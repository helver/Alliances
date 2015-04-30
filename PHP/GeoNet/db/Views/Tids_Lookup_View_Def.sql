CREATE OR REPLACE VIEW Tids_Lookup_View AS
SELECT
  t.id || ',' || i.id AS id,
  t.id as tid_id,
  t.dwdm_facility AS dwdm_facility,
  t.grouping_name AS grouping_name,
  t.name || ' - ' || it.namelbl || ' ' || i.name AS name,
  i.name AS ifname, 
  it.speed_id as speed_id
FROM
  tids t,
  interfaces i,
  interface_types it
WHERE
      i.interface_type_id = it.id
  AND it.element_type_id = t.element_type_id
;
COMMIT;