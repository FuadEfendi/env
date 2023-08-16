--
-- cresvctbl.db2
--
-- Copyright (c) 2012, 2014, Oracle and/or its affiliates. All rights reserved.
--
--    NAME
--      cresvctbl.db2 - SQL script to create ServiceTable schema. 
--
--    DESCRIPTION
--    This file creates the database schema for ServiceTable. 
--
--


CREATE TABLE SERVICETABLE 
(
  ID VARCHAR(200) NOT NULL, 
  STYPE VARCHAR(50) NOT NULL, 
  ENDPOINT CLOB NOT NULL, 
  LASTUPDATED TIMESTAMP NOT NULL, 
  PROMOTED CHAR(1) check (PROMOTED in ( 'Y', 'N' )),
  VALID CHAR(1) check (VALID in ( 'Y', 'N' )),
  PRIMARY KEY (ID) 
)
$IN_TABLESPACE
@

CREATE INDEX SERVICETABLE_IDX ON SERVICETABLE(STYPE)
@

