CREATE OR REPLACE VIEW Unscheduled_Outages_View AS
SELECT 
  f.name AS facilityid, 
  a.customer_id AS customerid, 
  a.start_time AS start_time, 
  a.end_time AS end_time, 
  a.secs_duration AS secs_duration
FROM 
  alarm_durations_view a, 
  valid_scheduled_outages_view v,
  facilities f
WHERE 
      a.facility_id = v.facility_id(+) 
  AND a.acknowledge_date = v.acknowledge_date(+) 
  AND v.facility_id IS NULL
  AND f.id = a.facility_id
;
COMMIT;