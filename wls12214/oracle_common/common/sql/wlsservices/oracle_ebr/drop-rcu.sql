Rem
Rem
Rem drop-rcu.sql
Rem
Rem Copyright (c) 2016, Oracle and/or its affiliates. All rights reserved.
Rem
Rem    NAME
Rem      drop-rcu.sql - RCU SQL script to drop Weblogic Services tables. 
Rem
Rem    DESCRIPTION
Rem    This file drops the database tables for weblogic services. To
Rem    be used only by RCU.
Rem

SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100

ALTER SESSION SET CURRENT_SCHEMA=&&1;
@@drop.sql 

Rem If there were any compilations problems this will spit out the 
Rem the errors. uncomment to get errors.
Rem show errors

EXIT;
