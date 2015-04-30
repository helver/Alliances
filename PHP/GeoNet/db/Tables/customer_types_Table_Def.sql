-- customer_types
--
-- Customer_types determine what display to show when drilling down into a
-- particular customer.
CREATE TABLE customer_types (
  id NUMBER NOT NULL PRIMARY KEY, -- Primary Key comes from customer_type_id_seq
  name VARCHAR2(50) NOT NULL      -- Customer Type Name
);
