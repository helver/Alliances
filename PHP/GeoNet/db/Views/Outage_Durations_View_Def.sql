CREATE OR REPLACE VIEW Outage_Durations_View AS
SELECT 
  so.facility_id AS facility_id, 
  so.start_time AS start_time, 
  so.end_time AS end_time 
FROM 
  scheduled_outages so
;
COMMIT;