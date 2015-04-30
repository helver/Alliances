create or replace view ENTRY_SMRY_AND_HSUSA as
SELECT 
  h.FILER, 
  h.ENTRY_NBR, 
  h.LINE_NBR, 
  h.HSUSA, 
  h.PRIMARY_SPI, 
  h.SECOND_SPI, 
  h.VALUE, 
  iif(l.calc_duty is null, h.EST_DUTY, l.calc_duty) as duty, 
  l.CTRY_ORIGIN,
  l.MID, 
  l.EST_TAX, 
  l.CHARGES, 
  l.ADD_DUTY, 
  l.CVD_DUTY, 
  l.ADD_BOND_PAY_DUTY, 
  l.CVD_BOND_PAY_DUTY,
  l.CGN_NBR
FROM ENTRY_SMRY_HSUSA h LEFT JOIN ENTRY_SMRY_LINE l ON (h.LINE_NBR = l.LINE_NBR AND h.ENTRY_NBR = l.ENTRY_NBR);


-------------------------------------------

create or replace view EntryYear as
SELECT 
  e.entry_nbr, 
  e.port_ent, 
  e.imp_nbr,
  DatePart("yyyy", iif(e.entry_date is null, e.arvl_date, e.ENTRY_DATE)) AS [Year]
FROM ENTRY AS e;

-------------------------------------------

create or replace view SMRY_AND_RLSE
SELECT 
  e.Year,
  shs.HSUSA, 
  1 AS [NumEntries], 
  shs.value AS [Value], 
  shs.DUTY AS Duty,
  shs.filer,
  shs.ctry_origin as coo,
  shs.mid as mid,
  e.port_ent as port,
  e.imp_nbr,
  shs.cgn_nbr,
  shs.entry_nbr,
  shs.line_nbr,
  shs.primary_spi,
  'H' as source
FROM     ENTRY_SMRY_AND_HSUSA shs 
  INNER JOIN EntryYear e ON e.entry_nbr = shs.entry_nbr 

union

SELECT 
  e.Year,
  crs.hsusa,
  1 AS [NumEntries], 
  crs.line_val AS [Value], 
  0 AS Duty,
  crs.filer,
  crs.ctry_code as coo,
  crs.mid as mid,
  e.port_ent as port,
  e.imp_nbr,
  crs.cgn_nbr,
  crs.entry_nbr,
  crs.line_nbr,
  null as primary_spi,
  'C' as source
FROM (    CARGO_RLSE_LINE crs
  INNER JOIN EntryYear e ON e.entry_nbr = crs.entry_nbr)
  LEFT JOIN ENTRY_SMRY_AND_HSUSA shs on (shs.entry_nbr = crs.entry_nbr and shs.line_nbr = crs.line_nbr and shs.hsusa = crs.hsusa)
WHERE
  shs.entry_nbr is null
;


-------------------------------------------

create or replace view SMRY_AND_RLSE_BY_ENTRY
SELECT 
  a.entry_nbr as entry_nbr,
  max(a.filer) as filer,
  max(a.port) as port,
  max(a.imp_nbr) as imp_nbr,
  sum(a.value) as [value],
  sum(a.duty) as duty,
  max(a.year) as [year],
  count(1) as [# of line items]
FROM SMRY_AND_RLSE a
GROUP BY 
  a.entry_nbr
;

---------------------------------------------------------

create or replace view HTSBreakdown as
SELECT 
  sr.Year, 
  sr.HSUSA AS [HTS #], 
  Count(sr.NumEntries) AS [Num Entries], 
  Sum(sr.value) AS [Value], 
  Sum(sr.DUTY) AS Duty, 
  iif(max(f.filer_name) = NULL, '', Max(f.FILER_NAME)) & '(' & sr.filer & ')' AS Filer, 
  iif(max(p.port_name) = NULL, '', Max(p.PORT_NAME)) & '(' & sr.port & ')' AS PORT
FROM (   SMRY_AND_RLSE sr
  LEFT JOIN Filer_Lookup f ON sr.FILER = f.FILER) 
  LEFT JOIN Port p ON sr.PORT = p.PORT_CODE
GROUP BY 
  sr.Year, 
  sr.HSUSA, 
  sr.FILER, 
  sr.PORT
ORDER BY 
  sr.HSUSA, 
  sr.Year, 
  Count(1) DESC
;



---------------------------------------------------------

create or replace view HTSDetail as
SELECT 
  sr.Year,
  sr.IMP_NBR, 
  sr.HSUSA AS [HTS #], 
  count(sr.NumEntries) AS [Num Entries], 
  Sum(sr.value) AS [Value], 
  Sum(sr.DUTY) AS Duty
FROM 
  SMRY_AND_RLSE sr
GROUP BY 
  sr.Year, 
  sr.IMP_NBR, 
  sr.HSUSA
ORDER BY 
  sr.Year, 
  sr.IMP_NBR, 
  count(1) DESC
;





---------------------------------------------------------

create or replace view HTSSummary as
SELECT 
  sr.Year,
  sr.HSUSA AS [HTS #], 
  count(sr.NumEntries) AS [Num Entries], 
  Sum(sr.value) AS [Value], 
  Sum(sr.DUTY) AS Duty
FROM 
  SMRY_AND_RLSE sr
GROUP BY 
  sr.Year, 
  sr.HSUSA
ORDER BY 
  sr.Year, 
  count(1) DESC
;

---------------------------------------------------------

create or replace view YearlyTotalsFromEntry as
SELECT 
  sr.Year, 
  count(1) AS [Num Entries], 
  Sum(sr.value) AS [Value], 
  Sum(sr.DUTY) AS Duty
FROM 
  SMRY_AND_RLSE_BY_ENTRY sr
GROUP BY
  sr.Year
ORDER BY 
  sr.Year
;


---------------------------------------------------------

create or replace view BrokerIORSummary as
SELECT 
  sr.Year,
  iif(max(f.filer_name) = NULL, '', Max(f.FILER_NAME)) & '(' & sr.filer & ')' AS Filer, 
  sr.IMP_NBR, 
  count(1) AS [Num Entries], 
  Sum(sr.value) AS [Value], 
  Sum(sr.DUTY) AS Duty
FROM 
  SMRY_AND_RLSE_BY_ENTRY sr
  LEFT JOIN Filer_Lookup f ON sr.FILER = f.FILER
GROUP BY
  sr.Year,
  sr.filer,
  sr.imp_nbr
ORDER BY 
  sr.Year,
  sr.filer,
  sum(sr.value) desc
;


---------------------------------------------------------

create or replace view BrokerSummary as
SELECT 
  sr.Year,
  iif(max(f.filer_name) = NULL, '', Max(f.FILER_NAME)) & '(' & sr.filer & ')' AS Filer, 
  count(1) AS [Num Entries], 
  Sum(sr.value) AS [Value], 
  Sum(sr.DUTY) AS Duty
FROM 
  SMRY_AND_RLSE_BY_ENTRY sr
  LEFT JOIN Filer_Lookup f ON sr.FILER = f.FILER
GROUP BY
  sr.Year,
  sr.filer
ORDER BY 
  sr.Year,
  count(1) desc
;


---------------------------------------------------------

create or replace view COOMidReport as
SELECT 
  sr.Year,
  sr.imp_nbr,
  Max(c.country_name) AS Country,
  iif(Max(m.acs_name) is null, '', max(m.acs_name)) & '(' & sr.mid & ')' as Manufacturer,
  count(1) AS [Num Entries], 
  Sum(sr.value) AS [Value], 
  Sum(sr.DUTY) AS Duty
FROM (
  SMRY_AND_RLSE sr
  LEFT JOIN Mfr m ON m.ID_NBR = sr.MID)
  LEFT JOIN Country c ON c.CTRY_CODE = sr.coo
GROUP BY
  sr.Year,
  sr.imp_nbr,
  sr.coo,
  sr.mid
ORDER BY 
  sr.Year,
  sr.imp_nbr,
  count(1) desc
;


---------------------------------------------------------

create or replace view COOReport as
SELECT 
  sr.Year,
  sr.imp_nbr,
  Max(c.country_name) AS Country,
  count(1) AS [Num Entries], 
  Sum(sr.value) AS [Value], 
  Sum(sr.DUTY) AS Duty
FROM 
  SMRY_AND_RLSE sr
  LEFT JOIN Country c ON c.CTRY_CODE = sr.coo
GROUP BY
  sr.Year,
  sr.imp_nbr,
  sr.coo
ORDER BY 
  sr.Year,
  sr.imp_nbr,
  count(1) desc
;


---------------------------------------------------------

create or replace view COOSummary as
SELECT 
  sr.Year,
  Max(c.country_name) AS Country,
  count(1) AS [Num Entries], 
  Sum(sr.value) AS [Value], 
  Sum(sr.DUTY) AS Duty
FROM 
  SMRY_AND_RLSE sr
  LEFT JOIN Country c ON c.CTRY_CODE = sr.coo
GROUP BY
  sr.Year,
  sr.coo
ORDER BY 
  sr.Year,
  count(1) desc
;


---------------------------------------------------------

create or replace view ImporterSummary as
SELECT
  sr.Year,
  sr.imp_nbr,
  count(1) AS [Num Entries], 
  Sum(sr.value) AS [Value], 
  Sum(sr.DUTY) AS Duty
FROM 
  SMRY_AND_RLSE_BY_ENTRY sr
GROUP BY
  sr.Year,
  sr.imp_nbr
ORDER BY 
  sr.Year,
  count(1) desc
;


---------------------------------------------------------

create or replace view IORBrokerSummary as
SELECT
  sr.Year,
  iif(max(f.filer_name) = NULL, '', Max(f.FILER_NAME)) & '(' & sr.filer & ')' AS Filer, 
  sr.imp_nbr,
  count(1) AS [Num Entries], 
  Sum(sr.value) AS [Value], 
  Sum(sr.DUTY) AS Duty
FROM 
  SMRY_AND_RLSE_BY_ENTRY sr
  LEFT JOIN Filer_Lookup f ON sr.FILER = f.FILER
GROUP BY
  sr.Year,
  sr.filer,
  sr.imp_nbr
ORDER BY 
  sr.Year,
  sr.imp_nbr,
  count(1) desc
;


---------------------------------------------------------

create or replace view MIDIORSummary as
SELECT
  sr.Year,
  sr.imp_nbr,
  sr.mid,
  Max(m.acs_name) as Manufacturer,
  count(1) AS [Num Entries], 
  Sum(sr.value) AS [Value], 
  Sum(sr.DUTY) AS Duty
FROM 
  SMRY_AND_RLSE sr
  LEFT JOIN Mfr m ON m.ID_NBR = sr.MID
GROUP BY
  sr.Year,
  sr.mid,
  sr.imp_nbr
ORDER BY 
  sr.Year,
  sr.imp_nbr,
  count(1) desc
;


---------------------------------------------------------

create or replace view MIDSummary as
SELECT
  sr.Year,
  sr.mid,
  Max(m.acs_name) as Manufacturer,
  count(1) AS [Num Entries], 
  Sum(sr.value) AS [Value], 
  Sum(sr.DUTY) AS Duty
FROM 
  SMRY_AND_RLSE sr
  LEFT JOIN Mfr m ON m.ID_NBR = sr.MID
GROUP BY
  sr.Year,
  sr.mid
ORDER BY 
  sr.Year,
  count(1) desc
;


---------------------------------------------------------

create or replace view TransportModeSummary as
SELECT
  sr.Year,
  e.trnsprt_mode,
  count(1) AS [Num Entries], 
  Sum(sr.value) AS [Value], 
  Sum(sr.DUTY) AS Duty
FROM 
  SMRY_AND_RLSE_BY_ENTRY sr
  LEFT JOIN Entry e ON e.entry_nbr = sr.entry_nbr
GROUP BY
  sr.Year,
  e.trnsprt_mode
ORDER BY 
  sr.Year,
  sum(sr.value) desc
;


---------------------------------------------------------

create or replace view CombinedDataQ as
SELECT
  sr.imp_nbr as ior,
  sr.imp_nbr as cons,
  sr.FILER+'-'+Left(sr.ENTRY_NBR,7)+'-'+Right(sr.ENTRY_NBR,1) AS num,
  sr.filer as filer,
  sr.port as port,
  sr.value AS [Value], 
  sr.DUTY AS duties,
  IIf(e.entry_date Is Null, iif(e.arvl_date is null, #1/1/1970#, e.arvl_date),e.ENTRY_DATE) AS entry_date,
  e.entry_type as entrytype
FROM 
  SMRY_AND_RLSE_BY_ENTRY sr
  LEFT JOIN Entry e ON e.entry_nbr = sr.entry_nbr
;


---------------------------------------------------------

create or replace view CombinedByLineNum as
SELECT
  sr.filer as filer,
  sr.FILER+'-'+Left(sr.ENTRY_NBR,7)+'-'+Right(sr.ENTRY_NBR,1) AS ENTRY_NBR,
  sr.line_nbr,
  sr.coo,
  sr.hsusa,
  sr.imp_nbr,
  sr.cgn_nbr,
  sr.mid,
  sr.value AS [Value], 
  sr.DUTY AS duties,
  sr.port,
  e.liquid_date as liquid,
  IIf(e.entry_date Is Null, iif(e.arvl_date is null, #1/1/1970#, e.arvl_date),e.ENTRY_DATE) AS entry_date
FROM 
  SMRY_AND_RLSE sr
  LEFT JOIN Entry e ON e.entry_nbr = sr.entry_nbr
;


---------------------------------------------------------

create or replace view EntryLogByLineItem as
SELECT
  sr.FILER+'-'+Left(sr.ENTRY_NBR,7)+'-'+Right(sr.ENTRY_NBR,1) AS ENTRY_NBR,
  IIf(e.entry_date Is Null, iif(e.arvl_date is null, #1/1/1970#, e.arvl_date),e.ENTRY_DATE) AS entry_date,
  sr.imp_nbr,
  sr.line_nbr,
  sr.hsusa as [HTS #],
  sr.mid,
  sr.value AS [Value], 
  sr.DUTY AS duty
FROM 
  SMRY_AND_RLSE sr
  LEFT JOIN Entry e ON e.entry_nbr = sr.entry_nbr
;


---------------------------------------------------------

create or replace view IORTransportModeSummary as
SELECT
  sr.Year,
  sr.imp_nbr,
  e.trnsprt_mode as Transport,
  count(1) as [Num Entries],
  sum(sr.value) AS [Value], 
  sum(sr.DUTY) AS duty
FROM 
  SMRY_AND_RLSE_BY_ENTRY sr
  LEFT JOIN Entry e ON e.entry_nbr = sr.entry_nbr
GROUP BY
  sr.Year,
  sr.imp_nbr,
  e.trnsprt_mode
ORDER BY
  sr.Year,
  sr.imp_nbr,
  count(1) desc
;


---------------------------------------------------------

create or replace view NAFTAReport as
SELECT
  sr.Year,
  sr.FILER+'-'+Left(sr.ENTRY_NBR,7)+'-'+Right(sr.ENTRY_NBR,1) AS [Entry #],
  IIf(e.entry_date Is Null, iif(e.arvl_date is null, #1/1/1970#, e.arvl_date),e.ENTRY_DATE) AS entry_date,
  sr.imp_nbr as ior,
  sr.hsusa as [HTS #],
  sr.primary_spi,
  sr.coo,
  sr.mid,
  sr.value AS [Value], 
  sr.DUTY AS duty
FROM 
  SMRY_AND_RLSE sr
  LEFT JOIN Entry e ON e.entry_nbr = sr.entry_nbr
WHERE
  sr.primary_spi in ('CA', 'MX') and
  sr.Year = '2002'
;


---------------------------------------------------------

create or replace view TIB as
SELECT
  sr.Year,
  sr.FILER+'-'+Left(sr.ENTRY_NBR,7)+'-'+Right(sr.ENTRY_NBR,1) AS [Entry #],
  IIf(e.entry_date Is Null, iif(e.arvl_date is null, #1/1/1970#, e.arvl_date),e.ENTRY_DATE) AS entry_date,
  DateAdd("yyyy", 3, IIf(e.entry_date Is Null, iif(e.arvl_date is null, #1/1/1970#, e.arvl_date),e.ENTRY_DATE)) AS [3Yr Expiry Date],
  sr.imp_nbr as ior,
  sr.hsusa as [HTS #],
  sr.value AS [Value], 
  sr.DUTY AS [Duty Rate],
  null as [Bond Calculation]
FROM 
  SMRY_AND_RLSE sr
  LEFT JOIN Entry e ON e.entry_nbr = sr.entry_nbr
WHERE
  sr.entry_nbr in (SELECT ENTRY_NBR FROM entry_smry_hsusa where int(hsusa/10000) = 9813)
ORDER BY 
  IIf(e.entry_date Is Null, iif(e.arvl_date is null, #1/1/1970#, e.arvl_date),e.ENTRY_DATE),
  sr.entry_nbr, 
  sr.line_nbr, 
  sr.value DESC
;

------------------------------------------------------

create or replace view ModifiedEntryLog as
SELECT DatePart("yyyy",IIf(e.entry_date Is Null,e.arvl_date,e.ENTRY_DATE)) AS [year], e.FILER+'-'+Left(e.ENTRY_NBR,7)+'-'+Right(e.ENTRY_NBR,1) AS num, CDate(IIf(e.entry_date Is Null,e.arvl_date,e.ENTRY_DATE)) AS entrydate, e.ENTRY_TYPE AS entrytype, e.IMP_NBR AS ior, e.CGN_NBR AS cons, e.ENTRY_VAL AS [value], 'OST' AS source, e.port_ent AS port
FROM ENTRY AS e;

