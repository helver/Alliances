CREATE OR REPLACE TRIGGER tid_interface_status_AU_STM
AFTER UPDATE ON tid_interface_status
BEGIN
  tid_if_status_api.tis_statement_change;
  -- insert into debugging values ('Invoked tis_statement_change');
END;
/
SHOW ERRORS

