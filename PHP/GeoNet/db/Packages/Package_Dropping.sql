DROP PACKAGE tid_if_status_api;
DROP PACKAGE ack_alarms_api;

SELECT DISTINCT 'Packages Still Existing: ' || name FROM user_source WHERE type = 'PACKAGE';
