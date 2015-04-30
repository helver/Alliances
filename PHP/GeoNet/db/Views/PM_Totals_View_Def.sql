CREATE OR REPLACE VIEW pm_totals_view AS 
SELECT
  pm.interface_id AS interface_id,
  pm.tid_id AS tid_id,
  pm.a1 AS a1,
  pm.a2 AS a2,
  pm.a3 AS a3,
  pm.a4 AS a4,
  pm.a5 AS a5,
  pm.a6 AS a6,
  pm.a7 AS a7,
  pm.a8 AS a8,
  pm.a9 AS a9,
  pm.a10 AS a10,
  to_char(pm.timeentered, 'MM/DD/YYYY HH24:MI:SS') AS timeentered,
  SYSDATE AS currenttime,
  pm.cause AS cause,
  pm.c9 AS c9
FROM
  pm_info pm
;
COMMIT;