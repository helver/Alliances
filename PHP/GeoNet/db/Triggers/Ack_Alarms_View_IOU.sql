CREATE OR REPLACE TRIGGER alarms_to_ack_view_IOU
INSTEAD OF UPDATE ON ack_alarms_view
FOR EACH ROW
BEGIN
--  insert into debugging values ('Entering trigger');
  ack_alarms_api.ack_alarm_row(:new.facility_id, :new.initials, :new.ticketno);
  ack_alarms_api.ack_alarm_statement;
END;
/
SHOW ERRORS

