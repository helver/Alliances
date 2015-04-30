CREATE OR REPLACE VIEW Fac_History_Cur_Counts_View AS
SELECT
  pmi.tid_id AS tidid,
  pmi.interface_id as ifcid,
  tfm.facility_id as facility_id,
  to_char(pmi.timeentered, 'MM-DD-YYYY HH24:MI:SS') AS lasttime,
  to_char(pmi.timeentered, 'YYYY-MM-DD HH24:MI:SS') AS sorttime,
  decode(
    to_char(pmi.timeentered, 'MM-DD-YYYY'), 
    to_char(SYSDATE - 1, 'MM-DD-YYYY'), 
    '0', 
    '86400') + to_char(timeentered, 'SSSSS') AS lasttimenumber,
  (pmi.c1 * its.c1sev) + (pmi.c2 * its.c2sev) + (pmi.c3 * its.c3sev) + 
  (pmi.c4 * its.c4sev) + (pmi.c5 * its.c5sev) + (pmi.c6 * its.c6sev) + 
  (pmi.c7 * its.c7sev) + (pmi.c8 * its.c8sev) + (pmi.c9 * its.c9sev) + 
  (pmi.c10 * its.c10sev) as ec
FROM
  pm_info pmi,
  tid_facility_map tfm,
  interfaces ifs,
  interface_types its
WHERE
      pmi.tid_id = tfm.tid_id
  and pmi.interface_id = tfm.interface_id
  and pmi.interface_id = ifs.id
  and ifs.interface_type_id = its.id
  and (tfm.trans_seq > 0 or tfm.recv_seq > 0)
;
COMMIT;
