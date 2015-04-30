-- fiber_segments
--
-- Fiber_segments are conglomerated into fiber_routes.  Each segment must 
-- be checked for traffic and signal.  This would determine whether the 
-- segment (and by extention) the route is capable of being used as an 
-- alt-route.  The ASite and ZSite here is different from the fiber_routes.  
CREATE TABLE fiber_segments (
  id NUMBER NOT NULL PRIMARY KEY,-- Primary Key comes from fiber_segement_id_seq
  name VARCHAR2(9) NOT NULL,     -- DWDM Grouping Name
  system CHAR(1),                -- DWDM System Designator
  seq NUMBER,                    -- DWDM Segment Sequence number
  signal NUMBER,                 -- Does this segment have a signal
  channel NUMBER,                -- The channel this segment uses.  Relates to element_type_interfaces.name
  asite_id NUMBER NOT NULL REFERENCES tids(id), -- The ASite for this segment
  zsite_id NUMBER NOT NULL REFERENCES tids(id), -- The ZSite for this segment
  fiber_route_id NUMBER NOT NULL REFERENCES fiber_routes(id) -- Route this segment is a part of
);
