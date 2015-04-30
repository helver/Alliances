CREATE OR REPLACE VIEW get_customer_facility_view AS 
SELECT
  customer_id as customer_id,
  id as facility_id
FROM
  facilities
;
commit;
