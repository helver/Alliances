-- fiber_routes
--
-- Fiber_routes define the major fiber routes in the DWDM network.  
-- Fiber_routes are comprised of fiber_segments.  This is used primarily 
-- for Alt-Routes so that entire routes (and all their corresponding 
-- traffic) can be shown as being alt-routed with very minimal work.
CREATE TABLE fiber_routes (
  id NUMBER NOT NULL PRIMARY KEY, -- Primary Key comes from fiber_routes_id_seq
  name VARCHAR2(12) NOT NULL,     -- Route Name
  bay NUMBER NOT NULL,            -- Fiber Patch Panel Bay
  shelf NUMBER NOT NULL,          -- Fiber Patch Panel Shelf
  jack NUMBER NOT NULL,           -- Fiber Patch Panel Jack
  asite_id NUMBER NOT NULL REFERENCES tids(id), -- The ASite for this route
  zsite_id NUMBER NOT NULL REFERENCES tids(id)  -- The ZSite for this route
);
