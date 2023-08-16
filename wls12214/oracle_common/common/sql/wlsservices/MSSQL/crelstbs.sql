-- Copyright (c) 2006,2014, Oracle and/or its affiliates. All rights reserved.
-- All rights reserved. 
--
--
-- crelstbs.sql - create leasing tables for SQL Server
-- 

go
set nocount on
-- begin transaction crelstbs
go

-- Create leasing table
if object_id(N'$(ADDITIONAL_SCHEMA_NAME).ACTIVE', N'U') IS NOT NULL
begin
    drop table $(ADDITIONAL_SCHEMA_NAME).ACTIVE
end
go


create table $(ADDITIONAL_SCHEMA_NAME).ACTIVE (
  SERVER VARCHAR(255) NOT NULL,
  INSTANCE VARCHAR(255) NOT NULL,
  DOMAINNAME VARCHAR(255) NOT NULL,
  CLUSTERNAME VARCHAR(255) NOT NULL,
  TIMEOUT DATETIME,
  PRIMARY KEY (SERVER, DOMAINNAME, CLUSTERNAME)
)
go

-- commit transaction crelstbs
go

