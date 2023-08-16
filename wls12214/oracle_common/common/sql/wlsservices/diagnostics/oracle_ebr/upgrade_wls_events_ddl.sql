Rem Copyright (c) 2013,2014, Oracle and/or its affiliates. All rights reserved.
Rem All rights reserved. 
Rem
Rem    NAME
Rem      upgrade_wls_events_ddl.sql - Upgrade a non-EBR WLS_EVENTS table to an editioned view
Rem
Rem    DESCRIPTION
Rem      Upgrade the WLS_EVENTS tables to use an EBR editioning view in the main
Rem      ORA$BASE edition.  
Rem
Rem    NOTES
Rem      If the WLS_EVENTS table exists, rename it to an internal WLS_EVENTS_ 
Rem      name, and create an editioning view for WLS_EVENTS.  Also re-create the
Rem      sequence trigger on the new table.
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
  WHERE table_name = 'WLS_EVENTS';

  IF vCtr > 1 THEN 
    RAISE TOO_MANY_TABLES;
  ELSIF vCtr > 0 THEN
    dbms_output.put_line('Renaming WLS_EVENTS table to WLS_EVENTS_');
    vSQL := 'RENAME WLS_EVENTS TO WLS_EVENTS_';
    EXECUTE IMMEDIATE vSQL;
    changed := 1;
  ELSE
    dbms_output.put_line('Table WLS_EVENTS does not need to be renamed');
  END IF;

  SELECT COUNT(*) 
    INTO vCtr FROM user_triggers
    WHERE table_name = 'WLS_EVENTS_';

  IF vCtr = 0 AND changed > 0 THEN  
    dbms_output.put_line('Creating or replacing TRG_WLS_EVENTS_INSERT trigger');
    vSQL := 'CREATE OR REPLACE TRIGGER TRG_WLS_EVENTS_INSERT 
    BEFORE INSERT ON WLS_EVENTS_ 
    REFERENCING NEW AS newRow 
    FOR EACH ROW 
    BEGIN 
      IF :newRow.RECORDID IS NULL THEN 
        SELECT SEQ_WLS_EVENTS_RECORDID.nextval INTO :newRow.RECORDID FROM DUAL; 
      END IF;
    END;';
    EXECUTE IMMEDIATE vSQL;
  END IF;

  SELECT COUNT(*)
    INTO vCtr FROM USER_EDITIONING_VIEWS_AE
    WHERE view_name = 'WLS_EVENTS' AND EDITION_NAME = vEdition;

  IF vCtr = 0  AND changed > 0 THEN  
    dbms_output.put_line('Creating WLS_EVENTS editioning view');
    vSQL := 'CREATE OR REPLACE EDITIONING VIEW WLS_EVENTS AS SELECT
      RECORDID, 
      TIMESTAMP, 
      CONTEXTID, 
      TXID, 
      USERID, 
      TYPE, 
      DOMAIN, 
      SERVER, 
      SCOPE, 
      MODULE, 
      MONITOR, 
      FILENAME, 
      LINENUM, 
      CLASSNAME, 
      METHODNAME, 
      METHODDSC, 
      ARGUMENTS, 
      RETVAL, 
      PAYLOAD, 
      CTXPAYLOAD, 
      DYES,
      THREADNAME
     from WLS_EVENTS_';
    EXECUTE IMMEDIATE vSQL;
  ELSE
    dbms_output.put_line('WLS_EVENTS Editioning view already exists for edition ' || vEdition);
  END IF;  
  
END;
/

--SET ECHO 0FF;
