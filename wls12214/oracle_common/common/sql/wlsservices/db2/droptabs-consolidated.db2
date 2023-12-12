-- Copyright (c) 2012,2016, Oracle and/or its affiliates. All rights reserved.
-- All rights reserved. 
--
-- droptabs-consolidated.db2 - Drop Weblogic Services schema objects used by RCU
--
-- Assign schema name which is passed in as $1 to SCHEMA_NAME
define SCHEMA_NAME     =  $1 
@

SET SCHEMA=$SCHEMA_NAME
@

SET PATH=SYSTEM PATH, $SCHEMA_NAME
@

-- Drop a designated table
CREATE PROCEDURE dropTable (IN SCHEMA_NAME VARCHAR(200), IN TABLE_NAME VARCHAR(200))
LANGUAGE SQL
BEGIN
   DECLARE V_EXISTS VARCHAR(100);

   SET V_EXISTS = (SELECT 1 FROM SYSCAT.TABLES WHERE TABSCHEMA = SCHEMA_NAME AND TABNAME = TABLE_NAME);
   IF (V_EXISTS IS NOT NULL) THEN 
      EXECUTE IMMEDIATE 'DROP TABLE ' || SCHEMA_NAME || '.' || TABLE_NAME;
   END IF;
END
@

-- Perform WLS user drop for consolidated
CREATE PROCEDURE dropSchemaTables( IN DROPSCHEMA VARCHAR(200))
LANGUAGE SQL
BEGIN
      -- drop the tables and views
      call dropTable(DROPSCHEMA,'ACTIVE');
      call dropTable(DROPSCHEMA,'ACTIVE');
      call dropTable(DROPSCHEMA,'WEBLOGIC_TIMERS');
      call dropTable(DROPSCHEMA,'WLS_EVENTS');
      call dropTable(DROPSCHEMA,'WLS_HVST');
      
      -- drop batch tables
      call dropTable(DROPSCHEMA,'CHECKPOINTDATA');
      call dropTable(DROPSCHEMA,'EXECUTIONINSTANCEDATA');
      call dropTable(DROPSCHEMA,'JOBINSTANCEDATA');
      call dropTable(DROPSCHEMA,'JOBINSTANCEDATA_TRG');
      call dropTable(DROPSCHEMA,'JOBSTATUS');
      call dropTable(DROPSCHEMA,'STEPEXECUTIONINSTANCEDATA');
      call dropTable(DROPSCHEMA,'STEPEXECUTIONINSTANCEDATA_TRG');
      call dropTable(DROPSCHEMA,'STEPSTATUS');

      -- drop security tables
      call dropTable(DROPSCHEMA,'BEACSS_SCHEMA_VERSION');
      call dropTable(DROPSCHEMA,'BEAPC');
      call dropTable(DROPSCHEMA,'BEAPCM');
      call dropTable(DROPSCHEMA,'BEAPRMP');
      call dropTable(DROPSCHEMA,'BEARM');
      call dropTable(DROPSCHEMA,'BEASAML2_CACHE');
      call dropTable(DROPSCHEMA,'BEASAML2_ENDPOINT');
      call dropTable(DROPSCHEMA,'BEASAML2_IDPPARTNER');
      call dropTable(DROPSCHEMA,'BEASAML2_IDP_AUDIENCEURI');
      call dropTable(DROPSCHEMA,'BEASAML2_IDP_PT_EP');
      call dropTable(DROPSCHEMA,'BEASAML2_IDP_REDIRECTURI');
      call dropTable(DROPSCHEMA,'BEASAML2_SPPARTNER');
      call dropTable(DROPSCHEMA,'BEASAML2_SP_AUDIENCEURI');
      call dropTable(DROPSCHEMA,'BEASAML2_SP_PT_EP');
      call dropTable(DROPSCHEMA,'BEASAMLAP');
      call dropTable(DROPSCHEMA,'BEASAMLAP_AURI');
      call dropTable(DROPSCHEMA,'BEASAMLAP_ITP');
      call dropTable(DROPSCHEMA,'BEASAMLAP_RURI');
      call dropTable(DROPSCHEMA,'BEASAMLRP');
      call dropTable(DROPSCHEMA,'BEASAMLRP_ACP');
      call dropTable(DROPSCHEMA,'BEASAMLRP_AU');
      call dropTable(DROPSCHEMA,'BEAUPC');
      call dropTable(DROPSCHEMA,'BEAWCMCI');
      call dropTable(DROPSCHEMA,'BEAWCRE');
      call dropTable(DROPSCHEMA,'BEAWPCI');
      call dropTable(DROPSCHEMA,'BEAWRCI');
      call dropTable(DROPSCHEMA,'BEAXACMLAP');
      call dropTable(DROPSCHEMA,'BEAXACMLAP_RS');
      call dropTable(DROPSCHEMA,'BEAXACMLRAP');
      call dropTable(DROPSCHEMA,'BEAXACMLRAP_R');
      call dropTable(DROPSCHEMA,'BEAXACMLRAP_RS');
      
END
@

call dropSchemaTables('$SCHEMA_NAME')
@
drop procedure dropTable
@
