CREATE OR REPLACE VIEW ATMMap_Trans_Links_View AS
SELECT
  h.tracenum || '_' || h.pathindex as facility_id,
  h.clli as tid_id,
  h.hop as trans_facility_path
FROM
  historical h
WHERE
  h.currentpath = 1
  and h.clli is not null
and (h.connection like '%Lenexa%' or h.connection like '%Irving%')
ORDER BY
  facility_id, trans_facility_path
;
COMMIT;
