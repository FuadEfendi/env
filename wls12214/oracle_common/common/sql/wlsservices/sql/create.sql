Rem
Rem
Rem create.sql
Rem
Rem Copyright (c) 2011,2014, Oracle and/or its affiliates. All rights reserved.
Rem All rights reserved. 
Rem
Rem    NAME
Rem      create.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem    This file creates the database schema for the repository.
Rem
Rem    NOTES
Rem    The database user must have grant to create sequence in order to
Rem    successfully use the weblogic services features.
Rem

SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100

Rem Creating the tables and views
@@crejstbs
@@crelstbs &&1
@@../diagnostics/oracle/wls_events_ddl.sql
@@../diagnostics/oracle/wls_hvst_ddl.sql
@@../batch/oracle/job_instance_data_ddl.sql
@@../batch/oracle/execution_instance_data_ddl.sql
@@../batch/oracle/step_execution_instance_data_ddl.sql
@@../batch/oracle/job_status_ddl.sql
@@../batch/oracle/step_status_ddl.sql
@@../batch/oracle/checkpoint_data_ddl.sql

EXIT;
