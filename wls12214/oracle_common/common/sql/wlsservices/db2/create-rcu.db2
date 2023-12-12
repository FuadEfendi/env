--
--
-- create-rcu.db2
--
-- Copyright (c) 2012,2014, Oracle and/or its affiliates. All rights reserved.
-- All rights reserved. 
--
--    NAME
--     create-rcu.db2 - create repository for Weblogic Services.
--
--    DESCRIPTION
--    This file creates the database schema for the repository. To
--    be used only by RCU.
--
--    NOTES
--

SET SCHEMA $1@

-- We know that the current schema is the schema that will be used for 
-- Weblogic Services.

-- create tables for Weblogic Services - core services
--
!core_tables.db2 $4

-- Set up the WLDF tables in the schema
--
!../diagnostics/db2/wldf_tables.db2

-- Set up JSR 352 (JavaEE Batch) tables in the schema
!../batch/db2/jsr352-db2.ddl

--commit
--@

