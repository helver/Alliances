CREATE OR REPLACE VIEW alarm_creation_view AS
SELECT 
  tis.tid_id AS tid_id, 
  to_char(NVL(tis.timeentered, SYSDATE), 'MM/DD/YYYY HH24:MI:SS') AS timeentered, 
  DECODE(tis.cause, 'COM', to_char(tis.timeentered, 'MM/DD/YYYY HH24:MI:SS'), NULL) AS acknowledge_date, 
  tis.interface_id AS interface_id,
  tis.cause AS cause
FROM 
  tid_interface_status tis, 
  tid_facility_map tfm, 
  facilities f
WHERE 
    tis.tid_id = tfm.tid_id
AND tis.interface_id = tfm.interface_id
AND f.id = tfm.facility_id
AND f.active = 't'
AND tis.flag = 8
AND tis.tid_id NOT IN (
    SELECT UNIQUE tid_id FROM alarms WHERE cleared IS NULL OR acknowledge_date IS NULL) 
AND (tis.tid_id, tis.timeentered) NOT IN (
    SELECT tid_id, MAX(timeentered) FROM alarms WHERE tid_id = tis.tid_id GROUP BY tid_id)
;
COMMIT;
