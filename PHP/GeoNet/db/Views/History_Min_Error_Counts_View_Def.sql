CREATE OR REPLACE VIEW History_Min_Error_Counts_View AS
SELECT
  pmh.tid_id AS tidid,
  pmh.interface_id as ifcid,
  MIN(pmh.c1) AS c1,
  MIN(pmh.c2) AS c2,
  MIN(pmh.c3) AS c3,
  MIN(pmh.c4) AS c4,
  MIN(pmh.c5) AS c5,
  MIN(pmh.c6) AS c6,
  MIN(pmh.c7) AS c7,
  MIN(pmh.c8) AS c8,
  MIN(pmh.c9) AS c9,
  MIN(pmh.c10) AS c10
FROM
  pm_history pmh
WHERE
  pmh.timeentered >= SYSDATE - 1
GROUP BY
  pmh.tid_id, pmh.interface_id
;
COMMIT;
