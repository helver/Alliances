-- speeds
--
CREATE TABLE speeds (
  id NUMBER NOT NULL PRIMARY KEY, -- Primary Key comes from speeds_id_seq
  name VARCHAR2(10) NOT NULL,     -- Speed Name
  relative_id NUMBER REFERENCES speeds(id)
);
