CREATE OR REPLACE VIEW tids_to_update_view AS
SELECT 
  p.tid_id AS tid_id,
  p.interface_id AS interface_id,
  tif.connect_attempt AS connect_attempt,
  ff.name AS flag,
  p.status AS status,
  p.c1 AS c1,
  p.c2 AS c2,
  p.c3 AS c3,
  p.c4 AS c4,
  p.c5 AS c5,
  p.c6 AS c6,
  p.c7 AS c7,
  p.c8 AS c8,
  p.c9 AS c9,
  p.c10 AS c10,
  p.a1 AS a1,
  p.a2 AS a2,
  p.a3 AS a3,
  p.a4 AS a4,
  p.a5 AS a5,
  p.a6 AS a6,
  p.a7 AS a7,
  p.a8 AS a8,
  p.a9 AS a9,
  p.a10 AS a10,
  p.cause AS cause,
  p.trapnum AS trapnum,
  p.agent AS agent,
  p.timeentered AS timeentered
FROM
  pm_info p,
  tid_interface_status tif,
  flags ff
WHERE
      tif.tid_id = p.tid_id
  AND tif.flag = ff.id
  AND tif.interface_id = p.interface_id
;
COMMIT;