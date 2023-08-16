--
--
-- droptab-consolidated-rcu.sql
--
-- Copyright (c) 2006,2014, Oracle and/or its affiliates. All rights reserved.
--
--    NAME
--    droptab-consolidated-rcu.SQL - Drop Login, User and Schema
--
--    DESCRIPTION
--    Drop tables that were created for Weblogic core.
--    It has to be run from an administrator account.  This script is supposed
--    to be used by RCU only.
--

go
SET NOCOUNT ON
go

-- Assign database name which is passed in as V1 to DATABASE_NAE
:SETVAR DATABASE_NAME  $(v1)
go

-- Assign user name which is passed in as V2 to SCHEMA_USER
:SETVAR SCHEMA_USER  $(v2)
go

use $(DATABASE_NAME)
go 

IF OBJECT_ID('dropTable', 'P') IS NOT NULL
  EXEC ('DROP PROC dropTable')
go

CREATE PROCEDURE dropTable @dbName SYSNAME, @schemaName SYSNAME, @tableName SYSNAME
AS
    DECLARE @SQL NVARCHAR(MAX);
    IF OBJECT_ID(''+@schemaName + '.' + @tableName+'','U') IS NOT NULL
    BEGIN

    SET @SQL = 'DROP TABLE ' + @schemaName + '.' + @tableName
    --SET @SQL = 'IF OBJECT_ID(''' +  @dbName + '.' + @schemaName + '.' + @tableName + ''',''U'') IS NOT NULL DROP TABLE ' + @dbName + '.' + @schemaName + '.' + @tableName; 
    PRINT @SQL;
    EXEC sp_executesql @SQL;
    END
GO

EXEC dropTable @dbName=N'$(DATABASE_NAME)', @schemaName=N'$(SCHEMA_USER)', @tableName=N'ACTIVE'
EXEC dropTable @dbName=N'$(DATABASE_NAME)', @schemaName=N'$(SCHEMA_USER)', @tableName=N'WEBLOGIC_TIMERS'
EXEC dropTable @dbName=N'$(DATABASE_NAME)', @schemaName=N'$(SCHEMA_USER)', @tableName=N'WLS_EVENTS'
EXEC dropTable @dbName=N'$(DATABASE_NAME)', @schemaName=N'$(SCHEMA_USER)', @tableName=N'WLS_HVST'
EXEC dropTable @dbName=N'$(DATABASE_NAME)', @schemaName=N'$(SCHEMA_USER)', @tableName=N'CHECKPOINTDATA'
EXEC dropTable @dbName=N'$(DATABASE_NAME)', @schemaName=N'$(SCHEMA_USER)', @tableName=N'STEPSTATUS'
EXEC dropTable @dbName=N'$(DATABASE_NAME)', @schemaName=N'$(SCHEMA_USER)', @tableName=N'STEPEXECUTIONINSTANCEDATA'
EXEC dropTable @dbName=N'$(DATABASE_NAME)', @schemaName=N'$(SCHEMA_USER)', @tableName=N'STEPEXECUTIONINSTANCEDATA_TRG'
EXEC dropTable @dbName=N'$(DATABASE_NAME)', @schemaName=N'$(SCHEMA_USER)', @tableName=N'JOBSTATUS'
EXEC dropTable @dbName=N'$(DATABASE_NAME)', @schemaName=N'$(SCHEMA_USER)', @tableName=N'EXECUTIONINSTANCEDATA'
EXEC dropTable @dbName=N'$(DATABASE_NAME)', @schemaName=N'$(SCHEMA_USER)', @tableName=N'JOBINSTANCEDATA'
EXEC dropTable @dbName=N'$(DATABASE_NAME)', @schemaName=N'$(SCHEMA_USER)', @tableName=N'JOBINSTANCEDATA_TRG'
EXEC dropTable @dbName=N'$(DATABASE_NAME)', @schemaName=N'$(SCHEMA_USER)', @tableName=N'BEACSS_SCHEMA_VERSION'
EXEC dropTable @dbName=N'$(DATABASE_NAME)', @schemaName=N'$(SCHEMA_USER)', @tableName=N'BEAPC'
EXEC dropTable @dbName=N'$(DATABASE_NAME)', @schemaName=N'$(SCHEMA_USER)', @tableName=N'BEAPCM'
EXEC dropTable @dbName=N'$(DATABASE_NAME)', @schemaName=N'$(SCHEMA_USER)', @tableName=N'BEAPRMP'
EXEC dropTable @dbName=N'$(DATABASE_NAME)', @schemaName=N'$(SCHEMA_USER)', @tableName=N'BEARM'
EXEC dropTable @dbName=N'$(DATABASE_NAME)', @schemaName=N'$(SCHEMA_USER)', @tableName=N'BEASAML2_CACHE'
EXEC dropTable @dbName=N'$(DATABASE_NAME)', @schemaName=N'$(SCHEMA_USER)', @tableName=N'BEASAML2_ENDPOINT'
EXEC dropTable @dbName=N'$(DATABASE_NAME)', @schemaName=N'$(SCHEMA_USER)', @tableName=N'BEASAML2_IDPPARTNER'
EXEC dropTable @dbName=N'$(DATABASE_NAME)', @schemaName=N'$(SCHEMA_USER)', @tableName=N'BEASAML2_IDP_AUDIENCEURI'
EXEC dropTable @dbName=N'$(DATABASE_NAME)', @schemaName=N'$(SCHEMA_USER)', @tableName=N'BEASAML2_IDP_PT_EP'
EXEC dropTable @dbName=N'$(DATABASE_NAME)', @schemaName=N'$(SCHEMA_USER)', @tableName=N'BEASAML2_IDP_REDIRECTURI'
EXEC dropTable @dbName=N'$(DATABASE_NAME)', @schemaName=N'$(SCHEMA_USER)', @tableName=N'BEASAML2_SPPARTNER'
EXEC dropTable @dbName=N'$(DATABASE_NAME)', @schemaName=N'$(SCHEMA_USER)', @tableName=N'BEASAML2_SP_AUDIENCEURI'
EXEC dropTable @dbName=N'$(DATABASE_NAME)', @schemaName=N'$(SCHEMA_USER)', @tableName=N'BEASAML2_SP_PT_EP'
EXEC dropTable @dbName=N'$(DATABASE_NAME)', @schemaName=N'$(SCHEMA_USER)', @tableName=N'BEASAMLAP'
EXEC dropTable @dbName=N'$(DATABASE_NAME)', @schemaName=N'$(SCHEMA_USER)', @tableName=N'BEASAMLAP_AURI'
EXEC dropTable @dbName=N'$(DATABASE_NAME)', @schemaName=N'$(SCHEMA_USER)', @tableName=N'BEASAMLAP_ITP'
EXEC dropTable @dbName=N'$(DATABASE_NAME)', @schemaName=N'$(SCHEMA_USER)', @tableName=N'BEASAMLAP_RURI'
EXEC dropTable @dbName=N'$(DATABASE_NAME)', @schemaName=N'$(SCHEMA_USER)', @tableName=N'BEASAMLRP'
EXEC dropTable @dbName=N'$(DATABASE_NAME)', @schemaName=N'$(SCHEMA_USER)', @tableName=N'BEASAMLRP_ACP'
EXEC dropTable @dbName=N'$(DATABASE_NAME)', @schemaName=N'$(SCHEMA_USER)', @tableName=N'BEASAMLRP_AU'
EXEC dropTable @dbName=N'$(DATABASE_NAME)', @schemaName=N'$(SCHEMA_USER)', @tableName=N'BEAUPC'
EXEC dropTable @dbName=N'$(DATABASE_NAME)', @schemaName=N'$(SCHEMA_USER)', @tableName=N'BEAWCMCI'
EXEC dropTable @dbName=N'$(DATABASE_NAME)', @schemaName=N'$(SCHEMA_USER)', @tableName=N'BEAWCRE'
EXEC dropTable @dbName=N'$(DATABASE_NAME)', @schemaName=N'$(SCHEMA_USER)', @tableName=N'BEAWPCI'
EXEC dropTable @dbName=N'$(DATABASE_NAME)', @schemaName=N'$(SCHEMA_USER)', @tableName=N'BEAWRCI'
EXEC dropTable @dbName=N'$(DATABASE_NAME)', @schemaName=N'$(SCHEMA_USER)', @tableName=N'BEAXACMLAP'
EXEC dropTable @dbName=N'$(DATABASE_NAME)', @schemaName=N'$(SCHEMA_USER)', @tableName=N'BEAXACMLAP_RS'
EXEC dropTable @dbName=N'$(DATABASE_NAME)', @schemaName=N'$(SCHEMA_USER)', @tableName=N'BEAXACMLRAP'
EXEC dropTable @dbName=N'$(DATABASE_NAME)', @schemaName=N'$(SCHEMA_USER)', @tableName=N'BEAXACMLRAP_R'
EXEC dropTable @dbName=N'$(DATABASE_NAME)', @schemaName=N'$(SCHEMA_USER)', @tableName=N'BEAXACMLRAP_RS'
GO


DROP PROC dropTable;
GO
