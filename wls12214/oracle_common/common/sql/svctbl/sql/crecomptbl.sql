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
Rem

CREATE TABLE "COMPONENT_SCHEMA_INFO"
(
  "SCHEMA_USER"     VARCHAR2(100) NOT NULL,
  "SCHEMA_PASSWORD" BLOB ,
  "COMP_ID" VARCHAR2(100) NOT NULL,
  "PREFIX_NAME"     VARCHAR2(100) ,
  "DB_HOSTNAME"     VARCHAR2(255) ,
  "DB_SERVICE"      VARCHAR2(200) ,
  "DB_PORTNUMBER"   VARCHAR2(10),
  "DATABASE_NAME"   VARCHAR2(200),
  "STATUS"          VARCHAR2(20),  
  "URL"             VARCHAR2(4000),
  "CONNPROPS" BLOB  
) tablespace &&1;


CREATE INDEX COMPONENT_SCHEMA_INFO_IDX ON COMPONENT_SCHEMA_INFO(SCHEMA_USER);


                                      
