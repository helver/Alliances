CREATE OR REPLACE VIEW pull_customer_list_view AS 
SELECT
  c.id as customer_id,
  c.name as customer,
  c.short_name as short_name,
  c.flag as flag,
  ff.name as flagname
FROM
  customers c,
  flags ff
WHERE
  c.flag = ff.id
WITH READ ONLY
;
commit;
