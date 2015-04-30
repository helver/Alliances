CREATE OR REPLACE FUNCTION pnni_insertOrUpdate_interfaces
( xport VARCHAR,
  portnum  NUMBER,
  linerate VARCHAR,
  bandwidth NUMBER
)
RETURN NUMBER
AS

  CURSOR get_interfaceid_cursor IS 
    SELECT id FROM interfaces WHERE name = xport and e1 = xport;
  interfaceid_cur get_interfaceid_cursor%ROWTYPE;

  interface_id interfaces.id%TYPE; -- NUMBER
  interface_type_id interface_types.id%TYPE; -- NUMBER
  portlength  NUMBER;
  
BEGIN

  OPEN get_interfaceid_cursor;
  FETCH get_interfaceid_cursor INTO interfaceid_cur;
    interface_id := interfaceid_cur.id;
  CLOSE get_interfaceid_cursor;

  IF (interface_id IS NULL) THEN
    
    IF (portnum IS NULL) THEN 
      interface_id := -1; 
    ELSE
      -- need to insert it
  
      IF (linerate IS NOT NULL) THEN
        IF (linerate = 'DS3') THEN
          SELECT id
          INTO interface_type_id
          FROM interface_types
          WHERE name = 'Fore ASX-4000 DS3';
        ELSE
          SELECT id
          INTO interface_type_id
          FROM interface_types
          WHERE name = 'Fore ASX-4000 OC3';
        END IF;
      
      ELSE
        -- get the interface type: DS3 or OC3
        -- if the port contains , --> DS3
        -- else                   --> OC3
        SELECT length(xport)
        INTO portlength
        FROM DUAL;
    
        IF (portlength > 4) THEN
          SELECT id
          INTO interface_type_id
          FROM interface_types
          WHERE name = 'Fore ASX-4000 DS3';
        ELSE
          SELECT id
          INTO interface_type_id
          FROM interface_types
          WHERE name = 'Fore ASX-4000 OC3';
        END IF;
      END IF;
  
      SELECT interface_id_seq.NEXTVAL 
        INTO interface_id
        FROM dual;
      
      INSERT INTO interfaces (id, name, e1, e2, e3, interface_type_id) 
           values (interface_id, xport, xport, portnum, bandwidth, interface_type_id);
    
    END IF;      
  END IF;
  
  RETURN interface_id;
END;
/
SHOW ERRORS
