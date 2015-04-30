CREATE OR REPLACE VIEW History_Previous_Counts_View AS
SELECT
  pmh.tid_id AS tidid,
  pmh.interface_id as ifcid,
  to_char(pmh.timeentered, 'MM-DD-YYYY HH24:MI:SS') AS lasttime,
  to_char(pmh.timeentered, 'YYYY-MM-DD HH24:MI:SS') AS sorttime,
  decode(
    to_char(timeentered, 'MM-DD-YYYY'), 
    to_char(SYSDATE - 1, 'MM-DD-YYYY'), 
    '0', 
    '86400') + to_char(timeentered, 'SSSSS') AS lasttimenumber,
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
  pm_history pmh
WHERE
  pmh.timeentered >= SYSDATE - 1
ORDER BY
  pmh.timeentered
;
COMMIT;
