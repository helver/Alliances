CREATE OR REPLACE VIEW outage_procedure_list_view AS
SELECT
  op.id AS id, 
  op.label AS label, 
  all_customers_for_proc(op.id) AS customers,
  u.id as nsm_id,
  u.firstname || ' ' || u.lastname AS nsm_name,
  u.phone as nsm_phone,
  u.mobile as nsm_mobile,
  u.email as nsm_email,
  '<a href="mailto:' || u.email || '">' || u.lastname || ', ' || u.firstname || '</a><br>Phone: ' || u.phone || '<br>Mobile:' || u.mobile AS nsm,
  op.dws_outage_ticket as dws_outage_ticket,
  op.dwdm_unavailability_ticket as dwdm_unavailability_ticket,
  op.tsa_super_notification as tsa_super_notification,
  op.ncc_notification as ncc_notification,
  op.nsm_notification as nsm_notification,
  op.noc_notification as noc_notification,
  op.ncc_page as ncc_page,
  op.alt_route as alt_route,
  op.notification_interval as notification_interval,
  op.deferred as deferred,
  op.dws_outage_report as dws_outage_report,
  op.maintenance_window as maintenance_window
FROM
  outage_procedure op,
  users u
WHERE
  op.nsm_id = u.id
WITH READ ONLY;
COMMIT;
