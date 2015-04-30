CREATE OR REPLACE TRIGGER facility_keephistory_AU_ROW
AFTER UPDATE ON facilities
FOR EACH ROW
WHEN ( 
  new.keephistory <> old.keephistory
)
BEGIN
  update tids set keephistory = :new.keephistory where id in (select tid_id from tid_facility_map tfm where facility_id = :new.id);
END;
/
SHOW ERRORS
