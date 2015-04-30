-- scheduled_outages
--
-- Scheduled_outages are a way for users to indicate that an alarm based on
-- an outage was expected and therefore should not contribute to the total 
-- outage time for that element.
CREATE TABLE scheduled_outages (
  id NUMBER NOT NULL PRIMARY KEY,-- Primary Key comes from scheduled_outage_id_seq
  start_time DATE,               -- Timestamp for the beginning of the outage
  starttime_string VARCHAR2(25), -- String representing the time of the beginning of the outage
  end_time DATE,                 -- Timestamp for the end of the outage
  endtime_string VARCHAR2(25),   -- String representing the tme of the end of the outage
  description VARCHAR2(500),     -- Description of the outage
  ticketnum VARCHAR2(30),        -- Ticket Number for the scheduled maintenance ticket for this outage
  customer_id NUMBER NOT NULL REFERENCES customers(id), -- The Customer impacted by this scheduled outage
  facility_id NUMBER NOT NULL REFERENCES facilities(id), -- The Facility impacted by this scheduled outage
  asite_id NUMBER NOT NULL REFERENCES cities(id), -- The ASite TID for the facility impacted
  zsite_id NUMBER NOT NULL REFERENCES cities(id) -- The Zsite TID for the facility impacted
);
