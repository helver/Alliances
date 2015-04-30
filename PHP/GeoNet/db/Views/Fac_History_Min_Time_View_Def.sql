CREATE OR REPLACE VIEW Fac_History_Min_Time_View AS
SELECT 
  MAX(timeentered) as timeentered,
  tid_id as tid_id,
  interface_id as interface_id
FROM pm_history 
WHERE 
  timeentered <= SYSDATE -1 
GROUP BY tid_id, interface_id
UNION
SELECT 
  MIN(timeentered) as timeentered,
  tid_id as tid_id,
  interface_id as interface_id
FROM pm_history 
GROUP BY tid_id, interface_id
;
COMMIT;

