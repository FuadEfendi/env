--
-- crecomptbl.db2
--
-- Copyright (c) 2012, 2014, Oracle and/or its affiliates. All rights reserved.
--
--    NAME
--      crecomptbl.db2 - SQL script to create ShadowTable schema. 
--
--    DESCRIPTION
--    This file creates the database schema for ShadowTable. 
--


CREATE TABLE COMPONENT_SCHEMA_INFO
(
  SCHEMA_USER     VARCHAR(100) NOT NULL,
  SCHEMA_PASSWORD BLOB ,
  COMP_ID         VARCHAR(100) NOT NULL,
  PREFIX_NAME     VARCHAR(100) ,
  DB_HOSTNAME     VARCHAR(255) ,
  DB_SERVICE      VARCHAR(200) ,
  DB_PORTNUMBER   VARCHAR(10),
  DATABASE_NAME   VARCHAR(200),
  STATUS          VARCHAR(20),
  URL VARCHAR(4000),
  CONNPROPS BLOB
)
$IN_TABLESPACE
@

CREATE INDEX COMPONENT_SCHEMA_INFO_IDX ON COMPONENT_SCHEMA_INFO(SCHEMA_USER)
@

