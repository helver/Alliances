DROP VIEW Alarm_Creation_View;
DROP VIEW Unscheduled_Outages_View;
DROP VIEW Valid_Scheduled_Outages_View;
DROP VIEW Outage_Durations_View;
DROP VIEW Alarm_Durations_View;
DROP VIEW interface_info_by_tid_view;
DROP VIEW tids_to_update_view;
DROP VIEW pm_totals_view;
DROP VIEW customer_list_by_user_view;
DROP VIEW pull_customer_list_view;
DROP VIEW get_customer_facility_view;
DROP VIEW pull_facilities_info_view;
DROP VIEW user_initials_view;
DROP VIEW alarms_to_acknowledge_view;
DROP VIEW Tids_In_Facility_View;
DROP VIEW Tids_Lookup_View;
DROP VIEW USMap_Dataset_View;
DROP VIEW USMap_Ifc_Dataset_View;
DROP VIEW USMap_Trans_Links_View;
DROP VIEW USMap_Recv_Links_View;
DROP VIEW If_Status_TID_And_Cust_View;
DROP VIEW History_Dataset_View;
DROP VIEW History_Old_Counts_View;
DROP VIEW History_Previous_Counts_View;
DROP VIEW History_Current_Counts_View;
DROP VIEW History_Max_Error_Counts_View;
DROP VIEW History_Min_Error_Counts_View;
DROP VIEW Interface_Labels_View;
DROP VIEW Facility_End_Cities_View;
DROP VIEW Facility_End_Points_View;
DROP VIEW Last_15_Outages_View;
DROP VIEW Alarm_History_View;
DROP VIEW ATMMap_Dataset_View;
DROP VIEW facilities_list_view;
DROP VIEW cities_list_view;
DROP VIEW tids_list_view;
DROP VIEW Fac_History_Cur_Counts_View;
DROP VIEW Fac_History_Old_Counts_View;
DROP VIEW Fac_History_Prev_Counts_View;
DROP VIEW Fac_History_Min_Time_View;
DROP VIEW outage_procedure_list_view;

SELECT 'Views Still Existing: ' || view_name FROM user_views;