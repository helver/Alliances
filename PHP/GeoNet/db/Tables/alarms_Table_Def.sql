-- alarms
--
-- Alarms describe a situation where a TID/Interface combination reports a 
-- PM value that exceeds the threshhold for that value.  Once alarms are 
-- created, they turn components of the GeoNet display red.  For the color 
-- to return to green, the alarm must be both acknowledged by a user, and 
-- cleared - meaning that the PM value falls back down below the threshhold.
CREATE TABLE alarms (
  id NUMBER NOT NULL PRIMARY KEY,  -- Primary Key comes from alarm_id_seq
  timeentered DATE NOT NULL,       -- Timestamp for the time the alarm started
  acknowledge_date DATE,           -- Timestamp for when the alarm was acknowledged by a user
  time_cleared DATE,               -- Timestamp for when the alarm was cleared on the element
  cleared CHAR(1),                 -- Flag for whether the alarm is cleared
  cause VARCHAR2(20),              -- Cause code for the alarm
  candidate NUMBER,                -- Some alarms require an extended outage.  Candidate indicates that this alarm is a candidate for alarm status
  ticketnum VARCHAR2(10),          -- Ticket Number related to this alarm
  initials VARCHAR2(3),            -- Initials of the user that assigned the ticket number
  tid_id NUMBER NOT NULL REFERENCES tids(id), -- The TID in alarm.
  interface_id NUMBER REFERENCES interfaces(id) -- The interface of the TID that is in alarm.
);
