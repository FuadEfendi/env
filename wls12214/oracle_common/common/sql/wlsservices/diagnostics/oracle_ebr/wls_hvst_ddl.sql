Rem Copyright (c) 2013,2014, Oracle and/or its affiliates. All rights reserved.
Rem All rights reserved. 
Rem
Rem    NAME
Rem      wls_hvst_ddl.sql - Create and/or upgrade an editioned WLS_HVST view
Rem
Rem    DESCRIPTION
Rem
Rem    NOTES
Rem      Creates an internal WLS_HVST_ table and supporting objects, then 
Rem      creates an editioning view for WLS_HVST.  
Rem
SET ECHO OFF;
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
    WHERE table_name = 'WLS_HVST_';
 
  IF vCtr = 0 THEN
    dbms_output.put_line('Creating WLS_HVST_ table');
    vSQL := 'CREATE TABLE "WLS_HVST_"
    ( 
      "RECORDID" NUMBER(20,0) NOT NULL, 
      "TIMESTAMP" NUMBER(20,0) DEFAULT NULL, 
      "DOMAIN" VARCHAR2(250 BYTE) DEFAULT NULL, 
      "SERVER" VARCHAR2(250 BYTE) DEFAULT NULL, 
      "TYPE" VARCHAR2(250 BYTE) DEFAULT NULL, 
      "NAME" VARCHAR2(500 BYTE) DEFAULT NULL, 
      "ATTRNAME" VARCHAR2(250 BYTE) DEFAULT NULL, 
      "ATTRTYPE" NUMBER(10,0) DEFAULT NULL, 
      "ATTRVALUE" VARCHAR2(4000 BYTE) DEFAULT NULL, 
      "WLDFMODULE" VARCHAR2(250 BYTE) DEFAULT NULL,
      "PARTITION_ID" VARCHAR2(250 BYTE) DEFAULT NULL,
      "PARTITION_NAME" VARCHAR2(250 BYTE) DEFAULT NULL
    )';  
    EXECUTE IMMEDIATE vSQL;   
    vSQL := 'CREATE UNIQUE INDEX WLS_HVST_RECORD_IDX ON WLS_HVST_(RECORDID)';
    EXECUTE IMMEDIATE vSQL;
    vSQL := 'CREATE INDEX WLS_HVST_TS_IDX ON WLS_HVST_(TIMESTAMP)';
    EXECUTE IMMEDIATE vSQL;
    changed := 1;
  END IF;

  -- Add WLDFMODULE column (12.1.2)
  SELECT COUNT(*)
    INTO vCtr FROM user_tab_columns
    WHERE table_name = 'WLS_HVST_' AND column_name = 'WLDFMODULE';
  IF vCtr = 0 THEN
    dbms_output.put_line('Creating WLDFMODULE column in WLS_HVST_ table');
    vSQL := 'ALTER TABLE WLS_HVST_ ADD("WLDFMODULE" VARCHAR2(250 BYTE) DEFAULT NULL)';
    EXECUTE IMMEDIATE vSQL;  
    changed := 1;
  END IF;
  
  -- Add PARTITION_ID column (12.2.1)
  SELECT COUNT(*)
    INTO vCtr FROM user_tab_columns
    WHERE table_name = 'WLS_HVST_' AND column_name = 'PARTITION_ID';
  IF vCtr = 0 THEN
    dbms_output.put_line('Creating PARTITION_ID column in WLS_HVST_ table');
    vSQL := 'ALTER TABLE WLS_HVST_ ADD("PARTITION_ID" VARCHAR2(250 BYTE) DEFAULT NULL)';
    EXECUTE IMMEDIATE vSQL;  
    changed := 1;
  END IF;
  
  -- Add PARTITION_NAME column (12.2.1)
  SELECT COUNT(*)
    INTO vCtr FROM user_tab_columns
    WHERE table_name = 'WLS_HVST_' AND column_name = 'PARTITION_NAME';
  IF vCtr = 0 THEN
    dbms_output.put_line('Creating PARTITION_NAME column in WLS_HVST_ table');
    vSQL := 'ALTER TABLE WLS_HVST_ ADD("PARTITION_NAME" VARCHAR2(250 BYTE) DEFAULT NULL)';
    EXECUTE IMMEDIATE vSQL;  
    changed := 1;
  END IF;
  
  vSQL := 'ALTER TABLE WLS_HVST_ MODIFY("NAME" VARCHAR2(500 BYTE) DEFAULT NULL)';
  EXECUTE IMMEDIATE vSQL;  

  -- create auto-index sequence if necessary
  SELECT COUNT(*) INTO vCtr FROM user_sequences
  WHERE sequence_name = 'SEQ_WLS_HVST_RECORDID';
  IF vCtr = 0 THEN
    vSQL := 'CREATE SEQUENCE SEQ_WLS_HVST_RECORDID MINVALUE 1 MAXVALUE 99999999999999999999 START WITH 1 INCREMENT BY 1 NOCACHE';
    EXECUTE IMMEDIATE vSQL;
    changed := 1;
  END IF;

  -- create index trigger if necessary 
  SELECT COUNT(*) 
    INTO vCtr FROM user_triggers
    WHERE table_name = 'WLS_HVST_';
  IF vCtr = 0 THEN  
    dbms_output.put_line('Creating or replacing TRG_WLS_HVST_INSERT trigger');
    vSQL := 'CREATE OR REPLACE TRIGGER TRG_WLS_HVST_INSERT 
    BEFORE INSERT ON WLS_HVST_ 
    REFERENCING NEW AS newRow 
    FOR EACH ROW 
    BEGIN 
      IF :newRow.RECORDID IS NULL THEN 
        SELECT SEQ_WLS_HVST_RECORDID.nextval INTO :newRow.RECORDID FROM DUAL; 
      END IF; 
    END;';
    EXECUTE IMMEDIATE vSQL;
  END IF;

  -- check if we need to update the editioning view
  SELECT COUNT(*)
    INTO vCtr FROM USER_EDITIONING_VIEWS_AE
    WHERE view_name = 'WLS_HVST' AND EDITION_NAME = vEdition;

  IF vCtr = 0  AND changed > 0 THEN  
    dbms_output.put_line('Creating/updating WLS_HVST editioning view');
    vSQL := 'CREATE OR REPLACE EDITIONING VIEW WLS_HVST AS SELECT
        RECORDID, 
        TIMESTAMP, 
        DOMAIN, 
        SERVER, 
        TYPE, 
        NAME, 
        ATTRNAME, 
        ATTRTYPE, 
        ATTRVALUE,
        WLDFMODULE,
        PARTITION_ID,
        PARTITION_NAME
        FROM WLS_HVST_';
    EXECUTE IMMEDIATE vSQL;
  ELSE
    dbms_output.put_line('WLS_HVST_ table not changed, editioning view not modified ' || vEdition);
  END IF;
  
END;
/

