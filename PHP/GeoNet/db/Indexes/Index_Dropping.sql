DROP INDEX fiber_route_asite_index;
DROP INDEX fiber_route_zsite_index;
DROP INDEX fiber_segment_asite_index;
DROP INDEX fiber_segment_zsite_index;
DROP INDEX fiber_segment_fiberrteid_index;
DROP INDEX scheduled_outage_st_index;
DROP INDEX scheduled_outage_et_index;
DROP INDEX scheduled_outage_cid_index;
DROP INDEX scheduled_outage_fid_index;
DROP INDEX alarm_tid_id_index;
DROP INDEX alarm_interface_id_index;
DROP INDEX alarm_timeentered_index;
DROP INDEX alarm_acknowledge_date_index;
DROP INDEX alarm_cleared_index;
DROP INDEX alarm_time_cleared_index;
DROP INDEX tid_city_id_index;
DROP INDEX tid_element_type_id_index;
DROP INDEX tid_flag_index;
DROP INDEX tid_grouping_name_index;
DROP INDEX tid_dwdm_facility_index;
DROP INDEX tid_interface_status_tid_index;
DROP INDEX tid_interface_status_iid_index;
DROP INDEX tid_interface_status_flg_index;
DROP INDEX tid_facility_map_tid_id_index;
DROP INDEX tid_facility_map_ifid_index;
DROP INDEX tid_facility_map_facid_index;
DROP INDEX facility_customer_id_index;
DROP INDEX pm_info_tid_id_index;
DROP INDEX pm_info_interface_id_index;
DROP INDEX pm_info_timeentered_index;
DROP INDEX pm_history_tid_id_index;
DROP INDEX pm_history_interface_id_index;
DROP INDEX pm_history_timeentered_index;
DROP INDEX pm_history_archivetime_index;
DROP INDEX customer_group_map_ugid_index;
DROP INDEX customer_group_map_cid_index;
DROP INDEX user_email_index;
DROP INDEX user_group_umugid_index;
DROP INDEX user_group_umuid_index;
DROP INDEX city_clli_tid_index;
DROP INDEX interface_itype_index;
DROP INDEX interface_name_index;
DROP INDEX interface_type_etid_index;
DROP INDEX tid_queue_timeentered_index;


SELECT 'Indexes Still Existing: ' || index_name FROM user_indexes;