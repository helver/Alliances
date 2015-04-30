delete from tid_interface_status;
delete from tid_facility_map;
delete from scheduled_outages;
delete from pm_history;
delete from pm_info;
delete from alarms;
delete from fiber_routes;
delete from fiber_segments;
delete from facilities;
delete from tid_queue;
delete from tids;
delete from cities;

insert into cities (id, name, state, clli_tid, latitude, longitude) select rownum, city, state, tid, latitude, longitude from city@geonet.oss.sprint.com where city is not null;
insert into customers (id, name, short_name, flag, customer_type_id) select rownum, customer, short_name, 'n', 1 from customer@geonet.oss.sprint.com where customer is not null;

------------------
create or replace view migrate_tids as
select distinct t.tid as name, t.ipaddress as ipaddress, 'n' as flag, NULL as cause, 'UNK' as grouping_name, 'UNK' as dwdm_facility, c.id as city_id, t.element_typeid as element_type_id, 't' as keephistory, 0 as connect_attempt, NULL as directionality
from tid@geonet.oss.sprint.com t, city@geonet.oss.sprint.com cc, cities c
where cc.cityid = t.cityid and c.name = cc.city and t.tid is not null and t.element_typeid is not null;

insert into tids (id, name, ipaddress, flag, cause, grouping_name, dwdm_facility, city_id, element_type_id, keephistory, connect_attempt, directionality)
select rownum, name, ipaddress, flag, cause, grouping_name, dwdm_facility, city_id, element_type_id, keephistory, connect_attempt, directionality from migrate_tids;

drop view migrate_tids;

update tids set (grouping_name, dwdm_facility, directionality) = (select max(grouping_name), max(dwdm_facility), max(directionality) from tids@porky.oss.sprint.com tt where tt.name = tids.name) where tids.name in (select name from tids@porky.oss.sprint.com);
--------------------

insert into facilities (id, name, active, flag, customer_id, keephistory)
select rownum, f.facility as name, 'f', 'n', c.id, 't'
from facility@geonet.oss.sprint.com f, customer@geonet.oss.sprint.com cc, customers c
where cc.customerid = f.customerid and c.name = cc.customer and f.facility is not null;


--------------------
create or replace view migrate_tids as
select
  tt.tidid as id
from
  tid@geonet.oss.sprint.com tt
where
  (tt.tid, tt.channel, tt.timeentered) in (select max(tid), max(channel), max(timeentered) from tid@geonet.oss.sprint.com where tid = tt.tid and channel = tt.channel)
;

drop table blahblah;
create table blahblah as 
select rownum as xx, t.id tid_id, f.id facility_id, i.id interface_id, tt.trans_facility_path trans_seq, tt.recv_facility_path recv_seq, 't' certified, SYSDATE last_updatedate, 't' certified_recv
from 
  tid@geonet.oss.sprint.com tt, 
  tids t, 
  facilities f, 
  facility@geonet.oss.sprint.com ff, 
  interfaces i,
  interface_types ii
where 
  tt.tid = t.name
  and tt.tidid in (select id from migrate_tids)
  and (tt.channel is not null or tt.aid is not null)
  and ff.facility = f.name
  and ff.facilityid = tt.facilityid
  and ii.element_type_id = t.element_type_id
  and ii.id = i.interface_type_id
  and (   (    tt.channel is not null
           and i.name = tt.channel
          )
       or (    tt.aid is not null
           and i.name = tt.aid
          )
       )
;
delete from blahblah where xx in (select a.xx from blahblah a, blahblah b where a.xx < b.xx and a.tid_id = b.tid_id and a.facility_id = b.facility_id and a.interface_id = b.interface_id);

insert into tid_facility_map select trans_seq, recv_seq, tid_id, facility_id, interface_id, certified, last_updatedate, certified_recv from blahblah;

drop table blahblah;
drop view migrate_tids;

----------------------------

insert into pm_info (tid_id, interface_id, timeentered) select tid_id, interface_id, SYSDATE from tid_facility_map;

insert into tid_interface_status (tid_id, interface_id, timeentered, flag, connect_attempt) select tid_id, interface_id, sysdate, 'n', 0 from tid_facility_map;