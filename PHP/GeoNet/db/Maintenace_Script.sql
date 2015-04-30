ANALYZE TABLE alarms COMPUTE STATISTICS;
ANALYZE TABLE cities COMPUTE STATISTICS;
ANALYZE TABLE customers COMPUTE STATISTICS;
ANALYZE TABLE customer_group_map COMPUTE STATISTICS;
ANALYZE TABLE customer_types COMPUTE STATISTICS;
ANALYZE TABLE element_types COMPUTE STATISTICS;
ANALYZE TABLE facilities COMPUTE STATISTICS;
ANALYZE TABLE facility_associations COMPUTE STATISTICS;
ANALYZE TABLE fiber_routes COMPUTE STATISTICS;
ANALYZE TABLE fiber_segments COMPUTE STATISTICS;
ANALYZE TABLE flags COMPUTE STATISTICS;
ANALYZE TABLE historical COMPUTE STATISTICS;
ANALYZE TABLE interfaces COMPUTE STATISTICS;
ANALYZE TABLE interface_types COMPUTE STATISTICS;
ANALYZE TABLE ipconversion COMPUTE STATISTICS;
ANALYZE TABLE pm_info COMPUTE STATISTICS;
ANALYZE TABLE portconversion COMPUTE STATISTICS;
ANALYZE TABLE protocols COMPUTE STATISTICS;
ANALYZE TABLE receive_channels COMPUTE STATISTICS;
ANALYZE TABLE scheduled_outages COMPUTE STATISTICS;
ANALYZE TABLE security_levels COMPUTE STATISTICS;
ANALYZE TABLE speeds COMPUTE STATISTICS;
ANALYZE TABLE switchinfo COMPUTE STATISTICS;
ANALYZE TABLE tids COMPUTE STATISTICS;
ANALYZE TABLE tid_facility_map COMPUTE STATISTICS;
ANALYZE TABLE tid_interface_status COMPUTE STATISTICS;
ANALYZE TABLE tid_queue COMPUTE STATISTICS;
ANALYZE TABLE users COMPUTE STATISTICS;
ANALYZE TABLE user_groups COMPUTE STATISTICS;
ANALYZE TABLE user_group_user_map COMPUTE STATISTICS;
commit;


ANALYZE TABLE pm_history COMPUTE STATISTICS;
commit;

-- alarms
ALTER INDEX alarm_acknowledge_date_index REBUILD ONLINE STORAGE (INITIAL 40960 NEXT 40960 PCTINCREASE 50) tablespace GEONET_INDEXTHREE;
ALTER INDEX alarm_cleared_index REBUILD ONLINE STORAGE (INITIAL 40960 NEXT 40960 PCTINCREASE 50) tablespace GEONET_INDEXTHREE;
ALTER INDEX alarm_interface_id_index REBUILD ONLINE STORAGE (INITIAL 40960 NEXT 40960 PCTINCREASE 50) tablespace GEONET_INDEXTHREE;
ALTER INDEX alarm_tid_id_index REBUILD ONLINE STORAGE (INITIAL 40960 NEXT 40960 PCTINCREASE 50) tablespace GEONET_INDEXTHREE;
ALTER INDEX alarm_timeentered_index REBUILD ONLINE STORAGE (INITIAL 40960 NEXT 40960 PCTINCREASE 50) tablespace GEONET_INDEXTHREE;
ALTER INDEX alarm_time_cleared_index REBUILD ONLINE STORAGE (INITIAL 40960 NEXT 40960 PCTINCREASE 50) tablespace GEONET_INDEXTHREE;

-- cities
ALTER INDEX city_clli_tid_index REBUILD STORAGE (INITIAL 40960 NEXT 40960 PCTINCREASE 50) tablespace GEONET_INDEXTHREE;

-- group_customer_map
ALTER INDEX customer_group_map_cid_index REBUILD STORAGE (INITIAL 40960 NEXT 40960 PCTINCREASE 50) tablespace GEONET_INDEXTHREE;
ALTER INDEX customer_group_map_ugid_index REBUILD STORAGE (INITIAL 40960 NEXT 40960 PCTINCREASE 50) tablespace GEONET_INDEXTHREE;

-- facilities
ALTER INDEX facility_customer_id_index REBUILD STORAGE (INITIAL 40960 NEXT 40960 PCTINCREASE 50) tablespace GEONET_INDEXTHREE;

-- fiber_routes
ALTER INDEX fiber_route_asite_index REBUILD STORAGE (INITIAL 40960 NEXT 40960 PCTINCREASE 50) tablespace GEONET_INDEXTHREE;
ALTER INDEX fiber_route_zsite_index REBUILD STORAGE (INITIAL 40960 NEXT 40960 PCTINCREASE 50) tablespace GEONET_INDEXTHREE;

-- fiber_routes
ALTER INDEX fiber_segment_asite_index REBUILD STORAGE (INITIAL 40960 NEXT 40960 PCTINCREASE 50) tablespace GEONET_INDEXTHREE;
ALTER INDEX fiber_segment_fiberrteid_index REBUILD STORAGE (INITIAL 40960 NEXT 40960 PCTINCREASE 50) tablespace GEONET_INDEXTHREE;
ALTER INDEX fiber_segment_zsite_index REBUILD STORAGE (INITIAL 40960 NEXT 40960 PCTINCREASE 50) tablespace GEONET_INDEXTHREE;

-- interfaces
ALTER INDEX interface_itype_index REBUILD STORAGE (INITIAL 40960 NEXT 40960 PCTINCREASE 50) tablespace GEONET_INDEXTHREE;
ALTER INDEX interface_name_index REBUILD STORAGE (INITIAL 40960 NEXT 40960 PCTINCREASE 50) tablespace GEONET_INDEXTHREE;

-- interface_types
ALTER INDEX interface_type_etid_index REBUILD STORAGE (INITIAL 40960 NEXT 40960 PCTINCREASE 50) tablespace GEONET_INDEXTHREE;

-- pm_info
ALTER INDEX pm_info_interface_id_index REBUILD ONLINE STORAGE (INITIAL 40960 NEXT 40960 PCTINCREASE 50) tablespace GEONET_INDEXTHREE;
ALTER INDEX pm_info_tid_id_index REBUILD ONLINE STORAGE (INITIAL 40960 NEXT 40960 PCTINCREASE 50) tablespace GEONET_INDEXTHREE;
ALTER INDEX pm_info_timeentered_index REBUILD ONLINE STORAGE (INITIAL 40960 NEXT 40960 PCTINCREASE 50) tablespace GEONET_INDEXTHREE;

-- scheduled_outages
ALTER INDEX scheduled_outage_cid_index REBUILD STORAGE (INITIAL 40960 NEXT 40960 PCTINCREASE 50) tablespace GEONET_INDEXTHREE;
ALTER INDEX scheduled_outage_et_index REBUILD STORAGE (INITIAL 40960 NEXT 40960 PCTINCREASE 50) tablespace GEONET_INDEXTHREE;
ALTER INDEX scheduled_outage_fid_index REBUILD STORAGE (INITIAL 40960 NEXT 40960 PCTINCREASE 50) tablespace GEONET_INDEXTHREE;
ALTER INDEX scheduled_outage_st_index REBUILD STORAGE (INITIAL 40960 NEXT 40960 PCTINCREASE 50) tablespace GEONET_INDEXTHREE;

-- tids
ALTER INDEX tid_city_id_index REBUILD STORAGE (INITIAL 40960 NEXT 40960 PCTINCREASE 50) tablespace GEONET_INDEXTHREE;
ALTER INDEX tid_dwdm_facility_index REBUILD STORAGE (INITIAL 40960 NEXT 40960 PCTINCREASE 50) tablespace GEONET_INDEXTHREE;
ALTER INDEX tid_element_type_id_index REBUILD STORAGE (INITIAL 40960 NEXT 40960 PCTINCREASE 50) tablespace GEONET_INDEXTHREE;
ALTER INDEX tid_flag_index REBUILD STORAGE (INITIAL 40960 NEXT 40960 PCTINCREASE 50) tablespace GEONET_INDEXTHREE;
ALTER INDEX tid_grouping_name_index REBUILD STORAGE (INITIAL 40960 NEXT 40960 PCTINCREASE 50) tablespace GEONET_INDEXTHREE;

-- tid_facility_map
ALTER INDEX tid_facility_map_facid_index REBUILD STORAGE (INITIAL 40960 NEXT 40960 PCTINCREASE 50) tablespace GEONET_INDEXTHREE;
ALTER INDEX tid_facility_map_ifid_index REBUILD STORAGE (INITIAL 40960 NEXT 40960 PCTINCREASE 50) tablespace GEONET_INDEXTHREE;
ALTER INDEX tid_facility_map_tid_id_index REBUILD STORAGE (INITIAL 40960 NEXT 40960 PCTINCREASE 50) tablespace GEONET_INDEXTHREE;

-- tid_interface_status
ALTER INDEX tid_interface_status_flg_index REBUILD ONLINE STORAGE (INITIAL 40960 NEXT 40960 PCTINCREASE 50) tablespace GEONET_INDEXTHREE;
ALTER INDEX tid_interface_status_iid_index REBUILD ONLINE STORAGE (INITIAL 40960 NEXT 40960 PCTINCREASE 50) tablespace GEONET_INDEXTHREE;
ALTER INDEX tid_interface_status_tid_index REBUILD ONLINE STORAGE (INITIAL 40960 NEXT 40960 PCTINCREASE 50) tablespace GEONET_INDEXTHREE;

-- tid_queue
ALTER INDEX tid_queue_timeentered_index REBUILD ONLINE STORAGE (INITIAL 40960 NEXT 40960 PCTINCREASE 50) tablespace GEONET_INDEXTHREE;

-- users
ALTER INDEX user_email_index REBUILD STORAGE (INITIAL 40960 NEXT 40960 PCTINCREASE 50) tablespace GEONET_INDEXTHREE;

-- user_group_user_map
ALTER INDEX user_group_umugid_index REBUILD STORAGE (INITIAL 40960 NEXT 40960 PCTINCREASE 50) tablespace GEONET_INDEXTHREE;
ALTER INDEX user_group_umuid_index REBUILD STORAGE (INITIAL 40960 NEXT 40960 PCTINCREASE 50) tablespace GEONET_INDEXTHREE;

commit;

-- pm_history
ALTER INDEX pm_history_archivetime_index REBUILD ONLINE STORAGE (INITIAL 40960 NEXT 40960 PCTINCREASE 50) tablespace GEONET_INDEXTHREE;
ALTER INDEX pm_history_interface_id_index REBUILD ONLINE STORAGE (INITIAL 40960 NEXT 40960 PCTINCREASE 50) tablespace GEONET_INDEXTHREE;
ALTER INDEX pm_history_tid_id_index REBUILD ONLINE STORAGE (INITIAL 40960 NEXT 40960 PCTINCREASE 50) tablespace GEONET_INDEXTHREE;
ALTER INDEX pm_history_timeentered_index REBUILD ONLINE STORAGE (INITIAL 40960 NEXT 40960 PCTINCREASE 50) tablespace GEONET_INDEXTHREE;

commit;