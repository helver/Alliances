CREATE OR REPLACE VIEW Facility_End_Points_View AS
SELECT 
  q.facility_id AS facility_id,
  max(decode(q.trans_seq, 
            (SELECT MIN(trans_seq) FROM tid_facility_map WHERE facility_id = q.facility_id AND trans_seq >= 1), 
             q.tid_id, 
             NULL)) AS a_site_tid,
  max(decode(q.trans_seq, 
            (SELECT MAX(trans_seq) FROM tid_facility_map WHERE facility_id = q.facility_id AND trans_seq >= 1), 
             tid_id, 
             NULL)) AS z_site_tid
FROM
  tid_facility_map q 
GROUP BY
  q.facility_id
;
COMMIT;