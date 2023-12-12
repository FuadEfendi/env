--
-- crecomptbl.sql
--
-- Copyright (c) 2012, 2014, Oracle and/or its affiliates. All rights reserved.
--
--    NAME
--      crecomptbl.sql - SQL script to create ShadowTable schema. 
--
--    DESCRIPTION
--    This file creates the database schema for ShadowTable. 
--
--

if object_id(N'COMPONENT_SCHEMA_INFO', N'U') IS NOT NULL
begin
    drop table COMPONENT_SCHEMA_INFO
end
go

CREATE TABLE COMPONENT_SCHEMA_INFO
(
  SCHEMA_USER     VARCHAR(100) NOT NULL,
  SCHEMA_PASSWORD VARBINARY(MAX),
  COMP_ID         VARCHAR(100) NOT NULL,
  PREFIX_NAME     VARCHAR(100),
  DB_HOSTNAME     VARCHAR(255),
  DB_SERVICE      VARCHAR(200),
  DB_PORTNUMBER   VARCHAR(10),
  DATABASE_NAME   VARCHAR(200),
  STATUS          VARCHAR(20),
  URL             VARCHAR(4000),
  CONNPROPS VARBINARY(MAX)
)
go


CREATE INDEX COMPONENT_SCHEMA_INFO_IDX ON COMPONENT_SCHEMA_INFO(SCHEMA_USER)
go
