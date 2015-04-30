CREATE OR REPLACE VIEW Facility_End_Cities_View AS
SELECT
  a_city.id AS aside,
  z_city.id AS zside,
  fep.facility_id as facilityid
FROM
  facility_end_points_view fep,
  tids a_tid,
  tids z_tid,
  cities a_city,
  cities z_city
WHERE
      a_tid.city_id = a_city.id
  AND z_tid.city_id = z_city.id
  AND fep.a_site_tid = a_tid.id
  AND fep.z_site_tid = z_tid.id
;
COMMIT;
