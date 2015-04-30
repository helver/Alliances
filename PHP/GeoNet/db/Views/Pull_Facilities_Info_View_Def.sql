CREATE OR REPLACE VIEW pull_facilities_info_view AS 
SELECT
  f.id as facility_id,
  f.name as facility,
  f.customer_id as customer_id,
  ff.name as flag
FROM
  facilities f,
  flags ff
WHERE
  ff.id = f.flag
WITH READ ONLY
;
commit;
