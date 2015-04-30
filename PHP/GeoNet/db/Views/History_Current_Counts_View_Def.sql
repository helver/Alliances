CREATE OR REPLACE VIEW History_Current_Counts_View AS
SELECT
  pmi.tid_id AS tidid,
  pmi.interface_id as ifcid,
  to_char(pmi.timeentered, 'MM-DD-YYYY HH24:MI:SS') AS lasttime,
  to_char(pmi.timeentered, 'YYYY-MM-DD HH24:MI:SS') AS sorttime,
  decode(
    to_char(pmi.timeentered, 'MM-DD-YYYY'), 
    to_char(SYSDATE - 1, 'MM-DD-YYYY'), 
    '0', 
    '86400') + to_char(timeentered, 'SSSSS') AS lasttimenumber,
  pmi.c1 AS c1,
  pmi.c2 AS c2,
  pmi.c3 AS c3,
  pmi.c4 AS c4,
  pmi.c5 AS c5,
  pmi.c6 AS c6,
  pmi.c7 AS c7,
  pmi.c8 AS c8,
  pmi.c9 AS c9,
  pmi.c10 AS c10
FROM
  pm_info pmi
;
COMMIT;
