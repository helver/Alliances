CREATE OR REPLACE VIEW Alarm_History_View AS
SELECT
  a.tid_id AS tid_id,
  t.name AS tid,
  i.id AS interface_id,
  i.name AS ifname,
  f.id AS facilityid, 
  f.name AS facility,
  f.customer_id AS customer_id, 
  c.name as customer,
  to_char(a.acknowledge_date, 'MM-DD-YYYY HH24:MI:SS') AS acktime,
  to_char(a.timeentered, 'MM-DD-YYYY HH24:MI:SS') AS thetime,
  a.cause AS cause,
  a.timeentered AS timeentered,
  a.ticketnum AS ticketnum,
  a.initials as initials
FROM
  alarms a,
  tid_facility_map tfm,
  facilities f,
  customers c,
  interfaces i,
  tids t
WHERE 
      a.tid_id = tfm.tid_id
  AND a.interface_id = tfm.interface_id
  AND f.id = tfm.facility_id   
  AND c.id = f.customer_id
  AND i.id = a.interface_id
  AND t.id = a.tid_id
ORDER BY
  a.timeentered
;
COMMIT;
