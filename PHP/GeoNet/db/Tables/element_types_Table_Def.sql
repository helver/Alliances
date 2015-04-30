-- element_types
--
-- Element_types contains information about the different element_types we
-- interface with.
CREATE TABLE element_types (
  id NUMBER NOT NULL PRIMARY KEY, -- Primary Key comes from element_type_id_seq
  name VARCHAR2(30) NOT NULL,     -- Element Type Name
  windows NUMBER,                 -- Window count
  primus_name VARCHAR2(30),       -- Primus Name for Element Type
  predefined_ifs CHAR(1),         -- All interfaces are predefined?
  pm_doc_link VARCHAR2(100)       -- URL for PM documenation
);
