CREATE OR REPLACE VIEW Interface_Labels_View AS
SELECT
  it.c1 AS c1,
  it.c2 AS c2,
  it.c3 AS c3,
  it.c4 AS c4,
  it.c5 AS c5,
  it.c6 AS c6,
  it.c7 AS c7,
  it.c8 AS c8,
  it.c9 AS c9,
  it.c10 AS c10,
  i.id AS interface_id,
  it.namelbl AS ifname_lbl,
  p.e1 AS e1,
  p.e2 AS e2,
  p.e3 AS e3,
  p.e4 AS e4,
  p.e5 AS e5
FROM
  interfaces i,
  interface_types it,
  protocols p
WHERE
  i.interface_type_id = it.id
  AND it.protocol_id = p.id
;
COMMIT;
