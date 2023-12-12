--
-- cremds.sql
--
-- Copyright (c) 2006,2014, Oracle and/or its affiliates. All rights reserved.
-- All rights reserved. 
--
--    NAME
--      create-rcu.sql - <one-line expansion of the name>
--
--    DESCRIPTION
--    This file creates the database schema for the repository.
--
--    The user should also have grant to create sequence in order to
--    successfully use the MDS Repository.
--

go
SET NOCOUNT ON
set implicit_transactions off
-- begin transaction 
go

-- Assign additional schema name which is passed in as V3 to ADDITIONAL_SCHEMA_NAME
:SETVAR ADDITIONAL_SCHEMA_NAME  $(v3)
go

-- Creating the tables and views
:r crejstbs.sql
:r crelstbs.sql
:r ../diagnostics/sqlserver/wls_events_ddl.sql
:r ../diagnostics/sqlserver/wls_hvst_ddl.sql
:r ../batch/sqlserver/jsr352-ms-sqlserver.ddl

-- Creating the indexes

-- Creating the package specs

go

-- commit transaction 
go

