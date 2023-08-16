Rem
Rem
Rem drop.sql
Rem
Rem Copyright (c) 2016, Oracle and/or its affiliates. All rights reserved.
Rem All rights reserved.
Rem
Rem    NAME
Rem      drop.sql - Drop weblogic services tables
Rem
Rem    DESCRIPTION
Rem    This file drops the database tables for the repository.
Rem

SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100

CREATE OR REPLACE PROCEDURE DropTable(TableName IN VARCHAR2)
IS
   c int;
   drop_stmt varchar2(100);
   outstr varchar2(80);
BEGIN
   select count(*) into c from user_tables where table_name = upper(TableName);
   outstr := 'matching table names count for ' || TableName || ' = ' || c;
   dbms_output.put_line(outstr);
   IF c = 1 THEN 
      drop_stmt := 'drop table ' || TableName || ' cascade constraints';
      execute immediate drop_stmt;
   END IF;
END;
/

CREATE OR REPLACE PROCEDURE DropView(viewName IN VARCHAR2)
IS
   c int;
   drop_stmt varchar2(100);
   outstr varchar2(80);
BEGIN
   select count(*) into c from USER_EDITIONING_VIEWS_AE where view_name = upper(viewName);
   outstr := 'matching view count for ' || viewName || ' = ' || c;
   dbms_output.put_line(outstr);
   IF c = 1 THEN 
      drop_stmt := 'drop view ' || viewName || ' cascade constraints';
      execute immediate drop_stmt;
      DropTable(viewName || '_');
   END IF;
END;
/

DECLARE
   cnt integer;
BEGIN
   DropView('ACTIVE');
   DropView('WEBLOGIC_TIMERS');
   DropView('WLS_EVENTS');
   DropView('WLS_HVST');
   DropView('CHECKPOINTDATA');
   DropView('STEPSTATUS');
   DropView('STEPEXECUTIONINSTANCEDATA');
   DropView('STEPEXECUTIONINSTANCEDATA_TRG');
   DropView('JOBSTATUS');
   DropView('JOBINSTANCEDATA');
   DropView('JOBINSTANCEDATA_TRG');
   DropView('EXECUTIONINSTANCEDATA');
-- security tables
   DropView('BEACSS_SCHEMA_VERSION');
   DropView('BEAPC');
   DropView('BEAPCM');
   DropView('BEAPRMP');
   DropView('BEARM');
   DropView('BEASAML2_CACHE');
   DropView('BEASAML2_ENDPOINT');
   DropView('BEASAML2_IDPPARTNER');
   DropView('BEASAML2_IDP_AUDIENCEURI');
   DropView('BEASAML2_IDP_PT_EP');
   DropView('BEASAML2_IDP_REDIRECTURI');
   DropView('BEASAML2_SPPARTNER');
   DropView('BEASAML2_SP_AUDIENCEURI');
   DropView('BEASAML2_SP_PT_EP');
   DropView('BEASAMLAP');
   DropView('BEASAMLAP_AURI');
   DropView('BEASAMLAP_ITP');
   DropView('BEASAMLAP_RURI');
   DropView('BEASAMLRP');
   DropView('BEASAMLRP_ACP');
   DropView('BEASAMLRP_AU');
   DropView('BEAUPC');
   DropView('BEAWCMCI');
   DropView('BEAWCRE');
   DropView('BEAWPCI');
   DropView('BEAWRCI');
   DropView('BEAXACMLAP');
   DropView('BEAXACMLAP_RS');
   DropView('BEAXACMLRAP');
   DropView('BEAXACMLRAP_R');
   DropView('BEAXACMLRAP_RS');
END;
/

drop procedure DropTable;
drop procedure DropView;
