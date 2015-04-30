update facilities set flag = 'r' where id = 1;
EXECUTE status_to_customers_rollup(1);
select * from facilities;
select * from customers;
