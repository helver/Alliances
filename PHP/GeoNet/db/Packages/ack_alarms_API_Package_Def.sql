--SET serveroutput on
CREATE OR REPLACE PACKAGE ack_alarms_api AS

PROCEDURE ack_alarm_row (facility_id IN facilities.id%TYPE, initials IN alarms.initials%TYPE, ticketno IN alarms.ticketnum%TYPE);
PROCEDURE ack_alarm_statement;
PROCEDURE ack_alarm_by_fac (myfacility_id IN facilities.id%TYPE, myinitials IN alarms.initials%TYPE, myticketno IN alarms.ticketnum%TYPE);

END ack_alarms_api;
/
SHOW ERRORS


CREATE OR REPLACE PACKAGE BODY ack_alarms_api AS

TYPE ack_alarms_rec IS RECORD (
  id facilities.id%TYPE,
  initials alarms.initials%TYPE, 
  ticketno alarms.ticketnum%TYPE
);

TYPE ack_alarms_tab IS TABLE OF ack_alarms_rec;
g_ack_alarms_tab  ack_alarms_tab := ack_alarms_tab();

PROCEDURE ack_alarm_row 
( facility_id IN facilities.id%TYPE, 
  initials IN alarms.initials%TYPE, 
  ticketno IN alarms.ticketnum%TYPE
) 
AS
  foundit NUMBER := 0;
BEGIN
  IF g_ack_alarms_tab.first > 0 THEN
    FOR i IN g_ack_alarms_tab.first .. g_ack_alarms_tab.last LOOP
      IF g_ack_alarms_tab(i).id = facility_id THEN
        foundit := 1;
	  END IF;
    END LOOP;
  END IF;

  IF foundit = 0 THEN
    g_ack_alarms_tab.extend;
    g_ack_alarms_tab(g_ack_alarms_tab.last).id := facility_id;
    g_ack_alarms_tab(g_ack_alarms_tab.last).initials := initials;
    g_ack_alarms_tab(g_ack_alarms_tab.last).ticketno := ticketno;
  END IF;
END ack_alarm_row;



PROCEDURE ack_alarm_statement 
AS
  gtct_cnt NUMBER := 0;
BEGIN
  gtct_cnt := g_ack_alarms_tab.last;
  --insert into debugging values ('entering statement func - total in table: ' || gtct_cnt);
  
  IF g_ack_alarms_tab.first > 0 THEN
    FOR i IN g_ack_alarms_tab.first .. g_ack_alarms_tab.last LOOP
      IF g_ack_alarms_tab(i).id IS NOT NULL THEN
	    ack_alarm_by_fac(g_ack_alarms_tab(i).id, g_ack_alarms_tab(i).initials, g_ack_alarms_tab(i).ticketno);
	  END IF;
    END LOOP;
  END IF;
  g_ack_alarms_tab.delete;
END ack_alarm_statement;



PROCEDURE ack_alarm_by_fac
( myfacility_id IN facilities.id%TYPE,
  myinitials IN alarms.initials%TYPE, 
  myticketno IN alarms.ticketnum%TYPE
)
AS
  CURSOR pm_info_cursor IS
    SELECT * FROM tid_interface_status 
    WHERE (tid_id, interface_id) IN (SELECT tid_id, interface_id FROM tid_facility_map WHERE facility_id = myfacility_id);
  pms pm_info_cursor%ROWTYPE;
  
  status tid_interface_status.flag%TYPE := 4;
  cause tid_interface_status.cause%TYPE;
  currdate VARCHAR2(25);
  hostname VARCHAR2(100);
BEGIN
  FOR pms IN pm_info_cursor
  LOOP
    --insert into debugging values ('Doing fac ' || myfacility_id || ' if: ' || pms.interface_id || ' tid: ' || pms.tid_id);
    
    UPDATE alarms SET ticketnum = myticketno, initials = myinitials, acknowledge_date = SYSDATE WHERE tid_id = pms.tid_id and interface_id = pms.interface_id and acknowledge_Date is NULL;

    determine_tis(pms.tid_id, pms.interface_id, pms.c1, pms.c2, pms.c3, pms.c4, pms.c5, pms.c6, pms.c7, pms.c8, pms.c9, pms.c10, status, cause, 1);
    status_to_tids_rollup(pms.tid_id);
    status_to_facilities_rollup(pms.tid_id, pms.interface_id);
  END LOOP;
END ack_alarm_by_fac;


END ack_alarms_api;
/
SHOW ERRORS

@GeoNet/db/Views/Alarms_To_Acknowledge_View_Def.sql
@GeoNet/db/Triggers/Ack_Alarms_View_IOU.sql
COMMIT;
