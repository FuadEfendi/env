--
--
-- create-rcu.sql
--
-- Copyright (c) 2011,2014, Oracle and/or its affiliates. All rights reserved.
-- All rights reserved. 
--
--    NAME
--     create-rcu.sql - create tables for weblogic core services.
--
--    DESCRIPTION
--    This file creates the database schema for the weblogic core services.
--
--    NOTES
--

-- We know that the current schema is the schema that will be used.

define ADDITIONAL_SCHEMA_NAME=$2;

-- create weblogic core tables and indexes
source crewlstbs.sql
source ../diagnostics/mysql/wls_events_ddl.sql
source ../diagnostics/mysql/wls_hvst_ddl.sql
source ../batch/mysql/jsr352-mysql.ddl

-- create WLS Leasing Active table 
source crelstbs.sql

-- create procedures

--commit
--/

