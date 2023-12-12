Rem Copyright (c) 2014, Oracle and/or its affiliates. All rights reserved.
Rem All rights reserved. 
Rem
Rem    NAME
Rem      core_ebr_upgrade_ddl.sql - Upgrade a non-EBR WLS core JDBC archive 
Rem      to an EBR-enabled view; this script is intended to be called by the 
Rem      Upgrade Assistant plugin for the WLS component.
Rem
Rem    DESCRIPTION
Rem      Primarily to support the 12.1.2 RCU-installed schema to an EBR-enabled 
Rem      set of views.  Accepts the Edition name chosen by the user as an 
Rem      argument.
Rem
Rem      First, the tables are renamed and editioned views are created in the
Rem      base ORA$BASE edition; then any required table upgrades are run in the
Rem      chosen edition.
Rem
Rem    NOTES
Rem      If the WEBLOGIC_TIMERS table exists, rename it to an internal  
Rem      WEBLOGIC_TIMERS_ name, and create an editioning view for
Rem      WEBLOGIC_TIMERS. 
Rem

SET SERVEROUTPUT ON;
--SET ECHO OFF

ALTER SESSION SET EDITION = ORA$BASE;
@@upgrade_js_ddl.sql

ALTER SESSION SET EDITION = &&1;
@@crejstbs.sql

--SET ECHO OFF
