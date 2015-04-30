 --SET serveroutput on
CREATE OR REPLACE PACKAGE tid_if_status_api AS

PROCEDURE tis_row_change (p_id IN tids.id%TYPE, i_id IN interfaces.id%TYPE);
PROCEDURE tis_statement_change;

END tid_if_status_api;
/
SHOW ERRORS


CREATE OR REPLACE PACKAGE BODY tid_if_status_api AS

TYPE tis_change_rec IS RECORD (
  id tids.id%TYPE,
  ifid interfaces.id%TYPE
);

TYPE tis_change_tab IS TABLE OF tis_change_rec;
g_tis_change_tab  tis_change_tab := tis_change_tab();

PROCEDURE tis_row_change (p_id IN tids.id%TYPE, i_id IN interfaces.id%TYPE) IS
BEGIN
  g_tis_change_tab.extend;
  g_tis_change_tab(g_tis_change_tab.last).id := p_id;
  g_tis_change_tab(g_tis_change_tab.last).ifid := i_id;
END tis_row_change;

PROCEDURE tis_statement_change 
AS
  gtct_cnt NUMBER := 0;
BEGIN
  -- SELECT count(1) FROM g_tis_change_tag INTO gtct_cnt;
  IF g_tis_change_tab.first > 0 THEN
    --insert into debugging values ('first: ' || g_tis_change_tab.first);
    FOR i IN g_tis_change_tab.first .. g_tis_change_tab.last LOOP
	  --insert into debugging values ('i: ' || i);
      IF g_tis_change_tab(i).id IS NOT NULL THEN
        --insert into debugging values ('id: ' || g_tis_change_tab(i).id);
	    status_to_tids_rollup(g_tis_change_tab(i).id);
	    
	    IF g_tis_change_tab(i).ifid IS NOT NULL THEN
	      status_to_facilities_rollup(g_tis_change_tab(i).id, g_tis_change_tab(i).ifid);
	    END IF;
	  END IF;
    END LOOP;
  END IF;
  g_tis_change_tab.delete;
END tis_statement_change;


END tid_if_status_api;
/
SHOW ERRORS

