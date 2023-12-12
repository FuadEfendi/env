--
--
-- drop-user-rcu.sql
--
-- Copyright (c) 2006,2014, Oracle and/or its affiliates. All rights reserved.
--
--    NAME
--    drop-user-rcu.SQL - Drop Login, User and Schema
--
--    DESCRIPTION
--    Drop login, user and schema that were created for Weblogic core.
--    It has to be run from an administrator account.  This script is supposed
--    to be used by RCU only.
--

go
SET NOCOUNT ON
go

-- Assign database name which is passed in as V1 to DATABASE_NAE
:SETVAR DATABASE_NAME  $(v1)
go

-- Assign user name which is passed in as V2 to SCHEMA_USER
:SETVAR SCHEMA_USER  $(v2)
go

-- Assign additional schema name which is passed in as V3 to ADDITONAL_SCHEMA_NAME
:SETVAR ADDITIONAL_SCHEMA_NAME  $(v3)
go

-- Invoke dropuser.sql to drop login, user and schema.
:r dropuser.sql
go


