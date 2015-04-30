-- outage_procedure
--
CREATE TABLE outage_procedure (
  id NUMBER NOT NULL PRIMARY KEY,-- Primary Key comes from outage_procedure_id_seq
  nsm_id NUMBER NOT NULL REFERENCES users(id),
  label VARCHAR2(50),     -- DWDM Grouping Name
  dws_outage_ticket VARCHAR2(80) NOT NULL,
  dwdm_unavailability_ticket varchar2(80) NOT NULL,
  tsa_super_notification char(1) NOT NULL,
  ncc_notification VARCHAR2(80) NOT NULL,
  nsm_notification VARCHAR2(80) NOT NULL,
  noc_notification VARCHAR2(80) NOT NULL,
  ncc_page varchar2(80) NOT NULL,
  alt_route varchar2(80) NOT NULL,
  notification_interval varchar2(80) NOT NULL,
  deferred varchar2(80) NOT NULL,
  dws_outage_report char(1) NOT NULL,
  maintenance_window varchar2(80)
);
