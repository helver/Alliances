CREATE OR REPLACE VIEW normal_populate_tid_queue_view AS
SELECT 
  DISTINCT(DECODE(t.ring_id, NULL, tfm.tid_id, t.ring_id)) AS tid_id, 
  SYSDATE AS timeentered, 
  0 AS active
FROM 
  facilities f, 
  tid_queue tq,
  tids t,
  tid_facility_map tfm
WHERE 
      tfm.tid_id = tq.tid_id(+) 
  AND t.id = tfm.tid_id
  AND tq.tid_id IS NULL
  AND (t.ring_id IS NULL or t.ring_id not in (select tid_id from tid_queue))
  AND tfm.facility_id = f.id 
  AND f.active = 't' 
  AND (tfm.trans_seq > 0 OR tfm.recv_seq > 0)
;
COMMIT;