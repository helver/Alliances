-- fiber_routes
CREATE INDEX fiber_route_asite_index on fiber_routes (asite_id) tablespace GEONET_INDEXTHREE;
CREATE INDEX fiber_route_zsite_index on fiber_routes (zsite_id) tablespace GEONET_INDEXTHREE;

-- fiber_segments
CREATE INDEX fiber_segment_asite_index on fiber_segments (asite_id) tablespace GEONET_INDEXTHREE;
CREATE INDEX fiber_segment_zsite_index on fiber_segments (zsite_id) tablespace GEONET_INDEXTHREE;
CREATE INDEX fiber_segment_fiberrteid_index on fiber_segments (fiber_route_id) tablespace GEONET_INDEXTHREE;

-- scheduled_outages
CREATE INDEX scheduled_outage_st_index on scheduled_outages (start_time) tablespace GEONET_INDEXTHREE;
CREATE INDEX scheduled_outage_et_index on scheduled_outages (end_time) tablespace GEONET_INDEXTHREE;
CREATE INDEX scheduled_outage_cid_index on scheduled_outages (customer_id) tablespace GEONET_INDEXTHREE;
CREATE INDEX scheduled_outage_fid_index on scheduled_outages (facility_id) tablespace GEONET_INDEXTHREE;

-- alarms
CREATE INDEX alarm_tid_id_index on alarms (tid_id) tablespace GEONET_INDEXTHREE;
CREATE INDEX alarm_interface_id_index on alarms (interface_id) tablespace GEONET_INDEXTHREE;
CREATE INDEX alarm_timeentered_index on alarms (timeentered) tablespace GEONET_INDEXTHREE;
CREATE INDEX alarm_acknowledge_date_index on alarms (acknowledge_date) tablespace GEONET_INDEXTHREE;
CREATE INDEX alarm_cleared_index on alarms (cleared) tablespace GEONET_INDEXTHREE;
CREATE INDEX alarm_time_cleared_index on alarms (time_cleared) tablespace GEONET_INDEXTHREE;

-- tids
CREATE INDEX tid_city_id_index on tids (city_id) tablespace GEONET_INDEXTHREE;
CREATE INDEX tid_element_type_id_index on tids (element_type_id) tablespace GEONET_INDEXTHREE;
CREATE INDEX tid_flag_index on tids (flag) tablespace GEONET_INDEXTHREE;
CREATE INDEX tid_grouping_name_index on tids (grouping_name) tablespace GEONET_INDEXTHREE;
CREATE INDEX tid_dwdm_facility_index on tids (dwdm_facility) tablespace GEONET_INDEXTHREE;

-- tid_inteface_status
CREATE INDEX tid_interface_status_tid_index on tid_interface_status (tid_id) tablespace GEONET_INDEXTHREE;
CREATE INDEX tid_interface_status_iid_index on tid_interface_status (interface_id) tablespace GEONET_INDEXTHREE;
CREATE INDEX tid_interface_status_flg_index on tid_interface_status (flag) tablespace GEONET_INDEXTHREE;

-- tid_facility_map
CREATE INDEX tid_facility_map_tid_id_index on tid_facility_map (tid_id) tablespace GEONET_INDEXTHREE;
CREATE INDEX tid_facility_map_ifid_index on tid_facility_map (interface_id) tablespace GEONET_INDEXTHREE;
CREATE INDEX tid_facility_map_facid_index on tid_facility_map (facility_id) tablespace GEONET_INDEXTHREE;

-- facilities
CREATE INDEX facility_customer_id_index on facilities (customer_id) tablespace GEONET_INDEXTHREE;

-- pm_info
CREATE INDEX pm_info_tid_id_index on pm_info (tid_id) tablespace GEONET_INDEXTHREE;
CREATE INDEX pm_info_timeentered_index on pm_info (timeentered) tablespace GEONET_INDEXTHREE;
CREATE INDEX pm_info_interface_id_index on pm_info (interface_id) tablespace GEONET_INDEXTHREE;

-- pm_history
CREATE INDEX pm_history_tid_id_index on pm_history (tid_id) tablespace GEONET_INDEXTHREE;
CREATE INDEX pm_history_timeentered_index on pm_history (timeentered) tablespace GEONET_INDEXTHREE;
CREATE INDEX pm_history_archivetime_index on pm_history (archivetime) tablespace GEONET_INDEXTHREE;
CREATE INDEX pm_history_interface_id_index on pm_history (interface_id) tablespace GEONET_INDEXTHREE;

-- group_customer_map
CREATE INDEX customer_group_map_ugid_index on customer_group_map (user_group_id) tablespace GEONET_INDEXTHREE;
CREATE INDEX customer_group_map_cid_index on customer_group_map (customer_id) tablespace GEONET_INDEXTHREE;

-- users
CREATE INDEX user_email_index on users (email) tablespace GEONET_INDEXTHREE;

-- user_group_user_map
CREATE INDEX user_group_umuid_index on user_group_user_map (user_id) tablespace GEONET_INDEXTHREE;
CREATE INDEX user_group_umugid_index on user_group_user_map (user_group_id) tablespace GEONET_INDEXTHREE;

-- cities
CREATE INDEX city_clli_tid_index on cities (clli_tid) tablespace GEONET_INDEXTHREE;

-- interfaces
CREATE INDEX interface_name_index on interfaces (name) tablespace GEONET_INDEXTHREE;
CREATE INDEX interface_itype_index on interfaces (interface_type_id) tablespace GEONET_INDEXTHREE;

-- interface_types
CREATE INDEX interface_type_etid_index on interface_types (element_type_id) tablespace GEONET_INDEXTHREE;

-- tid_queue
CREATE INDEX tid_queue_timeentered_index on tid_queue (timeentered) tablespace GEONET_INDEXTHREE;
