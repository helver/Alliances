CREATE OR REPLACE PROCEDURE determine_tis
( xtid_id IN tids.id%TYPE,
  xinterface_id IN interfaces.id%TYPE,
  xc1 IN NUMBER,  
  xc2 IN NUMBER,
  xc3 IN NUMBER,
  xc4 IN NUMBER,
  xc5 IN NUMBER,
  xc6 IN NUMBER,
  xc7 IN NUMBER,
  xc8 IN NUMBER,
  xc9 IN NUMBER,
  xc10 IN NUMBER,
  status IN OUT tids.flag%TYPE,
  tcause IN OUT tids.cause%TYPE,
  do_remote IN NUMBER
)
AS
  CURSOR itype_cursor IS 
    SELECT c1red, c1yellow, c2red, c2yellow, c3red, c3yellow,
           c4red, c4yellow, c5red, c5yellow, c6red, c6yellow,
           c7red, c7yellow, c8red, c8yellow, c9red, c9yellow,
           c10red, c10yellow, c1, c2, c3, c4, c5, c6, c7, c8, c9, c10
    FROM interface_types WHERE id = (SELECT interface_type_id FROM interfaces where id = xinterface_id);
  itype itype_cursor%ROWTYPE;

  currdate VARCHAR2(25);
  xxstatus NUMBER := 0;
BEGIN
  OPEN itype_cursor;
  FETCH itype_cursor INTO itype;
 
  status := 4;
  evaluate_single_pm(xc1, itype.c1red, itype.c1yellow, itype.c1, status, tcause);
  evaluate_single_pm(xc2, itype.c2red, itype.c2yellow, itype.c2, status, tcause);
  evaluate_single_pm(xc3, itype.c3red, itype.c3yellow, itype.c3, status, tcause);
  evaluate_single_pm(xc4, itype.c4red, itype.c4yellow, itype.c4, status, tcause);
  evaluate_single_pm(xc5, itype.c5red, itype.c5yellow, itype.c5, status, tcause);
  evaluate_single_pm(xc6, itype.c6red, itype.c6yellow, itype.c6, status, tcause);
  evaluate_single_pm(xc7, itype.c7red, itype.c7yellow, itype.c7, status, tcause);
  evaluate_single_pm(xc8, itype.c8red, itype.c8yellow, itype.c8, status, tcause);
  evaluate_single_pm(xc9, itype.c9red, itype.c9yellow, itype.c9, status, tcause);
  evaluate_single_pm(xc10, itype.c10red, itype.c10yellow, itype.c10, status, tcause);
  
  --insert into debugging values ('cause: ' || tcause);    
  --insert into debugging values ('status: ' || status);    

  SELECT MAX(DECODE(SIGN(m.recv_seq), -1, 0, 1) + DECODE(SIGN(m.trans_seq), -1, 0, 1)) INTO xxstatus FROM tid_facility_map m WHERE m.tid_id = xtid_id AND m.interface_id = xinterface_id;
  IF xxstatus = 0 THEN
    status := 0;
    tcause := 'InAct';
  END IF;
  
  CLOSE itype_cursor;
  
  IF do_remote = 1 THEN
    SELECT to_char(SYSDATE, 'MM/DD/YYYY HH24:MI:SS') INTO currdate FROM dual;
    --insert into debugging values ('UPDATE tid_interface_status SET flag = ' || status || ', cause = ' || tcause || ', timeentered = to_date(' || currdate || ', ''MM/DD/YYYY HH24:MI:SS''), connect_attempt = 0 WHERE tid_id = ' || xtid_id || ' AND interface_id = ' || xinterface_id);
	UPDATE tid_interface_status SET flag = status, cause = tcause, timeentered = to_date(currdate, 'MM/DD/YYYY HH24:MI:SS'), connect_attempt = 0 WHERE tid_id = xtid_id AND interface_id = xinterface_id;
  END IF;

END;
/
SHOW ERRORS
