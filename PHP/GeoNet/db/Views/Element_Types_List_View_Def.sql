CREATE OR REPLACE VIEW element_types_list_view AS 
SELECT
  e.id AS id,
  e.id AS element_type_id,
  e.name AS name,
  e.windows AS windows,
  DECODE(e.predefined_ifs, 't', 'Yes', 'No') AS predefined_ifs,
  e.pm_doc_link AS pm_doc_link
FROM
  element_types e
;
COMMIT;

