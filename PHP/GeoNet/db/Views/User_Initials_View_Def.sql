CREATE OR REPLACE VIEW user_initials_view AS 
SELECT
  id,
  upper(substr(firstname, 0, 1) ||  substr(middlename, 0, 1) || substr(lastname, 0, 1)) as initials
FROM
  users
;
commit;
