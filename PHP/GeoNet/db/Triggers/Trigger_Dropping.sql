DROP TRIGGER pm_info_BU_ROW;
DROP TRIGGER pm_info_AU_ROW;
DROP TRIGGER tids_to_update_view_IOU_ROW;
DROP TRIGGER alarms_to_ack_view_IOU;
DROP TRIGGER facility_keephistory_AU_Row;
DROP TRIGGER pnni_historical_AI_ROW;
DROP TRIGGER pnni_historical_AU_ROW;
DROP TRIGGER pnni_historical_AIU_ROW;
DROP TRIGGER pnni_switchinfo_AI_ROW;
DROP TRIGGER tid_interface_status_AU_ROW;
DROP TRIGGER tid_interface_status_BU_ROW;
DROP TRIGGER tid_interface_status_AU_STM;
DROP TRIGGER tid_keephistory_AU_ROW;

SELECT DISTINCT 'Triggers Still Existing: ' || trigger_name FROM user_triggers;



