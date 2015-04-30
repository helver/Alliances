CREATE OR REPLACE PROCEDURE evaluate_single_pm
( val IN pm_info.c1%TYPE,
  redval IN interface_types.c1red%TYPE,
  yellowval IN interface_types.c1yellow%TYPE,
  pmname IN interface_types.c1%TYPE,
  status IN OUT tids.flag%TYPE,
  cause IN OUT tids.cause%TYPE
)
AS
  tmpstatus tids.flag%TYPE := 0;
  tmpcause tids.cause%TYPE := '';
BEGIN
  IF (val >= redval and redval >= 0)
    THEN 
      tmpstatus := 8;
      tmpcause := pmname;
  ELSIF (val >= yellowval and yellowval >= 0)
    THEN 
      tmpstatus := 6;
      tmpcause := pmname;
  ELSIF (val = -1 and redval >= 0 and yellowval >= 0)
    THEN tmpstatus := 5;
  END IF;
  
  IF tmpstatus > status THEN
    status := tmpstatus;
    cause := tmpcause;
  END IF;
END;
/
SHOW ERRORS
