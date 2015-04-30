CREATE OR REPLACE FUNCTION all_customers_for_proc
( apppid IN NUMBER )
RETURN VARCHAR2
AS
  CURSOR tech_cursor IS 
    SELECT s.name
    FROM customers s, proc_customer_map sem
    WHERE s.id = sem.customer_id and outage_proc_id = apppid;
  techlist tech_cursor%ROWTYPE;
 
  techsstring VARCHAR2(500); 
BEGIN
  FOR techlist IN tech_cursor
    LOOP
      IF techsstring IS NULL THEN
        techsstring := techlist.name;
      ELSE
        techsstring := techsstring || ',<br>' || techlist.name;
      END IF;
 END LOOP;
 RETURN techsstring;
END; 
/
SHOW ERRORS

