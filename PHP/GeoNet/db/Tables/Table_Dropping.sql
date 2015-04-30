DROP TABLE proc_customer_map;
DROP TABLE speed_equivalent_map;
DROP TABLE facility_associations;
DROP TABLE pm_history;
DROP TABLE pm_info;
DROP TABLE alarms;
DROP TABLE scheduled_outages;
DROP TABLE fiber_segments;
DROP TABLE fiber_routes;
DROP TABLE tid_facility_map;
DROP TABLE tid_interface_status;
DROP TABLE tid_queue;
DROP TABLE user_group_user_map;
DROP TABLE customer_group_map;
DROP TABLE interfaces;
DROP TABLE interface_types;
DROP TABLE tids;
DROP TABLE facilities;
DROP TABLE customers;
DROP TABLE element_types;
DROP TABLE users;
DROP TABLE protocols;
DROP TABLE receive_channels;
DROP TABLE cities;
DROP TABLE security_levels;
DROP TABLE speeds;
DROP TABLE user_groups;
DROP TABLE customer_types;
DROP TABLE debugging;
DROP TABLE historical;
DROP TABLE ipconversion;
DROP TABLE portconversion;
DROP TABLE switchinfo;
DROP TABLE outage_procedure;

SELECT 'Still existing: ' || table_name FROM user_tables;