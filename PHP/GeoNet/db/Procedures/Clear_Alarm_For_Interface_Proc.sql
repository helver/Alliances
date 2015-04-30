CREATE OR REPLACE PROCEDURE clear_alarm_for_interface
( xtid_id IN tids.id%TYPE,
  xinterface_id IN interfaces.id%TYPE,
  status IN OUT tids.flag%TYPE
)
AS
  CURSOR get_alarm_cursor IS
    SELECT 9 as newstat FROM alarms WHERE tid_id = xtid_id AND interface_id = xinterface_id AND acknowledge_date IS NULL;
  alarm get_alarm_cursor%ROWTYPE;

  xxnewstat tids.flag%TYPE := 4;
  currdate VARCHAR2(25);
  xxstatus NUMBER := 0;
BEGIN
  SELECT to_char(SYSDATE, 'MM/DD/YYYY HH24:MI:SS') INTO currdate FROM dual;

  UPDATE alarms SET cleared = 't', time_cleared = to_date(currdate, 'MM/DD/YYYY HH24:MI:SS') WHERE tid_id = xtid_id AND interface_id = xinterface_id AND time_cleared IS NULL;

  OPEN get_alarm_cursor;
  FETCH get_alarm_cursor INTO alarm;
    xxnewstat := alarm.newstat;
  CLOSE get_alarm_cursor;
  
  IF xxnewstat = 9 THEN
    status := xxnewstat;
  END IF;

  SELECT MAX(DECODE(SIGN(m.recv_seq), -1, 0, 1) + DECODE(SIGN(m.trans_seq), -1, 0, 1)) INTO xxstatus FROM tid_facility_map m WHERE m.tid_id = xtid_id AND m.interface_id = xinterface_id;
  IF xxstatus = 0 THEN
    status := 0;
  END IF;
END;
/
SHOW ERRORS
