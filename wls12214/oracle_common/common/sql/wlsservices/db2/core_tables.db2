--
--
-- create-rcu.db2
--
-- Copyright (c) 2012,2014, Oracle and/or its affiliates. All rights reserved.
-- All rights reserved.
--
--    NAME
--     core-tables.db2 - create or upgrade core tables for Weblogic Services.
--
--    DESCRIPTION
--    This file creates or upgrade the database schema for the WLS core
--    tables. The script is used by RCU and UA tools.
--
--    NOTES
--

--SET SCHEMA=$1
--@

CREATE OR REPLACE PROCEDURE executeCoreStatement(in coreStatement varchar(2056))
BEGIN
  EXECUTE IMMEDIATE coreStatement; 
END
@

CREATE OR REPLACE PROCEDURE createSchedulerTable(in tablename varchar(100))
BEGIN
  DECLARE sqlvar varchar(4096);

  SET sqlvar = 'CREATE TABLE ' || tablename || ' (
    TIMER_ID VARCHAR(100) NOT NULL,
    LISTENER BLOB(32M) NOT NULL,
    START_TIME BIGINT NOT NULL,
    INTERVAL BIGINT NOT NULL,
    TIMER_MANAGER_NAME VARCHAR(500) NOT NULL,
    DOMAIN_NAME VARCHAR(100) NOT NULL,
    CLUSTER_NAME VARCHAR(100) NOT NULL,
    USER_KEY VARCHAR(1000),
    PK INT NOT NULL GENERATED ALWAYS AS IDENTITY,
    IDX INT GENERATED ALWAYS AS (CASE WHEN USER_KEY IS NULL THEN PK ELSE NULL END),
    PRIMARY KEY (TIMER_ID, CLUSTER_NAME, DOMAIN_NAME)
  )';
  call executeCoreStatement(sqlvar);
END
@

CREATE OR REPLACE PROCEDURE createSchedulerIndex()
BEGIN
  DECLARE sqlvar varchar(2048);
 
  SET sqlvar = 'CREATE UNIQUE INDEX WEBLOGIC_TIMERS_IDX
    ON WEBLOGIC_TIMERS (USER_KEY, IDX)';

  call executeCoreStatement(sqlvar);
END
@

-- Create WEBLOGIC_TIMERS table if not yet exist
BEGIN ATOMIC
  DECLARE schemaName varchar(256); 
  DECLARE sqlvar varchar(4096);

  SET schemaName = CURRENT SCHEMA;

  VALUES 'Schema is ' || schemaName;

  IF (SELECT COUNT(*) FROM SYSCAT.TABLES WHERE 
        TABSCHEMA = schemaName AND TABNAME = 'WEBLOGIC_TIMERS') = 0 
  THEN
    call createSchedulerTable('WEBLOGIC_TIMERS');
    call createSchedulerIndex();
  END IF;
        
END@

-- TIMER_MANAGER_NAME column length has been increased in 12.2.1.
-- Encure that the column has the new longer length
BEGIN ATOMIC
  DECLARE schemaName varchar(256);
  DECLARE sqlvar varchar(4096);
  SET schemaName = CURRENT SCHEMA;

  VALUES 'Schema is ' || schemaName;

  SET sqlvar = 'ALTER TABLE WEBLOGIC_TIMERS ALTER COLUMN TIMER_MANAGER_NAME SET DATA TYPE VARCHAR(500)';
  call executeCoreStatement(sqlvar);

END
@

-- Check WEBLOGIC_TIMERS table and start upgrade if schema before 12.1.3
BEGIN ATOMIC
  DECLARE schemaName varchar(256); 
  DECLARE sqlvar varchar(4096);
  SET schemaName = CURRENT SCHEMA;

  VALUES 'Schema is ' || schemaName;

  -- Check for USER_KEY column (since 12.1.3) and add if necessary.
  -- First step is to rename existing table to WEBLOGIC_TIMERS_
  -- and then create the new table
  IF (SELECT COUNT(*) FROM SYSCAT.COLUMNS 
      WHERE TABSCHEMA = schemaName AND TABNAME = 'WEBLOGIC_TIMERS' 
      AND COLNAME ='USER_KEY') = 0 
  THEN
      SET sqlvar = 'RENAME WEBLOGIC_TIMERS TO WEBLOGIC_TIMERS_';
      call executeCoreStatement(sqlvar);
      call createSchedulerTable('WEBLOGIC_TIMERS');
      call createSchedulerIndex();
  END IF;  

END
@

-- Continue upgrading process
BEGIN ATOMIC
  DECLARE schemaName varchar(256);
  DECLARE sqlvar varchar(4096);
  SET schemaName = CURRENT SCHEMA;

  VALUES 'Schema is ' || schemaName;

  -- if WEBLOGIC_TIMERS_ table exist, ie, we are upgrading
  -- to 12.1.3 schema
  -- Copy existing data to upgraded WEBLOGIC_TIMERS table
  IF (SELECT COUNT(*) FROM SYSCAT.TABLES
      WHERE TABSCHEMA = schemaName AND TABNAME = 'WEBLOGIC_TIMERS_') > 0
  THEN
      SET sqlvar = 'INSERT INTO WEBLOGIC_TIMERS
        (TIMER_ID, LISTENER, START_TIME, INTERVAL,
         TIMER_MANAGER_NAME, DOMAIN_NAME, CLUSTER_NAME)
        SELECT TIMER_ID, LISTENER, START_TIME, INTERVAL,
          TIMER_MANAGER_NAME, DOMAIN_NAME,
          CLUSTER_NAME
        FROM WEBLOGIC_TIMERS_';
      call executeCoreStatement(sqlvar);
  END IF;

END
@

-- Clean up old, renamed WEBLOGIC_TIMER table
BEGIN ATOMIC
  DECLARE schemaName varchar(256);
  DECLARE sqlvar varchar(4096);
  SET schemaName = CURRENT SCHEMA;

  VALUES 'Schema is ' || schemaName;

  IF (SELECT COUNT(*) FROM SYSCAT.TABLES
      WHERE TABSCHEMA = schemaName AND TABNAME = 'WEBLOGIC_TIMERS_') > 0
  THEN
      SET sqlvar = 'DROP TABLE WEBLOGIC_TIMERS_';
      call executeCoreStatement(sqlvar);
  END IF;

END
@

define ADDITIONAL_SCHEMA=$1
@

-- Create ACTIVE table if necessary
BEGIN ATOMIC
  DECLARE schemaName varchar(256); 
  DECLARE sqlvar varchar(4096);

  SET schemaName = '$ADDITIONAL_SCHEMA';

  VALUES 'Schema is ' || schemaName;

  IF (SELECT COUNT(*) FROM SYSCAT.TABLES WHERE 
        TABSCHEMA = schemaName AND TABNAME = 'ACTIVE') = 0 
  THEN
    SET sqlvar = 'CREATE TABLE ' || schemaName || '.ACTIVE (
        SERVER VARCHAR(255) NOT NULL,
        INSTANCE VARCHAR(255) NOT NULL,
        DOMAINNAME VARCHAR(255) NOT NULL,
        CLUSTERNAME VARCHAR(255) NOT NULL,
        TIMEOUT TIMESTAMP,
        PRIMARY KEY (SERVER, DOMAINNAME, CLUSTERNAME)
      )';
      call executeCoreStatement(sqlvar);
    END IF;
        
END@

DROP PROCEDURE executeCoreStatement
@
DROP PROCEDURE createSchedulerTable
@
DROP PROCEDURE createSchedulerIndex
@

