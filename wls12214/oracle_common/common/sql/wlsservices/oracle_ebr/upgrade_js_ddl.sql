Rem Copyright (c) 2014, Oracle and/or its affiliates. All rights reserved.
Rem All rights reserved. 
Rem
Rem    NAME
Rem      upgrade_js_ddl.sql - Upgrade a non-EBR WEBLOGIC_TIMERS table
Rem                           to an editioned view
Rem
Rem    DESCRIPTION
Rem      Upgrade the WEBLOGIC_TIMERS tables to use an EBR editioning view 
Rem      in the main ORA$BASE edition.  
Rem
Rem    NOTES
Rem      If the WEBLOGIC_TIMERS table exists, rename it to an internal 
Rem      WEBLOGIC_TIMERS_ name, and create an editioning view for
Rem      WEBLOGIC_TIMERS.
Rem

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
  WHERE table_name = 'WEBLOGIC_TIMERS';

  IF vCtr > 1 THEN 
    RAISE TOO_MANY_TABLES;
  ELSIF vCtr > 0 THEN
    dbms_output.put_line('Renaming WEBLOGIC_TIMERS table to WEBLOGIC_TIMERS_');
    vSQL := 'RENAME WEBLOGIC_TIMERS TO WEBLOGIC_TIMERS_';
    EXECUTE IMMEDIATE vSQL;
    changed := 1;
  ELSE
    dbms_output.put_line('Table WEBLOGIC_TIMERS does not need to be renamed');
  END IF;

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
    dbms_output.put_line('WEBLOGIC_TIMERS Editioning view already exists for edition ' || vEdition);
  END IF;  
  
END;
/

--SET ECHO 0FF;
