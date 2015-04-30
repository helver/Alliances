-- cities
--
-- Cities contains information about the cities that our elements reside 
-- in.
CREATE TABLE cities (
  id NUMBER NOT NULL PRIMARY KEY,  -- Primary Key comes from city_id_seq
  name VARCHAR2(50) NOT NULL,      -- City Name
  state VARCHAR2(3) NOT NULL,      -- City's State
  clli_tid VARCHAR2(11),           -- City's TID Name prefix
  latitude FLOAT,                  -- City's Latitude
  longitude FLOAT                  -- City's Longitude
);
