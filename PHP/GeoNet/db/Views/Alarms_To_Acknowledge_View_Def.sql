CREATE OR REPLACE VIEW alarms_to_acknowledge_view AS
SELECT 
  a.id AS alarm_id, 
  a.tid_id AS tidid, 
  f.id AS facility_id, 
  t.name AS tid, 
  f.customer_id AS customerid, 
  a.interface_id AS channel,
  a.timeentered AS timeentered,
  a.acknowledge_date as acknowledge_date,
  a.ticketnum as ticketno,
  a.initials as initials
FROM
  alarms a,
  tids t,
  tid_facility_map tfm,
  facilities f
WHERE
      a.tid_id = t.id
  AND a.tid_id = tfm.tid_id
  AND a.interface_id = tfm.interface_id
  AND tfm.facility_id = f.id
  AND a.acknowledge_date IS NULL
;
commit;
