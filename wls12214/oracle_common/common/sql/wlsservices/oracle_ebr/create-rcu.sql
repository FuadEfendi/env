Rem
Rem create-rcu.sql
Rem
Rem Copyright (c) 2006,2014, Oracle and/or its affiliates. All rights reserved.
Rem All rights reserved. 
Rem
Rem    NAME
Rem      create-rcu.sql - RCU SQL script to create EBR-enabled schema for
Rem                       Weblogic services. 
Rem
Rem    DESCRIPTION
Rem    This file creates the EBR-enabled database schema for Weblogic services.
Rem    To be used only by RCU.
Rem
Rem    NOTES
Rem    The first parameter is the schema user, the second parameter is 
Rem    the edition name.
Rem

SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100

ALTER SESSION SET CURRENT_SCHEMA=&&1;
ALTER SESSION SET EDITION=&&2;

Rem Create Weblogic services database objects

Rem Creating the tables and views for EBR-enabled schema
Rem NOTE: Minimum Database version required - Oracle 11.2
@@crejstbs
@@crelstbs &&3
@@../diagnostics/oracle_ebr/wls_events_ddl.sql
@@../diagnostics/oracle_ebr/wls_hvst_ddl.sql
@@../batch/oracle_ebr/job_instance_data_ddl.sql
@@../batch/oracle_ebr/execution_instance_data_ddl.sql
@@../batch/oracle_ebr/step_execution_instance_data_ddl.sql
@@../batch/oracle_ebr/job_status_ddl.sql
@@../batch/oracle_ebr/step_status_ddl.sql
@@../batch/oracle_ebr/checkpoint_data_ddl.sql

Rem If there were any compilations problems this will spit out the 
Rem the errors. uncomment to get errors.
Rem show errors

EXIT;
