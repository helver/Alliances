CREATE OR REPLACE PROCEDURE pnni_insOrUpd_tid_intf_status
(
xtid_id IN tids.id%TYPE, 
xinterface_id IN interfaces.id%TYPE,
xflag IN tids.flag%TYPE, 
xcause IN tids.cause%TYPE

)
AS

  CURSOR get_newid_cursor IS 
    SELECT tid_id FROM tid_interface_status 
    WHERE tid_id = xtid_id and interface_id = xinterface_id;
  newid_cur get_newid_cursor%ROWTYPE;

  ntid_id tid_interface_status.tid_id%TYPE; -- NUMBER
  
BEGIN
  
    -- find the id: if exist, update it, o.w. insert it
    OPEN get_newid_cursor;
    FETCH get_newid_cursor INTO newid_cur;
      ntid_id := newid_cur.tid_id;
    CLOSE get_newid_cursor;
    
    IF (ntid_id IS NOT NULL) THEN
      UPDATE tid_interface_status SET flag = xflag, cause = xcause, timeentered = SYSDATE 
      WHERE tid_id = xtid_id and interface_id = xinterface_id;
    ELSE  
      INSERT INTO tid_interface_status (flag, cause, tid_id, interface_id, timeentered) 
        VALUES (xflag, xcause, xtid_id, xinterface_id, SYSDATE);
    END IF;
    
END;
/
SHOW ERRORS
