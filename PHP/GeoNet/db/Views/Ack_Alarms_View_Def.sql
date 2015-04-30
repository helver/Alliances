CREATE OR REPLACE VIEW ack_alarms_view AS
SELECT 
  f.id AS facility_id, 
  max(a.ticketnum) as ticketno,
  max(a.initials) as initials
FROM
  alarms a,
  tid_facility_map tfm,
  facilities f
WHERE
      a.tid_id = tfm.tid_id
  AND a.interface_id = tfm.interface_id
  AND tfm.facility_id = f.id
  AND a.acknowledge_date IS NULL
GROUP BY 
  f.id
;
commit;
