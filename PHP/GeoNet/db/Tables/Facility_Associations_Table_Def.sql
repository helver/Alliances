-- facility_associations
--
-- This table contains what facilities are tied together.
CREATE TABLE facility_associations (
  fac1 NUMBER NOT NULL REFERENCES facilities(id), -- First facility
  fac2 NUMBER NOT NULL REFERENCES facilities(id), -- Second facility
  PRIMARY KEY(fac1, fac2)
);
