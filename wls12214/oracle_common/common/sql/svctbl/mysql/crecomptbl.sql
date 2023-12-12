Rem
Rem crecomptbl.sql
Rem
Rem Copyright (c) 2012, 2014, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      crecomptbl.sql - SQL script to create ShadowTable schema. 
Rem
Rem    DESCRIPTION
Rem    This file creates the database schema for ShadowTable. 
Rem

-- Define table parameters 
define tabparams="ENGINE=InnoDB DEFAULT CHARACTER SET=UTF8MB4 DEFAULT COLLATE=UTF8MB4_BIN ROW_FORMAT=DYNAMIC";


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
  URL             VARCHAR(4000),
  CONNPROPS BLOB
)
$tabparams 
/

CREATE INDEX COMPONENT_SCHEMA_INFO_IDX ON COMPONENT_SCHEMA_INFO(SCHEMA_USER)
/

