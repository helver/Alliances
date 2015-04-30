drop view yearlysummary;
create or replace view yearlysummary as 
select 
  company_id, 
  to_char(entries.entry_date, 'YYYY'::text) AS year, 
  count(1) as entries, 
  sum(round(value * 100)/100) as value, 
  sum(round(duties * 100)/100) as duties, 
  sum(case when ior = 'N/A' then 0 else 1 end) as iorcount, 
  sum(case when ior = 'N/A' then 1 else 0 end) as consigneecount, 
  sum(case when liquid_date is null or liquid_date > report_date then 0 else 1 end) as liquidated, 
  sum(case when liquid_date is null or liquid_date > report_date then 1 else 0 end) as unliquidated 
from entries 
group by company_id, to_char(entries.entry_date, 'YYYY'::text) 
order by to_char(entries.entry_date, 'YYYY'::text) ASC;
grant all on yearlysummary to iar;

drop view yearlyiorsummary;
create or replace view yearlyiorsummary as 
select 
  company_id, 
  to_char(entries.entry_date, 'YYYY'::text) AS year, 
  ior, 
  count(1) as entries, 
  sum(round(value * 100)/100) as value, 
  sum(round(duties * 100)/100) as duties, 
  sum(case when ior = 'N/A' then 0 else 1 end) as iorcount, 
  sum(case when ior = 'N/A' then 1 else 0 end) as consigneecount, 
  sum(case when liquid_date is null or liquid_date > report_date then 0 else 1 end) as liquidated, 
  sum(case when liquid_date is null or liquid_date > report_date then 1 else 0 end) as unliquidated 
from entries 
group by company_id, to_char(entries.entry_date, 'YYYY'::text), ior 
order by to_char(entries.entry_date, 'YYYY'::text) ASC, entries DESC;
grant all on yearlyiorsummary to iar;

drop view yearlyconssummary;
create or replace view yearlyconssummary as 
select 
  company_id, 
  to_char(entries.entry_date, 'YYYY'::text) AS year, 
  consgnee, 
  count(1) as entries, 
  sum(round(value * 100)/100) as value, 
  sum(round(duties * 100)/100) as duties, 
  sum(case when liquid_date is null or liquid_date > report_date then 0 else 1 end) as liquidated, 
  sum(case when liquid_date is null or liquid_date > report_date then 1 else 0 end) as unliquidated 
from entries 
where ior = 'N/A' 
group by company_id, to_char(entries.entry_date, 'YYYY'::text), consgnee 
order by to_char(entries.entry_date, 'YYYY'::text) ASC, entries DESC;
grant all on yearlyconssummary to iar;

drop view yearlybrokersummary;
create or replace view yearlybrokersummary as 
select 
  company_id, 
  to_char(entries.entry_date, 'YYYY'::text) AS year, 
  filer_id as filercode,
  (case when f.name is null then filer_id else f.name end) as filer, 
  count(1) as entries, 
  sum(round(value * 100)/100) as value, 
  sum(round(duties * 100)/100) as duties, 
  sum(case when ior = 'N/A' then 0 else 1 end) as iorcount, 
  sum(case when ior = 'N/A' then 1 else 0 end) as consigneecount, 
  sum(case when liquid_date is null or liquid_date > report_date then 0 else 1 end) as liquidated, 
  sum(case when liquid_date is null or liquid_date > report_date then 1 else 0 end) as unliquidated 
from entries left outer join filer_lookup f on (entries.filer_id = f.id)
group by company_id, to_char(entries.entry_date, 'YYYY'::text), filer_id, (case when f.name is null then filer_id else f.name end)
order by to_char(entries.entry_date, 'YYYY'::text) ASC, entries DESC;
grant all on yearlybrokersummary to iar;

drop view yearlyportsummary;
create or replace view yearlyportsummary as 
select 
  company_id, 
  to_char(entries.entry_date, 'YYYY'::text) AS year,
  port_id as portcode,
  (case when p.name is null then port_id else p.name end) as port, 
  count(1) as entries, 
  sum(round(value * 100)/100) as value, 
  sum(round(duties * 100)/100) as duties, 
  sum(case when ior = 'N/A' then 0 else 1 end) as iorcount, 
  sum(case when ior = 'N/A' then 1 else 0 end) as consigneecount, 
  sum(case when liquid_date is null or liquid_date > report_date then 0 else 1 end) as liquidated, 
  sum(case when liquid_date is null or liquid_date > report_date then 1 else 0 end) as unliquidated 
from entries left outer join port_lookup p on (port_id = p.code)
group by company_id, to_char(entries.entry_date, 'YYYY'::text), port_id, (case when p.name is null then port_id else p.name end) 
order by to_char(entries.entry_date, 'YYYY'::text) ASC, entries DESC;
grant all on yearlyportsummary to iar;

drop view yearlyhtsussummary;
create or replace view yearlyhtsussummary as 
select 
  company_id, 
  to_char(line_items.entry_date, 'YYYY'::text) AS year, 
  substring(hsusa from 1 for 6) as hsusa_base,
  hsusa,
  (case when h.description is null then hsusa else h.description end) as hsusa_desc, 
  count(1) as line_items, 
  sum(round(value * 100)/100) as value, 
  sum(round(duties * 100)/100) as duties 
from line_items left outer join hsusa_lookup h on (hsusa = h.id)
group by company_id, to_char(line_items.entry_date, 'YYYY'::text), substring(hsusa from 1 for 6), hsusa, (case when h.description is null then hsusa else h.description end) 
order by to_char(line_items.entry_date, 'YYYY'::text) ASC, line_items DESC;
grant all on yearlyhtsussummary to iar;


drop view yearlymidsummary;
create or replace view yearlymidsummary as 
select 
  company_id, 
  to_char(line_items.entry_date, 'YYYY'::text) AS year, 
  mid,
  (case when m.name is null then mid else m.name end) as company, 
  count(1) as line_items, 
  sum(round(value * 100)/100) as value, 
  sum(round(duties * 100)/100) as duties 
from line_items left outer join mid_lookup m on (mid = m.id)
group by company_id, to_char(line_items.entry_date, 'YYYY'::text), mid, (case when m.name is null then mid else m.name end) 
order by to_char(line_items.entry_date, 'YYYY'::text) ASC, line_items DESC;
grant all on yearlymidsummary to iar;

drop view yearlycoosummary;
create or replace view yearlycoosummary as 
select 
  company_id, 
  to_char(line_items.entry_date, 'YYYY'::text) AS year, 
  (case when c.name is null then coo else c.name end) as coo, 
  count(1) as line_items, 
  sum(round(value * 100)/100) as value, 
  sum(round(duties * 100)/100) as duties 
from line_items left outer join country_lookup c on (coo = c.id)
group by company_id, to_char(line_items.entry_date, 'YYYY'::text), (case when c.name is null then coo else c.name end) 
order by to_char(line_items.entry_date, 'YYYY'::text) ASC, line_items DESC;
grant all on yearlycoosummary to iar;

drop view spisummary;
create or replace view spisummary as 
select 
  company_id, 
  to_char(line_items.entry_date, 'YYYY'::text) AS year, 
  line_items.id as num,
  to_char(line_items.entry_date, 'MM/DD/YYYY'::text) as entry_date,
  ior,
  hsusa,
  h.description as hsusa_desc,
  spi,
  coo,
  c.name as country,
  mid,
  m.name as company,
  value, 
  duties 
from ((line_items left outer join country_lookup c on (coo = c.id)) 
                  left outer join mid_lookup m on (mid = m.id))
                  left outer join hsusa_lookup h on (hsusa = h.id)
where spi is not null
order by spi, to_char(line_items.entry_date, 'YYYY'::text) ASC, ior, num;
grant all on spisummary to iar;

drop view valuedifferences;
create or replace view valuedifferences as 
select 
  company_id,
  id as num,
  ior,
  value,
  nfcvalue,
  value - nfcvalue as difference
from entries 
where value <> nfcvalue and value > 0
order by ior;
grant all on valuedifferences to iar;


drop view dutiesdifferences;
create or replace view dutiesdifferences as 
select 
  company_id,
  id as num,
  ior,
  duties,
  ostduties,
  duties - ostduties as difference
from entries 
where ABS(duties - ostduties) > .02
order by ior;
grant all on dutiesdifferences to iar;



drop view yearlyentrylog;
create or replace view yearlyentrylog as 
select 
  company_id, 
  to_char(entries.entry_date, 'YYYY'::text) AS year, 
  entries.id as num,
  entries.entry_date as entry_date,
  filer_id as filercode,
  (case when f.name is null then filer_id else f.name end) as filer, 
  entry_type_id as entrytype, 
  value as value, 
  duties as duties, 
  ior as ior, 
  consgnee as consgnee
from entries left outer join filer_lookup f on (entries.filer_id = f.id)
order by entries.entry_date ASC;
grant all on yearlyentrylog to iar;



drop view yearlyentrylogbylineitem;
create or replace view yearlyentrylogbylineitem as 
select 
  max(l.company_id) as company_id, 
  to_char(max(l.entry_date), 'YYYY'::text) AS year, 
  l.id as num,
  l.mid as mid,
  substr(l.mid, 0, 7) as submid,
  max(l.entry_date) as entry_date,
  max(l.filer_id) as filercode,
  (case when max(f.name) is null then max(l.filer_id) else max(f.name) end) as filer, 
  max(entry_type_id) as entrytype, 
  sum(l.value) as value, 
  sum(l.duties) as duties, 
  max(l.ior) as ior, 
  max(l.consgnee) as consgnee
from (line_items l inner join entries on l.id = entries.id) left outer join filer_lookup f on (entries.filer_id = f.id)
group by l.mid, l.id
order by l.mid, max(l.entry_date) ASC;
grant all on yearlyentrylogbylineitem to iar;



