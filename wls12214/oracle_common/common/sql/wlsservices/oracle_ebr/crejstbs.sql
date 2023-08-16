-- Copyright (c) 2006,2014, Oracle and/or its affiliates. All rights reserved.
-- All rights reserved. 
--
--
-- crejstbs.sql - create job scheduler tables
-- 
-- NOTES
--    This script is replicated from the same file under oracle folder
--    for EBR support.
--

--SET ECHO OFF;
SET SERVEROUTPUT ON;

DECLARE
 vCtr            Number;
 vSQL            VARCHAR2(2048);
 vcurrSchema     VARCHAR2(256);
 vEdition        VARCHAR2(256);
 changed         Number;
 TOO_MANY_TABLES EXCEPTION;
BEGIN

  changed := 0;

  SELECT sys_context( 'userenv', 'current_schema' ) into vcurrSchema from dual;
  dbms_output.put_line('Current Schema: '||vcurrSchema);

  SELECT SYS_CONTEXT('USERENV', 'CURRENT_EDITION_NAME') INTO vEdition FROM DUAL;
  dbms_output.put_line('Current edition: '|| vEdition);

  SELECT COUNT(*)
  INTO vCtr
  FROM user_tables
  WHERE table_name = 'WEBLOGIC_TIMERS_';

  IF vCtr = 0 THEN
    dbms_output.put_line('    Creating WEBLOGIC_TIMERS_ table');
    vSQL := 'CREATE TABLE "WEBLOGIC_TIMERS_" (
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
    changed := 1;
  END IF;

  -- Check for USER_KEY column and add if necessary (since 12.1.3)
  SELECT COUNT(*)
  INTO vCtr
  FROM user_tab_columns
  WHERE table_name = 'WEBLOGIC_TIMERS_' AND column_name = 'USER_KEY';
  IF vCtr = 0 THEN
    dbms_output.put_line('Creating USER_KEY column in WEBLOGIC_TIMERS_ table');
    vSQL := 'ALTER TABLE WEBLOGIC_TIMERS_ ADD("USER_KEY" VARCHAR2(1000) UNIQUE)';
    EXECUTE IMMEDIATE vSQL;
    changed := 1;
  END IF;

  -- TIMER_MANAGER_NAME column length has been increased in 12.2.1
  vSQL := 'ALTER TABLE WEBLOGIC_TIMERS_ MODIFY("TIMER_MANAGER_NAME" VARCHAR2(500))';
  EXECUTE IMMEDIATE vSQL; 

  -- check if we need to update the editioning view
  SELECT COUNT(*)
    INTO vCtr FROM USER_EDITIONING_VIEWS_AE
    WHERE view_name = 'WEBLOGIC_TIMERS' AND EDITION_NAME = vEdition;
    
  IF vCtr = 0  AND changed > 0 THEN
    dbms_output.put_line('Creating WEBLOGIC_TIMERS editioning view');
    vSQL := 'CREATE OR REPLACE EDITIONING VIEW WEBLOGIC_TIMERS AS SELECT
        TIMER_ID,
        LISTENER,
        START_TIME,
        INTERVAL,
        TIMER_MANAGER_NAME,
        DOMAIN_NAME,
        CLUSTER_NAME,
        USER_KEY
      from WEBLOGIC_TIMERS_';
    EXECUTE IMMEDIATE vSQL;
  ELSE
    dbms_output.put_line('WEBLOGIC_TIMERS view not modified, editioning view not updated ' || vEdition);
  END IF;  
  
END;
/

--SET ECHO 0FF;

