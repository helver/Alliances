CREATE OR REPLACE VIEW facilities_list_view AS
SELECT
  f.id AS id, 
  f.id AS facility_id,
  f.name AS facility, 
  DECODE(f.active, 't', 'Yes', 'No') as active,
  ff.name as flag, 
  c.name as customer,
  c.id as customer_id,
  f.speed_id as speed_id,
  all_speeds_for_speed(f.speed_id) as speed,
  f.notes as notes
FROM
  facilities f, 
  customers c,
  flags ff
WHERE
      c.id = f.customer_id
  AND ff.id = f.flag
WITH READ ONLY;
COMMIT;
