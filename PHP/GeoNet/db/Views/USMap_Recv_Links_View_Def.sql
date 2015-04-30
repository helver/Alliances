CREATE OR REPLACE VIEW USMap_Recv_Links_View AS
SELECT
  tfm.tid_id AS tid_id, 
  tfm.facility_id AS facility_id,
  tfm.interface_id AS interface_id,
  tfm.recv_seq AS recv_facility_path,
  f.customer_id AS customer_id
FROM
  tid_facility_map tfm,
  facilities f
WHERE
      tfm.recv_seq > 0
  AND f.id = tfm.facility_id
ORDER BY
  tfm.recv_seq
;
COMMIT;
