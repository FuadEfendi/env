--
-- cresvctbl.sql
--
-- Copyright (c) 2012, 2014, Oracle and/or its affiliates. All rights reserved.
--
--    NAME
--      cresvctbl.sql - SQL script to create ServiceTable schema. 
--
--    DESCRIPTION
--    This file creates the database schema for ServiceTable. 
--
--

if object_id(N'SERVICETABLE', N'U') IS NOT NULL
begin
    drop table SERVICETABLE
end
go

CREATE TABLE SERVICETABLE 
(
  ID VARCHAR(200) PRIMARY KEY, 
  STYPE VARCHAR(50) NOT NULL, 
  ENDPOINT VARCHAR(MAX) NOT NULL, 
  LASTUPDATED datetime NOT NULL, 
  PROMOTED bit NOT NULL,
  VALID bit NOT NULL
)
go


CREATE INDEX SERVICETABLE_IDX ON SERVICETABLE(STYPE);
go
