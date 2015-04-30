CREATE OR REPLACE VIEW History_Max_Error_Counts_View AS
SELECT
  pmh.tid_id AS tidid,
  pmh.interface_id as ifcid,
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
  History_Period_MaxError_View pmh
GROUP BY
  pmh.tid_id, pmh.interface_id
;
COMMIT;
