CREATE OR REPLACE FUNCTION pnni_insertOrUpdate_tids
( xclli VARCHAR,
  xip VARCHAR
)
RETURN NUMBER
AS
  CURSOR get_tidid_cursor IS 
    SELECT id FROM tids WHERE name = xclli AND ipaddress = xip;
  ntidid get_tidid_cursor%ROWTYPE;

  CURSOR get_cityid_cursor IS 
    SELECT id FROM cities WHERE clli_tid = substr(xclli, 0, 6);
  ncityid get_cityid_cursor%ROWTYPE;

  tid_id tids.id%TYPE; -- NUMBER
  city_id cities.id%TYPE; -- NUMBER
BEGIN

  DBMS_OUTPUT.PUT_LINE('PNNI INSERT OR UPDATE TID BEFORE: (CLLI, IP)' || xclli || ', ' || xip);

  OPEN get_tidid_cursor;
  FETCH get_tidid_cursor INTO ntidid;
    tid_id := ntidid.id;
  CLOSE get_tidid_cursor;

  DBMS_OUTPUT.PUT_LINE('PNNI INSERT OR UPDATE TID AFTER CHECKING FOR TIDID' || tid_id);
  
  IF (tid_id IS NULL) THEN
    DBMS_OUTPUT.PUT_LINE('PNNI INSERT OR UPDATE TID: tid_id IS NULL');

    OPEN get_cityid_cursor;
    FETCH get_cityid_cursor INTO ncityid;
      city_id := ncityid.id;
    CLOSE get_cityid_cursor;
    
    IF (city_id IS NULL) THEN
      DBMS_OUTPUT.PUT_LINE('PNNI: No city for CLLI = ' || xclli || '. Could not insert ' || xip);
      tid_id := -1;
    ELSE
      DBMS_OUTPUT.PUT_LINE('PNNI INSERT OR UPDATE TID: city_id IS NOT NULL');
      SELECT tid_id_seq.nextval 
        INTO tid_id
        FROM dual;
  
      INSERT INTO tids (id, name, ipaddress, flag, grouping_name, dwdm_facility, city_id, element_type_id) 
       SELECT tid_id, xclli, xip, 'g', 'na', 'na', city_id, id 
        FROM element_types
        WHERE name = 'Fore ASX-4000';
      
    END IF;
    
  END IF;
  
  DBMS_OUTPUT.PUT_LINE('PNNI INSERT OR UPDATE TID: ' || tid_id);
  
  RETURN tid_id;
END;
/
SHOW ERRORS
