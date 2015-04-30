CREATE OR REPLACE PROCEDURE status_to_customers_rollup
( xfac_id IN facilities.id%TYPE )
AS
  cust customers.id%TYPE;
BEGIN
  SELECT f.customer_id INTO cust FROM facilities f WHERE f.id = xfac_id;

  UPDATE customers SET flag = (SELECT MAX(flag) FROM facilities WHERE customer_id = cust) WHERE id = cust;
END;
/
SHOW ERRORS
