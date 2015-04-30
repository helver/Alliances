@GeoNet/db/Sequences/Build_Sequences_Proc.sql

execute build_sequence('fiber_route_id_seq', 'fiber_routes');
execute build_sequence('fiber_segment_id_seq', 'fiber_segments');
execute build_sequence('scheduled_outage_id_seq', 'scheduled_outages');
execute build_sequence('alarm_id_seq', 'alarms');
execute build_sequence('tid_id_seq', 'tids');
execute build_sequence('facility_id_seq', 'facilities');
execute build_sequence('customer_id_seq', 'customers');
execute build_sequence('user_group_id_seq', 'user_groups');
execute build_sequence('users_seq', 'users');
execute build_sequence('city_id_seq', 'cities');
execute build_sequence('element_type_id_seq', 'element_types');
execute build_sequence('interface_id_seq', 'interfaces');
execute build_sequence('interface_type_id_seq', 'interface_types');
execute build_sequence('speeds_id_seq', 'speeds');
execute build_sequence('protocols_id_seq', 'protocols');

CREATE SEQUENCE outage_procedure_id_seq start with 1 increment by 1 nocache;

commit;