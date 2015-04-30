CREATE OR REPLACE PROCEDURE build_sequence
( tname IN VARCHAR,
  ttable IN VARCHAR
)
AS
  startwith NUMBER := 0;
  incrby NUMBER := 1;
  isexists NUMBER := 0;
  statement VARCHAR2(100);
  totals NUMBER;
BEGIN
  EXECUTE IMMEDIATE 'SELECT count(1) FROM ' || ttable || ' WHERE id IS NOT NULL' INTO totals;

  if totals > 0 THEN
    EXECUTE IMMEDIATE 'SELECT MAX(id) FROM ' || ttable || ' WHERE id IS NOT NULL' INTO startwith;
--    insert into debugging values ('startwith -' || startwith || '-');
  END IF;
  
  startwith := startwith + 1;
--  insert into debugging values ('startwith -' || startwith || '-');

  SELECT sum(1) INTO isexists FROM user_sequences WHERE UPPER(sequence_name) = UPPER(tname);

  IF isexists >= 1 THEN
    EXECUTE IMMEDIATE 'DROP SEQUENCE ' || tname;
  END IF;

  statement := 'CREATE SEQUENCE ' || tname || ' START WITH ' || startwith || ' INCREMENT BY ' || incrby || ' NOCACHE';
--  insert into debugging values (statement);
  EXECUTE IMMEDIATE statement;
END;
/
SHOW ERRORS
