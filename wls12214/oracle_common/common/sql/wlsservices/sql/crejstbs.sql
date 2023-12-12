-- Copyright (c) 2006,2014, Oracle and/or its affiliates. All rights reserved.
-- All rights reserved. 
--
--
-- crejstbs.sql - create job scheduler tables for oracle
-- 
-- NOTES
--    Any changes made to this script should be replicated to the same file
--    under the oracle_ebr folder for creating the EBR-enabled schema tables.
--

SET VERIFY OFF


REM Create weblogic services tables for job scheduler

SET SERVEROUTPUT ON;

DECLARE
 vCtr     Number;
 vSQL     VARCHAR2(2000);
 vcurrSchema VARCHAR2(256);
BEGIN

  SELECT sys_context( 'userenv', 'current_schema' ) into vcurrSchema from dual;
  dbms_output.put_line('Current Schema: '||vcurrSchema);

  SELECT COUNT(*)
  INTO vCtr
  FROM user_tables
  WHERE table_name = 'WEBLOGIC_TIMERS';

  IF vCtr = 0 THEN
    dbms_output.put_line('Creating WEBLOGIC_TIMERS table');
    vSQL := 'CREATE TABLE "WEBLOGIC_TIMERS" (
    "TIMER_ID" VARCHAR2(100) NOT NULL,
    "LISTENER" BLOB NOT NULL,
    "START_TIME" NUMBER NOT NULL,
    "INTERVAL" NUMBER NOT NULL,
    "TIMER_MANAGER_NAME" VARCHAR2(500) NOT NULL,
    "DOMAIN_NAME" VARCHAR2(100) NOT NULL,
    "CLUSTER_NAME" VARCHAR2(100) NOT NULL,
    "USER_KEY" VARCHAR2(1000) UNIQUE,
    PRIMARY KEY (TIMER_ID, CLUSTER_NAME, DOMAIN_NAME)
   )';
   EXECUTE IMMEDIATE vSQL;
  END IF;

  -- Check for USER_KEY column and add if necessary (since 12.1.3)
  SELECT COUNT(*)
  INTO vCtr
  FROM user_tab_columns
  WHERE table_name = 'WEBLOGIC_TIMERS' AND column_name = 'USER_KEY';
  IF vCtr = 0 THEN
    dbms_output.put_line('Creating USER_KEY column in WEBLOGIC_TIMERS table');
    vSQL := 'ALTER TABLE WEBLOGIC_TIMERS ADD("USER_KEY" VARCHAR2(1000) UNIQUE)';
    EXECUTE IMMEDIATE vSQL;
  END IF;

  -- TIMER_MANAGER_NAME column length has been increased in 12.2.1
  vSQL := 'ALTER TABLE WEBLOGIC_TIMERS MODIFY("TIMER_MANAGER_NAME" VARCHAR2(500))';
  EXECUTE IMMEDIATE vSQL; 


END;
/


