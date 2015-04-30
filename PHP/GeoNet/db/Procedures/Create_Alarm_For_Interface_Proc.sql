CREATE OR REPLACE PROCEDURE create_alarm_for_interface
( xtid_id IN tids.id%TYPE,
  xinterface_id IN interfaces.id%TYPE,
  xcause IN tids.cause%TYPE,
  status IN OUT tids.flag%TYPE
)
AS
  CURSOR get_alarm_cursor IS
    SELECT id, DECODE(time_cleared, NULL, 'f', 't') as cleared, DECODE(acknowledge_date, NULL, 'f', 't') as acked, to_char(acknowledge_date, 'MM/DD/YYYY HH24:MI:SS') as ackdate FROM alarms 
    WHERE tid_id = xtid_id AND interface_id = xinterface_id;
  alarm get_alarm_cursor%ROWTYPE;

  CURSOR get_alarmc_cursor IS
    SELECT count(1) as cc FROM alarms WHERE tid_id = xtid_id AND interface_id = xinterface_id;
  calarm get_alarmc_cursor%ROWTYPE;

  alarm_id alarms.id%TYPE;
  alarm_acked CHAR(1);
  alarm_cleared CHAR(1);
  alarm_ackdate CHAR(25);
  currdate VARCHAR2(25);
  alarmc NUMBER := 0;
  xxstatus NUMBER := 0;
BEGIN
  SELECT MAX(DECODE(SIGN(m.recv_seq), -1, 0, 1) + DECODE(SIGN(m.trans_seq), -1, 0, 1)) INTO xxstatus FROM tid_facility_map m WHERE m.tid_id = xtid_id AND m.interface_id = xinterface_id;
  
  IF xxstatus > 0 THEN
    OPEN get_alarmc_cursor;
    FETCH get_alarmc_cursor INTO calarm;
      alarmc := calarm.cc; 
    CLOSE get_alarmc_cursor;

    IF alarmc > 0 THEN
      SELECT MAX(id) INTO alarm_id FROM alarms WHERE timeentered = (SELECT MAX(timeentered) FROM alarms WHERE tid_id = xtid_id AND interface_id = xinterface_id) AND tid_id = xtid_id AND interface_id = xinterface_id;
      SELECT DECODE(time_cleared, NULL, 'f', 't') INTO alarm_cleared  FROM alarms where id = alarm_id;
      SELECT DECODE(acknowledge_date, NULL, 'f', 't') INTO alarm_acked FROM alarms where id = alarm_id;
 
      --insert into debugging values ('Existing Alarm_id: ' || alarm_id || ' acked: ' || alarm_acked || ' cleared: ' || alarm_cleared || ' date: ' || alarm_ackdate);

      IF alarm_acked = 't' AND alarm_cleared = 't' 
      THEN
        alarm_id := NULL;
      END IF;
    END IF;
  
  
    IF (alarm_id IS NULL OR alarm_id = '')
    THEN 
      SELECT alarm_id_seq.nextval INTO alarm_id FROM DUAL;
      SELECT to_char(SYSDATE, 'MM/DD/YYYY HH24:MI:SS') INTO currdate FROM dual;
	  --insert into debugging values ('New Alarm_id: ' || alarm_id);
      INSERT INTO alarms (id, timeentered, cause, tid_id, interface_id) SELECT alarm_id, to_date(currdate, 'MM/DD/YYYY HH24:MI:SS'), xcause, xtid_id, xinterface_id from DUAL;
      status := 9;
    ELSIF (alarm_acked = 'f') 
    THEN
      status := 9;
    END IF;
  END IF;
END;
/
SHOW ERRORS


