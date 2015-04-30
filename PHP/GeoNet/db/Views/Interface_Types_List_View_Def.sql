CREATE OR REPLACE VIEW interface_types_list_view AS 
SELECT
  it.id AS id,
  it.name AS name,
  e.id AS element_type_id,
  e.name AS element_type,
  p.name AS protocol,
  p.id AS protocol_id,
  it.namelbl AS ifname,
  s.name AS speed,
  s.id AS speed_id
FROM
  interface_types it,
  protocols p,
  speeds s,
  element_types e
WHERE 
      it.protocol_id = p.id
  AND s.id = it.speed_id
  AND e.id = it.element_type_id
;
COMMIT;

