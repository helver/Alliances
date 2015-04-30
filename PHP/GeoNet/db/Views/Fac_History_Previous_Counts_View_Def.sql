CREATE OR REPLACE VIEW Fac_History_Prev_Counts_View AS
SELECT
  pmh.tid_id AS tidid,
  pmh.interface_id as ifcid,
  tfm.facility_id as facility_id,
  to_char(pmh.timeentered, 'MM-DD-YYYY HH24:MI:SS') AS lasttime,
  to_char(pmh.timeentered, 'YYYY-MM-DD HH24:MI:SS') AS sorttime,
  decode(
    to_char(timeentered, 'MM-DD-YYYY'), 
    to_char(SYSDATE - 1, 'MM-DD-YYYY'), 
    '0', 
    '86400') + to_char(timeentered, 'SSSSS') AS lasttimenumber,
  (pmh.c1 * its.c1sev) + (pmh.c2 * its.c2sev) + (pmh.c3 * its.c3sev) + 
  (pmh.c4 * its.c4sev) + (pmh.c5 * its.c5sev) + (pmh.c6 * its.c6sev) + 
  (pmh.c7 * its.c7sev) + (pmh.c8 * its.c8sev) + (pmh.c9 * its.c9sev) + 
  (pmh.c10 * its.c10sev) as ec
FROM
  pm_history pmh,
  tid_facility_map tfm,
  interfaces ifs,
  interface_types its
WHERE
      pmh.timeentered >= SYSDATE - 1
  and pmh.tid_id = tfm.tid_id
  and pmh.interface_id = tfm.interface_id
  and pmh.interface_id = ifs.id
  and ifs.interface_type_id = its.id
  and (tfm.trans_seq > 0 or tfm.recv_seq > 0)
ORDER BY
  pmh.timeentered
;
COMMIT;
