-- customers
--
-- Customers are the customers of large circuits that are monitored by 
-- GeoNet.
CREATE TABLE customers (
  id NUMBER NOT NULL PRIMARY KEY,   -- Primary Key comes from customer_id_seq
  name VARCHAR2(40) NOT NULL,       -- Customer Name
  short_name VARCHAR2(10) NOT NULL, -- Customer Short Name - Used for small color map display
  flag NUMBER(1) NOT NULL,          -- Customer Alarm status
  tracepath CHAR(1),                -- Has access to TracePath
  customer_type_id NUMBER NOT NULL REFERENCES customer_types(id) -- The customer type of this customer
);

ALTER TABLE customers DROP COLUMN flag;
ALTER TABLE customers ADD flag NUMBER(1);
UPDATE customers SET flag = 4;
