CREATE OR REPLACE VIEW interface_type_info_view AS 
SELECT
  it.id AS interface_type,
  it.protocol_id AS protocol_id,
  p.name AS protocol,
  p.e1 AS e1name,
  p.e2 AS e2name,
  p.e3 AS e3name,
  p.e4 AS e4name,
  p.e5 AS e5name,
  it.namelbl AS ifname,
  it.c1 AS c1name,
  it.c2 AS c2name,
  it.c3 AS c3name,
  it.c4 AS c4name,
  it.c5 AS c5name,
  it.c6 AS c6name,
  it.c7 AS c7name,
  it.c8 AS c8name,
  it.c9 AS c9name,
  it.c10 AS c10name,
  s.name AS speed,
  it.use_accumulators AS use_accumulators
FROM
  interface_types it,
  protocols p,
  speeds s
WHERE 
      it.protocol_id = p.id
  AND s.id = it.speed_id
;
COMMIT;

