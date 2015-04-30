CREATE OR REPLACE FUNCTION all_equivalents_for_speed
( apppid IN NUMBER )
RETURN VARCHAR2
AS
  CURSOR tech_cursor IS 
    SELECT s.name
    FROM speeds s, speed_equivalent_map sem
    WHERE s.id = sem.equivalent_id and speed_id = apppid;
  techlist tech_cursor%ROWTYPE;
 
  techsstring VARCHAR2(100); 
BEGIN
  FOR techlist IN tech_cursor
    LOOP
      IF techsstring IS NULL THEN
        techsstring := techlist.name;
      ELSE
        techsstring := techsstring || ', ' || techlist.name;
      END IF;
 END LOOP;
 RETURN techsstring;
END; 
/
SHOW ERRORS

