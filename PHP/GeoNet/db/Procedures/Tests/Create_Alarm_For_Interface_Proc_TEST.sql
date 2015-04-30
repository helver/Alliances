delete from debugging;
SELECT count(1) FROM alarms;
EXECUTE create_alarm_for_interface(1, 1, 'COM');
select * from debugging;
SELECT * FROM alarms WHERE id = (SELECT MAX(id) FROM alarms);
