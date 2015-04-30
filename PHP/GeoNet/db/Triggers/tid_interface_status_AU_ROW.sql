CREATE OR REPLACE TRIGGER tid_interface_status_AU_ROW
AFTER UPDATE ON tid_interface_status
FOR EACH ROW
WHEN ( 
  new.flag <> old.flag and
  new.cause = 'H_K' and
  (new.flag = 0 or new.flag = 2)
)
BEGIN
  tid_if_status_api.tis_row_change(:new.tid_id, NULL);
END;
/
SHOW ERRORS

