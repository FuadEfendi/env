Rem Copyright (c) 2013,2014, Oracle and/or its affiliates. All rights reserved.
Rem All rights reserved. 
Rem
Rem    NAME
Rem      wldf_ebr_upgrade_ddl.sql - Upgrade a non-EBR WLDF JDBC archive to an 
Rem      EBR-enabled view; this script is intended to be called by the 
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
Rem      If the WLS_EVENTS table exists, rename it to an internal WLS_EVENTS_ 
Rem      name, and create an editioning view for WLS_EVENTS.  Also re-create the
Rem      sequence trigger on the new table.
Rem

SET SERVEROUTPUT ON;
--SET ECHO OFF

ALTER SESSION SET EDITION = ORA$BASE;
@@upgrade_wls_events_ddl.sql
@@upgrade_wls_hvst_ddl.sql

ALTER SESSION SET EDITION = &&1;
@@wls_events_ddl.sql
@@wls_hvst_ddl.sql

--SET ECHO OFF
