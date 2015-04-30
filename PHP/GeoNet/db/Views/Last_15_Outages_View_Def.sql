CREATE OR REPLACE VIEW Last_15_Outages_View AS
SELECT
  so.id AS outageid,
  so.description AS description,
  so.ticketnum AS ticketnum,
  f.name AS facility,
  c.name AS customer,
  a.name || ', ' || a.state AS aside,
  z.name || ', ' || z.state AS zside,
  so.starttime_string AS starttime,
  so.endtime_string AS stoptime,
     trunc((so.end_time - so.start_time) * 24) || 'h ' 
  || trunc(((so.end_time - so.start_time) - (trunc((so.end_time - so.start_time) * 24)/24)) * 24 * 60) || 'm ' 
  || trunc(((so.end_time - so.start_time) - ((trunc((so.end_time - so.start_time) * 24)/24)) - ((trunc(((so.end_time - so.start_time) - (trunc((so.end_time - so.start_time) * 24)/24)) * 24 * 60) / 24 / 60))) * 24 * 60 * 60) || 's' AS duration
FROM
  scheduled_outages so,
  facilities f,
  customers c,
  cities a,
  cities z
WHERE
      so.facility_id = f.id(+)
  AND so.customer_id = c.id(+)
  AND so.asite_id = a.id(+)
  AND so.zsite_id = z.id(+)
ORDER BY
  so.start_time desc
;
COMMIT;
