CREATE OR REPLACE VIEW History_Period_MaxError_View AS
SELECT
  pmh.tid_id AS tid_id,
  pmh.interface_id as interface_id,
  MAX(pmh.c1) AS c1,
  MAX(pmh.c2) AS c2,
  MAX(pmh.c3) AS c3,
  MAX(pmh.c4) AS c4,
  MAX(pmh.c5) AS c5,
  MAX(pmh.c6) AS c6,
  MAX(pmh.c7) AS c7,
  MAX(pmh.c8) AS c8,
  MAX(pmh.c9) AS c9,
  MAX(pmh.c10) AS c10
FROM
  pm_history pmh
WHERE
  pmh.timeentered >= SYSDATE - 1
GROUP BY
  pmh.tid_id, pmh.interface_id
UNION
SELECT
  pmh.tid_id AS tid_id,
  pmh.interface_id as interface_id,
  pmh.c1 AS c1,
  pmh.c2 AS c2,
  pmh.c3 AS c3,
  pmh.c4 AS c4,
  pmh.c5 AS c5,
  pmh.c6 AS c6,
  pmh.c7 AS c7,
  pmh.c8 AS c8,
  pmh.c9 AS c9,
  pmh.c10 AS c10
FROM
  pm_history pmh,
  History_Min_Time_View hmtv
WHERE
      pmh.tid_id = hmtv.tid_id
  and pmh.interface_id = hmtv.interface_id
  and pmh.timeentered = hmtv.timeentered
UNION
SELECT
  pmh.tid_id AS tid_id,
  pmh.interface_id as interface_id,
  pmh.c1 AS c1,
  pmh.c2 AS c2,
  pmh.c3 AS c3,
  pmh.c4 AS c4,
  pmh.c5 AS c5,
  pmh.c6 AS c6,
  pmh.c7 AS c7,
  pmh.c8 AS c8,
  pmh.c9 AS c9,
  pmh.c10 AS c10
FROM
  pm_info pmh
;
COMMIT;
