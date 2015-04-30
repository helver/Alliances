CREATE OR REPLACE VIEW customer_list_by_user_view AS 
SELECT
  ugum.user_id as user_id,
  cgm.customer_id as customer_id,
  cgm.user_group_id as group_id,
  cgm.display_order as display_order
FROM
  user_group_user_map ugum,
  customer_group_map cgm
WHERE 
  cgm.user_group_id = ugum.user_group_id 
ORDER BY
  cgm.user_group_id, cgm.display_order
;
commit;