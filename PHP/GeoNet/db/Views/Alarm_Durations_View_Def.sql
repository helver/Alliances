CREATE OR REPLACE VIEW Alarm_Durations_View AS
SELECT
  f.id AS facility_id, 
  max(f.customer_id) AS customer_id, 
  min(a.timeentered) AS start_time, 
  max(a.time_cleared) AS end_time, 
  (max(a.time_cleared) - min(a.timeentered)) * 24 * 3600 AS secs_duration,
  a.acknowledge_date AS acknowledge_date
FROM
  alarms a,
  tid_facility_map tfm,
  facilities f
WHERE 
      a.tid_id = tfm.tid_id
  AND a.interface_id = tfm.interface_id
  AND f.id = tfm.facility_id   
  AND a.time_cleared IS NOT NULL 
GROUP BY
  f.id, 
  a.acknowledge_date
;
COMMIT;