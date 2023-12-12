Rem
Rem
Rem drop.sql
Rem
Rem Copyright (c) 2011,2016, Oracle and/or its affiliates. All rights reserved.
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
BEGIN
   select count(*) into c from user_tables where table_name = upper(TableName);
   IF c = 1 THEN 
      drop_stmt := 'drop table ' || TableName || ' cascade constraints';
      execute immediate drop_stmt;
   END IF;
END;
/

DECLARE
   cnt integer;
BEGIN
   DropTable('ACTIVE');
   DropTable('WEBLOGIC_TIMERS');
   DropTable('WLS_EVENTS');
   DropTable('WLS_HVST');
   DropTable('CHECKPOINTDATA');
   DropTable('STEPSTATUS');
   DropTable('STEPEXECUTIONINSTANCEDATA');
   DropTable('STEPEXECUTIONINSTANCEDATA_TRG');
   DropTable('JOBSTATUS');
   DropTable('JOBINSTANCEDATA');
   DropTable('JOBINSTANCEDATA_TRG');
   DropTable('EXECUTIONINSTANCEDATA');
   DropTable('BEACSS_SCHEMA_VERSION');
   DropTable('BEAPC');
   DropTable('BEAPCM');
   DropTable('BEAPRMP');
   DropTable('BEARM');
   DropTable('BEASAML2_CACHE');
   DropTable('BEASAML2_ENDPOINT');
   DropTable('BEASAML2_IDPPARTNER');
   DropTable('BEASAML2_IDP_AUDIENCEURI');
   DropTable('BEASAML2_IDP_PT_EP');
   DropTable('BEASAML2_IDP_REDIRECTURI');
   DropTable('BEASAML2_SPPARTNER');
   DropTable('BEASAML2_SP_AUDIENCEURI');
   DropTable('BEASAML2_SP_PT_EP');
   DropTable('BEASAMLAP');
   DropTable('BEASAMLAP_AURI');
   DropTable('BEASAMLAP_ITP');
   DropTable('BEASAMLAP_RURI');
   DropTable('BEASAMLRP');
   DropTable('BEASAMLRP_ACP');
   DropTable('BEASAMLRP_AU');
   DropTable('BEAUPC');
   DropTable('BEAWCMCI');
   DropTable('BEAWCRE');
   DropTable('BEAWPCI');
   DropTable('BEAWRCI');
   DropTable('BEAXACMLAP');
   DropTable('BEAXACMLAP_RS');
   DropTable('BEAXACMLRAP');
   DropTable('BEAXACMLRAP_R');
   DropTable('BEAXACMLRAP_RS');

END;
/
drop procedure DropTable;
