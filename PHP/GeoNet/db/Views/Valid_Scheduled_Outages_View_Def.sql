CREATE OR REPLACE VIEW Valid_Scheduled_Outages_View AS
SELECT
  a.facility_id AS facility_id,
  a.acknowledge_date AS acknowledge_date
FROM
  alarm_durations_view a, 
  outage_durations_view o
WHERE
      a.facility_id = o.facility_id
  AND o.start_time < a.start_time - 0/(24*60*60)
  AND o.end_time > a.end_time + 0/(24*60*60)
;
COMMIT;