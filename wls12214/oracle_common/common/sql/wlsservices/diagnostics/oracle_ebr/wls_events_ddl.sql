Rem Copyright (c) 2013,2014, Oracle and/or its affiliates. All rights reserved.
Rem All rights reserved. 
Rem
Rem    NAME
Rem      wls_events_ddl.sql - Create and/or upgrade an editioned WLS_EVENTS view
Rem
Rem    DESCRIPTION
Rem
Rem    NOTES
Rem      Creates an internal WLS_EVENTS_ table and supporting objects, then 
Rem      creates an editioning view for WLS_EVENTS.  
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
  WHERE table_name = 'WLS_EVENTS_';
 
  IF vCtr = 0 THEN
    dbms_output.put_line('    Creating WLS_EVENTS_ table');
    vSQL := 'CREATE TABLE "WLS_EVENTS_" ( 
        "RECORDID" NUMBER(20,0) DEFAULT NULL,  
        "TIMESTAMP" NUMBER(20,0) DEFAULT NULL, 
        "CONTEXTID" VARCHAR2(250 BYTE) DEFAULT NULL, 
        "TXID" VARCHAR2(250 BYTE) DEFAULT NULL, 
        "USERID" VARCHAR2(250 BYTE) DEFAULT NULL, 
        "TYPE" VARCHAR2(250 BYTE) DEFAULT NULL, 
        "DOMAIN" VARCHAR2(250 BYTE) DEFAULT NULL, 
        "SERVER" VARCHAR2(250 BYTE) DEFAULT NULL, 
        "SCOPE" VARCHAR2(250 BYTE) DEFAULT NULL, 
        "MODULE" VARCHAR2(250 BYTE) DEFAULT NULL,  
        "MONITOR" VARCHAR2(250 BYTE) DEFAULT NULL,  
        "FILENAME" VARCHAR2(250 BYTE) DEFAULT NULL,  
        "LINENUM" NUMBER(10,0) DEFAULT NULL,  
        "CLASSNAME" VARCHAR2(250 BYTE) DEFAULT NULL,  
        "METHODNAME" VARCHAR2(250 BYTE) DEFAULT NULL,  
        "METHODDSC" VARCHAR2(4000 BYTE) DEFAULT NULL,  
        "ARGUMENTS" CLOB DEFAULT NULL,  
        "RETVAL" VARCHAR2(4000 BYTE) DEFAULT NULL,  
        "PAYLOAD" BLOB DEFAULT NULL,  
        "CTXPAYLOAD" VARCHAR2(4000 BYTE) DEFAULT NULL,  
        "DYES" NUMBER(20,0) DEFAULT NULL,  
        "THREADNAME" VARCHAR2(250 BYTE) DEFAULT NULL,
        "PARTITION_ID" VARCHAR2(250 BYTE) DEFAULT NULL,
        "PARTITION_NAME" VARCHAR2(250 BYTE) DEFAULT NULL
         )';
    --dbms_output.put_line('      vSQL:= ' || vSQL);
    EXECUTE IMMEDIATE vSQL;
    vSQL := 'CREATE UNIQUE INDEX WLS_EVENTS_RECORD_IDX ON WLS_EVENTS_(RECORDID)';
    dbms_output.put_line('      vSQL:= ' || vSQL);
    EXECUTE IMMEDIATE vSQL;
    vSQL := 'CREATE INDEX WLS_EVENTS_TS_IDX ON WLS_EVENTS_(TIMESTAMP)';
    dbms_output.put_line('      vSQL:= ' || vSQL);
    EXECUTE IMMEDIATE vSQL;
    changed := 1;
  END IF;

  -- Check for THREADNAME column and add if necessary (10.3.x)
  SELECT COUNT(*)
  INTO vCtr
  FROM user_tab_columns
  WHERE table_name = 'WLS_EVENTS_' AND column_name = 'THREADNAME';
  IF vCtr = 0 THEN
    dbms_output.put_line('Creating THREADNAME column in WLS_EVENTS_ table');
    vSQL := 'ALTER TABLE WLS_EVENTS_ ADD("THREADNAME" VARCHAR2(250 BYTE) DEFAULT NULL)';
    --dbms_output.put_line('vSQL:= ' || vSQL);
    EXECUTE IMMEDIATE vSQL;  
    changed := 1;
  END IF;

  -- Check for PARTITION_ID column and add if necessary (12.2.1)
  SELECT COUNT(*)
  INTO vCtr
  FROM user_tab_columns
  WHERE table_name = 'WLS_EVENTS_' AND column_name = 'PARTITION_ID';
  IF vCtr = 0 THEN
    dbms_output.put_line('Creating PARTITION_ID column in WLS_EVENTS_ table');
    vSQL := 'ALTER TABLE WLS_EVENTS_ ADD("PARTITION_ID" VARCHAR2(250 BYTE) DEFAULT NULL)';
    --dbms_output.put_line('vSQL:= ' || vSQL);
    EXECUTE IMMEDIATE vSQL;  
    changed := 1;
  END IF;

  -- Check for PARTITION_NAME column and add if necessary (12.2.1)
  SELECT COUNT(*)
  INTO vCtr
  FROM user_tab_columns
  WHERE table_name = 'WLS_EVENTS_' AND column_name = 'PARTITION_NAME';
  IF vCtr = 0 THEN
    dbms_output.put_line('Creating PARTITION_NAME column in WLS_EVENTS_ table');
    vSQL := 'ALTER TABLE WLS_EVENTS_ ADD("PARTITION_NAME" VARCHAR2(250 BYTE) DEFAULT NULL)';
    --dbms_output.put_line('vSQL:= ' || vSQL);
    EXECUTE IMMEDIATE vSQL;  
    changed := 1;
  END IF;

  -- create auto-index sequence if necessary
  SELECT COUNT(*) INTO vCtr FROM user_sequences WHERE sequence_name = 'SEQ_WLS_EVENTS_RECORDID';
  IF vCtr = 0 THEN
    vSQL := 'CREATE SEQUENCE SEQ_WLS_EVENTS_RECORDID MINVALUE 1 MAXVALUE 99999999999999999999 START WITH 1 INCREMENT BY 1 NOCACHE';
    --dbms_output.put_line('vSQL:= ' || vSQL);
    EXECUTE IMMEDIATE vSQL;
    changed := 1;
  END IF;

  -- create index trigger if necessary 
  SELECT COUNT(*) 
    INTO vCtr FROM user_triggers
    WHERE table_name = 'WLS_EVENTS_';
  IF vCtr = 0 THEN  
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

  -- check if we need to update the editioning view
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
      THREADNAME,
      PARTITION_ID,
      PARTITION_NAME
     from WLS_EVENTS_';
    EXECUTE IMMEDIATE vSQL;
  ELSE
    dbms_output.put_line('WLS_EVENTS view not modified, editioning view not updated ' || vEdition);
  END IF;  
  
END;
/

--SET ECHO 0FF;