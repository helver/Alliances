CREATE OR REPLACE VIEW cities_list_view AS
SELECT
  c.id AS id, 
  c.name AS city, 
  c.state AS state,
  c.latitude AS latitude, 
  c.longitude AS longitude, 
  c.clli_tid AS clli_tid
FROM
  cities c
WITH READ ONLY;
COMMIT;
