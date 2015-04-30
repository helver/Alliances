CREATE OR REPLACE FUNCTION pnni_insertOrUpdate_facilities
( xname VARCHAR
)
RETURN NUMBER
AS
  --CURSOR get_customerid_cursor IS 
  --  SELECT id FROM customers WHERE name = xcustomer;  
  --customerid_cur get_customerid_cursor%ROWTYPE;

  CURSOR get_facilityid_cursor IS 
    SELECT id, customer_id FROM facilities WHERE name = xname;
  facilityid_cur get_facilityid_cursor%ROWTYPE;

  facilityid_id facilities.id%TYPE; -- NUMBER
  customer_id customers.id%TYPE; -- NUMBER
  ncustomer_id customers.id%TYPE; -- NUMBER
BEGIN
  --OPEN get_customerid_cursor;
  --FETCH get_customerid_cursor INTO customerid_cur;
  --  ncustomer_id := customerid_cur.id;
  --CLOSE get_customerid_cursor;

  SELECT id 
  INTO ncustomer_id
  FROM customers
  WHERE name = 'Echostar';
  
  IF (ncustomer_id IS NULL) THEN
    DBMS_OUTPUT.PUT_LINE('PNNI: in insertorUpdate_facilities, no customerid for Echostar. Operation aborted.');
    facilityid_id := -1;
  
  ELSE
  
    OPEN get_facilityid_cursor;
    FETCH get_facilityid_cursor INTO facilityid_cur;
      facilityid_id := facilityid_cur.id;
      customer_id := facilityid_cur.customer_id;
    CLOSE get_facilityid_cursor;

    IF (facilityid_id IS NULL) THEN
      SELECT facility_id_seq.nextval 
          INTO facilityid_id
          FROM dual;
    
      INSERT INTO facilities (id, name, active, flag, customer_id) 
         values (facilityid_id, xname, 't', 'g', ncustomer_id);
        
      
    --ELSE
      -- update the customer 
      --IF (ncustomer_id != customer_id) THEN
        --UPDATE facilities SET customer_id = ncustomer_id WHERE id = facilityid_id;
      --END IF;
    END IF;
    
  END IF;
  
  RETURN facilityid_id;
END;
/
SHOW ERRORS
