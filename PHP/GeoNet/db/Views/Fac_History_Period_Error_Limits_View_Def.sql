CREATE OR REPLACE VIEW FacHistory_Error_Limits_View AS
SELECT
  pmh.tid_id AS tid_id,
  pmh.interface_id as interface_id,
  MAX(tfm.facility_id) as facility_id,
  MAX((pmh.c1 * its.c1sev) + (pmh.c2 * its.c2sev) + (pmh.c3 * its.c3sev) + 
  (pmh.c4 * its.c4sev) + (pmh.c5 * its.c5sev) + (pmh.c6 * its.c6sev) + 
  (pmh.c7 * its.c7sev) + (pmh.c8 * its.c8sev) + (pmh.c9 * its.c9sev) + 
  (pmh.c10 * its.c10sev)) as max_ec,
  MIN((pmh.c1 * its.c1sev) + (pmh.c2 * its.c2sev) + (pmh.c3 * its.c3sev) + 
  (pmh.c4 * its.c4sev) + (pmh.c5 * its.c5sev) + (pmh.c6 * its.c6sev) + 
  (pmh.c7 * its.c7sev) + (pmh.c8 * its.c8sev) + (pmh.c9 * its.c9sev) + 
  (pmh.c10 * its.c10sev)) as min_ec
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
GROUP BY
  pmh.tid_id, pmh.interface_id
UNION
SELECT
  pmh.tid_id AS tid_id,
  pmh.interface_id as interface_id,
  MAX(tfm.facility_id) as facility_id,
  MAX((pmh.c1 * its.c1sev) + (pmh.c2 * its.c2sev) + (pmh.c3 * its.c3sev) + 
  (pmh.c4 * its.c4sev) + (pmh.c5 * its.c5sev) + (pmh.c6 * its.c6sev) + 
  (pmh.c7 * its.c7sev) + (pmh.c8 * its.c8sev) + (pmh.c9 * its.c9sev) + 
  (pmh.c10 * its.c10sev)) as max_ec,
  MIN((pmh.c1 * its.c1sev) + (pmh.c2 * its.c2sev) + (pmh.c3 * its.c3sev) + 
  (pmh.c4 * its.c4sev) + (pmh.c5 * its.c5sev) + (pmh.c6 * its.c6sev) + 
  (pmh.c7 * its.c7sev) + (pmh.c8 * its.c8sev) + (pmh.c9 * its.c9sev) + 
  (pmh.c10 * its.c10sev)) as min_ec
FROM
  pm_history pmh,
  Fac_History_Min_Time_View fhmtv,
  tid_facility_map tfm,
  interfaces ifs,
  interface_types its
WHERE
  pmh.tid_id = fhmtv.tid_id
  and pmh.interface_id = fhmtv.interface_id
  and pmh.timeentered = fhmtv.timeentered
  and pmh.tid_id = tfm.tid_id
  and pmh.interface_id = tfm.interface_id
  and pmh.interface_id = ifs.id
  and ifs.interface_type_id = its.id
  and (tfm.trans_seq > 0 or tfm.recv_seq > 0)
GROUP BY
  pmh.tid_id, pmh.interface_id
UNION
SELECT
  pmh.tid_id AS tid_id,
  pmh.interface_id as interface_id,
  tfm.facility_id as facility_id,
  (pmh.c1 * its.c1sev) + (pmh.c2 * its.c2sev) + (pmh.c3 * its.c3sev) + 
  (pmh.c4 * its.c4sev) + (pmh.c5 * its.c5sev) + (pmh.c6 * its.c6sev) + 
  (pmh.c7 * its.c7sev) + (pmh.c8 * its.c8sev) + (pmh.c9 * its.c9sev) + 
  (pmh.c10 * its.c10sev) as max_ec,
  (pmh.c1 * its.c1sev) + (pmh.c2 * its.c2sev) + (pmh.c3 * its.c3sev) + 
  (pmh.c4 * its.c4sev) + (pmh.c5 * its.c5sev) + (pmh.c6 * its.c6sev) + 
  (pmh.c7 * its.c7sev) + (pmh.c8 * its.c8sev) + (pmh.c9 * its.c9sev) + 
  (pmh.c10 * its.c10sev) as min_ec
FROM
  pm_info pmh,
  tid_facility_map tfm,
  interfaces ifs,
  interface_types its
WHERE
      pmh.tid_id = tfm.tid_id
  and pmh.interface_id = tfm.interface_id
  and pmh.interface_id = ifs.id
  and ifs.interface_type_id = its.id
  and (tfm.trans_seq > 0 or tfm.recv_seq > 0)
;
SHOW ERROR;
COMMIT;
