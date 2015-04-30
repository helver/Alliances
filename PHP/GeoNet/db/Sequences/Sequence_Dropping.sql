DROP SEQUENCE fiber_route_id_seq;
DROP SEQUENCE fiber_segment_id_seq;
DROP SEQUENCE scheduled_outage_id_seq;
DROP SEQUENCE alarm_id_seq;
DROP SEQUENCE tid_id_seq;
DROP SEQUENCE facility_id_seq;
DROP SEQUENCE customer_id_seq;
DROP SEQUENCE user_group_id_seq;
DROP SEQUENCE users_seq;
DROP SEQUENCE city_id_seq;
DROP SEQUENCE element_type_id_seq;
DROP SEQUENCE interface_id_seq;
DROP SEQUENCE interface_type_id_seq;
DROP SEQUENCE speeds_id_seq;
DROP SEQUENCE protocols_id_seq;
DROP SEQUENCE outage_procedure_id_seq;

commit;

select sequence_name from user_sequences;