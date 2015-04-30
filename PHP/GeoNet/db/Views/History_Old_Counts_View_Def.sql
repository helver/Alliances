CREATE OR REPLACE VIEW History_Old_Counts_View AS
SELECT
  pmh.tid_id AS tidid,
  pmh.interface_id as ifcid,
  to_char(pmh.timeentered, 'MM-DD-YYYY HH24:MI:SS') AS lasttime,
  to_char(pmh.timeentered, 'YYYY-MM-DD HH24:MI:SS') AS sorttime,
  to_char(SYSDATE - 1, 'SSSSS') AS lasttimenumber,
  pmh.c1 AS c1,
  pmh.c2 AS c2,
  pmh.c3 AS c3,
  pmh.c4 AS c4,
  pmh.c5 AS c5,
  pmh.c6 AS c6,
  pmh.c7 AS c7,
  pmh.c8 AS c8,
  pmh.c9 AS c9,
  pmh.c10 AS c10,
  pmh.timeentered as timeentered
FROM
  pm_history pmh,
  History_Min_Time_View hmtv
WHERE
      pmh.tid_id = hmtv.tid_id
  and pmh.interface_id = hmtv.interface_id
  and pmh.timeentered = hmtv.timeentered
;
COMMIT;
